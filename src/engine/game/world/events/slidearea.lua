local SlideArea, super = Class(Event)

function SlideArea:init(data)
    super:init(self, data.x, data.y, data.width, data.height)

    self.solid = false

    self.sliding = false

    self:setOrigin(0, 0)
    self:setHitbox(0, 0, data.width, data.height)
end

function SlideArea:onCollide(character)
    if character.y <= self.y and character:includes(Player) then
        self.solid = false
        self.sliding = true

        character:setState("SLIDE")
    end
end

function SlideArea:update(dt)
    if not Game.world.player then return end

    if Game.world.player.y > self.y + self.height then
        if self.sliding and not Game.world.player:collidesWith(self.collider) then
            self.sliding = false
            self.solid = true
            Game.world.player:setState("WALK")
        end
    end

    super:update(self, dt)
end

return SlideArea