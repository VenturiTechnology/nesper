import endians
import sequtils

import consts
import general
import gpios
import esp/driver/spi

# export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t, spi_device_handle_t
export spi
export consts.bits, consts.bytes, consts.TickType_t
export general.toBits
export gpios.gpio_num_t

const TAG = "spis"

{.experimental: "notnil".}

type

  SpiError* = object of OSError
    code*: esp_err_t

  SpiBus* = ref object
    host*: spi_host_device_t
    buscfg*: spi_bus_config_t

  SpiDev* = ref object
    devcfg*: spi_device_interface_config_t 
    handle*: spi_device_handle_t

  SpiTrans* = ref object
    dev*: SpiDev
    trn*: spi_transaction_t
    tx_data*: seq[uint8]
    rx_data*: seq[uint8]

  SpiHostDevice* = enum
    HSPI = SPI2_HOST.int(),              ## /< SPI2
    VSPI = SPI3_HOST.int()               ## /< SPI3


proc swapDataTx*(data: uint32, len: uint32): uint32 =
  # bigEndian( data shl (32-len) )
  var inp: uint32 = data shl (32-len)
  var outp: uint32 = 0
  addr(outp).bigEndian32(inp.addr())

proc swapDataRx*(data: uint32, len: uint32): uint32 =
  # bigEndian(data) shr (32-len)
  var inp: uint32 = data
  var outp: uint32 = 0
  addr(outp).bigEndian32(inp.addr())

  return outp shr (32-len)

proc newSpiBus*(
        host: SpiHostDevice;
        miso, mosi, sclk: gpio_num_t;
        quadwp = gpio_num_t(-1), quadhd = gpio_num_t(-1);
        dma_channel: range[0..2],
        flags: set[SpiBusFlag] = {},
        intr_flags: int = 0,
        max_transfer_sz = 4094
      ): SpiBus not nil = 

  result = SpiBus()
  result.host = spi_host_device_t(host.int())

  result.buscfg.miso_io_num = miso.cint
  result.buscfg.mosi_io_num = mosi.cint
  result.buscfg.sclk_io_num = sclk.cint
  result.buscfg.quadwp_io_num = quadwp.cint
  result.buscfg.quadhd_io_num = quadhd.cint
  result.buscfg.max_transfer_sz = max_transfer_sz.cint
  result.buscfg.intr_flags = intr_flags.cint

  result.buscfg.flags = 0
  for flg in flags:
    result.buscfg.flags = flg.uint32 or result.buscfg.flags 

    #//Initialize the SPI bus
  let ret = spi_bus_initialize(result.host, addr(result.buscfg), dma_channel)
  if (ret != ESP_OK):
    raise newEspError[SpiError]("Error initializing spi (" & $esp_err_to_name(ret) & ")", ret)


# TODO: setup spi device (create spi_device_interface_config_t )
#   - Note: SPI_DEVICE_* is bitwise flags in  spi_device_interface_config_t
# The attributes of a transaction are determined by the bus configuration structure spi_bus_config_t, device configuration structure spi_device_interface_config_t, and transaction configuration structure spi_transaction_t.
# 
# An SPI Host can send full-duplex transactions, during which the read and write phases occur simultaneously. The total transaction length is determined by the sum of the following members:
#     spi_device_interface_config_t::command_bits
#     spi_device_interface_config_t::address_bits
#     spi_transaction_t::length
# While the member spi_transaction_t::rxlength only determines the length of data received into the buffer.
# 
# In half-duplex transactions, the read and write phases are not simultaneous (one direction at a time). The lengths of the write and read phases are determined by length and rxlength members of the struct spi_transaction_t respectively.
# 
# The command and address phases are optional, as not every SPI device requires a command and/or address. This is reflected in the Device’s configuration: if command_bits and/or address_bits are set to zero, no command or address phase will occur.
# 
# The read and write phases can also be optional, as not every transaction requires both writing and reading data. If rx_buffer is NULL and SPI_TRANS_USE_RXDATA is not set, the read phase is skipped. If tx_buffer is NULL and SPI_TRANS_USE_TXDATA is not set, the write phase is skipped.
# 
# The driver supports two types of transactions: the interrupt transactions and polling transactions. The programmer can choose to use a different transaction type per Device. If your Device requires both transaction types, see Notes on Sending Mixed Transactions to the Same Device.


