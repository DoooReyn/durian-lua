local GG = _G.GG
local Magic = {__name = "Magic", __version = "0.0.1"}

-- 创造一个初始化之后就无法被修改的table
function Magic.ReadOnlyTable(t)
    t = t or {}
    setmetatable(t, {
        __newindex = function()
            Magic.CatchLuaError(string.format("table [%s] is readonly", t.__name or tostring(t)))
        end
    })
    return t
end

-- Lua错误跟踪
function Magic.CatchLuaError(err)
    GG.Console.E(tostring(err), debug.traceback("", 2))
end

return Magic