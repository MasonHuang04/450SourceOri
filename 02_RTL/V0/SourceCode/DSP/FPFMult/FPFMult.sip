set_global_assignment -entity "FPFMult" -library "lib_FPFMult" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPFMult" -library "lib_FPFMult" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPFMult" -library "lib_FPFMult" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPFMult" -name SPD_FILE [file join $::quartus(sip_path) "FPFMult.spd"]

set_global_assignment -library "lib_FPFMult" -name MISC_FILE [file join $::quartus(sip_path) "FPFMult_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FPFMult" -name MISC_FILE [file join $::quartus(sip_path) "FPFMult_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FPFMult" -name MISC_FILE [file join $::quartus(sip_path) "FPFMult_sim/FPFMult.vhd"]
