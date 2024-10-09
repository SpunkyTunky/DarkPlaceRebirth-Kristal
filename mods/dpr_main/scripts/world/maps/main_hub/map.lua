local MainHub, super = Class(Map)

function MainHub:onEnter()
    super.onEnter(self)
    if DTRANS then
        Game.world:startCutscene("darkenter")
    end
end

return MainHub