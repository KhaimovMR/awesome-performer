local awful = require('awful')
local screen_count = screen.count()
surfing_screen = 1
work_screen = 1
planning_screen = 1

surfing_screen_offset = 0 -- modkey
planning_screen_offset = 12 -- altkey
work_screen_offset = 24 -- control

surfing_screen_tag_number_offset = 0 -- modkey
planning_screen_tag_number_offset = 12 -- altkey
work_screen_tag_number_offset = 24 -- control

preferred_screen_outputs = {
    tag_1 = HDMI1,
    tag_2 = HDMI1,
    tag_3 = HDMI1,
    tag_4 = HDMI1,
    tag_5 = HDMI1,
    tag_6 = HDMI1,
    tag_7 = HDMI1,
    tag_8 = HDMI1,
    tag_9 = HDMI1,
    tag_10 = HDMI1,
    tag_11 = HDMI1,
    tag_12 = HDMI1,
    tag_13 = eDP1,
    tag_14 = eDP1,
    tag_15 = eDP1,
    tag_16 = eDP1,
    tag_17 = eDP1,
    tag_18 = eDP1,
    tag_19 = eDP1,
    tag_20 = eDP1,
    tag_21 = eDP1,
    tag_22 = eDP1,
    tag_23 = eDP1,
    tag_24 = eDP1,
    tag_25 = HDMI1,
    tag_26 = HDMI1,
    tag_27 = HDMI1,
    tag_28 = HDMI1,
    tag_29 = HDMI1,
    tag_30 = HDMI1,
    tag_31 = HDMI1,
    tag_32 = HDMI1,
    tag_33 = HDMI1,
    tag_34 = HDMI1,
    tag_35 = HDMI1,
    tag_36 = HDMI1,
}

function init_screen_tags_offsets()
    if screen_count == 1 then
        surfing_screen = 1
        work_screen = 1
        planning_screen = 1

        surfing_screen_offset = 0 -- modkey
        planning_screen_offset = 12 -- altkey
        work_screen_offset = 24 -- control

        surfing_screen_tag_number_offset = 0 -- modkey
        planning_screen_tag_number_offset = 12 -- altkey
        work_screen_tag_number_offset = 24 -- control
    elseif screen_count == 2 then
        surfing_screen = 2
        work_screen = 2
        planning_screen = 1

        surfing_screen_offset = 0 -- modkey
        planning_screen_offset = 0 -- altkey
        work_screen_offset = 12  -- control

        surfing_screen_tag_number_offset = 0 -- modkey
        planning_screen_tag_number_offset = 12 -- altkey
        work_screen_tag_number_offset = 24 -- control
    else
        surfing_screen = 1
        work_screen = 3
        planning_screen = 2

        surfing_screen_offset = 0 -- modkey
        planning_screen_offset = 0 -- altkey
        work_screen_offset = 0  -- control

        surfing_screen_tag_number_offset = 0 -- modkey
        planning_screen_tag_number_offset = 12 -- altkey
        work_screen_tag_number_offset = 24 -- control
    end
end

init_screen_tags_offsets()

surfing_screen_tags = tags[surfing_screen]
work_screen_tags = tags[work_screen]
planning_screen_tags = tags[planning_screen]

