local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = 'V',appname = 'Visual Studio Code'}, -- vscode V
    {shortcut = 'C',appname = 'Google Chrome'},  -- Chrome C
    {shortcut = 'F',appname = 'Finder'},    -- Finder   F
    {shortcut = 'D',appname = 'Dash'},      -- Dash     D
    {shortcut = 'W',appname = '企业微信'},      -- Wework    W
    {shortcut = 'N',appname = '有道云笔记'},    -- Note      N
    {shortcut = 'P',appname = 'System Preferences'},    -- Preference P
    {shortcut = 'X',appname = 'wechat'},    -- WeXin X
    {shortcut = 'L',appname = '网易有道翻译'},  -- Lexicon L
    {shortcut = 'A',appname = 'Activity Monitor'},  -- Activity A
    {shortcut = 'S',appname = 'Launchpad'},     -- System App Launch S
    {shortcut = 'M',appname = 'NeteaseMusic'},  -- Music M
    {shortcut = 'Q',appname = 'QQMusic'},   -- QQMusic Q
    {shortcut = 'I',appname = 'QQ'},        -- IM I
    {shortcut = 'R',appname = 'Microsoft Remote Desktop'},
    {shortcut = 'T',appname = 'Terminal'},
    {shortcut = 'K',appname = 'iTerm'},
    {shortcut = 'A',appname = 'iphone Mirroring'}
}

fnutils.each(applist, function(entry)
    hotkey.bind(CA, entry.shortcut, entry.appname, function()
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