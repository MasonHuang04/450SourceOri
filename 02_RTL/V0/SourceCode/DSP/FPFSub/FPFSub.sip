set_global_assignment -entity "FPFSub" -library "lib_FPFSub" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPFSub" -library "lib_FPFSub" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPFSub" -library "lib_FPFSub" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPFSub" -name SPD_FILE [file join $::quartus(sip_path) "FPFSub.spd"]

set_global_assignment -library "lib_FPFSub" -name MISC_FILE [file join $::quartus(sip_path) "FPFSub_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FPFSub" -name MISC_FILE [file join $::quartus(sip_path) "FPFSub_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FPFSub" -name MISC_FILE [file join $::quartus(sip_path) "FPFSub_sim/FPFSub.vhd"]
