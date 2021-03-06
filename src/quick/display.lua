--[[
  The module provide display related functions

  constant:
    display.sizeInPixels      , Screen pixel size
    display.widthInPixels     , Screen pixel width
    display.heightInPixels    , Screen pixel height
    display.contentScaleFactor, design resolution scale factor
    display.size              , design resolution size
    display.width             , design resolution width
    display.height            , design resolution height
    display.cx                , half screen width
    display.cy                , half screen height
    display.left              , left Coordinate X of screen
    display.top               , top Coordinate X of screen
    display.right             , right Coordinate X of screen
    display.bottom            , bottom Coordinate X of screen
    display.c_left            , left Coordinate X of screen when origin is at sreen center
    display.c_top             , top Coordinate X of screen when origin is at sreen center
    display.c_right           , right Coordinate X of screen when origin is at sreen center
    display.c_bottom          , bottom Coordinate X of screen when origin is at sreen center

  color constant:
    display.COLOR_WHITE       , cc.rgb(255, 255, 255)
    display.COLOR_YELLOW      , cc.rgb(255, 255, 0)
    display.COLOR_GREEN       , cc.rgb(0, 255, 0)
    display.COLOR_BLUE        , cc.rgb(0, 0, 255)
    display.COLOR_RED         , cc.rgb(255, 0, 0)
    display.COLOR_MAGENTA     , cc.rgb(255, 0, 255)
    display.COLOR_BLACK       , cc.rgb(0, 0, 0)
    display.COLOR_ORANGE      , cc.rgb(255, 127, 0)
    display.COLOR_GRAY        , cc.rgb(166, 166, 166)
]] --

local Display = {}

-- check device screen size
local glview = GG.S_Director:getOpenGLView()
assert(glview ~= nil, "Error: GLView not inited!")

local size = glview:getFrameSize()
Display.sizeInPixels = {
    width = size.width,
    height = size.height
}

local w = Display.sizeInPixels.width
local h = Display.sizeInPixels.height

if GG.Env.CONFIG_SCREEN_WIDTH == nil or GG.Env.CONFIG_SCREEN_HEIGHT == nil then
    GG.Env.CONFIG_SCREEN_WIDTH = w
    GG.Env.CONFIG_SCREEN_HEIGHT = h
end

if not GG.Env.CONFIG_SCREEN_AUTOSCALE then
    if w > h then
        GG.Env.CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
    else
        GG.Env.CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
    end
else
    GG.Env.CONFIG_SCREEN_AUTOSCALE = string.upper(GG.Env.CONFIG_SCREEN_AUTOSCALE)
end

local scale, scaleX, scaleY = 1.0, 1.0, 1.0

if GG.Env.CONFIG_SCREEN_AUTOSCALE and GG.Env.CONFIG_SCREEN_AUTOSCALE ~= "NONE" then
    if type(GG.Env.CONFIG_SCREEN_AUTOSCALE_CALLBACK) == "function" then
        scaleX, scaleY = GG.Env.CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h, GG.Device.model)
    end

    if GG.Env.CONFIG_SCREEN_AUTOSCALE == "EXACT_FIT" then
        scale = 1.0
        glview:setDesignResolutionSize(GG.Env.CONFIG_SCREEN_WIDTH, GG.Env.CONFIG_SCREEN_HEIGHT,
            cc.ResolutionPolicy.EXACT_FIT)
    elseif GG.Env.CONFIG_SCREEN_AUTOSCALE == "FILL_ALL" then
        GG.Env.CONFIG_SCREEN_WIDTH = w
        GG.Env.CONFIG_SCREEN_HEIGHT = h
        scale = 1.0
        glview:setDesignResolutionSize(GG.Env.CONFIG_SCREEN_WIDTH, GG.Env.CONFIG_SCREEN_HEIGHT,
            cc.ResolutionPolicy.SHOW_ALL)
    else
        if not scaleX or not scaleY then
            scaleX, scaleY = w / GG.Env.CONFIG_SCREEN_WIDTH, h / GG.Env.CONFIG_SCREEN_HEIGHT
        end

        if GG.Env.CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
            scale = scaleX
            GG.Env.CONFIG_SCREEN_HEIGHT = h / scale
        elseif GG.Env.CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
            scale = scaleY
            GG.Env.CONFIG_SCREEN_WIDTH = w / scale
        elseif GG.Env.CONFIG_SCREEN_AUTOSCALE == "FIXED_AUTO" then
            if scaleX < scaleY then
                scale = scaleX
                GG.Env.CONFIG_SCREEN_HEIGHT = h / scale
            else
                scale = scaleY
                GG.Env.CONFIG_SCREEN_WIDTH = w / scale
            end
        else
            scale = 1.0
            GG.Console.EF(string.format("display - invalid CONFIG_SCREEN_AUTOSCALE \"%s\"",
                              GG.Env.CONFIG_SCREEN_AUTOSCALE))
        end
        glview:setDesignResolutionSize(GG.Env.CONFIG_SCREEN_WIDTH, GG.Env.CONFIG_SCREEN_HEIGHT,
            cc.ResolutionPolicy.NO_BORDER)
    end
else
    GG.Env.CONFIG_SCREEN_WIDTH = w
    GG.Env.CONFIG_SCREEN_HEIGHT = h
    scale = 1.0
end

