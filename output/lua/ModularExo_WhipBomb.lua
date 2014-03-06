
Script.Load("lua/WhipBomb.lua")

local orig_WhipBomb_ProcessHit = WhipBomb.ProcessHit
function WhipBomb:ProcessHit(ent, surface, normal)
    if ent and ent:isa("ExoShield") then
        ent:AbsorbProjectile(self)
        if self.shooter then
            self.shooter:OnBombDetonation(self)
        end
        DestroyEntity(self)
        return
    end
    return orig_WhipBomb_ProcessHit(self, ent, surface, normal)
end

GetEffectManager():AddEffectData("ModularExo_ExoShield_WhipBomb_Absorb", {
    whipbomb_absorb = {
        effects = {
            {cinematic = "cinematics/marine/arc/hit_med.cinematic"},      
        },
    },
})

