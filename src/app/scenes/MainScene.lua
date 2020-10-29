local MainScene = GG.Class("MainScene", function()
	return GG.Display.newScene("MainScene")
end)

function MainScene:ctor()
	GG.Display.newSprite("HelloWorld.png")
		:addTo(self)
		:center()

	GG.Display.newTTFLabel({text = "Hello, World", size = 64})
		:align(GG.Display.CENTER, GG.Display.cx, GG.Display.cy)
		:addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
