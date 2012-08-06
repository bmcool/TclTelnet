
# Reference : http://www2.tcl.tk/1599
proc hexdump {data {start_addr 0} {width 20}} {
    set result ""
    if {[catch {
        # Convert the data to hex and to characters.
        binary scan $data H*@0a* hex ascii
        # Replace non-printing characters in the data.
        regsub -all -- {[^[:graph:] ]} $ascii {.} ascii
        set nbytes [string length $ascii]
        for {set pos 0} {$pos < $nbytes} {incr pos $width} {
            set addr [expr $pos + $start_addr]
            set s_hex [string range $hex [expr $pos * 2] [expr ($pos + $width)*2 - 1]]
            set s_ascii [string range $ascii $pos [expr $pos + $width - 1]]

            # Convert the hex to pairs of hex digits
            regsub -all -- {..} $s_hex {& } fmt_hex

            # Put the hex and Latin-1 data to the channel
            append out [format "%06x %-24s %-8s\n" $addr $fmt_hex $s_ascii]
        }
    } err]} {
        return -code error $err
    }
    return $result
 }