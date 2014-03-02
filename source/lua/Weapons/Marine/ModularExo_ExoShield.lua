-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\ExoShield.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'ExoShield' (Entity)

ExoShield.kMapName = "exoshield"

local networkVars =
{
    isShieldActive = "private boolean"
}

local kClawRange = 2.2

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function ExoShield:OnCreate()
    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    if Server then
        self.isShieldActive = false
    elseif Client then
        
    end
end

function ExoShield:OnDestroy()
    Entity.OnDestroy(self)
end

function ExoShield:OnPrimaryAttack(player)
    self.isShieldActive = true
end

function ExoShield:OnPrimaryAttackEnd(player)
    self.isShieldActive = false
end

function ExoShield:ProcessMoveOnWeapon(player, input)
    
end
Print("meow!!")
ExoShield.clawLightAttachPointName = "Exosuit_UpprTorso"
ExoShield.clawLightBoneList = {
     8, -- "Exosuit_LClavicle"
    58, -- "Exosuit_LShldr"
    59, -- "Exosuit_LElbow"
    63, -- "Exosuit_LWrist"
    68, -- "bone_Claw_Thumb_turner"
    69, -- "bone_Claw_Thumb_base"
    70, -- "bone_Claw_Thumb_mid"
    71, -- "bone_Claw_Thumb_mend"
}
function ExoShield:OnUpdateRender()
    local player = self:GetParent()
    if not self.clawLight then
        self.clawLight = Client.CreateRenderLight()
        self.clawLight:SetType(RenderLight.Type_Point)
    end
    self.clawLight:SetCastsShadows(false)
    self.clawLight:SetRadius(2.5)
    self.clawLight:SetIntensity(400)
    self.clawLight:SetColor(Color(0, 0.7, 1, 1))
    self.clawLight:SetAtmosphericDensity(1)
    self.clawLight:SetSpecular(1)
    
    --[[if not self.shieldModel then
        Print("A")
        self.shieldModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        Print("B")
        self.shieldModel:SetModel(Shared.GetModelIndex("models/props/refinery/refinery_crate_01.model"))
        Print("C")
        self.shieldModel:SetIsVisible(true)
        Print("D")
    end]]
    
    self.clawLightAttachPointIndex = self.clawLightAttachPointIndex or player:GetAttachPointIndex(self.clawLightAttachPointName)
    local clawLightCoords = player:GetAttachPointCoords(self.clawLightAttachPointIndex)
    for i = 1, 1 do--#self.clawLightBoneList do
        local boneI = self.clawLightBoneList[i]
        local coords = player.boneCoords:Get(boneI-1)
        clawLightCoords = clawLightCoords*coords
    end
    clawLightCoords.origin = clawLightCoords.origin+player:GetOrigin()
    --Print("%s", tostring(clawLightCoords))
    
    self.clawLight:SetCoords(clawLightCoords)
    --Print("abc")
    --self.shieldModel:SetCoords(Coords.GetIdentity())
    --Print("cba")
end

function ExoShield:OnTag(tagName)
    PROFILE("ExoShield:OnTag")
    local player = self:GetParent()
    if player then
        if tagName == "hit" then
        elseif tagName == "claw_attack_start" then
        end
    end
end

function ExoShield:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), false)
end

function ExoShield:GetWeight()
    return 0
end


Shared.LinkClassToMap("ExoShield", ExoShield.kMapName, networkVars)