# Run in Questa Transcript: do {absolute/path/to/simulate.do}
set here [file dirname [file normalize [info script]]]
set python [auto_execok python]
if {$python eq ""} {error "Python is not on PATH. Use python run.py from PowerShell instead."}
puts [exec {*}$python [file join $here run.py] --prepare]
cd [file join $here results run]
transcript file simulation.log
transcript on
set h [open run.do r]
set body [read $h]
close $h
regsub -all {quit -code 0 -force} $body {quit -sim} body
eval $body
transcript file transcript
puts [exec {*}$python [file join $here run.py] --analyze]
