local AppBase = GG.Magic.Class("AppBase")

function AppBase:ctor()
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function()
        GG.Audio.pauseAll()
        self:onEnterBackground()
    end)
    GG.S_EventDipatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function()
        GG.Audio.resumeAll()
        self:onEnterForeground()
    end)
    GG.S_EventDipatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

    -- set global app
    GG.S_App = self
end

function AppBase:run()
end

function AppBase:exit()
    GG.S_Director:endToLua()
    if GG.Device.IsWin or GG.Device.IsMac then
        os.exit()
    end
end

function AppBase:enterScene(sceneName, transitionType, time, more, ...)
    local scenePackageName = "app.scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(...)
    GG.Display.replaceScene(scene, transitionType, time, more)
end

function AppBase:createView(viewName, ...)
    local viewPackageName = "app.views." .. viewName
    local viewClass = require(viewPackageName)
    return viewClass.new(...)
end

-- override me
function AppBase:onEnterBackground()
end

-- override me
function AppBase:onEnterForeground()
end

return AppBase
