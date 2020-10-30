-- 添加lua搜索路径
package.path = "src/?.lua;src/framework/protobuf/?.lua"

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
local __self_defined__ = StrsAsKey {"Display", "Device", "Crypto", "Json", "Luaj", "Luaoc", "Audio", "Network", "S_App",
                                    "S_Director", "S_Texture", "S_Scheduler", "S_EventDipatcher", "S_SpriteFrame",
                                    "S_Animation", "S_Application", "S_FileUtils"}

-- 区别于quick的全局
_G.GG = setmetatable({
    -- 框架介绍
    Framework = {
        Engine = "Quick4.0.1",
        Name = "Durian",
        Version = "0.0.1",
        Author = "DoooReyn",
        Lua = "5.3.4"
    },
    -- 是否存在全局变量
    Exists = function(k)
        return rawget(GG, k) ~= nil
    end,
    -- 挂载并初始化模块
    Mount = function(k, v)
        local istable = type(v) == "table"
        if not istable then
            return
        end
        if not getmetatable(v) then
            setmetatable(v, {
                __tostring = function(self)
                    local name = self.__name or self.__cname or self.Name or k
                    local version = self.__version or self.Version or "unknown"
                    return ("[v%s] %s"):format(version, name)
                end
            })
        end
        if v.__Init and type(v.__Init) == "function" then
            print(("`GG`: Init module '%s'."):format(k))
            v.__Init(v)
        end
    end,
    -- 挂载全局变量
    Exports = function(globals)
        if type(globals) ~= "table" then
            local msg = ("`Exports`: expects table, but got %s."):format(type(globals))
            print(debug.traceback(msg, 2))
            return
        end

        for k, v in pairs(globals) do
            if GG.Exists(k) then
                print(("`Exports`: GG[%s] exists!"):format(k))
            else
                rawset(GG, k, v)
                GG.Mount(k, v)
            end
        end
    end,
    -- 删除全局变量
    Deletes = function(...)
        for _, k in ipairs({...}) do
            if type(k) == "string" then
                local raw = rawget(GG, k)
                if raw ~= nil then
                    rawset(GG, k, nil)
                end
            end
        end
    end,
    -- 导入全局变量
    Requires = function(...)
        for _, v in ipairs({...}) do
            local state, globals = pcall(require, v)
            if state then
                local info = debug.getinfo(2, "Sl")
                print(("`Requires`: '%s' from file '%s' at line[%s]."):format(v, info.source, info.currentline))
                if type(globals) == "table" then
                    GG.Exports(globals)
                end
            else
                print(("`Requires`: '%s' not exists."):format(v))
            end
        end
    end
}, {
    __newindex = function(self, k, v)
        if __sys_defined__[k] or __self_defined__[k] then
            rawset(self, k, v)
            return
        end
        error(("`GG`: Can not set GG[%s] directly, please predefine it instead."):format(k), 2)
    end
})

-- 禁止挂载到全局
local __g = _G
setmetatable(__g, {
    __newindex = function(_, _, _)
        print(debug.traceback("", 2))
        error("Can not mount variable to _G", 0)
    end
})

-- 引入全局模块，注意引入顺序
-- 优先加载cocos
-- 其次使用durian
-- 最后是quick
GG.Requires("cocos.init")
GG.Requires("durian.magic", "durian.checker", "durian.console", "durian.env", "durian.vec")
GG.Requires("framework.init")
-- GG.Run()

-- 程序入口
require("app.MyApp").new():run()
