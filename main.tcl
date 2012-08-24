package provide TclTelnet 0.0.4
package require XOTcl;namespace import ::xotcl::*

namespace eval ::TclTelnet {
    # TclTelnet directory
    variable _dir [file dirname [info script]]
    
    # TclTelnet library directory
    variable _libDir [file join $_dir library]
    
    # import initial configuration file
    source [file join $_dir _init.tcl]
    
    # import utility procedures
    source [file join $_libDir utility.tcl]
    
    # ------------------------------------------------------------
    # import TclTelnet files
    # ------------------------------------------------------------
    
    source [file join $_dir TclTelnet.xotcl]
}