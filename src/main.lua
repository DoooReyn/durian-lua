-- 添加lua搜索路径
package.path = "src/?.lua;src/quick/protobuf/?.lua"

-------------------------------------------------------------------------------------
-- 构建全局模块GG
-------------------------------------------------------------------------------------

-- 字符串数组映射为字符串字典
local function _strsAsKey(t)
    local r = {}
    for _, v in ipairs(t) do
        if type(v) == "string" then
            r[v] = true
        end
    end
    return r
end

-- 导入模块
local function _require(path)
    local state, globals = pcall(require, path)
    if state then
        local info = debug.getinfo(2, "Sl")
        print(("`Requires`: '%s' from file '%s' at line[%s]."):format(path, info.source, info.currentline))
    else
        error(("`Requires`: '%s' not exists."):format(path), 2)
    end
    return globals
end

-- 由系统保留的全局变量名称集合
local __sys_defined__ = _strsAsKey {"Framework", "Exists", "Exports", "Deletes", "Requires", "Console", "Magic",
                                    "Checker", "Env", "Vec", "v2", "v3"}

-- 由用户自定义的全局变量名称集合
local __self_defined__ = _strsAsKey {"Display", "Device", "Crypto", "Json", "Luaj", "Luaoc", "Audio", "Network",
                                     "S_App", "S_Director", "S_Texture", "S_EventDipatcher", "S_Scheduler",
                                     "S_SpriteFrame", "S_Animation", "S_Application", "S_FileUtils", "S_UserDefault"}

-- 区别于quick的全局
local _G = _G
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
        if select("#", ...) == 1 then
            local path = select(1, ...)
            return _require(path)
        end
        for _, path in ipairs({...}) do
            _require(path)
        end
    end
}, {
    __newindex = function(self, k, v)
        if __sys_defined__[k] or __self_defined__[k] then
            rawset(self, k, v)
            if v and type(v) == "table" and v.__Init and type(v.__Init) == "function" then
                v.__Init(v)
            end
            return
        end
        error(("`GG`: Can not set GG[%s] directly, please predefine it instead."):format(k), 2)
    end
})

-- 禁止挂载到全局
_G.__G__TRACKBACK__ = function()
end
setmetatable(_G, {
    __newindex = function(_, k, _)
        print(debug.traceback("", 2))
        error(("Can not mount variable [%s] to _G"):format(k), 0)
    end
})

-- 挂载cc单例对象
GG.S_Director = cc.Director:getInstance()
GG.S_Texture = GG.S_Director:getTextureCache()
GG.S_EventDipatcher = GG.S_Director:getEventDispatcher()
GG.S_SpriteFrame = cc.SpriteFrameCache:getInstance()
GG.S_Animation = cc.AnimationCache:getInstance()
GG.S_Application = cc.Application:getInstance()
GG.S_FileUtils = cc.FileUtils:getInstance()
GG.S_UserDefault = cc.UserDefault:getInstance()

-------------------------------------------------------------------------------------
-- 引入全局模块
-- 优先加载cocos
-- 其次使用durian
-- 最后是quick
-- 可以视情况自行删减
-------------------------------------------------------------------------------------
GG.Requires("durian.env")
GG.Requires("cocos.init")
GG.Requires("durian.magic", "durian.checker", "durian.console", "durian.vec")
GG.Requires("quick.init")

-------------------------------------------------------------------------------------
-- 搜索路径
-------------------------------------------------------------------------------------
if not GG.S_FileUtils:isDirectoryExist("cache/") then
    GG.S_FileUtils:createDirectory("cache/")
end
GG.S_FileUtils:setWritablePath("cache/")
GG.S_FileUtils:addSearchPath("cache/")
GG.S_FileUtils:addSearchPath("cache/res/")
GG.S_FileUtils:addSearchPath("res/")

-------------------------------------------------------------------------------------
-- 进入游戏
-------------------------------------------------------------------------------------
GG.Requires("app.MyApp").new():run()
