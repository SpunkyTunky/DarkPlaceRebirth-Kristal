local LightBattleCutscene, super = Class(Cutscene, "LightBattleCutscene")

local function _true() return true end

function LightBattleCutscene:init(group, id, ...)
    local scene, args = self:parseFromGetter(MagicalGlass.getLightBattleCutscene, group, id, ...)

    self.changed_sprites = {}
    self.waiting_for_text = nil
    self.waiting_for_enemy_text = nil

    self.last_battle_state = Game.battle.state
    Game.battle:setState("CUTSCENE")

    super.init(self, scene, unpack(args))
end

function LightBattleCutscene:onEnd()
    if Game.battle.cutscene == self then
        Game.battle.cutscene = nil
    end

    if Game.battle.battle_ui then
        Game.battle.battle_ui:clearEncounterText()

        Game.battle.battle_ui.encounter_text.active = true
        Game.battle.battle_ui.encounter_text.visible = true

        Game.battle.battle_ui.choice_box:clearChoices()
        Game.battle.battle_ui.choice_box.active = false
        Game.battle.battle_ui.choice_box.visible = false
    end

    self:resetSprites()

    if self.finished_callback then
        self.finished_callback(self)
    else
        Game.battle:setState(self.last_battle_state, "CUTSCENE")
    end
end

function LightBattleCutscene:getEnemy(id)
    for _,battler in ipairs(Game.battle.enemies) do
        if battler.id == id then
            return battler
        end
    end
end

function LightBattleCutscene:getEnemies(id)
    local result = {}
    for _,battler in ipairs(Game.battle.enemies) do
        if battler.id == id then
            table.insert(result, battler)
        end
    end
    return result
end

function LightBattleCutscene:getUser()
    return Game.battle.party[Game.battle:getCurrentAction().party_index]
end

function LightBattleCutscene:getTarget()
    return Game.battle:getCurrentAction().target
end

function LightBattleCutscene:resetSprites()
    for battler,_ in pairs(self.changed_sprites) do
        battler:toggleOverlay(false)
    end
    self.changed_sprites = {}
end

function LightBattleCutscene:setSprite(enemy, sprite, speed)
    if type(enemy) == "string" then
        enemy = self:getEnemy(enemy)
    end
    enemy:toggleOverlay(true)
    enemy.overlay_sprite:setSprite(sprite)
    if speed then
        enemy.overlay_sprite:play(speed, true)
    end
    self.changed_sprites[enemy] = true
end

function LightBattleCutscene:setAnimation(enemy, anim)
    if type(enemy) == "string" then
        enemy = self:getEnemy(enemy)
    end
    local done = false
    enemy:toggleOverlay(true)
    enemy.overlay_sprite:setAnimation(anim, function() done = true end)
    self.changed_sprites[enemy] = true
    return function() return done end
end

function LightBattleCutscene:slideTo(obj, x, y, time, ease)
    if type(obj) == "string" then
        obj = self:getEnemy(obj)
    end
    local slided = false
    if obj:slideTo(x, y, time, ease, function() slided = true end) then
        return function() return slided end
    else
        return _true
    end
end

function LightBattleCutscene:slideToSpeed(obj, x, y, speed)
    if type(obj) == "string" then
        obj = self:getEnemy(obj)
    end
    local slided = false
    if obj:slideToSpeed(x, y, speed, function() slided = true end) then
        return function() return slided end
    else
        return _true
    end
end

function LightBattleCutscene:shakeCharacter(chara, x, y, friction, delay)
    if type(chara) == "string" then
        chara = self:getEnemy(chara)
    end
    chara.sprite:shake(x, y, friction, delay)
    chara.overlay_sprite:shake(x, y, friction, delay)
    return function() return chara.sprite.graphics.shake_x == 0 and chara.sprite.graphics.shake_y == 0 end
end

local function cameraShakeCheck() return Game.battle.camera.shake_x == 0 and Game.battle.camera.shake_y == 0 end
function LightBattleCutscene:shakeCamera(x, y, friction)
    Game.battle:shakeCamera(x, y, friction)
    return cameraShakeCheck
end

function LightBattleCutscene:alert(chara, ...)
    if type(chara) == "string" then
        chara = self:getEnemy(chara)
    end
    local function waitForAlertRemoval() return chara.alert_icon == nil or chara.alert_timer == 0 end
    return chara:alert(...), waitForAlertRemoval
end

function LightBattleCutscene:fadeOut(speed, options)
    options = options or {}

    local fader = Game.fader

    if speed then
        options["speed"] = speed
    end

    local fade_done = false

    fader:fadeOut(function() fade_done = true end, options)

    return function() return fade_done end
end

function LightBattleCutscene:fadeIn(speed, options)
    options = options or {}

    local fader = Game.fader

    if speed then
        options["speed"] = speed
    end

    local fade_done = false

    fader:fadeIn(function() fade_done = true end, options)

    return function() return fade_done end
end

function LightBattleCutscene:setSpeaker(actor)
    if isClass(actor) and (actor:includes(LightPartyBattler) or actor:includes(LightEnemyBattler)) then
        actor = actor.actor
    end
    self.textbox_actor = actor
end

