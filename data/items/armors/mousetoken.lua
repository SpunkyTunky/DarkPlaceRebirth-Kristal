local item, super = Class(Item, "mousetoken")

function item:init()
    super.init(self)

    -- Display name
    self.name = "MouseToken"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Item icon (for equipment)
    self.icon = "ui/menu/icon/armor"

    -- Battle description
    self.effect = ""
    -- Shop description
    self.shop = "Magic up. It\nlooks cool!"
    -- Menu description
    self.description = "A golden coin with a once-powerful mousewizard engraved on it."

    -- Default shop price (sell price is halved)
    self.price = 120
    -- Whether the item can be sold
    self.can_sell = true

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "none"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        magic = 2,
    }
    -- Bonus name and icon (displayed in equip menu)
    self.bonus_name = nil
    self.bonus_icon = nil

    -- Equippable characters (default true for armors, false for weapons)
    self.can_equip = {}

    -- Character reactions
    self.reactions = {
        susie = "This guy's... familiar?",
        ralsei = "Chu! Healing power UP!",
        noelle = "... from the family entertainment center?",
        dess = "ermmm possible chuck-e-cheese reference?",
        jamm = "This brings back memories.",
        noel = "Is this from a resturant?",
    }
end

function item:getReaction(user_id, reactor_id)
    if user_id == "jamm" and reactor_id == user_id and Game:getFlag("marcy_joined") then
		return "Marcy wants to go there! // Maybe soon, Marcy."
	end
	return super.getReaction(self, user_id, reactor_id)
end

return item