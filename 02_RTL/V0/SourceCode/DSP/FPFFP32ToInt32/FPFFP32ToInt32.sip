set_global_assignment -entity "FPFFP32ToInt32" -library "lib_FPFFP32ToInt32" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPFFP32ToInt32" -library "lib_FPFFP32ToInt32" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPFFP32ToInt32" -library "lib_FPFFP32ToInt32" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPFFP32ToInt32" -name SPD_FILE [file join $::quartus(sip_path) "FPFFP32ToInt32.spd"]

set_global_assignment -library "lib_FPFFP32ToInt32" -name MISC_FILE [file join $::quartus(sip_path) "FPFFP32ToInt32_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FPFFP32ToInt32" -name MISC_FILE [file join $::quartus(sip_path) "FPFFP32ToInt32_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FPFFP32ToInt32" -name MISC_FILE [file join $::quartus(sip_path) "FPFFP32ToInt32_sim/FPFFP32ToInt32.vhd"]
