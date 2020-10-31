local AppBase = GG.Magic.Class("AppBase")

function AppBase:ctor()
    -- 进入后台的时间
    self.__time = nil

    -- 监听进入后台事件
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function()
        self.__time = os.time()
        print("App Enter Background: ", self.__time)
        GG.Audio.pauseAll()
        self:onEnterBackground()
    end)

    -- 监听进入前台事件
    GG.S_EventDipatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function()
        local leave_time = os.time() - self.__time
        self.__time = nil
        print("App Enter Foreground: ", leave_time)
        if GG.Env.APP_TIME_OUT and GG.Env.APP_TIME_OUT > 0 and leave_time >= GG.Env.APP_TIME_OUT then
            GG.S_App:run()
            return
        end
        GG.Audio.resumeAll()
        self:onEnterForeground()
    end)
    GG.S_EventDipatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
end

------------------------------------------------------------
-- 清理资源，慎重使用
------------------------------------------------------------
function AppBase:clear()
    GG.S_Scheduler.unscheduleGlobalAll()
    GG.S_EventDipatcher:removeAllEventListeners()
    GG.S_SpriteFrame:removeUnusedSpriteFrames()
    GG.S_Texture:removeUnusedTextures()
    cc.AnimationCache:destroyInstance()
    GG.S_Animation = cc.AnimationCache:getInstance()
end

function AppBase:run()
    self:clear()
end

function AppBase:exit()
    GG.S_Director:endToLua()
    if GG.Device.IsWin or GG.Device.IsMac then
        os.exit()
    end
end

function AppBase:enterScene(sceneName, transitionType, time, more, ...)
    local scenePackageName = "app.scenes." .. sceneName
    local sceneClass = GG.Requires(scenePackageName)
    local scene = sceneClass.new(...)
    GG.Display.replaceScene(scene, transitionType, time, more)
end

function AppBase:createView(viewName, ...)
    local viewPackageName = "app.views." .. viewName
    local viewClass = GG.Requires(viewPackageName)
    return viewClass.new(...)
end

function AppBase:refresh()

end

-- override me
function AppBase:onEnterBackground()
end

-- override me
function AppBase:onEnterForeground()
end

return AppBase
