const hdr = "esp_cpu.h"

##
##  @brief Stall a CPU core
##
##  @param core_id  The core's ID
##
proc esp_cpu_stall*(core_id: int): void {.importc: "esp_cpu_stall", header: hdr.}

##
##  @brief Resume a previously stalled CPU core
##
##  @param core_id The core's ID
##
proc esp_cpu_unstall*(core_id: int): void {.importc: "esp_cpu_unstall", header: hdr.}

##
##  @brief Reset a CPU core
##
##  @param core_id The core's ID
##
proc esp_cpu_reset*(core_id: int): void {.importc: "esp_cpu_reset", header: hdr.}

##
##  @brief Get the current core's ID
##
##  This function will return the ID of the current CPU (i.e., the CPU that calls
##  this function).
##
##  @return The current core's ID [0..SOC_CPU_CORES_NUM - 1]
##
proc esp_cpu_get_core_id*(): int {.importc: "esp_cpu_get_core_id", header: hdr.}
