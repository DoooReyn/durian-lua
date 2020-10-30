--[[
Provide query of device related properties and access to device functions 

device.platform: ios, android, mac, linux, windows.
device.model: unknown, iphone, ipad
device.language: en, cn, fr, it, gr, sp, ru, kr, jp, hu, pt, ar
device.writablePath
device.directorySeparator: on Windows is "\", other system is "/"
device.pathSeparator: on Windows is ";", other system is ":"
device.getOpenUDID()
device.openURL(url)
]]--

local device = {}

device.platform    = "unknown"
device.model       = "unknown"

local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    device.platform = "windows"
elseif target == cc.PLATFORM_OS_LINUX then
    device.platform = "linux"
elseif target == cc.PLATFORM_OS_MAC then
    device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    device.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        device.model = "iphone"
    else
        device.model = "ipad"
    end
end

local language_ = sharedApplication:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
else
    language_ = "en"
end

device.language = language_
device.writablePath = cc.FileUtils:getInstance():getWritablePath()
device.directorySeparator = "/"
device.pathSeparator = ":"
if device.platform == "windows" then
    device.directorySeparator = "\\"
    device.pathSeparator = ";"
end

GG.Console.P("#")
GG.Console.P("# device.platform              = " .. device.platform)
GG.Console.P("# device.model                 = " .. device.model)
GG.Console.P("# device.language              = " .. device.language)
GG.Console.P("# device.writablePath          = " .. device.writablePath)
GG.Console.P("# device.directorySeparator    = " .. device.directorySeparator)
GG.Console.P("# device.pathSeparator         = " .. device.pathSeparator)
GG.Console.P("#")

function device.getOpenUDID()
    local ret = cc.Device:getOpenUDID()
    if GG.Env.DEBUG > 1 then
        GG.Console.LF("device.getOpenUDID() - Open UDID: %s", tostring(ret))
    end
    return ret
end

function device.openURL(url)
    if GG.Env.DEBUG > 1 then
        GG.Console.LF("device.openURL() - url: %s", tostring(url))
    end
    sharedApplication:openURL(url)
end

GG.Device = device
