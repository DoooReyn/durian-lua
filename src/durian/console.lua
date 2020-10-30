-- 控制台输出条目id
local NextID = GG.Magic.GenerateID(8086)

-- 控制台输出
local Console = {
    -- 名称
    __name = "GG.Console",

    -- 版本
    __version = "0.0.1",

    -- 主题
    __theme = "color f0",

    -- 控制台输出标记
    Tag = {
        Warn = "WARN",
        Log = "INFO",
        Error = "ERROR"
    }
}

-- 控制台初始化
function Console.__Init()
    if GG.S_Application:getTargetPlatform() == 0 then
        os.execute(Console.__theme)
    end
end

-- 打印输出
function Console.P(...)
    print(...)
end

-- 打印格式化输出
function Console.PF(...)
    print(GG.Magic.Format(...))
end

-- 输出标记为group的信息
function Console.G(group, ...)
    local id = NextID()
    Console.P(string.format("==> %d [%s]", id, group))
    Console.P(...)
    Console.P(string.format("<== %d [%s]\n", id, group))
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

-- 输出标记为Log的信息
function Console.LF(...)
    Console.G(Console.Tag.Log, GG.Magic.Format(...))
end

-- 输出标记为Warn的信息
function Console.WF(...)
    Console.G(Console.Tag.Warn, GG.Magic.Format(...))
end

-- 输出标记为Error的信息
function Console.EF(...)
    Console.G(Console.Tag.Error, GG.Magic.Format(...))
end

-- 数据转换为字符串
local function _tostring(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

-- 打印lua数据结构
function Console.Dump(value, desciption, nesting)
    if type(nesting) ~= "number" then
        nesting = 3
    end

    local lookupTable = {}
    local result = {}

    local function _dump(_value, _desciption, _indent, _nest, _keylen)
        _desciption = _desciption or "<var>"
        local spc = ""
        if type(_keylen) == "number" then
            spc = string.rep(" ", _keylen - string.len(_tostring(_desciption)))
        end
        if type(_value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", _indent, _tostring(_desciption), spc, _tostring(_value))
        elseif lookupTable[_value] then
            result[#result + 1] = string.format("%s%s%s = *REF*", _indent, _desciption, spc)
        else
            lookupTable[_value] = true
            if _nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", _indent, _desciption)
            else
                result[#result + 1] = string.format("%s%s = {", _indent, _tostring(_desciption))
                local indent2 = _indent .. "    "
                local keys = {}
                local key_len = 0
                local values = {}
                for k, v in pairs(_value) do
                    keys[#keys + 1] = k
                    local vk = _tostring(k)
                    local vkl = string.len(vk)
                    if vkl > key_len then
                        key_len = vkl
                    end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for _, k in ipairs(keys) do
                    _dump(values[k], k, indent2, _nest + 1, key_len)
                end
                result[#result + 1] = string.format("%s}", _indent)
            end
        end
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    Console.P("Dump from: " .. string.trim(traceback[3]))
    _dump(value, desciption, "- ", 1)

    for _, line in ipairs(result) do
        Console.P(line)
    end
end

GG.Console = Console
