local AppBase = GG.Requires("quick.AppBase")
local MyApp = GG.Magic.Class("MyApp", AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    GG.S_FileUtils:addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
