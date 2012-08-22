encoding system utf-8

package require TclTelnet
source ptt.cc.utilities.tcl

set board Test
set username ""
set password ""

debug true
set debug_filter ""

# already login
if {[info commands ptt_client] == "" || ![ptt_client isConnected]} {
    login $username $password
}

goHomePage
goBoard $board

set totalArticleCount [goBottomAndGetTotalArticleCount]
puts "Total article count = $totalArticleCount"

goArticleNumber $totalArticleCount

ptt_client waitForExpectContent "看板《$board》" 1
puts "In board '$board'"

regexp {人氣:(\d+)} [ptt_client getLine 3] dummy popularity
puts "$board popularity = $popularity"

for {set i 1} {$i <= 10} {incr i} {
    puts "-------------------------"
    set currentLine [ptt_client getCurrentLine]
    regexp {●(.*?) (.)(.{1,2})../.. (\w+) } $currentLine dummy article_number article_status article_popularity author_id
    if {[regexp {本文已被刪除} $currentLine]} {
        puts "Article number $article_number has been deleted"
    } else {
        set article_popularity [string trim $article_popularity]
        if {$article_popularity == ""} {set article_popularity 0}
        
        set article_id [getCurrentArticleId]
        
        set article_content [getCurrentArticleContent]
        set article_content_list [split $article_content \n]
        
        set author_nickname [getAuthorNickname $article_content_list]
        set article_title [getArticleTitle $article_content_list]
        set article_create_time [getArticleCreateTime $article_content_list]
        
        if {$nickname == "" || $article_title == "" || $article_create_time == ""} {
            puts "Parse article error, maybe author delete all content"
        } else {
            puts "Article number = $article_number"
            puts "Article popularity = $article_popularity"
            
            switch -- $article_status {
                " " {puts "Article status = read"}
                "+" {puts "Article status = unread"}
                "~" {puts "Article status = updated"}
                "m" {puts "Article status = read and important marked"}
                "M" {puts "Article status = unread and important marked"}
                "=" {puts "Article status = updated and important marked"}
                "s" {puts "Article status = updated and just marked"}
                "S" {puts "Article status = unread and just marked"}
                "!" {puts "Article status = updated and locked"}
            }
            
            puts "Article ID = $article_id"
            
            puts "Author ID = $author_id"
            puts "Author nickname = $author_nickname"
            
            puts "Article title = $article_title"
            
            puts "Article create time = $article_create_time"
            
            set article_start 0
            puts ============================
            foreach line $article_content_list {
                if {$article_start == 0 && [regexp {──────────} $line]} {set article_start 1; continue}
                if {$article_start != 1} {continue}
                puts $line
            }
        }
    }
    
    ptt_client press up
    ptt_client waitUntilChange
}
