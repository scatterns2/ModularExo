
Script.Load("lua/LiveMixin.lua")

local orig_LiveMixin_TakeDamage = LiveMixin.TakeDamage
function LiveMixin:TakeDamage(...)
    if self.OverrideTakeDamage then
        return self:OverrideTakeDamage(...)
    end
    orig_LiveMixin_TakeDamage(self, ...)
end
