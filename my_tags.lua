if screen.count() == 1 then
    browsing_screen = 1
    work_screen = 1
    planning_screen = 1
elseif screen.count() == 2 then
    browsing_screen = 1
    work_screen = 2
    planning_screen = 1
else
    browsing_screen = 1
    work_screen = 2
    planning_screen = 3
end

browsing_screen_tags = tags[browsing_screen]
work_screen_tags = tags[work_screen]
planning_screen_tags = tags[planning_screen]

browsing_rlc_tag = browsing_screen_tags[1]
browsing_dev_tag = browsing_screen_tags[2]
browsing_test_tag = browsing_screen_tags[3]
browsing_prod_tag = browsing_screen_tags[4]
music_tag = browsing_screen_tags[12]
pycharm_tag = work_screen_tags[1]
netbeans_tag = work_screen_tags[2]
mysql_workbench_tag = work_screen_tags[5]
skype_tag = work_screen_tags[6]
teamviewer_tag = work_screen_tags[7]
freemind_tag = planning_screen_tags[1]
jira_tag = planning_screen_tags[2]

