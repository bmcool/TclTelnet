package require TclTelnet

TclTelnet::TclTelnet template

template setVar Title "example4"
template setVar NameList "Jack Mary"
template setArr Jack {
    Age 25
    Nickname "Good Man"
}
template setArr Mary {
    Age 30
    Nickname "Bad Woman"
}

template parseFile example4.tmpl

puts [template render]