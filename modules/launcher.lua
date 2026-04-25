local hotkey = require "hs.hotkey"
local application = require "hs.application"
local fnutils = require "hs.fnutils"
local canvas = require "hs.canvas"
local screen = require "hs.screen"

-- 固定位置提示画布
local fixedAlertCanvas = nil

-- 显示固定位置提示
local function showFixedAlert(text, duration)
    -- 先清除之前的提示
    if fixedAlertCanvas then
        fixedAlertCanvas:delete()
        fixedAlertCanvas = nil
    end
    
    -- 获取主屏幕
    local mainScreen = screen.primaryScreen()
    local screenFrame = mainScreen:frame()
    
    -- 创建画布（居中显示）
    local canvasWidth = 300
    local canvasHeight = 60
    fixedAlertCanvas = canvas.new({
        x = screenFrame.x + (screenFrame.w - canvasWidth) / 2,
        y = screenFrame.y + (screenFrame.h - canvasHeight) / 2,
        w = canvasWidth,
        h = canvasHeight
    })
    
    -- 设置画布样式
    fixedAlertCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {red = 0, green = 0, blue = 0, alpha = 0.7},
        roundedRectRadii = {xRadius = 10, yRadius = 10}
    }
    
    fixedAlertCanvas[2] = {
        type = "text",
        text = text,
        textColor = {red = 1, green = 1, blue = 1, alpha = 1},
        textSize = 24,
        textAlignment = "center",
        textFont = "Arial",
        textLineBreak = "truncateTail",
        -- 确保文字在画布中完美居中
        frame = {x = 0, y = (canvasHeight - 24) / 2, w = "100%", h = 24}
    }
    
    fixedAlertCanvas:level(canvas.windowLevels.overlay)
    fixedAlertCanvas:show()
    
    -- 设置定时器自动隐藏
    if duration and duration > 0 then
        hs.timer.doAfter(duration, function()
            if fixedAlertCanvas then
                fixedAlertCanvas:delete()
                fixedAlertCanvas = nil
            end
        end)
    end
end

-- 清除固定提示
local function clearFixedAlert()
    if fixedAlertCanvas then
        fixedAlertCanvas:delete()
        fixedAlertCanvas = nil
    end
end

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
        showFixedAlert(entry.appname, 3.0)
    end)
end)