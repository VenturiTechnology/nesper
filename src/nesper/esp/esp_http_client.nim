import
  ../consts

const hdr = "esp_http_client.h"

const
  DEFAULT_HTTP_BUF_SIZE* = (512)

type
  esp_http_client_handle_t* {.importc: "esp_http_client_handle_t",
                            header: hdr, bycopy.} = object
  esp_http_client_event_handle_t* {.importc: "esp_http_client_event_handle_t",
                            header: hdr, bycopy.} = object


type
  esp_http_client_event_id_t* {.size: sizeof(cint).} = enum
    HTTP_EVENT_ERROR = 0, HTTP_EVENT_ON_CONNECTED, HTTP_EVENT_HEADERS_SENT,
    HTTP_EVENT_ON_HEADER, HTTP_EVENT_ON_DATA, HTTP_EVENT_ON_FINISH,
    HTTP_EVENT_DISCONNECTED

const
  HTTP_EVENT_HEADER_SENT* = HTTP_EVENT_HEADERS_SENT


type
  esp_http_client_event_t* {.importc: "esp_http_client_event_t",
                            header: hdr, bycopy.} = object
    event_id* {.importc: "event_id".}: esp_http_client_event_id_t
    client* {.importc: "client".}: esp_http_client_handle_t
    data* {.importc: "data".}: pointer
    data_len* {.importc: "data_len".}: cint
    user_data* {.importc: "user_data".}: pointer
    header_key* {.importc: "header_key".}: cstring
    header_value* {.importc: "header_value".}: cstring



type
  esp_http_client_transport_t* {.size: sizeof(cint).} = enum
    HTTP_TRANSPORT_UNKNOWN = 0x0, HTTP_TRANSPORT_OVER_TCP, HTTP_TRANSPORT_OVER_SSL
  http_event_handle_cb* = proc (evt: ptr esp_http_client_event_t): esp_err_t {.cdecl.}



type
  esp_http_client_method_t* {.size: sizeof(cint).} = enum
    HTTP_METHOD_GET = 0, HTTP_METHOD_POST, HTTP_METHOD_PUT, HTTP_METHOD_PATCH,
    HTTP_METHOD_DELETE, HTTP_METHOD_HEAD, HTTP_METHOD_NOTIFY,
    HTTP_METHOD_SUBSCRIBE, HTTP_METHOD_UNSUBSCRIBE, HTTP_METHOD_OPTIONS,
    HTTP_METHOD_COPY, HTTP_METHOD_MOVE, HTTP_METHOD_LOCK, HTTP_METHOD_UNLOCK,
    HTTP_METHOD_PROPFIND, HTTP_METHOD_PROPPATCH, HTTP_METHOD_MKCOL, HTTP_METHOD_MAX



type
  esp_http_client_auth_type_t* {.size: sizeof(cint).} = enum
    HTTP_AUTH_TYPE_NONE = 0, HTTP_AUTH_TYPE_BASIC, HTTP_AUTH_TYPE_DIGEST



type
  esp_http_client_config_t* {.importc: "esp_http_client_config_t",
                             header: hdr, bycopy.} = object
    url* {.importc: "url".}: cstring
    host* {.importc: "host".}: cstring
    port* {.importc: "port".}: cint
    username* {.importc: "username".}: cstring
    password* {.importc: "password".}: cstring
    auth_type* {.importc: "auth_type".}: esp_http_client_auth_type_t
    path* {.importc: "path".}: cstring
    query* {.importc: "query".}: cstring
    cert_pem* {.importc: "cert_pem".}: cstring
    cert_len* {.importc: "cert_len".}: csize_t
    client_cert_pem* {.importc: "client_cert_pem".}: cstring
    client_cert_len* {.importc: "client_cert_len".}: csize_t
    client_key_pem* {.importc: "client_key_pem".}: cstring
    client_key_len* {.importc: "client_key_len".}: csize_t
    client_key_password* {.importc: "client_key_password".}: cstring
    client_key_password_len* {.importc: "client_key_password_len".}: csize_t
    user_agent* {.importc: "user_agent".}: cstring
    `method`* {.importc: "method".}: esp_http_client_method_t
    timeout_ms* {.importc: "timeout_ms".}: cint
    disable_auto_redirect* {.importc: "disable_auto_redirect".}: bool
    max_redirection_count* {.importc: "max_redirection_count".}: cint
    max_authorization_retries* {.importc: "max_authorization_retries".}: cint
    event_handler* {.importc: "event_handler".}: http_event_handle_cb
    transport_type* {.importc: "transport_type".}: esp_http_client_transport_t
    buffer_size* {.importc: "buffer_size".}: cint
    buffer_size_tx* {.importc: "buffer_size_tx".}: cint
    user_data* {.importc: "user_data".}: pointer
    is_async* {.importc: "is_async".}: bool
    use_global_ca_store* {.importc: "use_global_ca_store".}: bool
    skip_cert_common_name_check* {.importc: "skip_cert_common_name_check".}: bool
    crt_bundle_attach* {.importc: "crt_bundle_attach".}: proc (conf: pointer): esp_err_t {.
        cdecl.}
    keep_alive_enable* {.importc: "keep_alive_enable".}: bool
    keep_alive_idle* {.importc: "keep_alive_idle".}: cint
    keep_alive_interval* {.importc: "keep_alive_interval".}: cint
    keep_alive_count* {.importc: "keep_alive_count".}: cint
    # if_name* {.importc: "if_name".}: ptr ifreq
    if_name* {.importc: "if_name".}: pointer # will be unused, so just point to *something*
    # TODO: fix if_name, ifreq seems to come from sockets lib so need to provide that somehow



