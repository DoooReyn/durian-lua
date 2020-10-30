GG.Requires("cocos.cocos2d.Cocos2d", "cocos.cocos2d.Cocos2dConstants", "cocos.cocos2d.RendererConstants",
    "cocos.ui.GuiConstants", "cocos.network.NetworkConstants")

if GG.Env.USE_3D then
    GG.Requires("cocos.3d.3dConstants")
end

if GG.Env.USE_CONTROLLER then
    GG.Requires("cocos.controller.ControllerConstants")
end

if GG.Env.USE_SPINE then
    GG.Requires("cocos.spine.SpineConstants")
end

if GG.Env.USE_PHYSICS then
    GG.Requires("cocos.physics3d.physics3d-constants")
end

if GG.Env.USE_FAIRY_GUI then
    GG.Requires("cocos.fairygui.FairyGUIConstants")
end