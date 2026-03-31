local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = 'A',appname = 'Activity Monitor'},  -- Activity A
    {shortcut = 'B',appname = 'CodeBuddy CN'},  -- codebuddy B
    {shortcut = 'C',appname = 'Google Chrome'},  -- Chrome C
    {shortcut = 'D',appname = 'Dash'},      -- Dash     D
    {shortcut = 'F',appname = 'Finder'},    -- Finder   F
    {shortcut = 'I',appname = 'QQ'},        -- IM I
    {shortcut = 'K',appname = 'iTerm'},  -- i itermal K
    {shortcut = 'L',appname = '网易有道翻译'},  -- Lexicon L
    {shortcut = 'M',appname = 'NeteaseMusic'},  -- Music M
    {shortcut = 'N',appname = 'Obsidian'},    -- Note      N
    {shortcut = 'P',appname = 'Postman'},    -- postman P
    {shortcut = 'Q',appname = 'QQMusic'},   -- QQMusic Q
    {shortcut = 'R',appname = 'UURemote'}, -- remote desktop R
    {shortcut = 'S',appname = 'Cursor'}, -- Cursor S
    {shortcut = 'T',appname = 'Terminal'}, -- mac os inner intermal T
    {shortcut = 'V',appname = 'Visual Studio Code'}, -- vscode V
    {shortcut = 'W',appname = '企业微信'},      -- Wework    W
    {shortcut = 'X',appname = 'wechat'},    -- WeXin X
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