local winSize = GG.S_Director:getWinSize()
Display.screenScale = 2.0
Display.contentScaleFactor = scale
Display.size = {
    width = winSize.width,
    height = winSize.height
}
Display.width = Display.size.width
Display.height = Display.size.height
Display.cx = Display.width / 2
Display.cy = Display.height / 2
Display.c_left = -Display.width / 2
Display.c_right = Display.width / 2
Display.c_top = Display.height / 2
Display.c_bottom = -Display.height / 2
Display.left = 0
Display.right = Display.width
Display.top = Display.height
Display.bottom = 0
Display.widthInPixels = Display.sizeInPixels.width
Display.heightInPixels = Display.sizeInPixels.height

GG.Console.PF("# CONFIG_SCREEN_AUTOSCALE      = %s", GG.Env.CONFIG_SCREEN_AUTOSCALE)
GG.Console.PF("# CONFIG_SCREEN_WIDTH          = %0.2f", GG.Env.CONFIG_SCREEN_WIDTH)
GG.Console.PF("# CONFIG_SCREEN_HEIGHT         = %0.2f", GG.Env.CONFIG_SCREEN_HEIGHT)
GG.Console.PF("# display.widthInPixels        = %0.2f", Display.widthInPixels)
GG.Console.PF("# display.heightInPixels       = %0.2f", Display.heightInPixels)
GG.Console.PF("# display.contentScaleFactor   = %0.2f", Display.contentScaleFactor)
GG.Console.PF("# display.width                = %0.2f", Display.width)
GG.Console.PF("# display.height               = %0.2f", Display.height)
GG.Console.PF("# display.cx                   = %0.2f", Display.cx)
GG.Console.PF("# display.cy                   = %0.2f", Display.cy)
GG.Console.PF("# display.left                 = %0.2f", Display.left)
GG.Console.PF("# display.right                = %0.2f", Display.right)
GG.Console.PF("# display.top                  = %0.2f", Display.top)
GG.Console.PF("# display.bottom               = %0.2f", Display.bottom)
GG.Console.PF("# display.c_left               = %0.2f", Display.c_left)
GG.Console.PF("# display.c_right              = %0.2f", Display.c_right)
GG.Console.PF("# display.c_top                = %0.2f", Display.c_top)
GG.Console.PF("# display.c_bottom             = %0.2f", Display.c_bottom)
GG.Console.P("#")
Display.COLOR_WHITE = cc.rgb(255, 255, 255)
Display.COLOR_YELLOW = cc.rgb(255, 255, 0)
Display.COLOR_GREEN = cc.rgb(0, 255, 0)
Display.COLOR_BLUE = cc.rgb(0, 0, 255)
Display.COLOR_RED = cc.rgb(255, 0, 0)
Display.COLOR_MAGENTA = cc.rgb(255, 0, 255)
Display.COLOR_BLACK = cc.rgb(0, 0, 0)
Display.COLOR_ORANGE = cc.rgb(255, 127, 0)
Display.COLOR_GRAY = cc.rgb(166, 166, 166)

Display.AUTO_SIZE = 0
Display.FIXED_SIZE = 1
Display.LEFT_TO_RIGHT = 0
Display.RIGHT_TO_LEFT = 1
Display.TOP_TO_BOTTOM = 2
Display.BOTTOM_TO_TOP = 3

Display.CENTER = 1
Display.LEFT_TOP = 2
Display.TOP_LEFT = 2
Display.CENTER_TOP = 3
Display.TOP_CENTER = 3
Display.RIGHT_TOP = 4
Display.TOP_RIGHT = 4
Display.CENTER_LEFT = 5
Display.LEFT_CENTER = 5
Display.CENTER_RIGHT = 6
Display.RIGHT_CENTER = 6
Display.BOTTOM_LEFT = 7
Display.LEFT_BOTTOM = 7
Display.BOTTOM_RIGHT = 8
Display.RIGHT_BOTTOM = 8
Display.BOTTOM_CENTER = 9
Display.CENTER_BOTTOM = 9

Display.ANCHOR_POINTS = {cc.p(0.5, 0.5), -- CENTER
cc.p(0, 1), -- TOP_LEFT
cc.p(0.5, 1), -- TOP_CENTER
cc.p(1, 1), -- TOP_RIGHT
cc.p(0, 0.5), -- CENTER_LEFT
cc.p(1, 0.5), -- CENTER_RIGHT
cc.p(0, 0), -- BOTTOM_LEFT
cc.p(1, 0), -- BOTTOM_RIGHT
cc.p(0.5, 0) -- BOTTOM_CENTER
}