my_tags = {
    tag_1 = surfing_screen_tags[1 + surfing_screen_offset],
    surfing_main = surfing_screen_tags[1 + surfing_screen_offset],
    surfing_localhost = surfing_screen_tags[1 + surfing_screen_offset],
    surfing_rlc = surfing_screen_tags[1 + surfing_screen_offset],

    tag_2 = surfing_screen_tags[2 + surfing_screen_offset],
    surfing_work = surfing_screen_tags[2 + surfing_screen_offset],
    pyrun = surfing_screen_tags[2 + surfing_screen_offset],

    tag_3 = surfing_screen_tags[3 + surfing_screen_offset],
    surfing_dev = surfing_screen_tags[3 + surfing_screen_offset],

    tag_4 = surfing_screen_tags[4 + surfing_screen_offset],
    surfing_test = surfing_screen_tags[4 + surfing_screen_offset],

    tag_5 = surfing_screen_tags[5 + surfing_screen_offset],
    surfing_prod = surfing_screen_tags[5 + surfing_screen_offset],

    tag_6 = surfing_screen_tags[6 + surfing_screen_offset],

    tag_7 = surfing_screen_tags[7 + surfing_screen_offset],

    tag_8 = surfing_screen_tags[8 + surfing_screen_offset],

    tag_9 = surfing_screen_tags[9 + surfing_screen_offset],

    tag_10 = surfing_screen_tags[10 + surfing_screen_offset],
    teamviewer = surfing_screen_tags[10 + surfing_screen_offset],

    tag_11 = surfing_screen_tags[11 + surfing_screen_offset],

    tag_12 = surfing_screen_tags[12 + surfing_screen_offset],
    music = surfing_screen_tags[12 + surfing_screen_offset],
    google_music = surfing_screen_tags[12 + surfing_screen_offset],
    youtube = surfing_screen_tags[12 + surfing_screen_offset],
    twitch = surfing_screen_tags[12 + surfing_screen_offset],
    netflix = surfing_screen_tags[12 + surfing_screen_offset],

    tag_13 =         planning_screen_tags[1 + planning_screen_offset],
    messengers =     planning_screen_tags[1 + planning_screen_offset],
    work_2_skype =   planning_screen_tags[1 + planning_screen_offset],

    tag_14 =         planning_screen_tags[2 + planning_screen_offset],
    screen_sharing = planning_screen_tags[2 + planning_screen_offset],
    calls          = planning_screen_tags[2 + planning_screen_offset],
    google_meet    = planning_screen_tags[2 + planning_screen_offset],

    tag_15 =               planning_screen_tags[3 + planning_screen_offset],
    messengers_personal =  planning_screen_tags[3 + planning_screen_offset],
    viber =                planning_screen_tags[3 + planning_screen_offset],

    tag_16 = planning_screen_tags[4 + planning_screen_offset],
    personal_google_docs = planning_screen_tags[3 + planning_screen_offset],
    draw_io =              planning_screen_tags[3 + planning_screen_offset],
    work_1_google_docs =   planning_screen_tags[3 + planning_screen_offset],
    stash = planning_screen_tags[4 + planning_screen_offset],
    github = planning_screen_tags[4 + planning_screen_offset],
    codecov = planning_screen_tags[4 + planning_screen_offset],
    bamboo = planning_screen_tags[4 + planning_screen_offset],

    tag_17 = planning_screen_tags[5 + planning_screen_offset],
    mindmeister = planning_screen_tags[5 + planning_screen_offset],
    meistertask = planning_screen_tags[5 + planning_screen_offset],
    jira = planning_screen_tags[5 + planning_screen_offset],
    yt = planning_screen_tags[5 + planning_screen_offset],
    yt_rg = planning_screen_tags[5 + planning_screen_offset],
    rg_youtrack = planning_screen_tags[5 + planning_screen_offset],
    hub_rg = planning_screen_tags[5 + planning_screen_offset],
    trello = planning_screen_tags[5 + planning_screen_offset],
    rg_wiki = planning_screen_tags[5 + planning_screen_offset],
    wiki = planning_screen_tags[5 + planning_screen_offset],

    tag_18 = planning_screen_tags[6 + planning_screen_offset],

    tag_19 = planning_screen_tags[7 + planning_screen_offset],
    personal_mail = planning_screen_tags[7 + planning_screen_offset],

    tag_20 = planning_screen_tags[8 + planning_screen_offset],
    report_plus = planning_screen_tags[8 + planning_screen_offset],
    personal_google_calendar = planning_screen_tags[8 + planning_screen_offset],

    tag_21 = planning_screen_tags[9 + planning_screen_offset],
    work_1_mail = planning_screen_tags[9 + planning_screen_offset],

    tag_22 = planning_screen_tags[10 + planning_screen_offset],
    work_1_google_calendar = planning_screen_tags[10 + planning_screen_offset],

    tag_23 = planning_screen_tags[11 + planning_screen_offset],
    work_2_mail = planning_screen_tags[11 + planning_screen_offset],

    tag_24 = planning_screen_tags[12 + planning_screen_offset],
    work_2_google_calendar = planning_screen_tags[12 + planning_screen_offset],


    tag_25 = work_screen_tags[1 + work_screen_offset],
    pycharm = work_screen_tags[1 + work_screen_offset],
    vim_coding_python = work_screen_tags[1 + work_screen_offset],

    tag_26 = work_screen_tags[2 + work_screen_offset],
    vim_coding_golang = work_screen_tags[2 + work_screen_offset],
    netbeans = work_screen_tags[2 + work_screen_offset],

    tag_27 = work_screen_tags[3 + work_screen_offset],
    mysql = work_screen_tags[3 + work_screen_offset],

    tag_28 = work_screen_tags[4 + work_screen_offset],
    gimp = work_screen_tags[4 + work_screen_offset],
    blender = work_screen_tags[4 + work_screen_offset],
    inkscape = work_screen_tags[4 + work_screen_offset],

    tag_29 = work_screen_tags[5 + work_screen_offset],
    ssh_test = work_screen_tags[5 + work_screen_offset],

    tag_30 = work_screen_tags[6 + work_screen_offset],
    chrome_dev_tools = work_screen_tags[6 + work_screen_offset],

    tag_31 = work_screen_tags[7 + work_screen_offset],

    tag_32 = work_screen_tags[8 + work_screen_offset],
    pyr = work_screen_tags[8 + work_screen_offset],

    tag_33 = work_screen_tags[9 + work_screen_offset],
    phr = work_screen_tags[9 + work_screen_offset],

    tag_34 = work_screen_tags[10 + work_screen_offset],
    pyw = work_screen_tags[10 + work_screen_offset],

    tag_35 = work_screen_tags[11 + work_screen_offset],
    phw = work_screen_tags[11 + work_screen_offset],
    games = work_screen_tags[11 + work_screen_offset],

    tag_36 = work_screen_tags[12 + work_screen_offset],
    ipython = work_screen_tags[12 + work_screen_offset],
}
