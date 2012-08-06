package require TclTelnet

TclTelnet::TclTelnet template

template setVar Title "example3"
template setArr myInfo {
    Name "Good Man"
    Age "30"
}

template parseFile example3.tmpl

puts [template render]