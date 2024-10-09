local Noel = {}
local self = Noel

function Noel:checkNoel()
    local noelsave = Noel:loadNoel()
    if noelsave and Game:hasPartyMember("noel") and noelsave.SaveID ~= Game:getFlag("noel_SaveID") then
        Game:removePartyMember("noel")
        Game.world:removeFollower("noel")
        local noel = Game.world:getCharacter("noel")
        if noel then noel:remove() end
        Noel:NoelEnter(noelsave)
    end
end

function Noel:test()
    print("bithc")
end

local place_holder = function(cutscene, event)
    cutscene:text("* Placeholder.", "bruh", "noel")
end

local wake = function(cutscene, event)
            Game.world.music:fade(0, 0.25)

            local turncoat = Music("turncoat", 1, 1)

        local index = love.window.showMessageBox("???", "* ...", {"    "}, "info")
        local index = love.window.showMessageBox("???", "* Hello?", {"    "}, "info")
        local index = love.window.showMessageBox("???", "* Is anyone there?", {"    "}, "info")
        local index = love.window.showMessageBox("???", "* Can anyone hear me?", {"    "}, "warning")


        turncoat:stop()
        Game.world.music:fade(1, 0.5)

    --cutscene:text("* The wall seems cracked.", "bruh", "noel")
end

function Noel:NoelEnter(noelsave)
    local savedData = noelsave
    local map = Game.world.map.id
    local mod = Mod.info.id

        local spawnPositions = {
            warphub = {384, 361, {cutscene = place_holder, animation = "brella"}},
            room1 = {400, 740, {cutscene = place_holder, animation = "brella"}},
            main_hub = {460, 380, {cutscene = wake, animation = "battle/defeat"}},
        }

    if map == savedData.Map and mod == savedData.Mod then
        local position = spawnPositions[savedData.Map] 
        if position then
            if position[3] then
                Noel:spawnNoel(position[1], position[2], position[3])
            else
                Noel:spawnNoel(position[1], position[2])
            end
        end
    end
end

function Noel:spawnNoel(x, y, data)
    if Game:hasPartyMember("noel") then
        Noel:checkNoel()
    else
        if data then
            Game.world:spawnNPC("noel", x, y, data)
        else
            Game.world:spawnNPC("noel", x, y, {cutscene = "noel.found_again"})
        end
    end
end


function Noel:saveNoel(new_data)
    local save_dir = "saves"
    local n_save = save_dir.."/null.char"

    local data = self:loadNoel() or {}
    if new_data then
        for k, v in pairs(new_data) do
            data[k] = v
        end
    end

    love.filesystem.createDirectory(save_dir)
    love.filesystem.write(n_save, JSON.encode(data))
end

function Noel:loadNoel()
    local save_dir = "saves"
    local n_save = save_dir.."/null.char"
    if love.filesystem.getInfo(n_save) then
        return JSON.decode(love.filesystem.read(n_save))
    end
    return nil
end

function Noel:findDifferenceIndex(text, text2)
    local minLen = math.min(#text, #text2)
    for i = 1, minLen do
        if text:sub(i, i) ~= text2:sub(i, i) then
            return i
        end
    end
    return minLen
end

function Noel:noels_annoyance(cutscene)
    if not Game:getFlag("noel's_annoyance") then
        Game:setFlag("noel's_annoyance", 1)
    elseif Game:getFlag("noel's_annoyance") == 5 then
        cutscene:showNametag("Noel")
        local thing = love.math.random(1, 2)
        if thing == 1 then
            cutscene:text("* OH,[wait:5] MY,[wait:5] GOD!!!", "madloud", "noel")
            cutscene:text("* This is the dumbest puzzle ever, I'm leaving!", "madloud", "noel")
        elseif thing == 2 then
            cutscene:text("* Looks like you're in a bit of a pickle [color:yellow]"..Game.save_name.."[color:white].", "bruh", "noel")
            cutscene:text("* Don't worry.[wait:8] [face:neutral]For 12[color:yellow] PlayCoins[font:small]TM[font:main][color:white]\nI could teleport you to the nearest [color:yellow]CHECKPOINT[color:white]!", "lookup", "noel")
        -- noel random saying "this stinks, im leaving", or "playcoins or sum shit"
        end
        cutscene:hideNametag()
    else
        Game:setFlag("noel's_annoyance", Game:getFlag("noel's_annoyance") + 1)
    end
end


--Didnt think it was good enough 
--[[
        Game.world:startCutscene(function (cutscene, event)
            Game.world.music:fade(0, 0.25)

            local turncoat = Music("turncoat", 1, 1)

            local index = love.window.showMessageBox("???", "* Don't panic!", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* The game didn't crash!", {"    "}, "info")

            local index = love.window.showMessageBox("???", "* This is a prewritten message...", {"    "}, "warning")

            local index = love.window.showMessageBox("???", "* If youre reading this.", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* I'm probably not awake yet.", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* And won't be for a while.", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* ...", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* What are you waiting for!!!", {"    "}, "warning")
            local index = love.window.showMessageBox("???", "* Wake me up already "..Game.save_name.."!!!", {"    "}, "warning")

            turncoat:stop()
            Game.world.music:fade(1, 0.5)
            --cutscene:text("* The wall seems cracked.", "bruh", "noel")
        end)
]]

return Noel