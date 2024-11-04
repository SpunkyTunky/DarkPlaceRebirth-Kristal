local character, super = Class(PartyMember, "noel")

function character:init()
    super.init(self)
    self.set_buttons = {"magic", "item", "spare", "tension"}
    -- Display name
    self.name = "Noel"

    self.cm_draw = true

    -- Actor (handles sprites)
    self:setActor("noel")
    local lever = "-1"
    -- Display level (saved to the save file)
    self.level = lever
    -- Default title / class (saved to the save file)
    self.title = "Preist.\nDoesn't understand\nhow his class works."

    -- Determines which character the soul comes from (higher number = higher priority)
    self.soul_priority = 0.1
    -- The color of this character's soul (optional, defaults to red)
    self.soul_color = {1, 1, 1}

    -- Whether the party member can act / use spells
    self.has_act = false
    self.has_spells = true

    -- Whether the party member can use their X-Action
    self.has_xact = true
    -- X-Action name (displayed in this character's spell menu)
    self.xact_name = "Noel-Act"

    -- Spells
    self:addSpell("spare_smack")
    self:addSpell("soul_send")
    self:addSpell("quick_heal")
    self:addSpell("life_steal")


    -- Current health (saved to the save file)
    self.health = 890
    self.lw_health = 890

    -- Base stats (saved to the save file)
    self.stats = {
        health = 900,
        attack = 1,
        defense = -100,
        magic = 1
    }

    -- Max stats from level-ups
    self.max_stats = {
        health = 900,
        attack = 1,
        defense = -100,
        magic = 1
    }

    self.lw_stats = {
        health = 900,
        attack = 11,
        defense = -90,
        magic = 1
    }

    -- Max stats from level-ups
    self.lw_max_stats = {
        health = 900,
        attack = 11,
        defense = -90,
        magic = 1
    }

    -- Weapon icon in equip menu
    self.weapon_icon = "ui/menu/equip/old_umbrella"

    -- Equipment (saved to the save file)

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "light/old_umbrella"
    self.weapon_default = "old_umbrella"
    --self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    self.color = {1, 1, 1}
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = {1, 1, 1}
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.attack_bar_color = {1, 1, 1}
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = {1, 1, 1}
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = {1, 1, 1}

    -- Head icon in the equip / power menu
    self.menu_icon = "party/noel/head"
    -- Path to head icons used in battle
    self.head_icons = "party/noel/icon"
    -- Name sprite (optional)
    --self.name_sprite = "party/noel/name"

    -- Effect shown above enemy after attacking it
    --self.attack_sprite = "effects/attack/slap_n"
    -- Sound played when this character attacks
    self.attack_sound = "laz_c"
    -- Pitch of the attack sound
    self.attack_pitch = 0.8
    -- Battle position offset (optional)
    self.battle_offset = {0, 0}
    -- Head icon position offset (optional)
    self.head_icon_offset = nil
    -- Menu icon position offset (optional)
    self.menu_icon_offset = nil

    -- Message shown on gameover (optional)
    self.gameover_message = nil

    local save = Game:loadNoel()
    if save and not Kristal.temp_save == true then
            self:loadEquipment(save.Equipped)
        self.health = save.Health
        self.lw_health = save.Health
    else
        self:setWeapon("old_umbrella")
    end

    self.kills = 0

    self.opinions = {}
    self.default_opinion = 0

end

function character:getGameOverMessage(main)
    local save = Game:loadNoel()
    assert(save)
    return {
        "oh...[wait:5]\nYou died...",
        save.Player_Name.."...\n[wait:10]It's your call."
    }
end

--function character:n()

function character:save()
    local data = {
        id = self.id,
        title = self.title,
        level = self.level,
        health = self.health,
        stats = self.stats,
        lw_lv = self.lw_lv,
        lw_exp = self.lw_exp,
        lw_health = self.lw_health,
        lw_stats = self.lw_stats,
        spells = self:saveSpells(),
        equipped = self:saveEquipment(),
        flags = self.flags, 
        kills = self.kills,
    }

    if Kristal.temp_save == true then
    else
        local num = love.math.random(1, 999999)
        Game:setFlag("noel_SaveID", num)

    local save = Noel:loadNoel()
    --if save then
        local newData = {
            Attack = self.stats.attack,
            Magic = self.stats.magic,
            MaxHealth = self.stats.health,
            Health = self.health,
            Defense = self.stats.defense,
            Equipped = self:saveEquipment(),
            Spells = self:saveSpells(),
            Level = self.level,
            Kills = self.kills
        }    

        Noel:saveNoel(newData)

        local left_behind = Game:getFlag("noel_at")

            local maptable ={
                SaveID = num,
                Map = Game.world.map.id
            }

            Noel:saveNoel(maptable)

    end


    self:onSave(data)
    return data
end

function character:load(data)

    local save = Game:loadNoel()
    local save_stat = {}
    local lw_save_stat = {}
    if save then
        save_stat = {
            health = save.MaxHealth,
            attack = save.Attack,
            defense = save.Defense,
            magic = save.Magic
        }
        lw_save_stat = {
            health = save.MaxHealth,
            attack = save.Attack + 10,
            defense = save.Defense + 10,
            magic = save.Magic
        }
    end

    self.title = data.title or self.title

    if save then
        self.stats = save_stat or data.stats or self.stats
        self.health = save.Health or data.health or self:getStat("health", 0, false)
        if data.spells then
            self:loadSpells(save.Spells)
        end

        self.kills = save.Kills or self.kills

        self:loadEquipment(save.Equipped)

        self.level = save.Level or data.level or self.level
        self.lw_lv = save.Level or data.lw_lv or self.lw_lv
        self.lw_exp = data.lw_exp or self.lw_exp
        self.lw_stats = lw_save_stat or data.lw_stats or self.lw_stats
        self.flags = data.flags or self.flags
        self.lw_health = save.Health or data.lw_health or self:getStat("health", 0, true)
    else
        self.stats = data.stats or self.stats
        self.health = data.health or self:getStat("health", 0, false)
        if data.spells then
            self:loadSpells(data.spells)
        end
        if data.equipped then
            self:loadEquipment(data.equipped)
        end
        self.level = data.level or self.level
        self.lw_lv = data.lw_lv or self.lw_lv
        self.lw_exp = data.lw_exp or self.lw_exp
        self.lw_stats = data.lw_stats or self.lw_stats
        self.flags = data.flags or self.flags
        self.lw_health = data.lw_health or self:getStat("health", 0, true)
    end

    self:onLoad(data)

    if Kristal.temp_save == true then
        Kristal.temp_save = nil
    end
end

function character:CharacterMenuDraw()

    local party = self
	local x = 330
	love.graphics.print("ATK "..party.stats["attack"], x, 310)
	love.graphics.print("PAIN x10", x, 342)
	love.graphics.print("MAG "..party.stats["magic"], x, 374)

	x = 420

	love.graphics.print("HP "..party.health.."/"..party.stats["health"], x, 310)
	love.graphics.print("   LOVE -1", x, 342)
	love.graphics.print("KILLS "..party.kills, x, 374)
end

return character