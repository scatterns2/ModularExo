
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'ExoShield' (Entity)

ExoShield.kMapName = "exoshield"

local networkVars = {
    isShieldActive = "private boolean"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function ExoShield:OnCreate()
    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.isShieldActive = false
end

function ExoShield:OnInitialized()
    
end

function ExoShield:OnDestroy()
    Entity.OnDestroy(self)
    
    if Client then
        if self.shieldModel then
            Client.DestroyRenderModel(self.shieldModel)
            self.shieldModel = nil
        end
        if self.clawLight then
            Client.DestroyRenderLight(self.clawLight)
            self.clawLight = nil
        end
    end
end

function ExoShield:OnPrimaryAttack(player)
    self.isShieldActive = true
end

function ExoShield:OnPrimaryAttackEnd(player)
    self.isShieldActive = false
end

function ExoShield:ProcessMoveOnWeapon(player, input)
    
end

--  1 = "Exosuit_UpprTorso"
--  8 = "Exosuit_LClavicle"
-- 58 = "Exosuit_LShldr"
-- 59 = "Exosuit_LElbow"
-- 63 = "Exosuit_LWrist"
-- 68 = "bone_Claw_Thumb_turner"
-- 69 = "bone_Claw_Thumb_base"
-- 70 = "bone_Claw_Thumb_mid"
-- 71 = "bone_Claw_Thumb_end"
function ExoShield:OnUpdateRender()
    local player = self:GetParent()
    if not self.clawLight then
        self.clawLight = Client.CreateRenderLight()
        self.clawLight:SetType(RenderLight.Type_Point)
    end
    self.clawLight:SetCastsShadows(false)
    self.clawLight:SetRadius(4)
    self.clawLight:SetIntensity(100)
    self.clawLight:SetColor(Color(0, 0.7, 1, 1))
    self.clawLight:SetAtmosphericDensity(1)
    self.clawLight:SetSpecular(0)
    
    local shouldDisplayAsViewModel = (player == Client.GetLocalPlayer() and player:GetIsFirstPerson())
    if not self.shieldModel or (shouldDisplayAsViewModel ~= self.shieldModelIsViewModel) then
        if self.shieldModel then
            Client.DestroyRenderModel(self.shieldModel)
            self.shieldModel = nil
        end
        self.shieldModelIsViewModel = shouldDisplayAsViewModel
        self.shieldModel = Client.CreateRenderModel(shouldDisplayAsViewModel and RenderScene.Zone_ViewModel or RenderScene.Zone_Default)
        self.shieldModel:SetModel("models/props/refinery/refinery_crate_01.model")
        self.shieldModel:SetIsVisible(true)
    end
    
    if shouldDisplayAsViewModel then
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
            local coords = viewModel.boneCoords:Get(6-1)
            
            local modelMiddleCoords = Coords.GetIdentity()
            modelMiddleCoords.origin = Vector(0, -0.15, 0)
            
            coords = coords*modelMiddleCoords
            
            coords:Scale(0.3)
            
            self.shieldModel:SetCoords(coords)
        end
    end
    
    local coords = player._renderModel and player._renderModel:GetCoords() or Coords.GetIdentity()
    
    coords = coords*player.boneCoords:Get(63-1)
    
    local modelMiddleCoords = Coords.GetIdentity()
    modelMiddleCoords.origin = Vector(0, -0.15, 0)
    
    coords = coords*modelMiddleCoords
    
    coords:Scale(0.3)
    if not shouldDisplayAsViewModel then
        self.shieldModel:SetCoords(coords)
    end
    self.clawLight:SetCoords(coords)
    
end


function ExoShield:OnTag(tagName)
    PROFILE("ExoShield:OnTag")
    local player = self:GetParent()
    if player then
        if tagName == "hit" then
        elseif tagName == "claw_attack_start" then
            --player:TriggerEffects("claw_attack")
        end
    end
end

function ExoShield:OnUpdateAnimationInput(modelMixin)
    --modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), self.isShieldActive)
end

function ExoShield:GetWeight()
    return 0
end

Shared.LinkClassToMap("ExoShield", ExoShield.kMapName, networkVars)