type
  HttpStatus_Code* {.size: sizeof(cint).} = enum
    HttpStatus_Ok = 200, HttpStatus_NoContent = 204, HttpStatus_MultipleChoices = 300,
    HttpStatus_MovedPermanently = 301, HttpStatus_Found = 302,
    HttpStatus_SeeOther = 303, HttpStatus_TemporaryRedirect = 307,
    HttpStatus_PermanentRedirect = 308, HttpStatus_BadRequest = 400,
    HttpStatus_Unauthorized = 401, HttpStatus_Forbidden = 403,
    HttpStatus_NotFound = 404, HttpStatus_InternalError = 500


const
  ESP_ERR_HTTP_BASE* = (0x7000)
  ESP_ERR_HTTP_MAX_REDIRECT* = (ESP_ERR_HTTP_BASE + 1)
  ESP_ERR_HTTP_CONNECT* = (ESP_ERR_HTTP_BASE + 2)
  ESP_ERR_HTTP_WRITE_DATA* = (ESP_ERR_HTTP_BASE + 3)
  ESP_ERR_HTTP_FETCH_HEADER* = (ESP_ERR_HTTP_BASE + 4)
  ESP_ERR_HTTP_INVALID_TRANSPORT* = (ESP_ERR_HTTP_BASE + 5)
  ESP_ERR_HTTP_CONNECTING* = (ESP_ERR_HTTP_BASE + 6)
  ESP_ERR_HTTP_EAGAIN* = (ESP_ERR_HTTP_BASE + 7)
  ESP_ERR_HTTP_CONNECTION_CLOSED* = (ESP_ERR_HTTP_BASE + 8)


proc esp_http_client_init*(config: ptr esp_http_client_config_t): esp_http_client_handle_t {.
    cdecl, importc: "esp_http_client_init", header: hdr.}

proc esp_http_client_perform*(client: esp_http_client_handle_t): esp_err_t {.cdecl,
    importc: "esp_http_client_perform", header: hdr.}

proc esp_http_client_set_url*(client: esp_http_client_handle_t; url: cstring): esp_err_t {.
    cdecl, importc: "esp_http_client_set_url", header: hdr.}

proc esp_http_client_set_post_field*(client: esp_http_client_handle_t;
                                    data: cstring; len: cint): esp_err_t {.cdecl,
    importc: "esp_http_client_set_post_field", header: hdr.}

proc esp_http_client_get_post_field*(client: esp_http_client_handle_t;
                                    data: cstringArray): cint {.cdecl,
    importc: "esp_http_client_get_post_field", header: hdr.}

proc esp_http_client_set_header*(client: esp_http_client_handle_t; key: cstring;
                                value: cstring): esp_err_t {.cdecl,
    importc: "esp_http_client_set_header", header: hdr.}

proc esp_http_client_get_header*(client: esp_http_client_handle_t; key: cstring;
                                value: cstringArray): esp_err_t {.cdecl,
    importc: "esp_http_client_get_header", header: hdr.}

proc esp_http_client_get_username*(client: esp_http_client_handle_t;
                                  value: cstringArray): esp_err_t {.cdecl,
    importc: "esp_http_client_get_username", header: hdr.}

proc esp_http_client_set_username*(client: esp_http_client_handle_t;
                                  username: cstring): esp_err_t {.cdecl,
    importc: "esp_http_client_set_username", header: hdr.}

