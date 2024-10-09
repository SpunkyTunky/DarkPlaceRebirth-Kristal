local item, super = Class(HealItem, "cheeseslice")

function item:init()
    super.init(self)

    self.name = "CheeseSlice"
    self.use_name = nil

    self.type = "item"
    self.icon = nil

    self.effect = "Heals\n50HP"
    self.shop = "A classic\nslice of\ncheese!\nHeals 50HP"
    self.description = "Heals 50 HP. A slice of American-style cheese."

    self.heal_amount = 50

    self.price = 50
    self.can_sell = true

    self.target = "ally"
    self.usable_in = "all"
    self.result_item = nil
    self.instant = false

    self.bonuses = {}
    self.bonus_name = nil
    self.bonus_icon = nil

    self.can_equip = {}

    self.reactions = {
        susie = "Eh, better than nothing.",
        ralsei = "Tastes... okay...?",
        noelle = "It barely tastes like real cheese...",
        dess = "HELL YEAH AN AMERICAN CLASSIC!!!!",
        brenda = "The perfect midnight snack.",
        jamm = "",
    }
end

function item:getReaction(user_id, reactor_id)
    if user_id == "jamm" and reactor_id == user_id and Game:getFlag("marcy_joined") then
		return ""
	end
	return super.getReaction(self, user_id, reactor_id)
end

return item