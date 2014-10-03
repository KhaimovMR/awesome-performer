awesome-performer
=================

## My optimal Awesome WM configuration for development and management performance.


Clone this repository into ~/.config/awesome directory.

For script to execute properly, afterwards, place my_vars.lua into ~/.config/awesome directory.

Example of my_vars.lua (all variables is required):

```lua
my_skype_login = 'my.skype.login'
my_jira_url = 'http://jira.example.com'
my_startup_applications = {
    -- { "<command_to_start_an_app>" , <check_if_already_started> }
    -- <command_to_start_an_app> - shell command to start an application
    -- <check_if_already_started> - (could be: true | false | string)
    --     if true then check by start command
    --     if false then bypass check for existent instance of this application
    --     if string then the check will be accomplished by represented string
    { "easystroke", true },
    { "us-ru-nocaps", false },
    { "firefox http://jira.example.com --new-window", "firefox" },
}

-- variables below are using with appropriate browser plugin, that prints in a
-- part of browser title string with template (with brackets): [some-website.com]
my_local_website_url = 'some-local-website.com'
my_dev_website_url = 'some-dev-website.com'
my_test_website_url = 'some-test-website.com'
my_prod_website_url = 'some-website.com'
```
