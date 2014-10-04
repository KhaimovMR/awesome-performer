if screen.count() == 1 then
    surfing_screen = 1
    work_screen = 1
    planning_screen = 1
elseif screen.count() == 2 then
    surfing_screen = 1
    work_screen = 2
    planning_screen = 1
else
    surfing_screen = 1
    work_screen = 2
    planning_screen = 3
end

surfing_screen_tags = tags[surfing_screen]
work_screen_tags = tags[work_screen]
planning_screen_tags = tags[planning_screen]

my_tags = {
    surfing_rlc = surfing_screen_tags[1],
    surfing_dev = surfing_screen_tags[2],
    surfing_test = surfing_screen_tags[3],
    surfing_prod = surfing_screen_tags[4],
    music = surfing_screen_tags[12],
    pycharm = work_screen_tags[1],
    netbeans = work_screen_tags[2],
    mysql_workbench = work_screen_tags[5],
    skype = work_screen_tags[6],
    teamviewer = work_screen_tags[7],
    freemind = planning_screen_tags[1],
    jira = planning_screen_tags[2],
    work_mail = planning_screen_tags[9],
    personal_mail = planning_screen_tags[10]
}
