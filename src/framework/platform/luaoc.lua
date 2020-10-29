--[[--
Lua Objective-c reflection
]]

local luaoc = {}
local callStaticMethod = LuaObjcBridge.callStaticMethod

--[[
  Lua call Objective-C method
  @function callStaticMethod
  @param string className, Objective-C Class name
  @param string methodName, Objective-C Class's static method
  @param table args, method's param
  @return boolean ok, int errorCode (mix return)
        ok is true, call sucess
        ok is false, call fail and errorCode return
]]--

function luaoc.callStaticMethod(className, methodName, args)
    local ok, ret = callStaticMethod(className, methodName, args)
    if not ok then
        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                className, methodName, tostring(args), tostring(ret))
        if ret == -1 then
            GG.Console.EF(msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            GG.Console.EF(msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            GG.Console.EF(msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            GG.Console.EF(msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            GG.Console.EF(msg .. "INVALID METHOD SIGNATURE")
        else
            GG.Console.EF(msg .. "UNKNOWN")
        end
    end
    return ok, ret
end

return luaoc
