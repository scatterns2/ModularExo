
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")

Script.Load("lua/ModularExo_ShieldProjectorMixin.lua")

class 'ExoShield' (Entity)

ExoShield.kMapName = "exoshield"

-- shield state: undeployed --*toggle*-> deployed
--               deployed --*delay*-> active
--               active --*overheat*-> overheated --*delay*-> deployed
--               active --*toggle*-> deployed --*delay-> undeployed
-- combat state: idle --*damage*-> combat --*delay*-> idle

-- TODO: Move balance-related stuff into ModularExo_Balance.lua
ExoShield.kHeatPerDamage = 0.0015

ExoShield.kHeatUndeployedDrainRate = 0.2
ExoShield.kHeatActiveDrainRate = 0.1
ExoShield.kHeatOverheatedDrainRate = 0.13
ExoShield.kHeatCombatDrainRate = 0.05
ExoShield.kCombatDuration = 2.5

ExoShield.kIdleBaseHeatMin = 0.0
ExoShield.kIdleBaseHeatMax = 0.2
ExoShield.kIdleBaseHeatMaxDelay = 10--30
ExoShield.kCombatBaseHeatExtra = 0.1
ExoShield.kOverheatCooldownGoal = 0

ExoShield.kCorrodeDamageScalar = 0.5

ExoShield.kShieldOnDelay = 0.8
ExoShield.kShieldToggleDelay = 1 -- prevent spamming (should be longer than kShieldOnDelay)

ExoShield.kShieldDistance = 2.3
ExoShield.kShieldAngle = math.rad(100)
ExoShield.kShieldDepth = 0.10
ExoShield.kShieldHeight = 2
ExoShield.kPhysBodyCount = 6

ExoShield.kShieldPitchUpDeadzone = math.rad(10)
ExoShield.kShieldPitchUpLimit    = math.rad(30)

ExoShield.kShieldEffectOnDelay = 1
ExoShield.kShieldEffectOffDelay = 0.6

local networkVars = {
    heatAmount = "float (0 to 1 by 0.01)", -- current shield heat
    isShieldDesired = "boolean", -- if the user wants the shield up (click to toggle)
    isShieldDeployed = "boolean", -- if the shield is "powered" (may not be active)
    --isShieldActive = "boolean", -- if the shield is 
    isShieldOverheated = "boolean", -- if the shield is currently cooling down from an overheat
    shieldDeployChangeTime = "time", -- the time the shield was deployed/undeployed
    lastHitTime = "time", -- the last time damage was done to the shield
}

--AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ShieldProjectorMixin, networkVars)

function ExoShield:OnCreate()
    Entity.OnCreate(self)
    
    --InitMixin(self, TechMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, ShieldProjectorMixin)
    
    self.heatAmount = 0
    self.isShieldDesired = false
    self.isShieldDeployed = false
    self.isShieldOverheated = false
    self.shieldDeployChangeTime = 0
    self.lastHitTime = 0
    
    self.isShieldActive = false
    self.idleHeatAmount = 0
    self.isInCombat = false
    
    self.isPhysicsActive = false
    
    if Client then
        self.shieldEffectScalar = 0
    end
    
    --self:SetUpdates(true)
end
function ExoShield:OnInitialized()
    
end
function ExoShield:GetTechId() return nil end
function ExoShield:OnDestroy()
    Entity.OnDestroy(self)
    self:DestroyPhysics()
    if Client then
        if self.shieldModel then
            Client.DestroyRenderModel(self.shieldModel)
            self.shieldModel = nil
        end
        if self.clawLight then
            Client.DestroyRenderLight(self.clawLight)
            self.clawLight = nil
        end
        if self.heatDisplayUI then
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
        end
    end
end

function ExoShield:OnPrimaryAttack(player)
    if not player:GetPrimaryAttackLastFrame() then
        self.isShieldDesired = not self.isShieldDesired -- toggle desired state
    end
