import ../consts

# Need FreeRTOSConfig.h first so that number of cores is defined.
const hdr = """
#include <freertos/FreeRTOSConfig.h>
#include "esp_freertos_hooks.h"
"""

#
#  Definitions for the tickhook and idlehook callbacks
#
type
  esp_freertos_idle_cb_t* = proc (): bool {.cdecl.}
  esp_freertos_tick_cb_t* = proc (): void {.cdecl.}

#
#  @brief  Register a callback to be called from the specified core's idle hook.
#          The callback should return true if it should be called by the idle hook
#          once per interrupt (or FreeRTOS tick), and return false if it should
#          be called repeatedly as fast as possible by the idle hook.
#
#  @warning Idle callbacks MUST NOT, UNDER ANY CIRCUMSTANCES, CALL
#           A FUNCTION THAT MIGHT BLOCK.
#
#  @param[in]  new_idle_cb     Callback to be called
#  @param[in]  cpuid           id of the core
#
#  @return
#      - ESP_OK:              Callback registered to the specified core's idle hook
#      - ESP_ERR_NO_MEM:      No more space on the specified core's idle hook to register callback
#      - ESP_ERR_INVALID_ARG: cpuid is invalid
#
proc esp_register_freertos_idle_hook_for_cpu*(
          new_idle_cb: esp_freertos_idle_cb_t, cpuid: UBaseType_t): esp_err_t
          {.importc: "esp_register_freertos_idle_hook_for_cpu", header: hdr.}
