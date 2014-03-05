
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'ExoShield' (Entity)

ExoShield.kMapName = "exoshield"

ExoShield.kHeatPerDamage = 0.01
ExoShield.kHeatIdleDrainRate = 0.2
ExoShield.kHeatOverheatedDrainRate = 0.15
ExoShield.kHeatCombatDrainRate = 0.1
ExoShield.kCombatDuration = 1.3

ExoShield.kShieldOnDelay = 0.8
ExoShield.kShieldToggleDelay = 1 -- prevent spamming

ExoShield.kShieldDistance = 2.65
ExoShield.kShieldAngle = math.rad(100)
ExoShield.kShieldDepth = 0.10
ExoShield.kShieldHeight = 2
ExoShield.kPhysBodyCount = 6

ExoShield.kShieldPitchUpDeadzone = math.rad(10)
ExoShield.kShieldPitchUpLimit    = math.rad(30)

ExoShield.kShieldEffectOnDelay = 1
ExoShield.kShieldEffectOffDelay = 0.6

--!!!
Script.Load("lua/PhysicsGroups.lua")

if not rawget(PhysicsGroup, "ShieldGroup") then
    local i = #PhysicsGroup+1
    rawset(PhysicsGroup, i, "ShieldGroup")
    rawset(PhysicsGroup, "ShieldGroup", i)
end

PhysicsMask.All = CreateMaskExcludingGroups(PhysicsGroup.ShieldGroup)
--!!!

local networkVars = {
    isShieldDesired = "private boolean",
    shieldChangeTime = "private time",
    lastHitTime = "private time",
    --isShieldActive = "private boolean",
    heatAmount = "private float (0 to 1 by 0.01)",
    overheated = "private boolean",
}

--AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function ExoShield:OnCreate()
    Entity.OnCreate(self)
    
    --InitMixin(self, TechMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.isShieldDesired = false
    self.shieldChangeTime = 0
    self.lastHitTime = 0
    self.heatAmount = 0
    self.overheated = false
    
    self.isShieldActive = false
    self.isPhysicsActive = false
    
    if Client then
        self.shieldEffectScalar = 0
    end
    
end
function ExoShield:OnInitialized()
    
end
function ExoShield:GetTechId() return nil end
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
    if not self.isShieldDesired and not self.overheated and Shared.GetTime() > self.shieldChangeTime+self.kShieldToggleDelay then
        self.isShieldDesired = true
        self.shieldChangeTime = Shared.GetTime()
    end
end
function ExoShield:OnPrimaryAttackEnd(player)
    if self.isShieldDesired then
        self.isShieldDesired = false
        self.shieldChangeTime = Shared.GetTime()
    end
end

function ExoShield:UpdateHeat(dt)
    local isInCombat = (Shared.GetTime() < self.lastHitTime+self.kCombatDuration)
    local cooldownRate = (isInCombat and self.kHeatCombatDrainRate or self.kHeatIdleDrainRate)
    if self.heatAmount >= 1 then
        self.overheated = true
    end
    if self.overheated then
        self.isShieldDesired = false
        self.shieldChangeTime = Shared.GetTime()
        cooldownRate = self.kHeatOverheatedDrainRate
        if self.heatAmount < 0.1 then
            self.overheated = false
        end
    end
    self.heatAmount = Clamp(self.heatAmount-cooldownRate*dt, 0, 1)
end

function ExoShield:OverrideTakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
    self.heatAmount = self.heatAmount+self.kHeatPerDamage*damage
    Print("heat: %s", tostring(self.heatAmount))
    self.lastHitTime = Shared.GetTime()
    return false
end

--function ExoShield:OnUpdate(deltaTime)
function ExoShield:ProcessMoveOnWeapon(player, input)
    local deltaTime = input.time
    --Print("wtf")
    if self.isShieldDesired then
        local time = Shared.GetTime()
        self.isShieldActive = (time > self.shieldChangeTime+self.kShieldOnDelay)
    else
        self.isShieldActive = false
    end
    self:UpdateHeat(deltaTime)
    self:UpdatePhysics(deltaTime)
end

Print("waasdasdt")
function ExoShield:UpdatePhysics()
    --Print("?!?")
    if self.isShieldActive and not self.isPhysicsActive then
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
        Print("Phyzzz on %s!", Server and "Server" or Client and "Client" or "?!?")
    elseif not self.isShieldActive and self.isPhysicsActive then
        for i, physBody in ipairs(self.physBodyList) do
            Shared.DestroyCollisionObject(physBody)
        end
        self.isPhysicsActive = false
        Print("Phyzzz dead on %s.", Server and "Server" or Client and "Client" or "?!?")
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

function ExoShield:OnUpdateRender()
    --Print("meow")
    local time = Shared.GetTime()
    local delay = (self.isShieldDesired and self.kShieldEffectOnDelay or self.kShieldEffectOffDelay)
    self.shieldEffectScalar = Clamp((time-self.shieldChangeTime)/delay, 0, 1)
    --Print(tostring(self.shieldChangeTime))
    if not self.isShieldDesired then
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
    coords.xAxis = coords.xAxis*20.00
    coords.yAxis = coords.yAxis*0.05
    coords.zAxis = coords.zAxis*15.00
    self.shieldModel:SetIsVisible(self.shieldEffectScalar > 0)
    self.shieldModel:SetCoords(coords)
    
    local heatDisplayUI = self.heatDisplayUI
    if not heatDisplayUI then
        heatDisplayUI = Client.CreateGUIView(242, 720)
        heatDisplayUI:Load("lua/ModularExo_GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "ShieldDisplay.lua")
        heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
        self.heatDisplayUI = heatDisplayUI
    end
    heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
end

function ExoShield:GetShieldCoords(fraction)
    fraction = fraction or 0.5
    local player = self:GetParent()
    local playerViewCoords = player:GetViewCoords() -- origin = player's eye pos, zAxis = player's looking direction
    local playerAngles = Angles()
    playerAngles:BuildFromCoords(playerViewCoords)
    
    playerAngles.pitch = Clamp(playerAngles.pitch+self.kShieldPitchUpDeadzone, -self.kShieldPitchUpLimit, 0)
    playerAngles.yaw = playerAngles.yaw+(fraction-0.5)*ExoShield.kShieldAngle
    
    local shieldCoords = playerAngles:GetCoords() -- face same way as player
    shieldCoords.origin = playerViewCoords.origin + shieldCoords.zAxis*self.kShieldDistance -- exo's eye pos + an offset in direction of playerAngles
    
    return shieldCoords
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


