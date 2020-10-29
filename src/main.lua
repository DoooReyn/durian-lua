-- 添加lua搜索路径
package.path = "src/?.lua;src/framework/protobuf/?.lua"

-- GG提示，忽略
_G.__GG_HINT__ = false

-- 区别于quick的全局
_G.GG = {}
setmetatable(GG, {
    __newindex = function()
        print("Can not change any value directly, please use `Exports/Deletes` instead.")
    end
})

-- 空函数
local function Idle()
end

-- 打印输出
local function Print(...)
    (GG.Console and GG.Console.P or print)(...)
end

-- 格式化打印输出
local function Printf(fmt, ...)
    Print(fmt:format(...))
end

-- 格式化打印错误输出
local function PrintEF(fmt, ...)
    (GG.Console and GG.Console.EF or Printf)(fmt, ...)
end

-- 是否存在全局变量
local function Exists(k)
    return rawget(GG, k) ~= nil
end

-- 挂载并初始化模块
local function Mount(k, v)
    local istable = type(v) == "table"
    if not istable then
        return
    end
    if not getmetatable(v) then
        setmetatable(v, {
            __tostring = function(self)
                local name = self.__name or self.Name or k
                local version = self.__version or self.Version or "unknown"
                local fmt = "[v%s] %s"
                return fmt:format(version, name)
            end
        })
    end
    if v.__Init and type(v.__Init) == "function" then
        Print("Init global module：GG[" .. k .. "]")
        v.__Init(v)
    end
end

-- 挂载全局变量
local function Exports(globals)
    if type(globals) ~= "table" then
        Print("`Exports` expects table, but got " .. type(globals))
        return
    end

    for k, v in pairs(globals) do
        if Exists(k) then
            PrintEF("GG[%s] exists!", k)
        else
            rawset(GG, k, v)
            Mount(k, v)
        end
    end
end

-- 删除全局变量
local function Deletes(...)
    for _, k in ipairs({...}) do
        if type(k) == "string" then
            local raw = rawget(GG, k)
            if raw ~= nil then
                rawset(GG, k, nil)
            end
        end
    end
end

-- 导入全局变量
local function Requires(...)
    for _, v in ipairs({...}) do
        local state, globals = pcall(require, v)
        if state then
            Exports(globals)
        else
            PrintEF("`Requires` path [%s] not exists", v)
        end
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

-- 导出框架
Exports({
    Framework = {
        Engine = "Quick4.0.1",
        Name = "Durian",
        Version = "0.0.1",
        Author = "DoooReyn"
    },
    Idle = Idle,
    Class = Class,
    Exists = Exists,
    Exports = Exports,
    Deletes = Deletes,
    Requires = Requires
})

-- 加载全局模块
GG.Requires("checker", "console", "magic", "env", "vec")

-- 程序入口
require("app.MyApp").new():run()

GG.Console.Dump(GG)