proc addDevice*(
      bus: SpiBus,
      commandlen: bits, ## \
        ## Default amount of bits in command phase (0-16), used when ``SPI_TRANS_VARIABLE_CMD`` is not used, otherwise ignored.
      addresslen: bits, ## \
        ## Default amount of bits in address phase (0-64), used when ``SPI_TRANS_VARIABLE_ADDR`` is not used, otherwise ignored.
      mode: range[0..3], ## \
        ## SPI mode (0-3)
      cs_io: gpio_num_t, ## \
        ## CS GPIO pin for this device, or -1 if not used
      clock_speed_hz: cint, ## \
        ## Clock speed, divisors of 80MHz, in Hz. See ``SPI_MASTER_FREQ_*``.
      queue_size: int, ## \
        ## Transaction queue size. This sets how many transactions can be 'in the air' \
        ## (queued using spi_device_queue_trans but not yet finished using \
        ## spi_device_get_trans_result) at the same time
      dummy_bits: uint8 = 0, ## \
        ## Amount of dummy bits to insert between address and data phase
      duty_cycle_pos: uint16 = 0, ## \
        ## Duty cycle of positive clock, in 1/256th increments (128 = 50%/50% duty). Setting this to 0 (=not setting it) is equivalent to setting this to 128.
      cs_cycles_pretrans: uint16 = 0, ## \
        ## Amount of SPI bit-cycles the cs should be activated before the transmission (0-16). This only works on half-duplex transactions.
      cs_cycles_posttrans: uint8 = 0, ## \
        ## Amount of SPI bit-cycles the cs should stay active after the transmission (0-16)
      input_delay_ns: cint = 0, ## \
      ## Maximum data valid time of slave. The time required between SCLK and MISO \
      ## valid, including the possible clock delay from slave to master. The driver uses this value to give an extra \
      ## delay before the MISO is ready on the line. Leave at 0 unless you know you need a delay. For better timing \
      ## performance at high frequency (over 8MHz), it's suggest to have the right value.
      flags: set[SpiDeviceFlag], ## \
        ## Flags from SpiDevices. Produces bitwise OR of SPI_DEVICE_* flags
      pre_cb: transaction_cb_t = nil, ## \
      ## Callback to be called before a transmission is started. \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
      post_cb: transaction_cb_t = nil, ## \
      ## Callback to be called after a transmission has completed \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
    ): SpiDev =

  # var devcfg: spi_device_interface_config_t 
  result = new(SpiDev)

  result.devcfg.command_bits = commandlen.uint8 
  result.devcfg.address_bits = addresslen.uint8
  result.devcfg.dummy_bits = dummy_bits 
  result.devcfg.mode = mode.uint8
  result.devcfg.duty_cycle_pos = duty_cycle_pos
  result.devcfg.cs_ena_pretrans = cs_cycles_pretrans
  result.devcfg.cs_ena_posttrans = cs_cycles_posttrans
  result.devcfg.clock_speed_hz = clock_speed_hz
  result.devcfg.input_delay_ns = input_delay_ns
  result.devcfg.spics_io_num = cs_io.cint
  result.devcfg.queue_size = queue_size.cint
  result.devcfg.pre_cb = pre_cb
  result.devcfg.post_cb = post_cb

  result.devcfg.flags = 0
  for flg in flags:
    result.devcfg.flags = flg.uint32 or result.devcfg.flags 

  let ret = spi_bus_add_device(bus.host, unsafeAddr(result.devcfg), addr(result.handle))

  if (ret != ESP_OK):
    raise newEspError[SpiError]("Error adding spi device (" & $esp_err_to_name(ret) & ")", ret)

# TODO: setup cmd/addr custom sizes
var spi_id: uint32 = 0'u32

proc fullTrans*(dev: SpiDev;
                     txdata: openArray[uint8],
                     txlength: bits = bits(-1),
                     rxlength: bits = bits(-1),
                     cmd: uint16 = 0,
                     cmdaddr: uint64 = 0,
                     flags: set[SpiTransFlag] = {},
                  ): SpiTrans =
  spi_id.inc()
  var tflags = flags
  assert txlength.int() <= 8*len(txdata)
  # assert rxlength.int() >= 0

  result = new(SpiTrans)
  result.dev = dev
  result.trn.user = cast[pointer]( addr(result) ) # use to keep track of spi trans id's
  result.trn.cmd = cmd
  result.trn.`addr` = cmdaddr

  # Set TX Details
  result.trn.length =
    if txlength.int < 0:
      8*txdata.len().csize_t()
    else:
      txlength.uint32()

  if result.trn.length <= 32:
    result.trn.rx_buffer = nil
    for i in 0..high(txdata):
      result.trn.txdata[i] = txdata[i]
  else:
    # This order is important, copy the seq then take the unsafe addr
    result.tx_data = txdata.toSeq()
    result.trn.tx_buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself

  if result.trn.length. in 1U..32U:
    tflags.incl({USE_TXDATA})

  # Set RX Details
  result.trn.rxlength =
    if rxlength.int() < 0:
      result.trn.length
    else:
      rxlength.uint()
      
  if result.trn.rxlength <= 32:
    result.trn.rx_buffer = nil
  else:
    # This order is important, copy the seq then take the unsafe addr
    let rm = if (result.trn.rxlength mod 8) > 0: 1 else: 0
    result.rx_data = newSeq[byte](int(result.trn.rxlength div 8) + rm)
    result.trn.rx_buffer = unsafeAddr(result.rx_data[0]) ## The data is the cmd itself

  if result.trn.rxlength in 1U..32U:
    tflags.incl({USE_RXDATA})

  ## Flags
  result.trn.flags = 0
  for flg in tflags:
    result.trn.flags = flg.uint32 or result.trn.flags 

  return result

