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

local Device = {}

Device.platform = "unknown"
Device.model = "unknown"
Device.IsWin = false
Device.IsMac = false
Device.IsLinux = false
Device.IsAndroid = false
Device.IsIos = false
Device.IsIphone = false
Device.IsIpad = false
Device.IsOther = false

-- 平台
local target = GG.S_Application:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    Device.platform = "windows"
    Device.IsWin = true
elseif target == cc.PLATFORM_OS_LINUX then
    Device.platform = "linux"
    Device.IsLinux = true
elseif target == cc.PLATFORM_OS_MAC then
    Device.platform = "mac"
    Device.IsMac = true
elseif target == cc.PLATFORM_OS_ANDROID then
    Device.platform = "android"
    Device.IsAndroid = true
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    Device.platform = "ios"
    Device.IsIos = true
    if target == cc.PLATFORM_OS_IPHONE then
        Device.model = "iphone"
        Device.IsIphone = true
    else
        Device.model = "ipad"
        Device.IsIpad = true
    end
else
    Device.IsOther = true
end

-- 语言
Device.IsCn = false
Device.IsFr = false
Device.IsIt = false
Device.IsGr = false
Device.IsSp = false
Device.IsRu = false
Device.IsKr = false
Device.IsJp = false
Device.IsHu = false
Device.IsPt = false
Device.IsAr = false
Device.IsEn = false
local language_ = GG.S_Application:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
    Device.IsCn = true
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
    Device.IsFr = true
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
    Device.IsIt = true
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
    Device.IsGr = true
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
    Device.IsSp = true
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
    Device.IsRu = true
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
    Device.IsKr = true
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
    Device.IsJp = true
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
    Device.IsHu = true
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
    Device.IsPt = true
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
    Device.IsAr = true
else
    language_ = "en"
    Device.IsEn = true
end

Device.language = language_
Device.writablePath = GG.S_FileUtils:getWritablePath()
Device.directorySeparator = "/"
Device.pathSeparator = ":"
if Device.platform == "windows" then
    Device.directorySeparator = "\\"
    Device.pathSeparator = ";"
end

GG.Console.P("#")
GG.Console.P("# platform              = " .. Device.platform)
GG.Console.P("# model                 = " .. Device.model)
GG.Console.P("# language              = " .. Device.language)
GG.Console.P("# writablePath          = " .. Device.writablePath)
GG.Console.P("# directorySeparator    = " .. Device.directorySeparator)
GG.Console.P("# pathSeparator         = " .. Device.pathSeparator)
GG.Console.P("#")

function Device.getOpenUDID()
    local ret = cc.Device:getOpenUDID()
    if GG.Env.DEBUG > 1 then
        GG.Console.LF("getOpenUDID() - Open UDID: %s", tostring(ret))
    end
    return ret
end

function Device.openURL(url)
    if GG.Env.DEBUG > 1 then
        GG.Console.LF("openURL() - url: %s", tostring(url))
    end
    GG.S_Application:openURL(url)
end

GG.Device = Device
