import
  ../consts

const hdr = "esp_task_wdt.h"

##
##  @brief Task Watchdog Timer (TWDT) configuration structure
##
type
  esp_task_wdt_config_t* {.importc: "esp_task_wdt_config_t", header: hdr, bycopy.} = object
    timeout_ms* {.importc: "timeout_ms"}: uint32         # TWDT timeout duration in milliseconds */
    idle_core_mask* {.importc: "idle_core_mask"}: uint32 # Bitmask of the core whose idle task should be subscribed on initialization where 1 << i means that core i's idle task will be monitored by the TWDT */
    trigger_panic* {.importc: "timeout_ms"}: bool        # Trigger panic when timeout occurs */


##
##  @brief  Initialize the Task Watchdog Timer (TWDT)
##
##  This function configures and initializes the TWDT. This function will subscribe the idle tasks if
##  configured to do so. For other tasks, users can subscribe them using esp_task_wdt_add() or esp_task_wdt_add_user().
##  This function won't start the timer if no task have been registered yet.
##
##  @note esp_task_wdt_init() must only be called after the scheduler is started. Moreover, it must not be called by
##        multiple tasks simultaneously.
##  @param[in] config Configuration structure
##  @return
##   - ESP_OK: Initialization was successful
##   - ESP_ERR_INVALID_STATE: Already initialized
##   - Other: Failed to initialize TWDT
##
proc esp_task_wdt_init*(config: ptr esp_task_wdt_config_t): esp_err_t {.importc: "esp_task_wdt_init", header: hdr.}


##
##  @brief Reconfigure the Task Watchdog Timer (TWDT)
##
##  The function reconfigures the running TWDT. It must already be initialized when this function is called.
##
##  @note esp_task_wdt_reconfigure() must not be called by multiple tasks simultaneously.
##
##  @param[in] config Configuration structure
##
##  @return
##   - ESP_OK: Reconfiguring was successful
##   - ESP_ERR_INVALID_STATE: TWDT not initialized yet
##   - Other: Failed to initialize TWDT
##
proc esp_task_wdt_reconfigure*(config: ptr esp_task_wdt_config_t): esp_err_t {.importc: "esp_task_wdt_reconfigure", header: hdr.}

##
##  @brief   Deinitialize the Task Watchdog Timer (TWDT)
##
##  This function will deinitialize the TWDT, and unsubscribe any idle tasks. Calling this function whilst other tasks
##  are still subscribed to the TWDT, or when the TWDT is already deinitialized, will result in an error code being
##  returned.
##
##  @note esp_task_wdt_deinit() must not be called by multiple tasks simultaneously.
##  @return
##   - ESP_OK: TWDT successfully deinitialized
##   - Other: Failed to deinitialize TWDT
##
proc esp_task_wdt_deinit*(): esp_err_t {.importc: "esp_task_wdt_deinit", header: hdr.}

##
##  @brief Reset the Task Watchdog Timer (TWDT) on behalf of the currently running task
##
##  This function will reset the TWDT on behalf of the currently running task. Each subscribed task must periodically
##  call this function to prevent the TWDT from timing out. If one or more subscribed tasks fail to reset the TWDT on
##  their own behalf, a TWDT timeout will occur.
##
##  @return
##   - ESP_OK: Successfully reset the TWDT on behalf of the currently running task
##   - Other: Failed to reset
##
proc esp_task_wdt_reset*(): esp_err_t {.importc: "esp_task_wdt_reset", header: hdr.}
