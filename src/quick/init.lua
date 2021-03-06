GG.Console.P("===========================================================")
GG.Console.P("              LOAD Cocos2d-Lua-Community FRAMEWORK")
GG.Console.P("===========================================================")

cc = cc or {}
GG.Env.DEBUG = GG.Checker.Number(GG.Env.DEBUG, 0)
GG.Env.DEBUG_FPS = GG.Checker.Bool(GG.Env.DEBUG_FPS, false)
GG.Env.DEBUG_MEM = GG.Checker.Bool(GG.Env.DEBUG_MEM, false)

GG.Console.P("# DEBUG = " .. GG.Env.DEBUG)
GG.Requires("quick.Functions", "quick.ToLuaEx", "quick.Device", "quick.Display", "quick.Scheduler", "quick.Audio", "quick.Network",
    "quick.Crypto", "quick.Json", "quick.Shortcodes", "quick.NodeEx", "quick.WidgetEx")

if GG.Device.IsAndroid then
    GG.Requires("quick.platform.Luaj")
elseif GG.Device.IsIos or GG.Device.IsMac then
    GG.Requires("quick.platform.Luaoc")
end

GG.S_Director:setDisplayStats(GG.Checker.Bool(GG.Env.DEBUG_FPS))

if GG.Env.DEBUG_MEM then
    local function showMemoryUsage()
        GG.Console.P("---------------------------------------------------")
        GG.Console.PF("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count"))
        GG.Console.P(GG.S_Texture:getCachedTextureInfo())
    end
    GG.S_Director:getScheduler():scheduleScriptFunc(showMemoryUsage, GG.Env.DEBUG_MEM_INTERVAL or 10.0, false)
end
