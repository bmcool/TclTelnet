package require TclTelnet

TclTelnet::TclTelnet template

template setVar Title "example1"
template setVar Content "Hello World!!!"

template parseFile example1.tmpl

puts [template render]