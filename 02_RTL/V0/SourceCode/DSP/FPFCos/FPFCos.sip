set_global_assignment -entity "FPFCos" -library "lib_FPFCos" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPFCos" -library "lib_FPFCos" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPFCos" -library "lib_FPFCos" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPFCos" -name SPD_FILE [file join $::quartus(sip_path) "FPFCos.spd"]

set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos_memoryC0_uid248_sinXTables_lutmem.hex"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos_memoryC1_uid251_sinXTables_lutmem.hex"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos_memoryC2_uid254_sinXTables_lutmem.hex"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos_rrTable_uid47_fpCosPiTest_lutmem.hex"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos_rrTable_uid48_fpCosPiTest_lutmem.hex"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FPFCos" -name MISC_FILE [file join $::quartus(sip_path) "FPFCos_sim/FPFCos.vhd"]
