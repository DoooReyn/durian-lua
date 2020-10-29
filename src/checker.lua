-- Checker: 类型和参数检查器
local Checker = {
    __name = "GG.Checker",
    __version = "0.0.1"
}

-- 基础数据类型
Checker.DataType = {
    Nil = "nil",
    Boolean = "boolean",
    Number = "number",
    String = "string",
    Table = "table",
    UserData = "userdata",
    Thread = "thread"
}

-- 获取值类型
function Checker.Type(v)
    return tolua.type(v)
end

-- 检测值类型
function Checker.TypeOf(v, t)
    return tolua.type(v) == t
end

-- 是否nil值
function Checker.IsNil(v)
    return Checker.TypeOf(v, Checker.DataType.Nil)
end

-- 如果v是nil值则返回默认值d
function Checker.Nil(v, d)
    return Checker.IsNull(v) and d or nil
end

-- 是否null值
function Checker.IsNull(v)
    return tolua.is_null(v)
end

-- 如果v是null值则返回默认值d
function Checker.Null(v, d)
    return Checker.IsNull(v) and d or nil
end

-- 是否bool值
function Checker.IsBool(v)
    return Checker.TypeOf(v, Checker.DataType.Boolean)
end

-- 如果v是bool值则返回默认值d
function Checker.Bool(v, d)
    return Checker.IsBool(v) and v or (not not d)
end

-- 是否number
function Checker.IsNumber(v)
    return Checker.TypeOf(v, Checker.DataType.Number)
end

-- 如果v是number则返回默认值d
function Checker.Number(v, d)
    return Checker.IsNumber(v) and v or (tonumber(d) or 0)
end

-- 转换为整型数值
function Checker.Int(v)
    return math.round(GG.Checker.Number(v))
end

-- 是否string
function Checker.IsString(v)
    return Checker.TypeOf(v, Checker.DataType.String)
end

-- 如果v是string则返回默认值d
function Checker.String(v, d)
    return Checker.IsString(v) and v or tostring(d)
end

-- 是否table
function Checker.IsTable(v)
    return Checker.TypeOf(v, Checker.DataType.Table)
end

-- 如果v是table则返回默认值d
function Checker.Table(v, d)
    return Checker.IsTable(v) and v or (Checker.IsTable(d) and d or {})
end

-- 是否thread
function Checker.IsThread(v)
    return Checker.TypeOf(v, Checker.DataType.Thread)
end

-- 是否userdata
function Checker.IsUserData(v)
    return type(v) == Checker.DataType.UserData
end

-- 是否存在字段
function Checker.IsKeyExists(hashtable, key)
    local t = type(hashtable)
    return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

-- 检查对象类型是否匹配
function Checker.KindOf(obj, classname)
    local t = type(obj)
    local mt
    if t == "table" then
        mt = getmetatable(obj)
    elseif t == "userdata" then
        mt = tolua.getpeer(obj)
    end

    while mt do
        if mt.__cname == classname then
            return true
        end
        mt = mt.super
    end

    return false
end

-- 对参数列表进行或运算检测
function Checker.Or(v, ...)
    local result = false
    for _, p in ipairs({...}) do
        if v == p then
            result = true
            break
        end
    end
    return result
end

-- 对参数列表进行与运算检测
function Checker.And(v, ...)
    local result = true
    for _, p in ipairs({...}) do
        if v ~= p then
            result = false
            break
        end
    end
    return result
end

if _G.__GG_HINT__ then
    GG.Checker = Checker
end

return {
    Checker = Checker
}
