# Run in Questa Transcript: do {absolute/path/to/simulate.do}
set here [file dirname [file normalize [info script]]]
set python [auto_execok python]
if {$python eq ""} {error "Python is not on PATH. Use python run.py from PowerShell instead."}
puts [exec {*}$python [file join $here run.py] --prepare]
cd [file join $here results run]
do compile_and_run.do
puts [exec {*}$python [file join $here run.py] --analyze]