end
function ExoShield:OnPrimaryAttackEnd(player)
    
end

function ExoShield:UpdateHeat(dt, shouldSet)
    self.isInCombat = (Shared.GetTime() < self.lastHitTime+self.kCombatDuration)
    local cooldownRate = (
            self.isShieldOverheated and self.kHeatOverheatedDrainRate
        or  not self.isShieldDeployed and self.kHeatUndeployedDrainRate
        or  self.isInCombat and self.kHeatCombatDrainRate
        or  self.kHeatActiveDrainRate
    )
    if self.isShieldOverheated and self.heatAmount <= self.kOverheatCooldownGoal then
        self.isShieldOverheated = false
    end
    local minHeat = 0
    if self.isShieldDeployed then
        local baseHeatScalar = Clamp((Shared.GetTime()-self.shieldDeployChangeTime)/self.kIdleBaseHeatMaxDelay, 0, 1)
        minHeat = minHeat+self.kIdleBaseHeatMin+(self.kIdleBaseHeatMax-self.kIdleBaseHeatMin)*baseHeatScalar
        if self.isInCombat then
            minHeat = minHeat+self.kCombatBaseHeatExtra
        end
        minHeat = Clamp(minHeat+math.sin(Shared.GetTime())*0.06, 0, 1)
    end
    self.idleHeatAmount = minHeat
    
    if self.heatAmount >= 1 then
        self.isShieldOverheated = true
    end
    if shouldSet then
        self.heatAmount = Clamp(self.heatAmount-cooldownRate*dt, minHeat, 1)
    end
end


function ExoShield:AbsorbDamage(damage)
    self.heatAmount = self.heatAmount+self.kHeatPerDamage*damage
    Print("ouch %s! (%s)", damage, self.heatAmount)
    self.lastHitTime = Shared.GetTime()
end
function ExoShield:AbsorbProjectile(projectileEnt)
    if projectileEnt:isa("Bomb") then
        projectileEnt:TriggerEffects("bomb_absorb")
        self:AbsorbDamage(self.kCorrodeDamageScalar)
    elseif projectileEnt:isa("WhipBomb") then
        projectileEnt:TriggerEffects("whipbomb_absorb")
        self:AbsorbDamage(self.kCorrodeDamageScalar)
        self.lastHitTime = Shared.GetTime()
    end
end
function ExoShield:OverrideTakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
    self:AbsorbDamage(damage)
    --Print("ouch %s", damage)
    return false, false, 0.0001 -- must be >0 if you want damage numbers to appear
end

function ExoShield:GetOwner()
    return self:GetParent()
end
function ExoShield:GetIsShieldActive()
    return self.isShieldActive
end
function ExoShield:GetShieldTeam()
    return kMarineTeamType
end
function ExoShield:GetShieldProjectorCoordinates()
    return self:GetShieldCoords()
end
function ExoShield:GetShieldDistance()
    return self.kShieldDistance
end
function ExoShield:GetShieldAngleExtents()
    return self.kShieldAngle/2, self.kShieldAngle/2
end

--function ExoShield:OnUpdate(deltaTime)
function ExoShield:ProcessMoveOnWeapon(player, input)
    local deltaTime = input.time
    local time = Shared.GetTime()
    
    if self.isShieldDesired and not self.isShieldOverheated then
        if not self.isShieldDeployed and time > self.shieldDeployChangeTime+self.kShieldToggleDelay then
            self.isShieldDeployed = true
            self.shieldDeployChangeTime = time
        end
    elseif self.isShieldDeployed and time > self.shieldDeployChangeTime+self.kShieldToggleDelay then
        self.isShieldDeployed = false
        self.shieldDeployChangeTime = time
    end
    
    self.isShieldActive = (self.isShieldDeployed and time > self.shieldDeployChangeTime+self.kShieldOnDelay)
    if Server then
        self:UpdateHeat(deltaTime, true)
    else
        self:UpdateHeat(deltaTime, false)
    end
    self:UpdatePhysics(deltaTime)
    
    self:UpdateShieldProjectorMixin(deltaTime)