proc writeTrans*(dev: SpiDev;
                  data: openArray[uint8],
                  txlength: bits = bits(-1),
                  cmd: uint16 = 0,
                  cmdaddr: uint64 = 0,
                  flags: set[SpiTransFlag] = {},
                ): SpiTrans =
  assert not (USE_RXDATA in flags)
  fullTrans(dev, cmd = cmd, cmdaddr = cmdaddr, txdata = data, txlength = txlength, rxlength = bits(0), flags = flags)

proc readTrans*(dev: SpiDev;
                  rxlength: bits = bits(-1),
                  cmd: uint16 = 0,
                  cmdaddr: uint64 = 0,
                  flags: set[SpiTransFlag] = {},
                ): SpiTrans =
  assert not (USE_TXDATA in flags)
  if (dev.devcfg.flags.uint32 and HALFDUPLEX.uint32) > 0:
    fullTrans(dev, cmd=cmd, cmdaddr=cmdaddr, rxlength=rxlength, txlength=bits(0), txdata=[], flags=flags)
  else:
    var n = rxlength.int div 8
    if rxlength.int > n*8 : n += 1
    var data = newSeq[byte](n)
    fullTrans(dev, cmd=cmd, cmdaddr=cmdaddr, rxlength=rxlength, txlength=rxlength, txdata=data, flags=flags)

proc getData*(trn: SpiTrans): seq[byte] = 
  if trn.trn.rxlength < 32:
    return trn.trn.rx_data.toSeq()
  else:
    return trn.rx_data.toSeq()

{.push stacktrace: off.}
proc getSmallData*(trn: SpiTrans): array[4, uint8] =
  if trn.trn.rxlength > 32:
    raise newException(SpiError, "transaction data too large")

  return trn.trn.rx_data

proc pollingStart*(trn: SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret = spi_device_polling_start(trn.dev.handle, addr(trn.trn), ticks_to_wait)
  if (ret != ESP_OK):
    raise newEspError[SpiError]("start polling (" & $esp_err_to_name(ret) & ")", ret)

proc pollingEnd*(dev: SpiDev, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret = spi_device_polling_end(dev.handle, ticks_to_wait)
  if (ret != ESP_OK):
    raise newEspError[SpiError]("end polling (" & $esp_err_to_name(ret) & ")", ret)

proc poll*(trn: SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret: esp_err_t = spi_device_polling_transmit(trn.dev.handle, addr(trn.trn))
  if (ret != ESP_OK):
    raise newEspError[SpiError]("spi polling (" & $esp_err_to_name(ret) & ")", ret)
{.pop.}

proc acquireBus*(trn: SpiDev, wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret: esp_err_t = spi_device_acquire_bus(trn.handle, wait)
  if (ret != ESP_OK):
    raise newEspError[SpiError]("spi aquire bus (" & $esp_err_to_name(ret) & ")", ret)

proc releaseBus*(dev: SpiDev) {.inline.} = 
  spi_device_release_bus(dev.handle)

template withSpiBus*(dev: SpiDev, blk: untyped): untyped =
  dev.acquireBus()
  try:
    blk
  finally:
    dev.releaseBus()

template withSpiBus*(dev: SpiDev, wait: TickType_t, blk: untyped): untyped =
  dev.acquireBus(wait)
  try:
    blk
  finally:
    dev.releaseBus()

proc queue*(trn: var SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) = 
  let ret: esp_err_t =
    spi_device_queue_trans(trn.dev.handle, addr(trn.trn), ticks_to_wait)

  if (ret != ESP_OK):
    raise newEspError[SpiError]("start polling (" & $esp_err_to_name(ret) & ")", ret)

  ## TODO: IMPORTANT test this...
  logi(TAG, "queue: %s", repr(trn.addr()))
  GC_ref(trn)

proc retrieve*(dev: SpiDev, ticks_to_wait: TickType_t = portMAX_DELAY): SpiTrans = 
  var trn: ptr spi_transaction_t

  let ret: esp_err_t =
    spi_device_get_trans_result(dev.handle, addr(trn), ticks_to_wait)

  let tptr = cast[ptr SpiTrans](trn.user)
  logi(TAG, "retrieve: %s", repr(tptr))
  result = tptr[]
  ## TODO: IMPORTANT test this...
  GC_unref( result )

  if (ret != ESP_OK):
    raise newEspError[SpiError]("start polling (" & $esp_err_to_name(ret) & ")", ret)

proc transmit*(trn: SpiTrans) {.inline.} = 
  # result = new(SpiTrans)
  let ret: esp_err_t =
    spi_device_transmit(trn.dev.handle, addr(trn.trn))

  if (ret != ESP_OK):
    raise newEspError[SpiError]("start polling (" & $esp_err_to_name(ret) & ")", ret)


