local hotkey = require "hs.hotkey"
local application = require "hs.application"
local fnutils = require "hs.fnutils"

local applist = {
    {shortcut = 'A', appname = 'Activity Monitor'},  -- Activity A
    {shortcut = 'B', appname = 'CodeBuddy CN'},      -- codebuddy B
    {shortcut = 'C', appname = 'Google Chrome'},     -- Chrome C
    {shortcut = 'D', appname = 'Dash'},              -- Dash D
    {shortcut = 'F', appname = 'Finder'},            -- Finder F
    {shortcut = 'I', appname = 'QQ'},                -- IM I
    {shortcut = 'K', appname = 'iTerm'},             -- iterm K
    {shortcut = 'L', appname = '网易有道翻译'},       -- Lexicon L
    {shortcut = 'M', appname = 'NeteaseMusic'},      -- Music M
    {shortcut = 'N', appname = 'Obsidian'},          -- Note N
    {shortcut = 'P', appname = 'Postman'},           -- postman P
    {shortcut = 'Q', appname = 'QQMusic'},           -- QQMusic Q
    {shortcut = 'R', appname = 'UURemote'},          -- remote desktop R
    {shortcut = 'S', appname = 'Cursor'},            -- Cursor S
    {shortcut = 'T', appname = 'Terminal'},          -- mac os inner terminal T
    {shortcut = 'V', appname = 'Visual Studio Code'},-- vscode V
    {shortcut = 'W', appname = '企业微信'},           -- Wework W
    {shortcut = 'X', appname = 'WeChat'},            -- WeChat X
}

fnutils.each(applist, function(entry)
    hotkey.bind(CA, entry.shortcut, function()
        application.launchOrFocus(entry.appname)
    end)
end)