local ElevatorDoor, super = Class(Event)

function ElevatorDoor:init(data)
    super.init(self, data.x, data.y, data.width, data.height)

    self.solid = true

    local properties = data.properties or {}

    --TO-DO: find a way to make these sprites customizable.
    self.sprite_inside     = Sprite("world/events/elevatordoor/floor1/inside")
    self.sprite_door_left  = Sprite("world/events/elevatordoor/floor1/door")
    self.sprite_door_right = Sprite("world/events/elevatordoor/floor1/door")
    self.sprite_frame      = Sprite("world/events/elevatordoor/floor1/frame")
    
    self.sprite_inside.debug_select = false
    self.sprite_door_left.debug_select = false
    self.sprite_door_right.debug_select = false
    --self.sprite_frame.debug_select = false
    
    self:addChild(self.sprite_inside)
    self:addChild(self.sprite_door_left)
    self:addChild(self.sprite_door_right)
    --self:addChild(self.sprite_frame)


    self.sprite_inside:setScale(2)
    self.sprite_door_left:setScale(2)
    self.sprite_door_right:setScale(2)
    self.sprite_frame:setScale(2)

    self.sprite_frame.x = 15
    self.sprite_frame.y = -65
    
    self.sprite_door_left.x = 23
    self.sprite_door_left.y = -55
    self.sprite_door_right.x = 61
    self.sprite_door_right.y = -55
    
    self.sprite_inside.x = 15
    self.sprite_inside.y = -65


end

function ElevatorDoor:onInteract()
    self.solid = not self.solid
    if not self.solid then
        self:open()
    elseif self.solid then
        self:close()
    end
end

function ElevatorDoor:open()
    Assets.playSound("elecdoor_open")
    self.sprite_door_left:slideTo(-20, self.sprite_door_left.y, 0.3)
    self.sprite_door_right:slideTo(104, self.sprite_door_right.y, 0.3)
end

function ElevatorDoor:close()
    Assets.playSound("elecdoor_close")
    self.sprite_door_left:slideTo(23, self.sprite_door_left.y, 0.3)
    self.sprite_door_right:slideTo(61, self.sprite_door_right.y, 0.3)
end

function ElevatorDoor:draw()
    Draw.scissor(self.sprite_frame.x, self.sprite_frame.y, self.sprite_frame.width*2-20, self.sprite_frame.height*2)
    super.draw(self)
    love.graphics.setScissor()
    love.graphics.draw(Assets.getTexture("world/events/elevatordoor/floor1/frame"), 15, -65, 0, 2, 2)
end

return ElevatorDoor