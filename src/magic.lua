-- Lua错误跟踪
local function CatchLuaError(err)
    GG.Console.E(tostring(err), debug.traceback("", 2))
end

-- 创造一个初始化之后就无法被修改的table
local function ReadOnlyTable(t)
    t = t or {}
    setmetatable(t, {
        __newindex = function()
            CatchLuaError(string.format("table [%s] is readonly", t.__name or tostring(t)))
        end
    })
    return t
end

-- 魔法系列
local Magic = {
    __name = "GG.Magic",
    __version = "0.0.1",
    ReadOnlyTable = ReadOnlyTable,
    CatchLuaError = CatchLuaError,
    __Init = function()
        _G.__G__TRACKBACK__ = CatchLuaError
    end
}

if _G.__GG_HINT__ then
    GG.Magic = Magic
end

return {
    Magic = Magic
}
