local caffeinate = require "hs.caffeinate"
local audiodevice = require "hs.audiodevice"

-- hotkey.bind(hyper, "L", function()
--   caffeinate.lockScreen()
--   -- caffeinate.startScreensaver()
-- end)

-- mute on sleep
local function muteOnWake(eventType)
  if (eventType == caffeinate.watcher.systemDidWake) then
    local output = audiodevice.defaultOutputDevice()
    if output then
      output:setMuted(true)
    end
  end
end
-- 保留到全局, 避免被 GC 回收导致 watcher 失效
caffeinateWatcher = caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()