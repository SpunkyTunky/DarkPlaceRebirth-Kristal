local actor, super = Class(Actor, "marcy")

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "Marcy"

    -- Width and height for this actor, used to determine its center
    self.width = 21
    self.height = 32

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {5, 27, 10, 5}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "world/npcs/marcy"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "light"

    -- Sound to play when this actor speaks (optional)
    self.voice = "marcy"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = "face/marcy"
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = {0, 4}

    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false
	
	self.offsets = {
        -- Movement offsets
        ["light/left"] = {0, 0},
        ["light/right"] = {0, 0},
        ["light/up"] = {0, 0},
        ["light/down"] = {0, 0},
		
        ["light_church/left"] = {0, 0},
        ["light_church/right"] = {0, 0},
        ["light_church/up"] = {0, 0},
        ["light_church/down"] = {0, 0},

        ["criss_cross"] = {0, 8},
        ["criss_cross_right"] = {0, 8},
        ["criss_cross_down"] = {0, 8},

        ["slide"] = {0, 0},
    }

    self.mirror_sprites = {
        ["light/down"] = "light/up",
        ["light/up"] = "light/down",
        ["light/left"] = "light/left",
        ["light/right"] = "light/right",
		
        ["light_church/down"] = "light_church/up",
        ["light_church/up"] = "light_church/down",
        ["light_church/left"] = "light_church/left",
        ["light_church/right"] = "light_church/right",
    }
	
	self.shiny_id = "jamm"
end

function actor:getDefaultSprite()
	return Game:getFlag("marcy_pirate") and "patch" or "walk"
end

return actor