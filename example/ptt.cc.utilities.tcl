
proc debug {debug} {
    global debug_filter
    set debug_filter ""
    
    catch {rename puts _puts}
    if {$debug} {
        proc puts {args} {
            global debug_filter
            if {[llength $args] == 1 || ([lindex $args 0] == "-nonewline" && [llength $args] == 2)} {
                set message [lindex $args 0]
                if {[regexp $debug_filter $message]} {
                    uplevel _puts $args
                }
            } else {
                uplevel _puts $args
            }
        }
        puts "Debug Mode : True"
    } else {
        proc puts {args} {
            if {[llength $args] != 1} {
                uplevel _puts $args
            }
        }
        puts "Debug Mode : False, disable all 'puts' command"
    }
}

proc login {username password} {
    puts "Try to login to ptt.cc..."
    
    ::TclTelnet::TclTelnet ptt_client
    ptt_client connect ptt.cc
    ptt_client update
    
    while 1 {
        if {[regexp {系統過載, 請稍後再來} [ptt_client printScreen]]} {
            puts "The system is in high load, retry...."
            ptt_client destroy
            ::TclTelnet::TclTelnet ptt_client
            ptt_client connect ptt.cc
            ptt_client update
        } else {
            break
        }
    }
    
    ptt_client sendLine $username
    ptt_client sendLine $password
    puts "Log-in"
}

proc goHomePage {} {
    puts "Try to go to home page"
    while 1 {
        if {[regexp {主功能表} [ptt_client getLine 1]]} {
            puts "At home page now"
            break
        } elseif {[regexp {您想刪除其他重複登入的連線嗎？} [ptt_client printScreen]]} {
            puts "Disconnect other connection"
            ptt_client sendLine y
        }
        ptt_client send q
        ptt_client update
    }
}

proc goBoard {board} {
    ptt_client send s
    ptt_client sendLine $board
    ptt_client update
    if {[regexp {請按任意鍵繼續} [ptt_client getLine 24]]} {
        ptt_client send q
        ptt_client update
    }
}

proc goArticleNumber {number} {
    puts "go article number '$number'"
    ptt_client sendLine $number
    time {ptt_client update 100} 5
}

proc goBottomAndGetTotalArticleCount {} {
    # get total article number, CAREFUL total > 99999 (<allpost> board)
    ptt_client press home
    ptt_client press end
    
    time {ptt_client update 100} 5
    
    for {set row 23} {$row >= 1} {incr row -1} {
        set line [ptt_client getLine $row]
        set line [string trimleft $line ●]
        set line [string trimleft $line]
        if {[regexp {^\d+} $line result]} {return $result}
    }
}

proc getCurrentArticleId {} {
    ptt_client send Q
    ptt_client waitForExpectContent {\(AID\): #(.*?) \(}
    regexp {\(AID\): #(.*?) \(} [ptt_client printScreen] dummy article_id
    ptt_client send q
    ptt_client update
    return $article_id
}

proc getCurrentArticleContent {} {
    puts "Get current article content.."
    ptt_client press right
    
    ptt_client waitForExpectContent {瀏覽 第.*?頁 \(.*?(\d+)%\)} 24
    set infoRow [ptt_client getLine 24]
    regexp {瀏覽 第.*?頁 \(.*?(\d+)%\)} $infoRow dummy pagePercent
    set totalLines [lreplace [split [ptt_client printScreen] \n] end end]
    
    set count 1
    while {$pagePercent != 100} {
        ptt_client press down
        ptt_client waitUntilChange
        set line [ptt_client getLine 23]
        lappend totalLines $line
        set infoRow [ptt_client getLine 24]
        regexp {瀏覽 第.*?頁 \(.*?(\d+)%\)} $infoRow dummy pagePercent
        if {[expr $count % 5] == 0} {puts -nonewline .}
        if {[expr $count % 100] == 0} {puts "${pagePercent}%"}
        incr count
    }
    puts "done"
    
    # leave article
    ptt_client press left
    ptt_client waitForExpectContent "文章選讀" 24
    
    return [string trim [join $totalLines \n]]
}

proc getAuthorAndNickname {content_list} {
    regexp {作者  (\w+) \((.*)\)} [lindex $content_list 0] dummy author_id nickname
    return [list $author_id $nickname]
}

proc getArticleTitle {content_list} {
    regexp {標題  (.+)$} [lindex $content_list 1] dummy title
    set title [string trim $title]
    return $title
}

proc getArticleCreateTime {content_list} {
    regexp {時間  (.+)$} [lindex $content_list 2] dummy create_time
    set create_time [string trim $create_time]
    if {[regexp {\(.+\)} $create_time]} {
        regexp {\((.+)\)} $create_time dummy create_time
    }
    return $create_time
}
