-- 环境变量
local Env = {
    -- 名称
    __name = "GG.Env",

    -- 版本
    __version = "0.0.1",

    -- 0 - 正式, 1 - 测试, 2 - 开发
    DEBUG = 2,

    -- 是否显示帧率信息
    DEBUG_FPS = true,

    -- 输出内存信息开关
    DEBUG_MEM = true,

    -- 输出内存信息间隔
    DEBUG_MEM_INTERVAL = 10,

    -- 设计分辨率
    CONFIG_SCREEN_WIDTH = 1136,
    CONFIG_SCREEN_HEIGHT = 640,

    -- 自动适配模式
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH",

    -- 自定义适配方法（如果有需要自行实现，这里就占个坑）
    CONFIG_SCREEN_AUTOSCALE_CALLBACK = nil,

    -- 是否使用spine模块
    USE_SPINE = false,

    -- 是否使用3D模块
    USE_3D = false,

    -- 是否使用手柄模块
    USE_CONTROLLER = false,

    -- 是否使用物理模块
    USE_PHYSICS = false,

    -- 是否使用FairyGUI
    USE_FAIRY_GUI = false
}

-- 是否正式环境
function Env.IsRelease()
    return Env.DEBUG == 0
end

-- 是否测试环境
function Env.IsDebug()
    return not Env.IsRelease()
end

GG.Env = Env
