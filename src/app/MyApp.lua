require("cocos.init")
require("framework.init")
local GG = _G.GG
local AppBase = require("framework.AppBase")
local MyApp = class("MyApp", AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
    print("tolua.type: ", GG.Checker.Type(nil))
    print("tolua.type: ", GG.Checker.Type(false))
    print("tolua.type: ", GG.Checker.Type(1))
    print("tolua.type: ", GG.Checker.Type("s"))
    print("tolua.type: ", GG.Checker.Type({1, 2}))
    print("tolua.type: ", GG.Checker.Type(cc.FileUtils:getInstance()))
    print("tolua.type: ", GG.Checker.Type(coroutine.create(function()
    end)))
    GG.Checker[0] = 1
end

return MyApp
