GG.Console.P("===========================================================")
GG.Console.P("              LOAD Cocos2d-Lua-Community FRAMEWORK")
GG.Console.P("===========================================================")

GG.Env.DEBUG = GG.Checker.Number(GG.Env.DEBUG, 0)
GG.Env.DEBUG_FPS = GG.Checker.Bool(GG.Env.DEBUG_FPS, false)
GG.Env.DEBUG_MEM = GG.Checker.Bool(GG.Env.DEBUG_MEM, false)

local CURRENT_MODULE_NAME = ...

cc = cc or {}
cc.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)

require(cc.PACKAGE_NAME .. ".functions")

GG.Console.P("# DEBUG = " .. GG.Env.DEBUG)

GG.Requires(cc.PACKAGE_NAME .. ".device")
GG.Requires(cc.PACKAGE_NAME .. ".display")

audio = require(cc.PACKAGE_NAME .. ".audio")
network = require(cc.PACKAGE_NAME .. ".network")
crypto = require(cc.PACKAGE_NAME .. ".crypto")
json = require(cc.PACKAGE_NAME .. ".json")
require(cc.PACKAGE_NAME .. ".shortcodes")
require(cc.PACKAGE_NAME .. ".NodeEx")
require(cc.PACKAGE_NAME .. ".WidgetEx")

if GG.Device.platform == "android" then
    require(cc.PACKAGE_NAME .. ".platform.android")
elseif GG.Device.platform == "ios" then
    require(cc.PACKAGE_NAME .. ".platform.ios")
elseif GG.Device.platform == "mac" then
    require(cc.PACKAGE_NAME .. ".platform.mac")
end

local sharedTextureCache = cc.Director:getInstance():getTextureCache()
local sharedDirector = cc.Director:getInstance()

if GG.Env.DEBUG_FPS then
    sharedDirector:setDisplayStats(true)
else
    sharedDirector:setDisplayStats(false)
end

if GG.Env.DEBUG_MEM then
    local function showMemoryUsage()
        GG.Console.LF(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
        GG.Console.LF(sharedTextureCache:getCachedTextureInfo())
        GG.Console.LF("---------------------------------------------------")
    end
    sharedDirector:getScheduler():scheduleScriptFunc(showMemoryUsage, GG.Env.DEBUG_MEM_INTERVAL or 10.0, false)
end

-- export global variable
local __g = _G
cc.exports = {}
setmetatable(cc.exports, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,

    __index = function(_, name)
        return rawget(__g, name)
    end
})

-- disable create unexpected global variable
function cc.disable_global()
    setmetatable(__g, {
        __newindex = function(_, name, value)
            error(string.format("USE \" cc.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
        end
    })
end
