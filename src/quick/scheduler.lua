--[[
  Global scheduler. This is Not auto loaded module, use following code to load.
  example:
  local scheduler = GG.Requires("quick.scheduler")
]] --

local scheduler = {
    __handles = {}
}

local sharedScheduler = GG.S_Director:getScheduler()

--[[
  Global frame event scheduler, need manually call scheduler.unscheduleGlobal() to stop scheduler.
  @function scheduleUpdateGlobal
  @param function listener
  @return handler
]]--
function scheduler.scheduleUpdateGlobal(listener)
    local handle = sharedScheduler:scheduleScriptFunc(listener, 0, false)
    scheduler.__handles:insert(handle)
    return handle
end

--[[
  Global scheduler with interval, need manually call scheduler.unscheduleGlobal() to stop scheduler.
  @function scheduleGlobal
  @param function listener
  @param integer interval
  @return handler
]]--
function scheduler.scheduleGlobal(listener, interval)
    local handle = sharedScheduler:scheduleScriptFunc(listener, interval, false)
    table.insert(scheduler.__handles, handle)
    return handle
end

--[[
  Stop a global scheduler.
  @function unscheduleGlobal
  @param function handler
]]--
function scheduler.unscheduleGlobal(handle, manually)
    sharedScheduler:unscheduleScriptEntry(handle)
    if manually then
        return
    end
    table.removebyvalue(scheduler.__handles, handle)
end

--[[
  Stop a global scheduler.
  @function unscheduleGlobal
  @param function handler
]]--
function scheduler.unscheduleGlobalAll()
    table.walk(scheduler.__handles, function(handle)
        sharedScheduler:unscheduleScriptEntry(handle)
    end)
    scheduler.__handles = {}
end

--[[
  Start a delay call by Global scheduler, NO need do stop manually,
  but can cancel before timeout by scheduler.unscheduleGlobal().
  @function scheduleGlobal
  @param function listener
  @param integer interval
  @return handler
]]--
function scheduler.performWithDelayGlobal(listener, time)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        scheduler.unscheduleGlobal(handle, true)
        listener()
    end, time, false)
    return handle
end

GG.S_Scheduler = scheduler
