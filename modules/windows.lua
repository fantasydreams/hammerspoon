-- window management
local hotkey   = require "hs.hotkey"
local window   = require "hs.window"
local layout   = require "hs.layout"
local hints    = require "hs.hints"
local screen   = require "hs.screen"
local alert    = require "hs.alert"
local geometry = require "hs.geometry"
local mouse    = require "hs.mouse"
local eventtap = require "hs.eventtap"

-- default 0.2
window.animationDuration = 0

-- 通用: 对焦点窗口执行操作, 无焦点窗口时弹出提示
local function withFocused(fn)
  local w = window.focusedWindow()
  if w then
    fn(w)
  else
    alert.show("No active window")
  end
end

-- left half
hotkey.bind(CCA, "Left",  function() withFocused(function(w) w:moveToUnit(layout.left50)  end) end)
-- right half
hotkey.bind(CCA, "Right", function() withFocused(function(w) w:moveToUnit(layout.right50) end) end)
-- top half
hotkey.bind(CCA, "Up",    function() withFocused(function(w) w:moveToUnit'[0,0,100,50]'   end) end)
-- bottom half
hotkey.bind(CCA, "Down",  function() withFocused(function(w) w:moveToUnit'[0,50,100,100]' end) end)
-- full screen
hotkey.bind(CCA, "F",     function() withFocused(function(w) w:toggleFullScreen()         end) end)
-- center window
hotkey.bind(CCA, "C",     function() withFocused(function(w) w:centerOnScreen()           end) end)

-- 记忆窗口原始 frame, 用于最大化切换
local frameCache = {}

-- 在窗口销毁时清理 frameCache, 防止长期运行后内存堆积
-- 保留到全局, 避免被 GC 回收导致 filter 失效
wfDestroy = window.filter.new()
wfDestroy:subscribe(window.filter.windowDestroyed, function(w)
  if w and w.id and w:id() then frameCache[w:id()] = nil end
end)

local function toggleMaximize(win)
  local id = win:id()
  if frameCache[id] then
    win:setFrame(frameCache[id])
    frameCache[id] = nil
  else
    frameCache[id] = win:frame()
    win:maximize()
  end
end

-- maximize window
hotkey.bind(CCA, "M", function() withFocused(toggleMaximize) end)

-- display a keyboard hint for switching focus to each window
hotkey.bind(CAS, "/", function() hints.windowHints() end)

-- switch active window
hotkey.bind(CAS, "H", function() window.switcher.nextWindow() end)

-- move active window to previous/next monitor
hotkey.bind(CAS, "Left",  function() withFocused(function(w) w:moveOneScreenWest() end) end)
hotkey.bind(CAS, "Right", function() withFocused(function(w) w:moveOneScreenEast() end) end)

---------------------------------------------------------
-- 跨屏幕光标切换 (带记忆坐标)
---------------------------------------------------------

-- 记忆每块屏幕上次离开时鼠标所在的坐标, key 为 screen 的 UUID
local lastCursorPos = {}

-- 判断坐标点是否落在指定屏幕的 frame 范围内
local function pointInScreen(pt, scr)
  local f = scr:fullFrame()
  return pt.x >= f.x and pt.x < (f.x + f.w)
     and pt.y >= f.y and pt.y < (f.y + f.h)
end

-- 记录当前鼠标所在屏幕的坐标, 切屏前调用
local function rememberCurrentCursor()
  local pt = mouse.absolutePosition()
  local curScreen = mouse.getCurrentScreen()
  if curScreen and pt then
    lastCursorPos[curScreen:getUUID()] = pt
  end
end

-- 屏幕变动(拔插/分辨率变化)时, 清理已不存在的 UUID
-- 保留到全局, 避免被 GC 回收导致 watcher 失效
screenWatcher = screen.watcher.new(function()
  local alive = {}
  for _, s in ipairs(screen.allScreens()) do alive[s:getUUID()] = true end
  for uuid in pairs(lastCursorPos) do
    if not alive[uuid] then lastCursorPos[uuid] = nil end
  end
end)
screenWatcher:start()

