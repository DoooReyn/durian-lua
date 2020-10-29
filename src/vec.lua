local GG = _G.GG

-- 定长数值数组
local Vec

-- 转换为字符串
local tostr = function(self)
    local len = self.size
    local ret = {"GG.Vec(" .. len .. "): "}
    ret[#ret + 1] = "{"
    for _, v in ipairs(self) do
        ret[#ret + 1] = v .. (_ < len and ", " or "")
    end
    ret[#ret + 1] = "}"
    return table.concat(ret)
end

-- 相等操作
local equal = function(self, other)
    if self.size == other.size then
        for i, v in ipairs(self) do
            if v ~= other[i] then
                return false
            end
        end
        return true
    end
    return false
end

-- 相加操作
local add = function(self, other)
    local ret = {}
    for i, v in ipairs(self) do
        ret[i] = v + (other[i] or 0)
    end
    return Vec(unpack(ret))
end

-- 相减操作
local sub = function(self, other)
    local ret = {}
    for i, v in ipairs(self) do
        ret[i] = v - (other[i] or 0)
    end
    return Vec(unpack(ret))
end

-- 相除操作
local div = function(self, other)
    local ret = {}
    for i, v in ipairs(self) do
        ret[i] = v / (other[i] or 1)
    end
    return Vec(unpack(ret))
end

-- 相乘操作
local mul = function(self, other)
    local ret = {}
    for i, v in ipairs(self) do
        ret[i] = v * (other[i] or 1)
    end
    return Vec(unpack(ret))
end

-- 取余操作
local mod = function(self, other)
    local ret = {}
    for i, v in ipairs(self) do
        ret[i] = v % (other[i] or 1)
    end
    return Vec(unpack(ret))
end

-- 赋值
local newindex = function(self, k, v)
    if GG.Checker.IsNumber(k) and k > 0 and k <= self.size then
        self[k] = v
    end
end

-- 索引
local search_index = function(self, k)
    if GG.Checker.IsNumber(k) and k > 0 and k <= self.size then
        return self[k]
    end
end

-- 调用
local call = function(self, index)
    return self[index]
end

Vec = function(...)
    local vec = {...}
    local len = #vec
    for i, v in ipairs(vec) do
        vec[i] = GG.Checker.Number(v, 0)
    end
    vec.__name = "GG.Vec"
    vec.__version = "0.0.1"
    vec.equal = equal
    vec.size = len
    vec.str = tostr
    setmetatable(vec, {
        __call = call,
        __index = search_index,
        __newindex = newindex,
        __tostring = tostr,
        __eq = equal,
        __add = add,
        __sub = sub,
        __div = div,
        __mul = mul,
        __mod = mod
    })
    return vec
end

--[[ test
local v1 = Vec(1)
local v2 = Vec(1)
local v3 = Vec(1,2,3,false)
local v4 = Vec(1,2,3,true)
local t1 = v1:equal(v2)
local t2 = v3 == v4
print(v1.str, v2.str, v3.str, v4.str, t1, t2)
]]

return Vec
