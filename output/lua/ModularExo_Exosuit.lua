
Script.Load("lua/Exosuit.lua")

local kAnimationGraphSpawnOnly = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphEject = PrecacheAsset("models/marine/exosuit/exosuit_spawn_animated.animation_graph")

local networkVars = {
    
}

local orig_Exosuit_OnInitialized = Exosuit.OnInitialized
function Exosuit:OnInitialized()
    orig_Exosuit_OnInitialized(self)
    if Server then
        Exo.InitExoModel(self, kAnimationGraphEject)
    end
end

if Server then
    local orig_Exosuit_OnUse = Exosuit.OnUse
    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
        if self:GetIsValidRecipient(player) then
            local weapons = player:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)
            end
            local exoPlayer = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, spawnPoint, {
                powerModuleType    = self.powerModuleType   ,
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType ,
                armorModuleType    = self.armorModuleType   ,
                utilityModuleType  = self.utilityModuleType ,
            })
            exoPlayer.prevPlayerMapName = player:GetMapName()
            exoPlayer.prevPlayerHealth = player:GetHealth()
            exoPlayer.prevPlayerMaxArmor = player:GetMaxArmor()
            exoPlayer.prevPlayerArmor = player:GetArmor()  
            if exoPlayer then
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end
                exoPlayer:SetMaxArmor(self:GetMaxArmor())  
                exoPlayer:SetArmor(self:GetArmor())
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                -- the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                self:TriggerEffects("pickup")
                DestroyEntity(self)
            end
        end
    end
end

Class_Reload("Exosuit", networkVars)
