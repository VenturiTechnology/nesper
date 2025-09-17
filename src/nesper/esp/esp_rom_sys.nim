const hdr = "esp_rom_sys.h"

##
##  @brief Pauses execution for us microseconds
##
##  @param us Number of microseconds to pause
##
proc esp_rom_delay_us*(us: uint32): void {.importc: "esp_rom_delay_us", header: hdr.}