local function waitForEncounterText() return Game.battle.battle_ui.encounter_text.text.text == "" end
function LightBattleCutscene:text(text, portrait, actor, options)
    if type(actor) == "table" then
        options = actor
        actor = nil
    end
    if type(portrait) == "table" then
        options = portrait
        portrait = nil
    end

    options = options or {}

    actor = actor or self.textbox_actor

    Game.battle.battle_ui.encounter_text:setActor(actor)
    Game.battle.battle_ui.encounter_text:setFace(portrait, options["x"], options["y"])

    Game.battle.battle_ui.encounter_text:resetReactions()
    if options["reactions"] then
        for id,react in pairs(options["reactions"]) do
            Game.battle.battle_ui.encounter_text:addReaction(id, react[1], react[2], react[3], react[4], react[5])
        end
    end

    Game.battle.battle_ui.encounter_text:resetFunctions()
    if options["functions"] then
        for id,func in pairs(options["functions"]) do
            Game.battle.battle_ui.encounter_text:addFunction(id, func)
        end
    end

    if options["font"] then
        if type(options["font"]) == "table" then
            -- {font, size}
            Game.battle.battle_ui.encounter_text:setFont(options["font"][1], options["font"][2])
        else
            Game.battle.battle_ui.encounter_text:setFont(options["font"])
        end
    else
        Game.battle.battle_ui.encounter_text:setFont()
    end

    Game.battle.battle_ui.encounter_text:setAlign(options["align"])

    Game.battle.battle_ui.encounter_text:setSkippable(options["skip"] or options["skip"] == nil)
    Game.battle.battle_ui.encounter_text:setAdvance(options["advance"] or options["advance"] == nil)
    Game.battle.battle_ui.encounter_text:setAuto(options["auto"])

    Game.battle.battle_ui.encounter_text:setText(text, function()
        Game.battle.battle_ui:clearEncounterText()
        self:tryResume()
    end)

    local wait = options["wait"] or options["wait"] == nil
    if not Game.battle.battle_ui.encounter_text.text.can_advance then
        wait = options["wait"] -- By default, don't wait if the textbox can't advance
    end

    if wait then
        return self:wait(waitForEncounterText)
    else
        return waitForEncounterText
    end
end

function LightBattleCutscene:battlerText(battlers, text, options)
    options = options or {}
    if type(battlers) == "string" then
        local id = battlers
        battlers = {}
        for _,battler in ipairs(Game.battle.enemies) do
            if battler.id == id then
                table.insert(battlers, battler)
            end
        end
    elseif isClass(battlers) then
        battlers = {battlers}
    end
    local wait = options["wait"] or options["wait"] == nil
    local bubbles = {}
    for _,battler in ipairs(battlers) do
        local bubble
        if not options["x"] and not options["y"] then
            bubble = battler:spawnSpeechBubble(text, options)
        else
            bubble = SpeechBubble(text, options["x"] or 0, options["y"] or 0, options, battler)
            Game.battle:addChild(bubble)
        end
        bubble:setAdvance(options["advance"] or options["advance"] == nil)
        bubble:setAuto(options["auto"])
        if not bubble.text.can_advance then
            wait = options["wait"]
        end
        bubble:setCallback(function()
            bubble:remove()
            local after = options["after"]
            if after then after() end
        end)
        if options["line_callback"] then
            bubble:setLineCallback(options["line_callback"])
        end
        table.insert(bubbles, bubble)
    end
    local wait_func = function()
        for _,bubble in ipairs(bubbles) do
            if not bubble:isDone() then
                return false
            end
        end
        return true
    end
    if wait then
        return self:wait(wait_func)
    else
        return wait_func, bubbles
    end
end

function LightBattleCutscene:speechBubble(text, x, y, options)
    options = options or {}
    local wait = options["wait"] or options["wait"] == nil
    local bubble
    bubble = UnderSpeechBubble(text, x, y, options)
    Game.battle:addChild(bubble)
    bubble:setAdvance(options["advance"] or options["advance"] == nil)
    bubble:setAuto(options["auto"])
    if not bubble.text.can_advance then
        wait = options["wait"]
    end
    bubble:setCallback(function()
        bubble:remove()
        local after = options["after"]
        if after then after() end
    end)
    if options["line_callback"] then
        bubble:setLineCallback(options["line_callback"])
    end
    local wait_func = function()
        if not bubble:isDone() then
            return false
        end
        return true
    end
    if wait then
        return self:wait(wait_func)
    else
        return wait_func, bubble
    end
end

local function waitForChoicer() return Game.battle.battle_ui.choice_box.done, Game.battle.battle_ui.choice_box.selected_choice end
function LightBattleCutscene:choicer(choices, options)
    options = options or {}

    Game.battle.battle_ui.choice_box.active = true
    Game.battle.battle_ui.choice_box.visible = true
    Game.battle.battle_ui.encounter_text.active = false
    Game.battle.battle_ui.encounter_text.visible = false

    Game.battle.battle_ui.choice_box.done = false

    Game.battle.battle_ui.choice_box:clearChoices()
    for _,choice in ipairs(choices) do
        Game.battle.battle_ui.choice_box:addChoice(choice)
    end
    Game.battle.battle_ui.choice_box:setColors(options["color"], options["highlight"])

    if options["wait"] or options["wait"] == nil then
        return self:wait(waitForChoicer)
    else
        return waitForChoicer, Game.battle.battle_ui.choice_box
    end
end

function LightBattleCutscene:closeText()
    local choice_box = Game.battle.battle_ui.choice_box
    local text = Game.battle.battle_ui.encounter_text
    if choice_box.active then
        choice_box:clearChoices()
        choice_box.active = false
        choice_box.visible = false
        text.active = true
        text.visible = true
    end
    for _,battler in ipairs(Game.battle:getActiveEnemies()) do
        if battler.bubble then
            battler:onBubbleRemove(battler.bubble)
            battler.bubble:remove()
            battler.bubble = nil
        end
    end
    Game.battle.battle_ui:clearEncounterText()
end

return LightBattleCutscene