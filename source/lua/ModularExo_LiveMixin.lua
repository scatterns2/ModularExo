
Script.Load("lua/LiveMixin.lua")

local orig_LiveMixin_TakeDamage = LiveMixin.TakeDamage
function LiveMixin:TakeDamage(...)
    local shouldExecuteTakeDamage, killedFromDamage, damageDone = true
    if self.OverrideTakeDamage then
        shouldExecuteTakeDamage, killedFromDamage, damageDone = self:OverrideTakeDamage(...)
    end
    if shouldExecuteTakeDamage then
        killedFromDamage, damageDone = orig_LiveMixin_TakeDamage(self, ...)
    end
    return killedFromDamage, damageDone
end
