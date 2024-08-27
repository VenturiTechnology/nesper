set(requires lwip newlib nvs_flash app_update)

string(SUBSTRING "$${IDF_VER}" 1 3 IDF_VER_VAL_STR)
if("$${IDF_VER_VAL_STR}" VERSION_GREATER_EQUAL "5.0")
    list(APPEND requires esp_netif)
endif()

idf_component_register(SRC_DIRS "$NIMBLE_NIMCACHE"
                    INCLUDE_DIRS ""
                    REQUIRES $${requires})

# set(C_COMPILE_OPTIONS "$${C_COMPILE_OPTIONS} -Wno-error=unused-label")
# list(APPEND C_COMPILE_OPTIONS "-Wno-error=unused-label ")

idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-discarded-qualifiers APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-ignored-qualifiers APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)
