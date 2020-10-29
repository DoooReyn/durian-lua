-- >>>>>> math <<<<<<--
--[[
  get a value between min_inclusive and max_inclusive.
  @function math.clamp
]]
function math.clamp(value, min_inclusive, max_inclusive)
    if min_inclusive > max_inclusive then
        min_inclusive, max_inclusive = max_inclusive, min_inclusive
    end
    return math.max(math.min(max_inclusive, value), min_inclusive)
end

--[[
  Initialize random seed according to system time.
  @function math.newrandomseed
]]--
function math.newrandomseed()
    local ok, socket = pcall(function()
        return require("socket")
    end)

    if ok then -- Luasocket's gettime return microsecond
        math.randomseed(socket.gettime())
    else
        math.randomseed(os.time())
    end
    math.random()
    math.random()
    math.random()
    math.random()
end

--[[
  Rounding value, if not a number, return 0.
  @function math.round
  @param mixed value
  @return number
]]--
function math.round(value)
    value = GG.Checker.Number(value)
    return math.floor(value + 0.5)
end

--[[
  @see math.rad()
]]--
function math.angle2radian(angle)
    return angle * math.pi / 180
end

--[[
  @see math.deg()
]]--
function math.radian2angle(radian)
    return radian / math.pi * 180
end

-- >>>>>> io <<<<<<--

--[[
  Check if path exists.
  @function io.exists
  @param string path
  @return boolean

  example:
  local path = cc.FileUtils:getInstance():fullPathForFilename("data.txt")
  if io.exists(path) then
    GG.Console.P("exists")
  end
]]--
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

--[[
  Read whole file into memory.
  @function io.readfile
  @param string path
  @return string

  example:
  local path = cc.FileUtils:getInstance():fullPathForFilename("data.txt")
  local buf = io.readfile(path)
]]--
function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

--[[
  Write buff into file.
  @function io.writefile
  @param string path
  @param string content
  @param string mode, default is "w+b"
  @return boolean

  example:
  local path = GG.Device.writablePath .. "data.txt"
  io.writefile(path, "this is a buffer")
]]--
function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end

--[[
  Decompose path info.
  @function io.pathinfo
  @param string path
  @return table, {dirname, filename, basename, extname}
]]--
function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

--[[
  Get file size.
  @function io.filesize
  @param string path
  @return integer
]]--
function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

-- >>>>>> table <<<<<<--