-- 在指定坐标模拟一次干净的左键点击
-- 必须显式清空修饰键: hotkey 回调执行时 option 仍处于按下状态,
-- 否则 macOS 收到的是 option+click 而非普通点击
local function leftClickAt(pt)
  local types = eventtap.event.types
  local down = eventtap.event.newMouseEvent(types.leftMouseDown, pt)
  local up = eventtap.event.newMouseEvent(types.leftMouseUp, pt)
  if not down or not up then
    alert.show("Failed to create mouse event")
    return
  end

  down:setFlags({})
  down:post()
  up:setFlags({})
  up:post()
end

-- 将光标移到目标屏幕(记忆坐标或中心)并原地点击一次
-- 这里不强制 focus 目标屏幕的最前窗口, 而是让落点处的窗口获得焦点,
-- 与 option + C 的"原地点击"语义保持一致
local function focusScreen(targetScreen)
  if not targetScreen then return end

  -- 切到新屏幕前, 先记下当前屏幕的鼠标位置
  rememberCurrentCursor()

  -- 目标屏幕若有记忆坐标且仍在屏幕内, 用记忆坐标; 否则回退到屏幕中心
  local remembered = lastCursorPos[targetScreen:getUUID()]
  local pt
  if remembered and pointInScreen(remembered, targetScreen) then
    pt = remembered
  else
    pt = geometry.rectMidPoint(targetScreen:fullFrame())
  end
  mouse.absolutePosition(pt)

  leftClickAt(pt)
end

-- 获取所有屏幕并按位置排序(先左右, 同列时再上下)
-- 供 focusScreenByIndex 与 moveWindowToScreen 共用, 保证 option+N 与 CAS+N 指向同一块屏
local function orderedScreens()
  local screens = screen.allScreens()
  table.sort(screens, function(a, b)
    local fa, fb = a:fullFrame(), b:fullFrame()
    if fa.x ~= fb.x then return fa.x < fb.x end
    return fa.y < fb.y
  end)
  return screens
end

-- 按索引定位光标到指定屏幕（按系统显示器排列顺序）
local function focusScreenByIndex(n)
  local screens = orderedScreens()
  if n < 1 or n > #screens then
    alert.show("Only " .. #screens .. " monitors")
    return
  end
  focusScreen(screens[n])
end

-- 光标跳到上/下一块显示器 (基于鼠标所在屏幕, 不再依赖 focusedWindow)
hotkey.bind(CCS, "Left",  function()
  local cur = mouse.getCurrentScreen()
  if cur then focusScreen(cur:previous()) end
end)
hotkey.bind(CCS, "Right", function()
  local cur = mouse.getCurrentScreen()
  if cur then focusScreen(cur:next()) end
end)

-- option + D: 光标跳到下一块显示器
hotkey.bind(option, "D", function()
  local cur = mouse.getCurrentScreen()
  if cur then focusScreen(cur:next()) end
end)

---------------------------------------------------------
-- 将窗口最大化并移动到指定屏幕
---------------------------------------------------------

local function moveWindowToScreen(win, n)
  local screens = orderedScreens()
  if n < 1 or n > #screens then
    alert.show("Only " .. #screens .. " monitors")
    return
  end
  local target = screens[n]
  alert.show("Move " .. win:application():name() .. " to " .. target:name())
  win:moveToScreen(target)
  win:maximize()
end

-- 批量注册 option + 1/2/3/4 (光标跳转), CAS + 1/2/3/4 (窗口跨屏最大化)
for i = 1, 4 do
  local key = tostring(i)
  hotkey.bind(option, key, function() focusScreenByIndex(i) end)
  hotkey.bind(CAS,    key, function() withFocused(function(w) moveWindowToScreen(w, i) end) end)
end

-- option + C: 在当前鼠标位置原地模拟一次左键点击
hotkey.bind(option, "C", function()
  leftClickAt(mouse.absolutePosition())
end)