Display.SCENE_TRANSITIONS = {
    CROSSFADE = {cc.TransitionCrossFade, 2},
    FADE = {cc.TransitionFade, 3, cc.rgb(0, 0, 0)},
    FADEBL = {cc.TransitionFadeBL, 2},
    FADEDOWN = {cc.TransitionFadeDown, 2},
    FADETR = {cc.TransitionFadeTR, 2},
    FADEUP = {cc.TransitionFadeUp, 2},
    FLIPANGULAR = {cc.TransitionFlipAngular, 3, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPX = {cc.TransitionFlipX, 3, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPY = {cc.TransitionFlipY, 3, cc.TRANSITION_ORIENTATION_UP_OVER},
    JUMPZOOM = {cc.TransitionJumpZoom, 2},
    MOVEINB = {cc.TransitionMoveInB, 2},
    MOVEINL = {cc.TransitionMoveInL, 2},
    MOVEINR = {cc.TransitionMoveInR, 2},
    MOVEINT = {cc.TransitionMoveInT, 2},
    PAGETURN = {cc.TransitionPageTurn, 3, false},
    ROTOZOOM = {cc.TransitionRotoZoom, 2},
    SHRINKGROW = {cc.TransitionShrinkGrow, 2},
    SLIDEINB = {cc.TransitionSlideInB, 2},
    SLIDEINL = {cc.TransitionSlideInL, 2},
    SLIDEINR = {cc.TransitionSlideInR, 2},
    SLIDEINT = {cc.TransitionSlideInT, 2},
    SPLITCOLS = {cc.TransitionSplitCols, 2},
    SPLITROWS = {cc.TransitionSplitRows, 2},
    TURNOFFTILES = {cc.TransitionTurnOffTiles, 2},
    ZOOMFLIPANGULAR = {cc.TransitionZoomFlipAngular, 2},
    ZOOMFLIPX = {cc.TransitionZoomFlipX, 3, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    ZOOMFLIPY = {cc.TransitionZoomFlipY, 3, cc.TRANSITION_ORIENTATION_UP_OVER}
}

Display.TEXTURES_PIXEL_FORMAT = {}
Display.DEFAULT_TTF_FONT = "Arial"
Display.DEFAULT_TTF_FONT_SIZE = 24

--[[
  Create a new scene, auto enable Node event(true)
  @function newScene
  @param string name, scene name
]]--
function Display.newScene(name)
    local scene = cc.Scene:create()
    scene.name = name or "<unknown-scene>"
    scene:setNodeEventEnabled(true)
    return scene
end

--[[
  Create a new physics scene, auto enable Node event(true)
  @function newPhysicsScene
  @param string name, scene name
]]--
function Display.newPhysicsScene(name)
    local scene = cc.Scene:createWithPhysics()
    scene.name = name or "<unknown-scene>"
    scene:setNodeEventEnabled(true)
    return scene
end

--[[
  Create a new transition scene, auto enable Node event(true)
  @function wrapSceneWithTransition
  @param Scene scene, cc.Scene
  @param string transitionType,  transition type name
  @param number time, transition time
  @param string more, more param needed by some transition type
  @return Scene ret, cc.Scene

  example:
  local nextScene = display.newScene("NextScene")
  local transition = display.wrapSceneWithTransition(nextScene, "fade", 0.5)
  display.replaceScene(transition)

  transitionType:
  crossFade      , fadeOut curren scene and fadeIn next scene.
  fade           , fadeOut with specified color, which can set by param "more".
  fadeBL         , fadeOut start from lower left corner.
  fadeDown       , fadeOut start from bottom.
  fadeTR         , fadeOut start from upper right corner.
  fadeUp         , fadeOut start from top.
  flipAngular    , flip then into next scene, flip angular set by param "more" which value can be:
    cc.TRANSITION_ORIENTATION_LEFT_OVER
    cc.TRANSITION_ORIENTATION_RIGHT_OVER
    cc.TRANSITION_ORIENTATION_UP_OVER
    cc.TRANSITION_ORIENTATION_DOWN_OVER
  flipX          , flip horizontally.
  flipY          , flip vertically.
  zoomFlipAngular, flip and zoomIn, flip angular set by param "more" which value can be:
    cc.TRANSITION_ORIENTATION_LEFT_OVER
    cc.TRANSITION_ORIENTATION_RIGHT_OVER
    cc.TRANSITION_ORIENTATION_UP_OVER
    cc.TRANSITION_ORIENTATION_DOWN_OVER
  zoomFlipX      , flip horizontally and zoomIn
  zoomFlipY      , flip vertically abd zoomIn.
  jumpZoom       , jump and zoomIn.
  moveInB        , the new scene coming in from bottom, cover the old scene.
  moveInL        , the new scene coming in from left, cover the old scene.
  moveInR        , the new scene coming in from right, cover the old scene.
  moveInT        , the new scene coming in from top, cover the old scene.
  pageTurn       , pageTune effect, default from right to left, if param "more" set to true, from left to right
  rotoZoom       , roation and zoomIn.
  shrinkGrow     , shrink grow and cross fade.
  slideInB       , the new scene coming in from bottom, the old exit from top.
  slideInL       , the new scene coming in from left, the old exit from right.
  slideInR       , the new scene coming in from right, the old exit from left.
  slideInT       , the new scene coming in from top, the old exit from bottom.
  splitCols      , split into cols to enter new scene, like a shuttered window.
  splitRows      , split into rows to enter new scene, like a shuttered window.
  turnOffTiles   , split into tiles, replace by new scene gradually.
]]--
function Display.wrapSceneWithTransition(scene, transitionType, time, more)
    local key = string.upper(tostring(transitionType))
    if string.sub(key, 1, 12) == "CCTRANSITION" then
        key = string.sub(key, 13)
    end

    if key == "RANDOM" then
        local keys = table.keys(Display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if Display.SCENE_TRANSITIONS[key] then
        local cls, count, default = unpack(Display.SCENE_TRANSITIONS[key])
        time = time or 0.2

        if count == 3 then
            scene = cls:create(time, scene, more or default)
        else
            scene = cls:create(time, scene)
        end
    else
        GG.Console.EF("display.wrapSceneWithTransition() - invalid transitionType %s", tostring(transitionType))
    end
    return scene
end

--[[
  Enter a new scene, remove the old scene. And can set transitionType when do replaceScene.
  inner auto call wrapSceneWithTransition
  @function replaceScene
  @param string transitionType, transition type name
  @param number time, transition time
  @param mixed more, param needed be some transition type

  example:
  display.replaceScene(nextScene, "fade", 0.5, cc.rgb(255, 0, 0))
]]--
function Display.replaceScene(newScene, transitionType, time, more)
    if GG.S_Director:getRunningScene() then
        if transitionType then
            newScene = Display.wrapSceneWithTransition(newScene, transitionType, time, more)
        end
        GG.S_Director:replaceScene(newScene)
    else
        GG.S_Director:runWithScene(newScene)
    end
end

--[[
  Get current running scene.
  @function getRunningScene
  @return Scene ret, cc.Scene
]]--
function Display.getRunningScene()
    return GG.S_Director:getRunningScene()
end

--[[
  Pause Game.
  @function pause
]]--
function Display.pause()
    GG.S_Director:pause()
end

--[[
  Resume Game.
  @function resume
]]--
function Display.resume()
    GG.S_Director:resume()
end

--[[
  New a layer. In 4.0, cc.Layer removed, cc.Node do the same things.
  @function newLayer
  @return Node ret, cc.Node
]]--
function Display.newLayer()
    local node = cc.Node:create()
    node:setContentSize(cc.size(Display.width, Display.height))
    return node
end

--[[
  New a color layer.
  @function newColorLayer
  @return LayerColor ret, cc.LayerColor
]]--
function Display.newColorLayer(color)
    return cc.LayerColor:create(color)
end

--[[
  New a node.
  @function newNode
  @return Node ret, cc.Node
]]--
function Display.newNode()
    return cc.Node:create()
end

if cc.ClippingRectangleNode then
    cc.ClippingRegionNode = cc.ClippingRectangleNode
else
    cc.ClippingRectangleNode = cc.ClippingRegionNode
end

--[[
  New a ClippingRectangleNode.
  @function newClippingRectangleNode
  @param Rect cc.Rect, clip rect
  @return Node ret, cc.ClippingRegionNode

  example:
  local layer = display.newColorLayer(cc.c4b(255, 255, 0, 255))
  local clipnode = display.newClippingRectangleNode(cc.rect(0, 0, 100, 100))
  layer:addTo(clipnode)
  clipnode:addTo(scene)
]]--
function Display.newClippingRectangleNode(rect)
    return cc.ClippingRegionNode:create(rect)
end

--[[
  New a Sprite.
  @function newSprite
  @param mixed, image path or cc.SpriteFrame
  @param number x
  @param number y
  @param table params
  @return Sprite ret, cc.Sprite

  example:
  local sprite1 = display.newSprite("hello1.png") -- from file
  local sprite2 = display.newSprite("#frame0001.png") -- from SpriteFrame cache
  local frame = display.newFrame("frame0002.png") -- new cc.SpriteFrame then create sprite
  local sprite3 = display.newSprite(frame)
]]--
function Display.newSprite(filename, x, y, params)
    local spriteClass = nil
    local size = nil

    if params then
        spriteClass = params.class
        size = params.size
    end
    if not spriteClass then
        spriteClass = cc.Sprite
    end

    local t = type(filename)
    if t == "userdata" then
        t = tolua.type(filename)
    end
    local sprite

    if not filename then
        sprite = spriteClass:create()
    elseif t == "string" then
        if string.byte(filename) == 35 then -- first char is #
            local frame = Display.newSpriteFrame(string.sub(filename, 2))
            if frame then
                if params and params.capInsets then
                    sprite = spriteClass:createWithSpriteFrame(frame, params.capInsets)
                else
                    sprite = spriteClass:createWithSpriteFrame(frame)
                end
            end
        else
            if Display.TEXTURES_PIXEL_FORMAT[filename] then
                cc.Texture2D:setDefaultAlphaPixelFormat(Display.TEXTURES_PIXEL_FORMAT[filename])
                sprite = spriteClass:create(filename)
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGBA8888)
            else
                if params and params.capInsets then
                    sprite = spriteClass:create(filename, params.capInsets)
                else
                    sprite = spriteClass:create(filename)
                end
            end
        end
    elseif t == "cc.SpriteFrame" then
        sprite = spriteClass:createWithSpriteFrame(filename)
    elseif t == "cc.Texture2D" then
        sprite = spriteClass:createWithTexture(filename)
    else
        GG.Console.EF("display.newSprite() - invalid filename value type")
        sprite = spriteClass:create()
    end

    if sprite then
        if x and y then
            sprite:setPosition(x, y)
        end
        if size then
            sprite:setContentSize(size)
        end
    else
        GG.Console.EF("display.newSprite() - create sprite failure, filename %s", tostring(filename))
        sprite = spriteClass:create()
    end

    return sprite
end

--[[
  New a Scale9Sprite.
  @function newScale9Sprite
  @param string filename, image path
  @param integer x, positionX
  @param integer y, positionY
  @param table size, scale to size
  @param table capInsets, scale9 param
  @return Scale9Sprite ret, ccui.Scale9Sprite

  example:
  local sprite = display.newScale9Sprite("bg.png", 0, 0, cc.size(200, 100), cc.rect(10, 10, 20, 20))
]]--
function Display.newScale9Sprite(filename, x, y, size, capInsets)
    return Display.newSprite(filename, x, y, {
        class = ccui.Scale9Sprite,
        size = size,
        capInsets = capInsets
    })
end

--[[
  New a Tiled sprite.
  @function newTilesSprite
  @param string filename, image path
  @param cc.rect rect, Tiling rect
  @return Sprite ret, cc.Sprite

  example:
  local sprite = display.newTilesSprite("bg.png", cc.rect(10, 10, 20, 20))
]]--
function Display.newTilesSprite(filename, rect)
    if not rect then
        rect = cc.rect(0, 0, Display.width, Display.height)
    end
    local sprite = cc.Sprite:create(filename, rect)
    if not sprite then
        GG.Console.EF("display.newTilesSprite() - create sprite failure, filename %s", tostring(filename))
        return
    end

    sprite:getTexture():setTexParameters(cc.backendSamplerFilter.LINEAR, cc.backendSamplerFilter.LINEAR,
        cc.backendSamplerAddressMode.REPEAT, cc.backendSamplerAddressMode.REPEAT)

    Display.align(sprite, Display.LEFT_BOTTOM, 0, 0)

    return sprite
end

--[[
  Create a tiled SpriteBatchNode
  @function newTiledBatchNode
  @param mixed filename, As same a the first parameter for display.newSprite
  @param string plistFile, Texture(plist) image filename, filename must be a part of the texture.
  @param size size, The tiled node size, use cc.size create it please.
  @param integer hPadding, Horizontal padding.
  @param integer vPadding, Vertical padding.
  @return SpriteBatchNode ret, cc.SpriteBatchNode
]]--
function Display.newTiledBatchNode(filename, plistFile, size, hPadding, vPadding)
    size = size or cc.size(Display.width, Display.height)
    hPadding = hPadding or 0
    vPadding = vPadding or 0
    local __sprite = Display.newSprite(filename)
    local __sliceSize = __sprite:getContentSize()
    __sliceSize.width = __sliceSize.width - hPadding
    __sliceSize.height = __sliceSize.height - vPadding
    local __xRepeat = math.ceil(size.width / __sliceSize.width)
    local __yRepeat = math.ceil(size.height / __sliceSize.height)
    -- How maney sprites we need to fill in tiled node?
    local __capacity = __xRepeat * __yRepeat
    local __batch = Display.newBatchNode(plistFile, __capacity)
    local __newSize = cc.size(0, 0)

    for y = 0, __yRepeat - 1 do
        for x = 0, __xRepeat - 1 do
            __newSize.width = __newSize.width + __sliceSize.width
            __sprite = Display.newSprite(filename):align(Display.LEFT_BOTTOM, x * __sliceSize.width,
                           y * __sliceSize.height):addTo(__batch)
        end
        __newSize.height = __newSize.height + __sliceSize.height
    end
    __batch:setContentSize(__newSize)

    return __batch, __newSize.width, __newSize.height
end

--[[
  Create a DrawNode
  @function newDrawNode
  @return DrawNode ret, cc.DrawNode
]]--
function Display.newDrawNode()
    return cc.DrawNode:create()
end

--[[
  Create a solid circle DrawNode
  @function newSolidCircle
  @param number radius, radius of the circle
  @param table params, {x, y, color}
  @return DrawNode ret, cc.DrawNode

  example:
  local circle = display.newSolidCircle(10, {x = 150, y = 150, color = cc.c4f(1, 1, 1, 1)})
]]--
function Display.newSolidCircle(radius, params)
    local circle = Display.newDrawNode()
    circle:drawSolidCircle(cc.p(params.x or 0, params.y or 0), radius or 0, params.angle or 0, params.segments or 50,
        params.scaleX or 1.0, params.scaleY or 1.0, params.color or cc.c4f(0, 0, 0, 1))
    return circle
end

--[[
  Create a circle DrawNode
  @function newCircle
  @param number radius, radius of the circle
  @param table params, {x, y, fillColor, borderColor, borderWidth}
  @return DrawNode ret, cc.DrawNode

  example:
  local circle = display.newCircle(50, {
    x = 100,
	y = 100,
    fillColor = cc.c4f(1, 0, 0, 1), -- if set, be a solid circle
    borderColor = cc.c4f(0, 1, 0, 1),
    borderWidth = 2
  })
]]--
function Display.newCircle(radius, params)
    params = GG.Checker.Table(params)

    local function makeVertexs(radius)
        local segments = params.segments or 32
        local startRadian = 0
        local endRadian = math.pi * 2
        local posX = params.x or 0
        local posY = params.y or 0
        if params.startAngle then
            startRadian = math.angle2radian(params.startAngle)
        end
        if params.endAngle then
            endRadian = startRadian + math.angle2radian(params.endAngle)
        end
        local radianPerSegm = 2 * math.pi / segments
        local points = {}
        for i = 1, segments do
            local radii = startRadian + i * radianPerSegm
            if radii > endRadian then
                break
            end
            points[#points + 1] = {posX + radius * math.cos(radii), posY + radius * math.sin(radii)}
        end
        return points
    end

    local points = makeVertexs(radius)
    local circle = Display.newPolygon(points, params)
    if circle then
        circle.radius = radius
        circle.params = params

        function circle:setRadius(radius)
            self:clear()
            local points = makeVertexs(radius)
            Display.newPolygon(points, params, self)
        end

        function circle:setLineColor(color)
            self:clear()
            local points = makeVertexs(radius)
            params.borderColor = color
            Display.newPolygon(points, params, self)
        end
    end
    return circle
end

--[[
  Create a rect DrawNode
  @function newRect
  @param table rect
  @param table params, {fillColor, borderColor, borderWidth}
  @return DrawNode ret, cc.DrawNode

  example:
  local rect = display.newRect(cc.rect(100, 100, 40, 40), {
    fillColor = cc.c4f(1,0,0,1),
	borderColor = cc.c4f(0,1,0,1),
	borderWidth = 5
  })
]]--
function Display.newRect(rect, params)
    local x, y, width, height = 0, 0
    x = rect.x or 0
    y = rect.y or 0
    height = rect.height
    width = rect.width

    local points = {{x, y}, {x + width, y}, {x + width, y + height}, {x, y + height}}
    return Display.newPolygon(points, params)
end

--[[
  Create a rounded rect DrawNode
  @function newRoundedRect
  @param size size
  @param integer radius, rounded corner radius
  @param table params, {fillColor, borderColor, borderWidth}
  @return DrawNode ret, cc.DrawNode

  example:
  local rect = display.newRoundedRect(cc.size(200, 100), 40, {
    fillColor = cc.c4f(1,0,0,1),
    borderColor = cc.c4f(0,1,0,1),
    borderWidth = 1
  })
]]--
function Display.newRoundedRect(size, radius, params)
    local radius = radius or 1
    local segments = math.ceil(radius)
    local radianPerSegment = math.pi * 0.5 / segments
    local radianVertices = {}

    for i = 0, segments do
        local radian = i * radianPerSegment
        radianVertices[i] = cc.p(math.round(math.cos(radian) * radius * 10) / 10,
                                math.round(math.sin(radian) * radius * 10) / 10)
    end

    local points = {}
    local tagCenter = cc.p(0, 0)

    -- left up
    tagCenter = cc.p(radius, size.height - radius)
    for i = 0, segments do
        local ri = i
        points[#points + 1] = cc.p(tagCenter.x - radianVertices[ri].x, tagCenter.y + radianVertices[ri].y)
    end

    -- right up
    tagCenter = cc.p(size.width - radius, size.height - radius)
    for i = 0, segments do
        local ri = segments - i
        points[#points + 1] = cc.p(tagCenter.x + radianVertices[ri].x, tagCenter.y + radianVertices[ri].y)
    end

    -- right bottom
    tagCenter = cc.p(size.width - radius, radius)
    for i = 0, segments do
        local ri = i
        points[#points + 1] = cc.p(tagCenter.x + radianVertices[ri].x, tagCenter.y - radianVertices[ri].y)
    end

    -- left bottom
    tagCenter = cc.p(radius, radius)
    for i = 0, segments do
        local ri = segments - i
        points[#points + 1] = cc.p(tagCenter.x - radianVertices[ri].x, tagCenter.y - radianVertices[ri].y)
    end
    points[#points + 1] = cc.p(points[1].x, points[1].y)

    params = GG.Checker.Table(params)
    local borderWidth = params.borderWidth or 0.5
    local fillColor = params.fillColor or cc.c4f(1, 1, 1, 1)
    local borderColor = params.borderColor or cc.c4f(1, 1, 1, 1)
    local drawNode = cc.DrawNode:create()
    drawNode:drawPolygon(points, #points, fillColor, borderWidth, borderColor)
    drawNode:setContentSize(size)
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))

    return drawNode
end

--[[
  Create a line DrawNode
  @function newLine
  @param table points
  @param table params, {borderColor, borderWidth}
  @return DrawNode ret, cc.DrawNode

  example:
  local line = display.newLine({{10, 10}, {100,100}}, {
    borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0),
    borderWidth = 1
  })
]]--
function Display.newLine(points, params)
    local radius
    local borderColor
    local scale

    if not params then
        borderColor = cc.c4f(0, 0, 0, 1)
        radius = 0.5
        scale = 1.0
    else
        borderColor = params.borderColor or cc.c4f(0, 0, 0, 1)
        radius = (params.borderWidth and params.borderWidth / 2) or 0.5
        scale = GG.Checker.Number(params.scale, 1.0)
    end

    for i, p in ipairs(points) do
        p = cc.p(p[1] * scale, p[2] * scale)
        points[i] = p
    end

    local drawNode = cc.DrawNode:create()
    drawNode:drawSegment(points[1], points[2], radius, borderColor)

    return drawNode
end

--[[
  Create a polygon DrawNode
  @function newPolygon
  @param table points
  @param table params, {scale, borderWidth, fillColor, borderColor}
  @param DrawNode drawNode
  @return DrawNode ret, cc.DrawNode

  example:
  local line = display.newPolygon({{30, 30}, {30, 60}, {60, 60}}, {
    scale = 1,
    borderWidth = 1,
    fillColor = cc.c4f(0.0, 1.0, 0.0, 1.0),
    borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0),
  })
]]--
function Display.newPolygon(points, params, drawNode)
    params = GG.Checker.Table(params)
    local scale = GG.Checker.Number(params.scale or 1.0)
    local borderWidth = GG.Checker.Number(params.borderWidth or 0.5)
    local fillColor = params.fillColor or cc.c4f(1, 1, 1, 0)
    local borderColor = params.borderColor or cc.c4f(0, 0, 0, 1)

    local pts = {}
    for i, p in ipairs(points) do
        pts[i] = {
            x = p[1] * scale,
            y = p[2] * scale
        }
    end

    drawNode = drawNode or cc.DrawNode:create()
    drawNode:drawPolygon(pts, #pts, fillColor, borderWidth, borderColor)
    return drawNode
end

--[[
  Create a bmfont label
  @function newBMFontLabel
  @param table params, {text, font, align, maxLineWidth, offsetX, offsetY, x, y}
  @return Label ret, cc.Label

  example:
  local label = display.newBMFontLabel({
    text = "Hello",
    font = "UIFont.fnt",
  })
]]--
function Display.newBMFontLabel(params)
    assert(type(params) == "table", "display.newBMFontLabel() invalid params")

    local text = tostring(params.text)
    local font = params.font
    local textAlign = params.align or cc.TEXT_ALIGNMENT_LEFT
    local maxLineW = params.maxLineWidth or 0
    local offsetX = params.offsetX or 0
    local offsetY = params.offsetY or 0
    local x, y = params.x, params.y
    assert(font ~= nil, "display.newBMFontLabel() - not set font")

    local label = cc.Label:createWithBMFont(font, text, textAlign, maxLineW, cc.p(offsetX, offsetY));
    if not label then
        return
    end

    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end

    return label
end

--[[
  Create a TTF label
  @function newTTFLabel
  @param table params, {text, font, size, color, align, valign, dimensions, x, y}
  @return Label ret, cc.Label

  align can be:
  cc.TEXT_ALIGNMENT_LEFT
  cc.TEXT_ALIGNMENT_CENTER
  cc.TEXT_ALIGNMENT_RIGHT

  valign can be:
  cc.VERTICAL_TEXT_ALIGNMENT_TOP
  cc.VERTICAL_TEXT_ALIGNMENT_CENTER
  cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM

  example:
  local label = display.newTTFLabel({
    text = "Hello, World\n您好，世界",
    font = "Arial",
    size = 64,
    color = cc.rgb(255, 0, 0),
    align = cc.TEXT_ALIGNMENT_LEFT,
    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    dimensions = cc.size(400, 200)
  })
]]--
function Display.newTTFLabel(params)
    assert(type(params) == "table", "display.newTTFLabel() invalid params")

    local text = tostring(params.text)
    local font = params.font or Display.DEFAULT_TTF_FONT
    local size = params.size or Display.DEFAULT_TTF_FONT_SIZE
    local color = params.color or Display.COLOR_WHITE
    local textAlign = params.align or cc.TEXT_ALIGNMENT_LEFT
    local textValign = params.valign or cc.VERTICAL_TEXT_ALIGNMENT_TOP
    local x, y = params.x, params.y
    local dimensions = params.dimensions or cc.size(0, 0)

    assert(type(size) == "number", "display.newTTFLabel() invalid params.size")

    local label
    if GG.S_FileUtils:isFileExist(font) then
        label = cc.Label:createWithTTF(text, font, size, dimensions, textAlign, textValign)
        if label then
            label:setColor(color)
        end
    else
        label = cc.Label:createWithSystemFont(text, font, size, dimensions, textAlign, textValign)
        if label then
            label:setTextColor(color)
        end
    end

    if label then
        if x and y then
            label:setPosition(x, y)
        end
    end

    return label
end

--[[
  setAnchorPoint for specified target with specified type, and setPosition.
  @function align
  @param Node target
  @param integer anchorPointType
  @param integer x
  @param integer y

  anchorPointType can be:
  display.CENTER
  display.LEFT_TOP
  display.TOP_LEFT
  display.CENTER_TOP
  display.TOP_CENTER
  display.RIGHT_TOP
  display.TOP_RIGHT
  display.CENTER_LEFT
  display.LEFT_CENTER
  display.CENTER_RIGHT
  display.RIGHT_CENTER
  display.BOTTOM_LEFT
  display.LEFT_BOTTOM
  display.BOTTOM_RIGHT
  display.RIGHT_BOTTOM
  display.BOTTOM_CENTER
  display.CENTER_BOTTOM

  example:
  display.align(node, display.LEFT_TOP, 0, 0)
]]--
function Display.align(target, anchorPoint, x, y)
    target:setAnchorPoint(Display.ANCHOR_POINTS[anchorPoint])
    if x and y then
        target:setPosition(x, y)
    end
end

--[[
  Load a image into TextureCache Async.
  @function addImageAsync
  @param string imagePath
  @param function callback
]]--
function Display.addImageAsync(imagePath, callback)
    GG.S_Texture:addImageAsync(imagePath, callback)
end

--[[
  Load SpriteFrames from plist(TexturePacker).
  @function addSpriteFrames
  @param string plistFilename
  @param string imageName
  @param function handler, if set, load Async

  example:
  display.addSpriteFrames("Sprites.plist", "Sprites.png")
]]--
function Display.addSpriteFrames(plistFilename, image, handler)
    local async = type(handler) == "function"
    local asyncHandler = nil
    if async then
        asyncHandler = function()
            local texture = GG.S_Texture:getTextureForKey(image)
            assert(texture, string.format("The texture %s, %s is unavailable.", plistFilename, image))
            GG.S_SpriteFrame:addSpriteFrames(plistFilename, texture)
            GG.Magic.Pack(plistFilename, image)
        end
    end

    if Display.TEXTURES_PIXEL_FORMAT[image] then
        cc.Texture2D:setDefaultAlphaPixelFormat(Display.TEXTURES_PIXEL_FORMAT[image])
        if async then
            GG.S_Texture:addImageAsync(image, asyncHandler)
        else
            GG.S_SpriteFrame:addSpriteFrames(plistFilename, image)
        end
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.backendPixelFormat.BGRA8888)
    else
        if async then
            GG.S_Texture:addImageAsync(image, asyncHandler)
        else
            GG.S_SpriteFrame:addSpriteFrames(plistFilename, image)
        end
    end
end

--[[
  Unload SpriteFrames from plist(TexturePacker).
  @function removeSpriteFramesWithFile
  @param string plistFilename
  @param string imageName
]]--
function Display.removeSpriteFramesWithFile(plistFilename, imageName)
    GG.S_SpriteFrame:removeSpriteFramesFromFile(plistFilename)
    if imageName then
        Display.removeSpriteFrameByImageName(imageName)
    end
end

--[[
  Set Texture PixelFormat when Texture file load by display functions.
  @function setTexturePixelFormat
  @param string filename
  @param integer format (cc.backendPixelFormat)
]]--
function Display.setTexturePixelFormat(filename, format)
    Display.TEXTURES_PIXEL_FORMAT[filename] = format
end

--[[
  Remove image from SpriteFrameCache & TextureCache.
  @function removeSpriteFrameByImageName
  @param string imageName
]]--
function Display.removeSpriteFrameByImageName(imageName)
    GG.S_SpriteFrame:removeSpriteFrameByName(imageName)
    GG.S_Texture:removeTextureForKey(imageName)
end

--[[
  Create a batch node base no texture.
  @function newBatchNode
  @param string image
  @param integer capacity
]]--
function Display.newBatchNode(image, capacity)
    return cc.SpriteBatchNode:create(image, capacity or 100)
end

--[[
  Create or Get SpriteFrame.
  @function newSpriteFrame
  @param string frameName
  @return frame cc.SpriteFrame
]]--
function Display.newSpriteFrame(frameName)
    local frame = GG.S_SpriteFrame:getSpriteFrame(frameName)
    if not frame then
        GG.Console.EF("display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
    end
    return frame
end

--[[
  Create a table contain SpriteFrames.
  @function newFrames
  @param string pattern
  @param integer begin
  @param integer length
  @param boolean isReversed
  @return table ret

  example:
  local frames = display.newFrames("Walk%04d.png", 1, 8)
]]--
function Display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = GG.S_SpriteFrame:getSpriteFrame(frameName)
        if not frame then
            GG.Console.EF("display.newFrames() - invalid frame, name %s", tostring(frameName))
            return
        end

        frames[#frames + 1] = frame
    end
    return frames
end

--[[
  Create a cc.Animation from SpriteFrames.
  @function newAnimation
  @param table frames, get from display.newFrames()
  @param number time
  @return Animation ret, cc.Animation

  example:
  local animation = display.newAnimation(frames, 0.5 / 8)
]]--
function Display.newAnimation(frames, time)
    time = time or (1.0 / #frames)
    return cc.Animation:createWithSpriteFrames(frames, time)
end

--[[
  Cache cc.Animation by name.
  @function setAnimationCache
  @param string name
  @param Animation animation

  example:
  display.setAnimationCache("Walk", animation)
]]--
function Display.setAnimationCache(name, animation)
    GG.S_Animation:addAnimation(animation, name)
end

--[[
  Get cached cc.Animation by name.
  @function getAnimationCache
  @param string name
  @return Animation ret, cc.Animation

  example:
  local animation = display.getAnimationCache("Walk")
]]--
function Display.getAnimationCache(name)
    return GG.S_Animation:getAnimation(name)
end

--[[
  Remove cached cc.Animation by name.
  @function removeAnimationCache
  @param string name
]]--
function Display.removeAnimationCache(name)
    GG.S_Animation:removeAnimation(name)
end

--[[
  Remove Unused Sprite Frames.
  @function removeUnusedSpriteFrames
]]--
function Display.removeUnusedSpriteFrames()
    GG.S_SpriteFrame:removeUnusedSpriteFrames()
    GG.S_Texture:removeUnusedTextures()
end

Display.PROGRESS_TIMER_RADIAL = 0
Display.PROGRESS_TIMER_BAR = 1

--[[
  Create progress timer node.
  @function newProgressTimer
  @param mixed image
  @param number progressType
]]--
function Display.newProgressTimer(image, progresssType)
    if type(image) == "string" then
        image = Display.newSprite(image)
    end

    local progress = cc.ProgressTimer:create(image)
    progress:setType(progresssType)
    return progress
end

--[[
  Capture Screen and save to file.
  @function captureScreen
  @param function callback
  @param string fileName

  example:
  display.captureScreen(function(bSuc, filePath)
    GG.Console.P(bSuc, filePath)
  end, "screen.png")
]]--
function Display.captureScreen(callback, fileName)
    cc.utils:captureScreen(callback, fileName)
end

GG.Display = Display