proc esp_http_client_get_password*(client: esp_http_client_handle_t;
                                  value: cstringArray): esp_err_t {.cdecl,
    importc: "esp_http_client_get_password", header: hdr.}

proc esp_http_client_set_password*(client: esp_http_client_handle_t;
                                  password: cstring): esp_err_t {.cdecl,
    importc: "esp_http_client_set_password", header: hdr.}

proc esp_http_client_set_authtype*(client: esp_http_client_handle_t;
                                  auth_type: esp_http_client_auth_type_t): esp_err_t {.
    cdecl, importc: "esp_http_client_set_authtype", header: hdr.}

proc esp_http_client_get_errno*(client: esp_http_client_handle_t): cint {.cdecl,
    importc: "esp_http_client_get_errno", header: hdr.}

proc esp_http_client_set_method*(client: esp_http_client_handle_t;
                                `method`: esp_http_client_method_t): esp_err_t {.
    cdecl, importc: "esp_http_client_set_method", header: hdr.}

proc esp_http_client_set_timeout_ms*(client: esp_http_client_handle_t;
                                    timeout_ms: cint): esp_err_t {.cdecl,
    importc: "esp_http_client_set_timeout_ms", header: hdr.}

proc esp_http_client_delete_header*(client: esp_http_client_handle_t; key: cstring): esp_err_t {.
    cdecl, importc: "esp_http_client_delete_header", header: hdr.}

proc esp_http_client_open*(client: esp_http_client_handle_t; write_len: cint): esp_err_t {.
    cdecl, importc: "esp_http_client_open", header: hdr.}

proc esp_http_client_write*(client: esp_http_client_handle_t; buffer: cstring;
                           len: cint): cint {.cdecl,
    importc: "esp_http_client_write", header: hdr.}

proc esp_http_client_fetch_headers*(client: esp_http_client_handle_t): cint {.cdecl,
    importc: "esp_http_client_fetch_headers", header: hdr.}

proc esp_http_client_is_chunked_response*(client: esp_http_client_handle_t): bool {.
    cdecl, importc: "esp_http_client_is_chunked_response",
    header: hdr.}

proc esp_http_client_read*(client: esp_http_client_handle_t; buffer: cstring;
                          len: cint): cint {.cdecl, importc: "esp_http_client_read",
    header: hdr.}

proc esp_http_client_get_status_code*(client: esp_http_client_handle_t): cint {.
    cdecl, importc: "esp_http_client_get_status_code", header: hdr.}

proc esp_http_client_get_content_length*(client: esp_http_client_handle_t): cint {.
    cdecl, importc: "esp_http_client_get_content_length",
    header: hdr.}

proc esp_http_client_close*(client: esp_http_client_handle_t): esp_err_t {.cdecl,
    importc: "esp_http_client_close", header: hdr.}

proc esp_http_client_cleanup*(client: esp_http_client_handle_t): esp_err_t {.cdecl,
    importc: "esp_http_client_cleanup", header: hdr.}

proc esp_http_client_get_transport_type*(client: esp_http_client_handle_t): esp_http_client_transport_t {.
    cdecl, importc: "esp_http_client_get_transport_type",
    header: hdr.}

proc esp_http_client_set_redirection*(client: esp_http_client_handle_t): esp_err_t {.
    cdecl, importc: "esp_http_client_set_redirection", header: hdr.}

proc esp_http_client_add_auth*(client: esp_http_client_handle_t) {.cdecl,
    importc: "esp_http_client_add_auth", header: hdr.}

proc esp_http_client_is_complete_data_received*(client: esp_http_client_handle_t): bool {.
    cdecl, importc: "esp_http_client_is_complete_data_received",
    header: hdr.}

proc esp_http_client_read_response*(client: esp_http_client_handle_t;
                                   buffer: pointer; len: cint): cint {.cdecl,
    importc: "esp_http_client_read_response", header: hdr.}

proc esp_http_client_flush_response*(client: esp_http_client_handle_t;
                                    len: ptr cint): esp_err_t {.cdecl,
    importc: "esp_http_client_flush_response", header: hdr.}

proc esp_http_client_get_url*(client: esp_http_client_handle_t; url: cstring;
                             len: cint): esp_err_t {.cdecl,
    importc: "esp_http_client_get_url", header: hdr.}

proc esp_http_client_get_chunk_length*(client: esp_http_client_handle_t;
                                      len: ptr cint): esp_err_t {.cdecl,
    importc: "esp_http_client_get_chunk_length", header: hdr.}