end

function ExoShield:UpdatePhysics()
    --Print("?!?")
    if self.isShieldActive and not self.isPhysicsActive then
        self:CreatePhysics()
    elseif not self.isShieldActive and self.isPhysicsActive then
        self:DestroyPhysics()
    end
    if self.isPhysicsActive then
        local prevCoords = self:GetShieldCoords(0)
        local prevAngles = Angles()
        prevAngles:BuildFromCoords(prevCoords)
        for i, physBody in ipairs(self.physBodyList) do
            local currCoords = self:GetShieldCoords(i/self.kPhysBodyCount)
            local currAngles = Angles()
            currAngles:BuildFromCoords(currCoords)
            
            local sectionAngles = SlerpAngles(prevAngles, currAngles, 0.37)
            local sectionCoords = sectionAngles:GetCoords()
            sectionCoords.origin = (prevCoords.origin+currCoords.origin)/2
            physBody:SetCoords(sectionCoords)
            
            prevCoords, prevAngles = currCoords, currAngles
        end
    end
end
function ExoShield:CreatePhysics()
    if not self.isPhysicsActive then
        self.isPhysicsActive = true
        self.physBodyList = {}
        
        local prevCoords = self:GetShieldCoords(0)
        local prevAngles = Angles()
        prevAngles:BuildFromCoords(prevCoords)
        for i = 1, self.kPhysBodyCount do
            local currCoords = self:GetShieldCoords(i/self.kPhysBodyCount)
            local currAngles = Angles()
            currAngles:BuildFromCoords(currCoords)
            
            local sectionAngles = SlerpAngles(prevAngles, currAngles, 0.5)
            local sectionCoords = sectionAngles:GetCoords()
            sectionCoords.origin = (prevCoords.origin+currCoords.origin)/2
            
            local width = math.sqrt(2*self.kShieldDistance^2*(1-math.cos(self.kShieldAngle/self.kPhysBodyCount)))*0.5
            
            local physBody = Shared.CreatePhysicsBoxBody(true, Vector(width, self.kShieldHeight, self.kShieldDepth), 10, sectionCoords)
            physBody:SetEntity(self)
            physBody:SetPhysicsType(CollisionObject.Dynamic)
            physBody:SetGroup(PhysicsGroup.ShieldGroup)
            --physBody:SetGroupFilterMask(PhysicsMask.None)
            physBody:SetTriggeringEnabled(true)
            --self.physBody:SetCollisionEnabled(true)
            physBody:SetGravityEnabled(false)
            self.physBodyList[i] = physBody
            
            prevCoords, prevAngles = currCoords, currAngles
        end
        --Print("Phyzzz on %s!", Server and "Server" or Client and "Client" or "?!?")
    end
end
function ExoShield:DestroyPhysics()
    if self.isPhysicsActive then
        for i, physBody in ipairs(self.physBodyList) do
            Shared.DestroyCollisionObject(physBody)
        end
        self.isPhysicsActive = false
        --Print("Phyzzz dead on %s.", Server and "Server" or Client and "Client" or "?!?")
    end
