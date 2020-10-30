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
]] --

local device = {}

device.platform = "unknown"
device.model = "unknown"
device.IsWin = false
device.IsMac = false
device.IsLinux = false
device.IsAndroid = false
device.IsIos = false
device.IsIphone = false
device.IsIpad = false
device.IsOther = false

-- 平台
local target = GG.S_Application:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    device.platform = "windows"
    device.IsWin = true
elseif target == cc.PLATFORM_OS_LINUX then
    device.platform = "linux"
    device.IsLinux = true
elseif target == cc.PLATFORM_OS_MAC then
    device.platform = "mac"
    device.IsMac = true
elseif target == cc.PLATFORM_OS_ANDROID then
    device.platform = "android"
    device.IsAndroid = true
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    device.platform = "ios"
    device.IsIos = true
    if target == cc.PLATFORM_OS_IPHONE then
        device.model = "iphone"
        device.IsIphone = true
    else
        device.model = "ipad"
        device.IsIpad = true
    end
else
    device.IsOther = true
end

-- 语言
device.IsCn = false
device.IsFr = false
device.IsIt = false
device.IsGr = false
device.IsSp = false
device.IsRu = false
device.IsKr = false
device.IsJp = false
device.IsHu = false
device.IsPt = false
device.IsAr = false
device.IsEn = false
local language_ = GG.S_Application:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
    device.IsCn = true
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
    device.IsFr = true
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
    device.IsIt = true
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
    device.IsGr = true
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
    device.IsSp = true
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
    device.IsRu = true
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
    device.IsKr = true
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
    device.IsJp = true
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
    device.IsHu = true
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
    device.IsPt = true
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
    device.IsAr = true
else
    language_ = "en"
    device.IsEn = true
end

device.language = language_
device.writablePath = GG.S_FileUtils:getWritablePath()
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
    GG.S_Application:openURL(url)
end

GG.Device = device
