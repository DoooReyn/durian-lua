-- 添加lua搜索路径
package.path = "src/?.lua;src/durian/?.lua;src/framework/protobuf/?.lua"

-- 消息提示
local Msg = {
    RequiresOk = "`Requires`: '%s' from file '%s' at line[%s].",
    RequiresFail = "`Requires`: '%s' not exists.",
    SetGlobal = "`GG`: Can not set GG[%s] directly, please predefine it instead.",
    MountModule = "[v%s] %s",
    ModuleInit = "`GG`: Init global module '%s'.",
    ExportsFail = "`Exports`: expects table, but got %s.",
    ExportsExist = "`Exports`: GG[%s] exists!"
}

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

-- 由系统保留的全局变量名称集合
local __sys_defined__ = StrsAsKey {"Framework", "Exists", "Exports", "Deletes", "Requires", "Console", "Magic",
                                   "Checker", "Env", "Vec", "v2", "v3"}

-- 由用户自定义的全局变量名称集合
local __self_defined__ = StrsAsKey {"Display", "Device", "Crypto", "Json", "Luaj", "Luaoc", "Audio",
                                    "Network", "S_App", "S_Director", "S_Texture", "S_Scheduler", "S_EventDipatcher"}

-- 区别于quick的全局
_G.GG = {}
setmetatable(GG, {
    __newindex = function(self, k, v)
        if __sys_defined__[k] or __self_defined__[k] then
            rawset(self, k, v)
            return
        end
        print(Msg.SetGlobal:format(k))
    end
})

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
                return Msg.MountModule:format(version, name)
            end
        })
    end
    if v.__Init and type(v.__Init) == "function" then
        print(Msg.ModuleInit:format(k))
        v.__Init(v)
    end
end

-- 挂载全局变量
local function Exports(globals)
    if type(globals) ~= "table" then
        print(debug.traceback(Msg.ExportsFail:format(type(globals)), 2))
        return
    end

    for k, v in pairs(globals) do
        if Exists(k) then
            print(Msg.ExportsExist:format(k))
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
            local info = debug.getinfo(2, "Sl")
            print(Msg.RequiresOk:format(v, info.source, info.currentline))
            if type(globals) == "table" then
                Exports(globals)
            end
        else
            print(Msg.RequiresFail:format(v))
        end
    end
end

-- 导出框架
local Framework = {
    Engine = "Quick4.0.1",
    Name = "Durian",
    Version = "0.0.1",
    Author = "DoooReyn"
}

GG.Framework = Framework
GG.Exists = Exists
GG.Exports = Exports
GG.Deletes = Deletes
GG.Requires = Requires

-- 加载全局模块
GG.Requires("magic", "checker", "console", "env", "vec")

-- 程序入口
require("app.MyApp").new():run()

GG.Console.Dump(GG, "GG", 1)