end
function ExoShield:OnUpdateRender()
    --Print("meow")
    local time = Shared.GetTime()
    local delay = (self.isShieldDeployed and self.kShieldEffectOnDelay or self.kShieldEffectOffDelay)
    self.shieldEffectScalar = Clamp((time-self.shieldDeployChangeTime)/delay, 0, 1)
    --Print(tostring(self.shieldDeployChangeTime))
    if not self.isShieldDeployed then
        self.shieldEffectScalar = 1-self.shieldEffectScalar
    end
    
    local player = self:GetParent()
    if not self.clawLight then
        self.clawLight = Client.CreateRenderLight()
        self.clawLight:SetType(RenderLight.Type_Point)
        self.clawLight:SetCastsShadows(false)
        self.clawLight:SetAtmosphericDensity(1)
        self.clawLight:SetSpecular(0)
    end
    
    local shouldDisplayAsViewModel = (player == Client.GetLocalPlayer() and player:GetIsFirstPerson())
    if not self.shieldModel or (shouldDisplayAsViewModel ~= self.shieldModelIsViewModel) then
        if self.shieldModel then
            Client.DestroyRenderModel(self.shieldModel)
            self.shieldModel = nil
        end
        self.shieldModelIsViewModel = shouldDisplayAsViewModel
        self.shieldModel = Client.CreateRenderModel(RenderScene.Zone_Default)--shouldDisplayAsViewModel and RenderScene.Zone_ViewModel or RenderScene.Zone_Default)
        self.shieldModel:SetModel("models/effects/arc_blast.model")
    end
    
    local coords = self:GetShieldCoords()
    self.clawLight:SetIsVisible(self.shieldEffectScalar > 0)
    self.clawLight:SetRadius(10*self.shieldEffectScalar)
    self.clawLight:SetIntensity(100*self.shieldEffectScalar)
    self.clawLight:SetColor(LerpColor(Color(0, 0.7, 1, 1), Color(1, 0, 0, 1), self.heatAmount))
    self.clawLight:SetCoords(coords)
    
    local rotAngles = Angles(-math.pi/2, 0, 0)
    coords = coords*rotAngles:GetCoords()
    coords.xAxis = coords.xAxis*24.00
    coords.yAxis = coords.yAxis*0.05
    coords.zAxis = coords.zAxis*15.00*(0.1+math.max(0, self.shieldEffectScalar-0.5)/0.5*0.9)
    self.shieldModel:SetIsVisible(self.shieldEffectScalar > 0)
    self.shieldModel:SetCoords(coords)
    
    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
            heatDisplayUI = Client.CreateGUIView(242+64, 720)
            heatDisplayUI:Load("lua/ModularExo_GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "ShieldDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_claw_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
        end
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        heatDisplayUI:SetGlobal("idleHeatAmount" .. self:GetExoWeaponSlotName(), self.idleHeatAmount)
        heatDisplayUI:SetGlobal("shieldStatus" .. self:GetExoWeaponSlotName(), (
                self.isShieldOverheated and "overheat"
            or  not self.isShieldDesired and "off"
            or  self.isInCombat and "combat"
            or  "on"
        ))
    end
end

function ExoShield:GetShieldCoords(fraction)
    fraction = fraction or 0.5
    local player = self:GetParent()
    local playerViewCoords = player:GetViewCoords() -- origin = player's eye pos, zAxis = player's looking direction
    local playerAngles = Angles()
    playerAngles:BuildFromCoords(playerViewCoords)
    
    playerAngles.pitch = Clamp(playerAngles.pitch+self.kShieldPitchUpDeadzone, -self.kShieldPitchUpLimit, 0)
    playerAngles.yaw = playerAngles.yaw+(fraction-0.5)*self.kShieldAngle
    
    local shieldCoords = playerAngles:GetCoords() -- face same way as player
    shieldCoords.origin = playerViewCoords.origin + shieldCoords.zAxis*self.kShieldDistance -- exo's eye pos + an offset in direction of playerAngles
    
    return shieldCoords
end

function ExoShield:GetSurfaceOverride(dmg)
    return "nanoshield" -- alternatively: "electronic", "armor", "flame", "ethereal", "hallucination", "structure"
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

-- to fix a bug
function ExoShield:GetExoWeaponSlotName()
    return "left"
end
function ExoShield:GetIsLeftSlot()
    return true
end
function ExoShield:GetIsRightSlot()
    return false
end
function ExoShield:GetExoWeaponSlot()
    return ExoWeaponHolder.kSlotNames.Left
end

Shared.LinkClassToMap("ExoShield", ExoShield.kMapName, networkVars)


