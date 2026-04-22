local pathwatcher = require "hs.pathwatcher"
local alert = require "hs.alert"

-- http://www.hammerspoon.org/go/#fancyreload
local function reloadConfig(files)
	for _, file in ipairs(files) do
		if file:sub(-4) == ".lua" then
			hs.reload()
			return
		end
	end
end

-- 必须保留到全局, 避免被 GC 回收导致 watcher 失效
configWatcher = pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon", reloadConfig):start()
alert.show("Hammerspoon Config Reloaded")
