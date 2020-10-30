GG.Console.P("===========================================================")
GG.Console.P("              LOAD Cocos2d-Lua-Community FRAMEWORK")
GG.Console.P("===========================================================")

cc = cc or {}
GG.Env.DEBUG = GG.Checker.Number(GG.Env.DEBUG, 0)
GG.Env.DEBUG_FPS = GG.Checker.Bool(GG.Env.DEBUG_FPS, false)
GG.Env.DEBUG_MEM = GG.Checker.Bool(GG.Env.DEBUG_MEM, false)

GG.S_Director = cc.Director:getInstance()
GG.S_Texture = GG.S_Director:getTextureCache()
GG.S_EventDipatcher = GG.S_Director:getEventDispatcher()
GG.S_Scheduler = GG.S_Director:getScheduler()
GG.S_SpriteFrame = cc.SpriteFrameCache:getInstance()
GG.S_Animation = cc.AnimationCache:getInstance()
GG.S_Application = cc.Application:getInstance()
GG.S_FileUtils = cc.FileUtils:getInstance()

GG.S_Director:setDisplayStats(GG.Checker.Bool(GG.Env.DEBUG_FPS))

GG.Console.P("# DEBUG = " .. GG.Env.DEBUG)
GG.Requires("framework.functions", "framework.device", "framework.display", "framework.audio", "framework.network",
    "framework.crypto", "framework.json", "framework.shortcodes", "framework.NodeEx", "framework.WidgetEx")
if GG.Device.IsAndroid then
    GG.Requires("framework.platform.luaj")
elseif GG.Device.IsIos or GG.Device.IsMac then
    GG.Requires("framework.platform.luaoc")
end

if GG.Env.DEBUG_MEM then
    local function showMemoryUsage()
        GG.Console.P("---------------------------------------------------")
        GG.Console.PF("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count"))
        GG.Console.P(GG.S_Texture:getCachedTextureInfo())
    end
    GG.S_Scheduler:scheduleScriptFunc(showMemoryUsage, GG.Env.DEBUG_MEM_INTERVAL or 10.0, false)
end
