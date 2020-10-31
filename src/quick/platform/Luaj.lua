--[[--
Lua Java reflection
]]
local Luaj = {}
local callJavaStaticMethod = LuaJavaBridge.callStaticMethod

local function checkArguments(args, sig)
    if type(args) ~= "table" then
        args = {}
    end
    if sig then
        return args, sig
    end

    sig = {"("}
    for _, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")V"

    return args, table.concat(sig)
end

--[[
  Lua call Android Java API。
  @function callStaticMethod
  @param string className, Java Class
  @param string methodName, Java Class Static method
  @param table args, method's param
  @param string sig, method's signature
  @return boolean ok, int errorCode (mix return)
        ok is true, call sucess
        ok is false, call fail and errorCode return
]]--
function Luaj.callStaticMethod(className, methodName, args, sig)
    args, sig = checkArguments(args, sig)
    GG.Console.LF("luaj.callStaticMethod(\"%s\",\n\t\"%s\",\n\targs,\n\t\"%s\"", className, methodName, sig)
    return callJavaStaticMethod(className, methodName, args, sig)
end

GG.Luaj = Luaj