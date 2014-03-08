
Script.Load("lua/Weapons/Alien/Bomb.lua")

Bomb.kBileBombDotIntervall = GetLocal(Bomb.ProcessHit, "kBileBombDotIntervall")

local orig_Bomb_ProcessHit = Bomb.ProcessHit
function Bomb:ProcessHit(ent, surface, normal)
    if ent and ent:isa("ExoShield") then
        ent:AbsorbProjectile(self)
        DestroyEntity(self)
        return
    end
    return orig_Bomb_ProcessHit(self, ent, surface, normal)
end

GetEffectManager():AddEffectData("ModularExo_ExoShield_Bomb_Absorb", {
    bomb_absorb = {
        effects = {
            {cinematic = "cinematics/marine/arc/hit_med.cinematic"},      
        },
    },
})
