GG.Console.P("===========================================================")
GG.Console.P("              LOAD Cocos2d-Lua-Community FRAMEWORK")
GG.Console.P("===========================================================")

cc = cc or {}
GG.Env.DEBUG = GG.Checker.Number(GG.Env.DEBUG, 0)
GG.Env.DEBUG_FPS = GG.Checker.Bool(GG.Env.DEBUG_FPS, false)
GG.Env.DEBUG_MEM = GG.Checker.Bool(GG.Env.DEBUG_MEM, false)

local CURRENT_MODULE_NAME = ...
cc.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)
GG.Console.P("# DEBUG = " .. GG.Env.DEBUG)
GG.Requires(cc.PACKAGE_NAME .. ".functions")
GG.Requires(cc.PACKAGE_NAME .. ".device")
GG.Requires(cc.PACKAGE_NAME .. ".display")
GG.Requires(cc.PACKAGE_NAME .. ".audio")
GG.Requires(cc.PACKAGE_NAME .. ".network")
GG.Requires(cc.PACKAGE_NAME .. ".crypto")
GG.Requires(cc.PACKAGE_NAME .. ".json")
GG.Requires(cc.PACKAGE_NAME .. ".shortcodes")
GG.Requires(cc.PACKAGE_NAME .. ".NodeEx")
GG.Requires(cc.PACKAGE_NAME .. ".WidgetEx")
if GG.Checker.Or(GG.Device.platform, "android") then
    GG.Requires(cc.PACKAGE_NAME .. ".platform.luaj")
elseif GG.Checker.Or(GG.Device.platform, "ios", "mac") then
    GG.Requires(cc.PACKAGE_NAME .. ".platform.luaoc")
end

local S_Director = cc.Director:getInstance()
local S_Texture = S_Director:getTextureCache()
local S_EventDipatcher = S_Director:getEventDispatcher()
local S_Scheduler = S_Director:getScheduler()
S_Director:setDisplayStats(GG.Checker.Bool(GG.Env.DEBUG_FPS))

if GG.Env.DEBUG_MEM then
    local function showMemoryUsage()
        GG.Console.P("---------------------------------------------------")
        GG.Console.PF("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count"))
        GG.Console.P(S_Texture:getCachedTextureInfo())
        GG.Console.P("---------------------------------------------------")
    end
    S_Scheduler:scheduleScriptFunc(showMemoryUsage, GG.Env.DEBUG_MEM_INTERVAL or 10.0, false)
end

-- disable mount global variable
local __g = _G
setmetatable(__g, {
    __newindex = function(_, _, _)
        print(debug.traceback("", 2))
        error("Can not mount variable to _G", 0)
    end
})

if _G.__GG_HINT__ then
    GG.S_Director = S_Director
    GG.S_Texture = S_Texture
    GG.S_Scheduler = S_Scheduler
    GG.S_EventDipatcher = S_EventDipatcher
end

GG.Exports({
    S_Director = S_Director,
    S_Texture = S_Texture,
    S_Scheduler = S_Scheduler,
    S_EventDipatcher = S_EventDipatcher
})
