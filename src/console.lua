-- 控制台输出条目id
local __cid__ = math.random(os.time())

-- 控制台输出条目id自增长
local function NextID()
    __cid__ = __cid__ + 1
    return __cid__
end

-- 控制台输出
local Console = {
    -- 名称
    __name = "Console",

    -- 版本
    __version = "0.0.1",

    -- 主题
    __theme = "color f0",

    -- 控制台输出标记
    Tag = {
        Warn = "warn",
        Log = "log",
        Error = "error"
    }
}

-- 控制台初始化
function Console.init()
    if cc.Application:getInstance():getTargetPlatform() == 0 then
        os.execute(Console.__theme)
    end
end

-- 输出标记为group的信息
function Console.G(group, ...)
    local id = NextID()
    print(string.format("==> %d [%s]", id, group))
    print(...)
    print(string.format("<== %d [%s]\n", id, group))
end

-- 输出标记为Log的信息
function Console.L(...)
    Console.G(Console.Tag.Log, ...)
end

-- 输出标记为Warn的信息
function Console.W(...)
    Console.G(Console.Tag.Warn, ...)
end

-- 输出标记为Error的信息
function Console.E(...)
    Console.G(Console.Tag.Error, ...)
end

return Console
