-- lua\Weapons\Marine\Welder.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Weapon used for repairing structures and armor of friendly players (marines, exosuits, jetpackers).
--    Uses hud slot 3 (replaces axe)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/Flame.lua")
Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/Weapons/BulletsMixin.lua")

class 'ExoFlamer' (Entity)

ExoFlamer.kMapName = "exoflamer"

local kConeWidth = 0.17


if Client then
   Script.Load("lua/Weapons/Marine/ModularExo_ExoFlamer_Client.lua")
end

ExoFlamer.kMapName = "exoflamer"

ExoFlamer.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
--local kViewModels = GenerateMarineViewModelPaths("famethrower")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")




local networkVars =
{
	
    createParticleEffects = "boolean",
    animationDoneTime = "float",
    range = "integer (0 to 11)",
    isShooting = "boolean",
    loopingSoundEntId = "entityid",

}

AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)


local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")



function ExoFlamer:OnCreate()

   Entity.OnCreate(self)
	self.lastAttackApplyTime = 0

	self.isShooting = false
    InitMixin(self, ExoWeaponSlotMixin)
	InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, EffectsMixin)
    
	self.timeWeldStarted = 0
    self.timeLastWeld = 0
    self.loopingSoundEntId = Entity.invalidId
	self.range = 9


    if Server then

        self.lastAttackApplyTime = 0

		self.createParticleEffects = false
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        -- SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    elseif Client then
    
        self:SetUpdates(true)
        self.lastAttackEffectTime = 0.0
        self.lastAttackApplyTime = 0
    end
    
end

function ExoFlamer:OnInitialized()

    Entity.OnInitialized(self)
    
   
end


function ExoFlamer:OnDestroy()
    Entity.OnDestroy(self)
    if Server then
        self.loopingFireSound = nil
    elseif Client then
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end
        if self.pilotCinematic then
            Client.DestroyCinematic(self.pilotCinematic)
            self.pilotCinematic = nil
        end
    end
end

function ExoFlamer:OnUpdateAnimationInput(modelMixin)

 PROFILE("ExoWelder:OnUpdateAnimationInput")
    
    local parent = self:GetParent()
    --local sprinting = parent ~= nil and HasMixin(parent, "Sprint") and parent:GetIsSprinting()
    local activity =self.isShooting  and "primary" or "none"
       -- modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)

	
end

function Minigun:ModifyMaxSpeed(maxSpeedTable)
    if self.isShooting then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * kMinigunMovementSlowdown
    end
end

function ExoFlamer:GetIsAffectedByWeaponUpgrades()
    return false
end

function ExoFlamer:CreatePrimaryAttackEffect(player)
    -- Remember this so we can update gun_loop pose param
    self.timeOfLastPrimaryAttack = Shared.GetTime()
end

function ExoFlamer:GetRange()
    return self.range
end

local function BurnSporesAndUmbra(self, startPoint, endPoint)

    local toTarget = endPoint - startPoint
    local distanceToTarget = toTarget:GetLength()
    toTarget:Normalize()
    
    local stepLength = 2

    for i = 1, 5 do
    
        -- stop when target has reached, any spores would be behind
        if distanceToTarget < i * stepLength then
            break
        end
    
        local checkAtPoint = startPoint + toTarget * i * stepLength
        local spores = GetEntitiesWithinRange("SporeCloud", checkAtPoint, kSporesDustCloudRadius)
        
        local umbras = GetEntitiesWithinRange("CragUmbra", checkAtPoint, CragUmbra.kRadius)
        table.copy(GetEntitiesWithinRange("StormCloud", checkAtPoint, StormCloud.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("MucousMembrane", checkAtPoint, MucousMembrane.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("EnzymeCloud", checkAtPoint, EnzymeCloud.kRadius), umbras, true)
        
        local bombs = GetEntitiesWithinRange("Bomb", checkAtPoint, 1.6)
        table.copy(GetEntitiesWithinRange("WhipBomb", checkAtPoint, 1.6), bombs, true)
        
        for index, bomb in ipairs(bombs) do
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) } )
            DestroyEntity(bomb)
        end
        
        for index, spore in ipairs(spores) do
            self:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) } )
            DestroyEntity(spore)
        end
        
        for index, umbra in ipairs(umbras) do
            self:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(umbra:GetOrigin()) } )
            DestroyEntity(umbra)
        end
    
    end

end



local function CreateFlame(self, player, position, normal, direction)

    -- create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", player:GetTeamNumber(), position, 1.5)    

    if table.count(nearbyFlames) == 0 then
    
        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)
        
        local coords = Coords.GetTranslation(position)
        coords.yAxis = normal
        coords.zAxis = direction
        
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()
        
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()
        
        flame:SetCoords(coords)
        
    end

end

 function ExoFlamer:GetMeleeOffset()

	return 0

 end


