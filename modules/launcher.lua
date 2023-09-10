local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = 'V',appname = 'Visual Studio Code'},
    {shortcut = 'C',appname = 'Google Chrome'},
    {shortcut = 'T',appname = 'WeTERM'},
    {shortcut = 'F',appname = 'Finder'},
    {shortcut = 'D',appname = 'Dash'},
    {shortcut = 'W',appname = '企业微信'},
    {shortcut = 'N',appname = '有道云笔记'},
    {shortcut = 'P',appname = 'System Preferences'},
    {shortcut = 'X',appname = 'wechat'},
    {shortcut = 'L',appname = '网易有道翻译'},
    {shortcut = 'A',appname = 'Activity Monitor'},
    {shortcut = 'S',appname = 'Launchpad'},
    {shortcut = 'M',appname = 'NeteaseMusic'},
    {shortcut = 'Q',appname = 'QQMusic'}, 
    {shortcut = 'R',appname = 'CLion'}, 
}

fnutils.each(applist, function(entry)
    hotkey.bind({'ctrl', 'alt', 'cmd'}, entry.shortcut, entry.appname, function()
        application.launchOrFocus(entry.appname)
        -- toggle_application(applist[i].appname)
    end)
end)

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
    local app = appfinder.appFromName(_app)
    if not app then
        application.launchOrFocus(_app)
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end