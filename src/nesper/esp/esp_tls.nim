import
  ../consts,
  esp_tls_errors

proc esp_tls_get_and_clear_last_error*(h: esp_tls_error_handle_t;
  esp_tls_code: ptr cint;
  esp_tls_flags: ptr cint): esp_err_t {.cdecl,
  importc: "esp_tls_get_and_clear_last_error", header: "esp_tls.h".}