local function ApplyConeDamage(self, player)
    
    local eyePos  = player:GetEyePos()    
    local ents = {}


    local fireDirection = player:GetViewCoords().zAxis
    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = self:GetRange()
    
    local startPoint = Vector(eyePos)
    local filterEnts = {self, player}
    
    for i = 1, 20 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Flame, EntityFilterList(filterEnts))
        
        --DebugLine(startPoint, trace.endPoint, 0.3, 1, 0, 0, 1)        
        
        -- Check for spores in the way.
        if Server and i == 1 then
            BurnSporesAndUmbra(self, startPoint, trace.endPoint)
        end
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
                
                table.insertunique(filterEnts, trace.entity)
                
            else
            
                -- Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(startPoint, startPoint + remainingRange * fireDirection, CollisionRep.Damage, PhysicsMask.Flame, EntityFilterOne(player))
                
                if lineTrace.fraction < 0.8 then
                
                    fireDirection = fireDirection + trace.normal * 0.55
                    fireDirection:Normalize()
                    
                    if Server then
                        CreateFlame(self, player, lineTrace.endPoint, lineTrace.normal, fireDirection)
                    end
                    
                end
                
                remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength()
                startPoint = trace.endPoint -- + fireDirection * kConeWidth * 2
                
            end
        
        else
            break
        end

    end
    
    for index, ent in ipairs(ents) do
    
        if ent ~= player then
        
            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - eyePos)
            local health = ent:GetHealth()
            
            self:DoDamage(kFlamethrowerDamage, ent, ent:GetModelOrigin(), toEnemy)
            
            -- Only light on fire if we successfully damaged them
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
            
            if ent.GetEnergy and ent.SetEnergy then
                ent:SetEnergy(ent:GetEnergy() - kFlameThrowerEnergyDamage)
            end
            
            if Server and ent:isa("Alien") then
                ent:CancelEnzyme()
            end
            
        end
    
    end

end


function ExoFlamer:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
		if Client and player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end

local function ShootFlame(self, player)

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    
    viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
    local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()
    
    local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Damage, PhysicsMask.Flame, EntityFilterAll())
    
    local range = (trace.endPoint - viewCoords.origin):GetLength()
    if range < 0 then
        range = range * (-1)
    end
    
    if trace.endPoint ~= endPoint and trace.entity == nil then
    
        local angles = Angles(0,0,0)
        angles.yaw = GetYawFromVector(trace.normal)
        angles.pitch = GetPitchFromVector(trace.normal) + (math.pi/2)
        
        local normalCoords = angles:GetCoords()
        normalCoords.origin = trace.endPoint
        range = range - 3
        
    end
    
    ApplyConeDamage(self, player)
    
    TEST_EVENT("Flamethrower primary attack")
    
end

function ExoFlamer:FirePrimary(player, bullets, range, penetration)
    ShootFlame(self, player)
end

function ExoFlamer:OnTag(tagName)

    PROFILE("ExoWelder:OnTag")
              
    if not self:GetIsLeftSlot() then
    
    if    tagName == "deploy_end" then
            self.deployed = true
     end
        
    end
    
end

function ExoFlamer:OnPrimaryAttack(player)

       
     PROFILE("ExoFlamer:OnPrimaryAttack")
     
      --  Entity.OnPrimaryAttack(self, player)
        
        if not self.isShooting then
            
            if not self.createParticleEffects then
                
                if self:GetIsLeftSlot() then
                    player:TriggerEffects("leftexoflamer_muzzle")
                elseif self:GetIsRightSlot() then
                    player:TriggerEffects("rightexoflamer_muzzle")  
                end        
            end
        
            self.createParticleEffects = true
            
            if Server and not self.loopingFireSound:GetIsPlaying() then
                self.loopingFireSound:Start()
            end
            
        end
        
        self.isShooting = true
		
		if Client and self.createParticleEffects and self.lastAttackEffectTime + 0.5 < Shared.GetTime() then
            
			player:TriggerEffects("exoflamer_muzzle")
            self.lastAttackEffectTime = Shared.GetTime()

        end

		 if  self.lastAttackApplyTime  + 0.5 < Shared.GetTime() then
            
			ShootFlame(self, player)
            self.lastAttackApplyTime  = Shared.GetTime()

        end
		
        -- Fire the cool flame effect periodically
        -- Don't crank the period too low - too many effects slows down the game a lot.
       
        
     -- if self.timeLastWeld + kWelderFireDelay < Shared.GetTime () then
    --
       -- self.timeLastWeld = Shared.GetTime()
        
	 -- end
    
end

function ExoFlamer:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function ExoFlamer:OnPrimaryAttackEnd(player)
   
  if self.isShooting then 

    self.createParticleEffects = false
        
    if Server then    
        self.loopingFireSound:Stop()        
    end
   end 
	self.isShooting = false
	
end
	
function ExoFlamer:OnReload(player)

    if self:CanReload() then
    
        if Server then
        
            self.createParticleEffects = false
            self.loopingFireSound:Stop()
        
        end
        
        self:TriggerEffects("reload")
        self.reloading = true
        
    end
    
end	
	


	
function ExoFlamer:ProcessMoveOnWeapon(player, input)

	if self.isShooting then
    
        local exoWeaponHolder = player:GetActiveWeapon()
        
    end


end	

function ExoFlamer:GetNotifiyTarget()
    return false
end

function ExoFlamer:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end
	
function ExoFlamer:GetRange()
    return self.range
end	



function ExoFlamer:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)    
end

function ExoFlamer:OnUpdatePoseParameters(viewModel)

    PROFILE("ExoFlamer:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)
    
end




GetEffectManager():AddEffectData("FlamerModEffects", {
    leftexoflamer_muzzle = {
        flamerMuzzleEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/flamethrower/flame_1p.cinematic", attach_point = "fxnode_l_railgun_muzzle"},
            {weapon_cinematic = "cinematics/marine/flamethrower/flame.cinematic", attach_point = "fxnode_lrailgunmuzzle"},
        },
    },
    rightexoflamer_muzzle = {
        flamerMuzzleEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/flamethrower/flame_1p.cinematic", attach_point = "fxnode_r_railgun_muzzle"},
            {weapon_cinematic = "cinematics/marine/flamethrower/flame.cinematic", attach_point = "fxnode_rrailgunmuzzle"},
        },
    },
})
    
 
    

Shared.LinkClassToMap("ExoFlamer", ExoFlamer.kMapName, networkVars)