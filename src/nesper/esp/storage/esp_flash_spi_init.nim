##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

import
  ../../consts,
  ../../esp/storage/esp_flash,
  ../../spis

const hdr = "esp_flash_spi_init.h"

## Ported missing types
##
const
  SPI_FLASH_OPI_FLAG* = 16

type
  spi_common_dma_t* = enum
    SPI_DMA_DISABLED = 0, ## < Do not enable DMA for SPI
    SPI_DMA_CH1 = 1,      ## < Enable DMA, select DMA Channel 1
    SPI_DMA_CH2 = 2,      ## < Enable DMA, select DMA Channel 2
    SPI_DMA_CH_AUTO = 3,  ## < Enable DMA, channel is automatically selected by driver

type
  esp_flash_io_mode_t* = enum
    SPI_FLASH_SLOWRD = 0,       ## < Data read using single I/O, some limits on speed
    SPI_FLASH_FASTRD,         ## < Data read using single I/O, no limit on speed
    SPI_FLASH_DOUT,           ## < Data read using dual I/O
    SPI_FLASH_DIO,            ## < Both address & data transferred using dual I/O
    SPI_FLASH_QOUT,           ## < Data read using quad I/O
    SPI_FLASH_QIO,            ## < Both address & data transferred using quad I/O
    SPI_FLASH_OPI_STR = SPI_FLASH_OPI_FLAG, ## < Only support on OPI flash, flash read and write under STR mode
    SPI_FLASH_OPI_DTR,        ## < Only support on OPI flash, flash read and write under DTR mode
    SPI_FLASH_READ_MODE_MAX   ## < The fastest io mode supported by the host is ``ESP_FLASH_READ_MODE_MAX-1``.

type
  esp_flash_speed_t* = enum
    ESP_FLASH_5MHZ = 0,         ## < The flash runs under 5MHz
    ESP_FLASH_10MHZ,          ## < The flash runs under 10MHz
    ESP_FLASH_20MHZ,          ## < The flash runs under 20MHz
    ESP_FLASH_26MHZ,          ## < The flash runs under 26MHz
    ESP_FLASH_40MHZ,          ## < The flash runs under 40MHz
    ESP_FLASH_80MHZ,          ## < The flash runs under 80MHz
    ESP_FLASH_120MHZ,         ## < The flash runs under 120MHz, 120MHZ can only be used by main flash after timing tuning in system. Do not use this directely in any API.
    ESP_FLASH_SPEED_MAX       ## < The maximum frequency supported by the host is ``ESP_FLASH_SPEED_MAX-1``.

##  Configurations for the SPI Flash to init

type
  esp_flash_spi_device_config_t* {.importc: "esp_flash_spi_device_config_t",
                                  header: hdr, bycopy.} = object
    host_id* {.importc: "host_id".}: spi_host_device_t
    ## < Bus to use
    cs_io_num* {.importc: "cs_io_num".}: cint
    ## < GPIO pin to output the CS signal
    io_mode* {.importc: "io_mode".}: esp_flash_io_mode_t
    ## < IO mode to read from the Flash
    speed* {.importc: "speed".}: esp_flash_speed_t
    ## < Speed of the Flash clock
    input_delay_ns* {.importc: "input_delay_ns".}: cint
    ## < Input delay of the data pins, in ns. Set to 0 if unknown.
    ##
    ##  CS line ID, ignored when not `host_id` is not SPI1_HOST, or
    ##  `CONFIG_SPI_FLASH_SHARE_SPI1_BUS` is enabled. In this case, the CS line used is
    ##  automatically assigned by the SPI bus lock.
    ##
    cs_id* {.importc: "cs_id".}: cint
    ## < IO mode to read from the Flash
    freq_mhz* {.importc: "freq_mhz".}: cint

##
##   Add a SPI Flash device onto the SPI bus.
##
##  The bus should be already initialized by ``spi_bus_initialization``.
##
##  @param out_chip Pointer to hold the initialized chip.
##  @param config Configuration of the chips to initialize.
##
##  @return
##       - ESP_ERR_INVALID_ARG: out_chip is NULL, or some field in the config is invalid.
##       - ESP_ERR_NO_MEM: failed to allocate memory for the chip structures.
##       - ESP_OK: success.
##

proc spi_bus_add_flash_device*(out_chip: ptr ptr esp_flash_t;
                              config: ptr esp_flash_spi_device_config_t): esp_err_t {.
    importc: "spi_bus_add_flash_device", header: hdr.}
##
##   Remove a SPI Flash device from the SPI bus.
##
##  @param chip The flash device to remove.
##
##  @return
##       - ESP_ERR_INVALID_ARG: The chip is invalid.
##       - ESP_OK: success.
##

proc spi_bus_remove_flash_device*(chip: ptr esp_flash_t): esp_err_t {.
    importc: "spi_bus_remove_flash_device", header: hdr.}
