--[[
Copyright 2017 KeNan Liu

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]] -- Singleton class

local Audio = {}
Audio._buffers = {}
Audio._sources = {}
Audio._scheduler = nil -- global schedule hander
-- pos 1 is for BGM
Audio._sources[1] = Rapid2D_CAudio.newSource()
if not (Audio._sources[1]) then
    GG.Console.P("Error: init BGM source fail, check if have OpenAL init error above!")
    -- fake function, disable audio output when init failed
    Audio.loadFile = function(path, callback)
        callback(path, true)
    end
    Audio.unloadFile = function(path)
    end
    Audio.unloadAllFile = function()
    end
    Audio.playBGMAsync = function(path, isLoop)
    end
    Audio.playBGM = function(path, isLoop)
    end
    Audio.stopBGM = function()
    end
    Audio.setBGMVolume = function(vol)
    end
    Audio.playEffectAsync = function(path, isLoop)
    end
    Audio.playEffect = function(path, isLoop)
    end
    Audio.setEffectVolume = function(vol)
    end
    Audio.stopEffect = function()
    end
    Audio.stopAll = function()
    end
    Audio.pauseAll = function()
    end
    Audio.resumeAll = function()
    end
    return Audio
end

Audio._BGMVolume = 1.0
Audio._effectVolume = 1.0

local scheduler = GG.S_Scheduler

-- INTERNAL API, recircle source from effects, call by director
local function update(dt)
    local sources = Audio._sources
    local total = #sources
    local index = 2
    while index <= total do
        local stat = sources[index]:getStat()
        if 4 == stat then
            sources[index]:__gc() -- free OpenAL resource
            table.remove(sources, index)
            total = total - 1
        else
            index = index + 1
        end
    end

    if 1 == total then
        scheduler.unscheduleGlobal(Audio._scheduler)
        Audio._scheduler = nil
    end
end

--------------- buffer -------------------
function Audio.loadFile(path, callback)
    if Audio._buffers[path] then
        callback(path, true)
    else
        assert(callback, "ONLY support asyn load file, please set callback!")
        Rapid2D_CAudio.newBuffer(path, function(buffID)
            if buffID then
                Audio._buffers[path] = buffID
                callback(path, true)
            else
                callback(path, false)
            end
        end)
    end
end

function Audio.unloadFile(path)
    local buffer = Audio._buffers[path]
    if buffer then
        buffer:__gc()
    end
    Audio._buffers[path] = nil
end

function Audio.unloadAllFile()
    for path, buffer in pairs(Audio._buffers) do
        buffer:__gc()
    end
    Audio._buffers = {}
end

--[[
function for CSource
	play2d(buffer, isLoop)
    pause()
    resume()
    stop()
	setVolume(vol)
    getStat()
]]--

--------------- BGM 2D API -------------------
-- no need preload file
function Audio.playBGMAsync(path, isLoop)
    Audio.loadFile(path, function(pn, isSuccess)
        if isSuccess then
            Audio.playBGM(pn, isLoop)
        end
    end)
end

-- need preload file
function Audio.playBGM(path, isLoop)
    local buffer = Audio._buffers[path]
    if not buffer then
        GG.Console.P(path .. " have not loaded!!")
        return
    end

    isLoop = isLoop ~= false and true or false
    Audio._sources[1]:stop()
    Audio._sources[1]:play2d(buffer, isLoop)
    Audio._sources[1]:setVolume(Audio._BGMVolume)
end

function Audio.stopBGM()
    Audio._sources[1]:stop()
end

function Audio.setBGMVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    end
    if vol < 0.0 then
        vol = 0.0
    end
    Audio._sources[1]:setVolume(vol)
    Audio._BGMVolume = vol
end

--------------- Effect 2D API -------------------
-- no need preload file
function Audio.playEffectAsync(path, isLoop)
    Audio.loadFile(path, function(pn, isSuccess)
        if isSuccess then
            Audio.playEffect(pn, isLoop)
        end
    end)
end

-- need preload file
function Audio.playEffect(path, isLoop)
    local buffer = Audio._buffers[path]
    if not buffer then
        GG.Console.P(path .. " have not loaded!!")
        return
    end

    local source = Rapid2D_CAudio.newSource()
    if source then
        isLoop = isLoop == true and true or false
        table.insert(Audio._sources, source)
        source:setVolume(Audio._effectVolume)
        source:play2d(buffer, isLoop)

        -- start recircle scheduler
        if not Audio._scheduler then
            Audio._scheduler = scheduler.scheduleGlobal(update, 0.1)
        end
    end
    return source
end

function Audio.setEffectVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    end
    if vol < 0.0 then
        vol = 0.0
    end
    Audio._effectVolume = vol

    for i = 2, #Audio._sources do
        Audio._sources[i]:setVolume(vol)
    end
end

function Audio.stopEffect()
    for i = 2, #Audio._sources do
        Audio._sources[i]:stop()
    end
end

--------------- work both on BGM and Effects -------------------
function Audio.stopAll()
    for i = 1, #Audio._sources do
        Audio._sources[i]:stop()
    end
end

function Audio.pauseAll()
    for i = 1, #Audio._sources do
        Audio._sources[i]:pause()
    end
end

function Audio.resumeAll()
    for i = 1, #Audio._sources do
        Audio._sources[i]:resume()
    end
end

GG.Audio = Audio
