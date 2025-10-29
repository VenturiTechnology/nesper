import
  ../tasks,
  ../consts

const hdr = "esp_task_wdt.h"

##
##  @brief Task Watchdog Timer (TWDT) configuration structure
##
type
  esp_task_wdt_config_t* {.importc: "esp_task_wdt_config_t", header: hdr, bycopy.} = object
    timeout_ms* {.importc: "timeout_ms"}: uint32         # TWDT timeout duration in milliseconds */
    idle_core_mask* {.importc: "idle_core_mask"}: uint32 # Bitmask of the core whose idle task should be subscribed on initialization where 1 << i means that core i's idle task will be monitored by the TWDT */
    trigger_panic* {.importc: "trigger_panic"}: bool     # Trigger panic when timeout occurs */
  esp_task_wdt_user_handle_t* {.importc: "esp_task_wdt_user_handle_t", header: hdr, bycopy.} = object

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
##  @brief Subscribe a task to the Task Watchdog Timer (TWDT)
##
##  This function subscribes a task to the TWDT. Each subscribed task must periodically call esp_task_wdt_reset() to
##  prevent the TWDT from elapsing its timeout period. Failure to do so will result in a TWDT timeout.
##
##  @param task_handle Handle of the task. Input NULL to subscribe the current running task to the TWDT
##  @return
##   - ESP_OK: Successfully subscribed the task to the TWDT
##   - Other: Failed to subscribe task
##
proc esp_task_wdt_add*(task_handle: TaskHandle_t): esp_err_t {.importc: "esp_task_wdt_add", header: hdr.}

##
##  @brief Subscribe a user to the Task Watchdog Timer (TWDT)
##
##  This function subscribes a user to the TWDT. A user of the TWDT is usually a function that needs to run
##  periodically. Each subscribed user must periodically call esp_task_wdt_reset_user() to prevent the TWDT from elapsing
##  its timeout period. Failure to do so will result in a TWDT timeout.
##
##  @param[in] user_name String to identify the user
##  @param[out] user_handle_ret Handle of the user
##  @return
##   - ESP_OK: Successfully subscribed the user to the TWDT
##   - Other: Failed to subscribe user
##
proc esp_task_wdt_add_user*(user_name: cstring, user_handle_ret: ptr esp_task_wdt_user_handle_t): esp_err_t {.importc: "esp_task_wdt_add_user", header: hdr.}

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

##
##  @brief Reset the Task Watchdog Timer (TWDT) on behalf of a user
##
##  This function will reset the TWDT on behalf of a user. Each subscribed user must periodically call this function to
##  prevent the TWDT from timing out. If one or more subscribed users fail to reset the TWDT on their own behalf, a TWDT
##  timeout will occur.
##
##  @param[in] user_handle User handle
##   - ESP_OK: Successfully reset the TWDT on behalf of the user
##   - Other: Failed to reset
##
proc esp_task_wdt_reset_user*(user_handle: esp_task_wdt_user_handle_t): esp_err_t {.importc: "esp_task_wdt_reset_user", header: hdr.}

## *
##  @brief Unsubscribes a task from the Task Watchdog Timer (TWDT)
##
##  This function will unsubscribe a task from the TWDT. After being unsubscribed, the task should no longer call
##  esp_task_wdt_reset().
##
##  @param[in] task_handle Handle of the task. Input NULL to unsubscribe the current running task.
##  @return
##   - ESP_OK: Successfully unsubscribed the task from the TWDT
##   - Other: Failed to unsubscribe task
## /
proc esp_task_wdt_delete*(task_handle: TaskHandle_t): esp_err_t {.importc: "esp_task_wdt_delete", header: hdr.}

##
##  @brief Unsubscribes a user from the Task Watchdog Timer (TWDT)
##
##  This function will unsubscribe a user from the TWDT. After being unsubscribed, the user should no longer call
##  esp_task_wdt_reset_user().
##
##  @param[in] user_handle User handle
##  @return
##   - ESP_OK: Successfully unsubscribed the user from the TWDT
##   - Other: Failed to unsubscribe user
##
proc esp_task_wdt_delete_user*(user_handle: esp_task_wdt_user_handle_t): esp_err_t {.importc: "esp_task_wdt_delete_user", header: hdr.}

##
##  @brief Query whether a task is subscribed to the Task Watchdog Timer (TWDT)
##
##  This function will query whether a task is currently subscribed to the TWDT, or whether the TWDT is initialized.
##
##  @param[in] task_handle Handle of the task. Input NULL to query the current running task.
##  @return:
##   - ESP_OK: The task is currently subscribed to the TWDT
##   - ESP_ERR_NOT_FOUND: The task is not subscribed
##   - ESP_ERR_INVALID_STATE: TWDT was never initialized
##
proc esp_task_wdt_status*(task_handle: TaskHandle_t): esp_err_t {.importc: "esp_task_wdt_status", header: hdr.}

##
##  @brief User ISR callback placeholder
##
##  This function is called by task_wdt_isr function (ISR for when TWDT times out). It can be defined in user code to
##  handle TWDT events.
##
##  @note It has the same limitations as the interrupt function. Do not use ESP_LOGx functions inside.
##
## !!!Ignored construct:  void __attribute__ ( ( weak ) ) esp_task_wdt_isr_user_handler ( void ) ;

type
  task_wdt_msg_handler* = proc (opaque: pointer; msg: cstring)

##
##  @brief Prints or retrieves information about tasks/users that triggered the Task Watchdog Timeout.
##
##  This function provides various operations to handle tasks/users that did not reset the Task Watchdog in time.
##  It can print detailed information about these tasks/users, such as their names, associated CPUs, and whether they have been reset.
##  Additionally, it can retrieve the total length of the printed information or the CPU affinity of the failing tasks.
##
##  @param[in]  msg_handler Optional message handler function that will be called for each printed line.
##  @param[in]  opaque      Optional pointer to opaque data that will be passed to the message handler function.
##  @param[out] cpus_fail   Optional pointer to an integer where the CPU affinity of the failing tasks will be stored.
##
##  @return
##      - ESP_OK: The function executed successfully.
##      - ESP_FAIL: No triggered tasks were found, and thus no information was printed or retrieved.
##
##  @note
##      - If `msg_handler` is not provided, the information will be printed to console using ESP_EARLY_LOGE.
##      - If `msg_handler` is provided, the function will send the printed information to the provided message handler function.
##      - If `cpus_fail` is provided, the function will store the CPU affinity of the failing tasks in the provided integer.
##      - During the execution of this function, logging is allowed in critical sections, as TWDT timeouts are considered fatal errors.
##
proc esp_task_wdt_print_triggered_tasks*(msg_handler: task_wdt_msg_handler;
                                        opaque: pointer; cpus_fail: ptr cint): esp_err_t {.
    importc: "esp_task_wdt_print_triggered_tasks", header: hdr.}