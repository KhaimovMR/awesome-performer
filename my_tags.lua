local awful = require('awful')

if screen.count() == 1 then
    surfing_screen = 1
    work_screen = 1
    planning_screen = 1
    screen_1_offset = 0
    screen_2_offset = 12
    screen_3_offset = 24
elseif screen.count() == 2 then
    surfing_screen = 1
    work_screen = 2
    planning_screen = 1
    screen_1_offset = 0
    screen_2_offset = 0
    screen_3_offset = 0
else
    surfing_screen = 1
    work_screen = 2
    planning_screen = 3
    screen_1_offset = 0
    screen_2_offset = 0
    screen_3_offset = 0
end

surfing_screen_tags = tags[surfing_screen]
work_screen_tags = tags[work_screen]
planning_screen_tags = tags[planning_screen]

my_tags = {
    surfing_rlc = surfing_screen_tags[1 + screen_1_offset],
    surfing_dev = surfing_screen_tags[2 + screen_1_offset],
    surfing_test = surfing_screen_tags[3 + screen_1_offset],
    surfing_prod = surfing_screen_tags[4 + screen_1_offset],
    music = surfing_screen_tags[11 + screen_1_offset],
    teamviewer = surfing_screen_tags[10 + screen_1_offset],
    youtube = surfing_screen_tags[12 + screen_1_offset],
    google_music = surfing_screen_tags[12 + screen_1_offset],
    pycharm = work_screen_tags[1 + screen_2_offset],
    vim_coding_python = work_screen_tags[1 + screen_2_offset],
    vim_coding_php = work_screen_tags[2 + screen_2_offset],
    netbeans = work_screen_tags[2 + screen_2_offset],
    mysql = work_screen_tags[3 + screen_2_offset],
    gimp = work_screen_tags[4 + screen_2_offset],
    ssh_test = work_screen_tags[5 + screen_2_offset],
    skype = work_screen_tags[6 + screen_2_offset],
    discord = work_screen_tags[6 + screen_2_offset],
    hangouts = work_screen_tags[6 + screen_2_offset],
    pyr = work_screen_tags[8 + screen_2_offset],
    phr = work_screen_tags[9 + screen_2_offset],
    pyw = work_screen_tags[10 + screen_2_offset],
    phw = work_screen_tags[11 + screen_2_offset],
    ipython = work_screen_tags[12 + screen_2_offset],
    mindmeister = planning_screen_tags[1 + screen_3_offset],
    meistertask = planning_screen_tags[1 + screen_3_offset],
    jira = planning_screen_tags[2 + screen_3_offset],
    yt = planning_screen_tags[2 + screen_3_offset],
    wiki = planning_screen_tags[3 + screen_3_offset],
    stash = planning_screen_tags[4 + screen_3_offset],
    bamboo = planning_screen_tags[5 + screen_3_offset],
    pyrun = planning_screen_tags[6 + screen_3_offset],
    work_mail = planning_screen_tags[9 + screen_3_offset],
    work_google_docs = planning_screen_tags[10 + screen_3_offset],
    work_google_calendar = planning_screen_tags[10 + screen_3_offset],
    personal_mail = planning_screen_tags[11 + screen_3_offset],
    personal_google_docs = planning_screen_tags[12 + screen_3_offset],
    personal_google_calendar = planning_screen_tags[12 + screen_3_offset]
}

--awful.layout.set(awful.layout.suit.tile, my_tags['skype'])
