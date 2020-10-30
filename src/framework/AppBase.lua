local AppBase = GG.Magic.Class("AppBase")

function AppBase:ctor()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function()
        Rapid2D_CAudio.pause() -- stop OpenAL backend thread
        self:onEnterBackground()
    end)
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function()
        Rapid2D_CAudio.resume() -- start OpenAL backend thread
        self:onEnterForeground()
    end)
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

    -- set global app
    GG.S_App = self
end

function AppBase:run()
end

function AppBase:exit()
    cc.Director:getInstance():endToLua()
    if GG.Device.platform == "windows" or GG.Device.platform == "mac" then
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
