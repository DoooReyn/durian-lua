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
    GG.Console.P("tolua.type: ", GG.Checker.Type(nil))
    GG.Console.P("tolua.type: ", GG.Checker.Type(false))
    GG.Console.P("tolua.type: ", GG.Checker.Type(1))
    GG.Console.P("tolua.type: ", GG.Checker.Type("s"))
    GG.Console.P("tolua.type: ", GG.Checker.Type({1, 2}))
    GG.Console.P("tolua.type: ", GG.Checker.Type(cc.FileUtils:getInstance()))
    GG.Console.P("tolua.type: ", GG.Checker.Type(coroutine.create(function()
    end)))
    GG.Checker[0] = 1
end

return MyApp
