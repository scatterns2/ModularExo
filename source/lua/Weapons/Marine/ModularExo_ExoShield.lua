// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Marine\ExoShield.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'ExoShield' (Entity)

ExoShield.kMapName = "exoshield"

local networkVars =
{
    clawAttacking = "private boolean"
}

local kClawRange = 2.2

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function ExoShield:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.clawAttacking = false
    
end

function ExoShield:GetMeleeBase()
    return 1, 0.8
end

function ExoShield:GetMeleeOffset()
    return 0.0
end

function ExoShield:OnPrimaryAttack(player)
    self.clawAttacking = true
end

function ExoShield:OnPrimaryAttackEnd(player)
    self.clawAttacking = false
end

function ExoShield:GetDeathIconIndex()
    return kDeathMessageIcon.ExoShield
end

function ExoShield:ProcessMoveOnWeapon(player, input)
end

function ExoShield:GetWeight()
    return kClawWeight
end

function ExoShield:OnTag(tagName)

    PROFILE("ExoShield:OnTag")

    local player = self:GetParent()
    if player then
    
        if tagName == "hit" then
            AttackMeleeCapsule(self, player, kClawDamage, kClawRange)
        elseif tagName == "claw_attack_start" then
            player:TriggerEffects("claw_attack")
        end
        
    end
    
end

function ExoShield:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), self.clawAttacking)
end

Shared.LinkClassToMap("ExoShield", ExoShield.kMapName, networkVars)