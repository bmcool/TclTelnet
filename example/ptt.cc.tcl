package require TclTelnet

set board Test

set debug true
set debug_filter {}

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
} else {
    proc puts {args} {
        if {[llength $args] != 1} {
            uplevel _puts $args
        }
    }
}

proc goMainPage {} {
    while 1 {
        if {[regexp {主功能表} [ptt_client printScreen]]} {
            puts "debug :\n[ptt_client printScreen]"
            break
        } elseif {[regexp {您想刪除其他重複登入的連線嗎？} [ptt_client printScreen]]} {
            ptt_client sendLine y
        }
        ptt_client send q
        ptt_client update
    }
}

# already login
if {[info commands ptt_client] == ""} {
    
    ::TclTelnet::TclTelnet ptt_client
    ptt_client connect ptt.cc
    
    ptt_client sendLine coevo
    ptt_client sendLine coevo53118909
    puts "debug : Log-in"
}

goMainPage
    
ptt_client send s
ptt_client sendLine $board
ptt_client update
if {[regexp {請按任意鍵繼續} [ptt_client printScreen]]} {
    ptt_client send q
    ptt_client update
}
puts "debug :\n[ptt_client printScreen]"

# make sure we are at bottom
ptt_client press end
ptt_client update
puts "debug :\n[ptt_client printScreen]"

# begin to get message...
ptt_client waitForExpectContent "^.*看板《$board》.*\n"

regexp {人氣:(\d+)} [ptt_client printScreen] dummy popularity
puts "debug : $board 版人氣 = $popularity"
for {set i 1} {$i <= 10} {incr i} {
    regexp {●.*? .(.{1,2})../..} [ptt_client printScreen] dummy article_popularity
    set article_popularity [string trim $article_popularity]
    if {$article_popularity == ""} {set article_popularity 0}
    puts "debug : 文章人氣 = $article_popularity"
    puts 999
    ptt_client send Q
    ptt_client waitForExpectContent {\(AID\): #(.*?) \(}
    regexp {\(AID\): #(.*?) \(} [ptt_client printScreen] dummy article_id
    puts "debug : 文章代碼 = $article_id"
    ptt_client send q
    ptt_client press right
    puts 888
    ptt_client waitForExpectContent {瀏覽 第.*?頁 \(.*?(\d+)%\)  目前顯示: 第 (\d+)~(\d+) 行}
    set infoRow [lindex [split [ptt_client printScreen] \n] end]
    regexp {瀏覽 第.*?頁 \(.*?(\d+)%\)} $infoRow dummy pagePercent
    puts 777
    set totalLines [lreplace [split [ptt_client printScreen] \n] end end]
    puts 666
    while {$pagePercent != 100} {
        ptt_client press down
        ptt_client waitUntilChange
        lappend totalLines [lindex [split [ptt_client printScreen] \n] end-1]
        set infoRow [lindex [split [ptt_client printScreen] \n] end]
        regexp {瀏覽 第.*?頁 \(.*?(\d+)%\)} $infoRow dummy pagePercent
        puts [lindex [split [ptt_client printScreen] \n] end],$pagePercent
    }
    puts 111
    set content [join $totalLines \n]
    set content [string trim $content]
    set totalLines [split $content \n]
    puts 222
    regexp {作者  (\w+) \((.*)\)} [lindex $totalLines 0] dummy author_id nickname
    puts "debug : 作者 = $author_id, 暱稱 = $nickname"
    set totalLines [lreplace $totalLines 0 0]
    puts 333
    regexp {標題  (.+)$} [lindex $totalLines 0] dummy title
    set title [string trim $title]
    puts "debug : 標題 = $title"
    set totalLines [lreplace $totalLines 0 0]
    puts 444
    regexp {時間  (.+)$} [lindex $totalLines 0] dummy datetime
    set datetime [string trim $datetime]
    if {[regexp {\(.+\)} $datetime]} {
        regexp {\((.+)\)} $datetime dummy datetime
    }
    puts 555
    puts "debug : 時間 = $datetime"
    set totalLines [lreplace $totalLines 0 0]
    
    # TODO ........
    while 1 {
        set line [lindex $totalLines 0]
        set totalLines [lreplace $totalLines 0 0]
        if {[regexp {───────────────────────────────────────} $line]} {
            set totalLines [lreplace $totalLines 0 0]
            break
        }
    }
    puts aaa
    foreach line $totalLines {
        puts $line
    }
    puts bbb
    puts =================================
    ptt_client press up
    ptt_client waitUntilChange
}






