awesome-performer
=================

## My optimal Awesome WM configuration for development and management performance.


Clone this repository into ~/.config/awesome directory.

For script to execute properly, afterwards, place my_vars.lua into ~/.config/awesome directory.

Example of "my_vars.lua" (all variables is required):

```lua
my_skype_login = 'my.skype.login'
my_jira_url = 'http://jira.example.com'
my_browser_window_class_1 = 'Google-chrome-stable'
my_browser_window_class_2 = 'Google-chrome'

my_browser_titles_to_intercept = {
    -- <tag_name> = '<browser_title_search_pattern>'
    work_mail = 'workuser@example',
    personal_mail = 'personaluser@example.com',
    jira = '%[jira.example.com%]',
    wiki = '%[wiki.example.com%]'
}

my_startup_applications = {
    -- { <section_1_name> = { <section_applications> }, <section_2_name> = { <section_applications> } ... etc }
    --     <section_name> - any syntax compatible name of the applications section
    --     <section_applications> - table, containing elements with structure described below
    --         { '<command_to_start_an_app>', <check_if_already_started> }
    --             <command_to_start_an_app> - shell command to start an application
    --             <check_if_already_started> - (could be: true | false | string)
    --                 if true then check by start command
    --                 if false then bypass check for existent instance of this application
    --                 if string then the check will be accomplished by represented string
    default = {
        { 'easystroke', true },
        { 'us-ru-nocaps', false },
        { 'firefox http://jira.example.com --new-window', 'firefox' },
    },
    mail = {
        { 'firefox http://mail-server.com --new-window', false },
    }
}
-- variables below are using with appropriate browser plugin, that prints in a
-- part of browser title string with template (with brackets): [some-website.com]
my_local_website_url = 'some-local-website.com'
my_dev_website_url = 'some-dev-website.com'
my_test_website_url = 'some-test-website.com'
my_prod_website_url = 'some-website.com'
```

