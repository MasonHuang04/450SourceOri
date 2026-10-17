set_global_assignment -entity "FPFDiv" -library "lib_FPFDiv" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPFDiv" -library "lib_FPFDiv" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPFDiv" -library "lib_FPFDiv" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPFDiv" -name SPD_FILE [file join $::quartus(sip_path) "FPFDiv.spd"]

set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/FPFDiv_memoryC0_uid112_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/FPFDiv_memoryC0_uid113_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/FPFDiv_memoryC1_uid116_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/FPFDiv_memoryC2_uid120_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FPFDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPFDiv_sim/FPFDiv.vhd"]
