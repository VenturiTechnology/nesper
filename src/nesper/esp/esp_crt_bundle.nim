import
  ../consts

const hdr = "esp_crt_bundle.h"

proc esp_crt_bundle_attach*(conf: pointer): esp_err_t {.
  cdecl, importc: "esp_crt_bundle_attach", header: hdr.}

proc esp_crt_bundle_detach*(conf: pointer) {.
  cdecl, importc: "esp_crt_bundle_detach", header: hdr.}

proc esp_crt_bundle_set*(x509_bundle: ptr uint8; bundle_size: csize_t): esp_err_t {.
  cdecl, importc: "esp_crt_bundle_set", header: hdr.}