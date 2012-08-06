package require TclTelnet

TclTelnet::TclTelnet template

template setVar Title "example2"
template setVar Languages "Tcl Python C C++ Ruby C# Java"

template parseFile example2.tmpl

puts [template render]