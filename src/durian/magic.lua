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

-- 空函数
local function Idle()
end

-- 字符串数组映射为字符串字典
local function StrsAsKey(t)
    local r = {}
    for _, v in ipairs(t) do
        if type(v) == "string" then
            r[v] = true
        end
    end
    return r
end

-- 参数格式化，首个参数应该为格式化文本
local function Format(...)
    local fmt = select(1, ...)
    if type(fmt) == "string" then
        return fmt:format(select(2, ...))
    end
    return ""
end

-- 随机自增长ID
local function GenerateID(seed)
    seed = seed or os.time()
    math.randomseed(seed)
    local id = math.random(seed)
    return function()
        id = id + 1
        return id
    end
end

-- 利用闭包完成对象打包
local function Pack(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

-- 类继承实现
local function Class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
            cls.ctor = function()
            end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {
                __index = super
            })
            cls.super = super
        else
            cls = {
                ctor = function()
                end
            }
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

-- 深度拷贝
local function Clone(object)
    local lookup_table = {}
    local function _copy(_object)
        if type(_object) ~= "table" then
            return _object
        elseif lookup_table[_object] then
            return lookup_table[_object]
        end
        local new_table = {}
        lookup_table[_object] = new_table
        for key, value in pairs(_object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(_object))
    end
    return _copy(object)
end

-- 魔法系列
local Magic = {
    __name = "GG.Magic",
    __version = "0.0.1",
    ReadOnlyTable = ReadOnlyTable,
    CatchLuaError = CatchLuaError,
    Idle = Idle,
    Pack = Pack,
    Class = Class,
    Clone = Clone,
    Format = Format,
    GenerateID = GenerateID,
    StrsAsKey = StrsAsKey,
    __Init = function()
        _G.__G__TRACKBACK__ = CatchLuaError
    end
}

GG.Magic = Magic