--[[
  Get hashtable size.
  @function table.nums
  @param table t
  @return integer
]]--
function table.nums(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

--[[
  Get table's keys as value in array.
  @function table.keys
  @param table hashtable
  @return table(array)
]]--
function table.keys(hashtable)
    local keys = {}
    for k, _ in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

--[[
  Get table's values as value in array.
  @function table.values
  @param table hashtable
  @return table(array)
]]--
function table.values(hashtable)
    local values = {}
    for _, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

--[[
  Merge src table into dest table.
  @function table.merge
  @param table dest
  @param table src
]]--
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[
  Insert src array into dest array.
  @function table.insertto
  @param table dest, must be a array
  @param table src, must be a array
  @param integer begin, insert pos
]]--
function table.insertto(dest, src, begin)
    begin = GG.Checker.Int(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

--[[
  Search value in array, return it's key; if not found, return false
  @function table.indexof
  @param table array, must be a array
  @param mixed value
  @param integer begin, search begin
  @return mixed
]]--
function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return false
end

--[[
  Search value in hashtable, return it's key; if not found, return nil
  @function table.keyof
  @param table hashtable
  @param mixed value
  @return mixed
]]--
function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

--[[
  Safty remove value from array, return the deleted count.
  @function table.removebyvalue
  @param table array, must be a array
  @param mixed value
  @param boolean removeall, if set to true, remove all.
  @return integer
]]--
function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

--[[
  Iterate table, pass value and key to callback, use callback's return as new value.
  @function table.map
  @param table t
  @param function fn
]]--
function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

--[[
  Like table.map, but not change the origin value.
  @function table.walk
  @param table t
  @param function fn
]]--
function table.walk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

--[[
  Iterate table, pass value and key to callback, if callback return false, then delete it from table.
  @function table.filter
  @param table t
  @param function fn
]]--
function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

--[[
  Iterate table, auto remove duplicate values.
  @function table.unique
  @param table t
  @param boolean bArray, if t is array, auto move forward the key.
]]--
function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

-- >>>>>> string <<<<<<--

local _htmlspecialchars_set = {}
_htmlspecialchars_set["&"] = "&amp;"
_htmlspecialchars_set["\""] = "&quot;"
_htmlspecialchars_set["'"] = "&#039;"
_htmlspecialchars_set["<"] = "&lt;"
_htmlspecialchars_set[">"] = "&gt;"

--[[
  Convet string to htmlspecialchars.
  @function string.htmlspecialchars
  @param string input
  @return string

  example:
  GG.Console.P(string.htmlspecialchars("<ABC>")) -- logout: &lt;ABC&gt;
]]--
function string.htmlspecialchars(input)
    for k, v in pairs(_htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

--[[
  Convet htmlspecialchars to string.
  @function string.restorehtmlspecialchars
  @param string input
  @return string

  example:
  GG.Console.P(string.restorehtmlspecialchars("&lt;ABC&gt;")) -- logout: <ABC>
]]--
function string.restorehtmlspecialchars(input)
    for k, v in pairs(_htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

--[[
  Convet \n to <br />.
  @function string.nl2br
  @param string input
  @return string

  example:
  GG.Console.P(string.nl2br("Hello\nWorld")) -- logout: Hello<br />World
]]--
function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

--[[
  Convert string to html string.
  @function string.text2html
  @param string input
  @return string

  example:
  GG.Console.P(string.text2html("<Hello>\nWorld")) -- logout: &lt;Hello&gt;<br />World
]]--
function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

--[[
  Split string into table by delimiter.
  @function string.split
  @param string input
  @param string delimiter
  @return array
]]--
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == '') then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

--[[
  Remove whitespace(space \t \n \r) from the string header.
  @function string.ltrim
  @param string input
  @return string
]]--
function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

--[[
  Remove whitespace(space \t \n \r) from the string tail.
  @function string.rtrim
  @param string input
  @return string
]]--
function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[
  Remove whitespace(space \t \n \r) from the string header and tail.
  @function string.trim
  @param string input
  @return string
]]--
function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[
  Upper fisrt char of the string.
  @function string.ucfirst
  @param string input
  @return string

  example:
  GG.Console.P(string.ucfirst("hello")) -- logout: Hello
]]--
function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

--[[
  Encode string to URL.
  @function string.urlencode
  @param string input
  @return string

  example:
  GG.Console.P(string.urlencode("hello world")) -- logout: hello%20world
]]--
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

--[[
  Decode URL to normal string.
  @function string.urldecode
  @param string input
  @return string

  example:
  GG.Console.P(string.urldecode("hello%20world")) -- logout: hello world
]]--
function string.urldecode(input)
    input = string.gsub(input, "+", " ")
    input = string.gsub(input, "%%(%x%x)", function(h)
        return string.char(tonumber(GG.Checker.Number(h), 16))
    end)
    input = string.gsub(input, "\r\n", "\n")
    return input
end

--[[
  Get word length from utf8 string.
  @function string.utf8len
  @param string input
  @return integer

  example:
  GG.Console.P(string.utf8len("你好World")) -- logout: 7
]]--
function string.utf8len(input)
    local left = string.len(input)
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left > 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--[[
  Format a value as a string containing a thousandth separator.
  @function string.formatnumberthousands
  @param string input
  @return string

  example:
  GG.Console.P(string.formatnumberthousands(1924235)) -- logout: 1,924,235
]]--
function string.formatnumberthousands(num)
    local formatted = tostring(GG.Checker.Number(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end
