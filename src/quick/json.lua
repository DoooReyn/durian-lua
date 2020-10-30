--[[
  JSON encode and decode
]] --

local json = {}
local cjson = GG.Requires("cjson")
json.null = cjson.null

--[[
  Table => JSON string.
  @function encode
  @param table var
  @return string

  example:
  GG.Console.P(json.encode({[3]=2,[5]=3})) -- logout: [null,null,2,null,3]
]]--
function json.encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then
        return result
    end
    if GG.Env.DEBUG > 1 then
        GG.Console.EF("json.encode() - encoding failed: %s", tostring(result))
    end
end

--[[
  JSON string => Table.
  @function decode
  @param string text
  @return table

  example:
  dump(json.decode('[null,null,2,null,3]'))
  - "<var>" = {
  -     3 = 2
  -     5 = 3
  - }
]]--
function json.decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then
        return result
    end
    if GG.Env.DEBUG > 1 then
        GG.Console.EF("json.decode() - decoding failed: %s", tostring(result))
    end
end

GG.Json = json
