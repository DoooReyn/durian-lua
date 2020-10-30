local AppBase = GG.Requires("quick.AppBase")
local MyApp = GG.Magic.Class("MyApp", AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    -- 将App设置为全局可访问
    GG.S_App = self
    self:enterScene("MainScene")
end

return MyApp
