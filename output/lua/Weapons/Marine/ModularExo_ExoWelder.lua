-- lua\Weapons\Marine\Welder.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Weapon used for repairing structures and armor of friendly players (marines, exosuits, jetpackers).
--    Uses hud slot 3 (replaces axe)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

function _D(...)
    local t = {'['..debug.getinfo(2, 'l').currentline..']', ...}
    for i = 1, #t do
        t[i] = tostring(t[i])
    end
    Print("%s", table.concat(t, ' '))
end



Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'ExoWelder' (Entity)

ExoWelder.kMapName = "exowelder"

ExoWelder.kModelName = PrecacheAsset("models/marine/welder/welder.model")
local kViewModels = GenerateMarineViewModelPaths("welder")
local kAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph")


local kWelderTraceExtents = Vector(0.4, 0.4, 0.4)


local networkVars =
{
    welding = "boolean",
    loopingSoundEntId = "entityid",
  
}

AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)

local kWeldRange = 4
local kWelderEffectRate = 0.45

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/welder/weld")

local kHealScoreAdded = 2
-- Every kAmountHealedForPoints points of damage healed, the player gets
-- kHealScoreAdded points to their score.
local kAmountHealedForPoints = 600

function ExoWelder:OnCreate()

   Entity.OnCreate(self)
    
    
    
    --InitMixin(self, LiveMixin)
    InitMixin(self, ExoWeaponSlotMixin)

    self.loopingSoundEntId = Entity.invalidId
    self.welding = false
	
    if Server then
    
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        -- SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    end
    
end

function ExoWelder:OnInitialized()

    Entity.OnInitialized(self)
    
    self.timeWeldStarted = 0
    self.timeLastWeld = 0
    
end

function ExoWelder:OnTag(tagName)

    if tagName == "deploy_end" then
        self.deployed = true
    end

end


if client then

	local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
	cinematic:SetCinematic("cinematics/marine/welder/welder_muzzle.cinematic")
	local cinematicCoords = self:GetCoords()
	local scale = 5
			if scale then
				coords.xAxis = coords.xAxis * scale
				coords.yAxis = coords.yAxis * scale
				coords.zAxis = coords.zAxis * scale
			end
	cinematic:SetCoord(coords)

end	
	
function ExoWelder:GetIsAffectedByWeaponUpgrades()
    return false
end

function ExoWelder:OnPrimaryAttack(player)

       
    PROFILE("ExoWelder:OnPrimaryAttack")
    
    if not self.welding then
    
       -- self:TriggerEffects("welder_start")
        self.timeWeldStarted = Shared.GetTime()
        
        if Server then
            self.loopingFireSound:Start()
        end
        
    end
    
    self.welding = true
    local hitPoint = nil
    
    if self.timeLastWeld + kWelderFireDelay < Shared.GetTime () then
    
      hitPoint = self:PerformWeld(player)
        self.timeLastWeld = Shared.GetTime()
        
    end
    
    if not self.timeLastWeldEffect or self.timeLastWeldEffect + kWelderEffectRate < Shared.GetTime() then

		if self:GetIsLeftSlot() then
        
			player:TriggerEffects("leftexowelder_muzzle", { effecthostcoords = coords})
            
        elseif self:GetIsRightSlot() then
        
            player:TriggerEffects("rightexowelder_muzzle", { effecthostcoords = coords})
            
        end
                        self.timeLastWeldEffect = Shared.GetTime()

    end
    
end

function ExoWelder:GetDeathIconIndex()
    return kDeathMessageIcon.Welder
end

function ExoWelder:OnPrimaryAttackEnd(player)

    if self.welding then
     player:TriggerEffects("welder_end")
    end
    
    self.welding = false
    
  if Server then
       self.loopingFireSound:Stop()
    end
   
end
	
function ExoWelder:ProcessMoveOnWeapon(player, input)

	if self.welding then
    
        local exoWeaponHolder = player:GetActiveWeapon()
        
    end


end	
	
function ExoWelder:GetRange()
    return kWeldRange
end	

--function ExoWelder:GetRepairRate(repairedEntity)

  --  local repairRate = kPlayerWeldRate
 --   if repairedEntity.GetReceivesStructuralDamage and repairedEntity:GetReceivesStructuralDamage() then
    --    repairRate = kStructureWeldRate
  --  end
    
   -- return repairRate
    
--end

function ExoWelder:GetMeleeBase()
    return 2, 2
end

function ExoWelder:GetMeleeOffset()
    return 0.0
end

--local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
 --    _D("WTF", weapon, player)
  --  return not oldTarget or (HasMixin(newTarget, "Team") and newTarget:GetTeamNumber() == player:GetTeamNumber() and (HasMixin(newTarget, "Weldable") and newTarget:GetCanBeWelded(player)))
--end

local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
    return true
end


function ExoWelder:PerformWeld(player)

    local attackDirection = player:GetViewCoords().zAxis
    local success = false
    -- prioritize friendlies
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true, 1, PrioritizeDamagedFriends, nil, PhysicsMask.Flame)
    
    if didHit and target and HasMixin(target, "Live") then
        
        if HasMixin(target, "Team")and GetAreEnemies(player, target) then
           -- self:DoDamage(kWelderDamagePerSecond * kWelderFireDelay, target, endPoint, attackDirection)
            --success = true     
         elseif HasMixin(target, "Team") and player:GetTeamNumber() == target:GetTeamNumber() and HasMixin(target, "Weldable") then

        
            if target:GetHealthScalar() < 1 then
                
                local prevHealthScalar = target:GetHealthScalar()
                local prevHealth = target:GetHealth()
                local prevArmor = target:GetArmor()
               -- target:OnWeld(self, kWelderFireDelay, player)
                 if target:GetCanBeWelded(player) then
                    if target.OnWeldOverride then
                        target:OnWeldOverride(player, kWelderFireDelay)
                    else
                        target:AddHealth(self:GetRepairRate(target) * kWelderFireDelay)

                    end
                    if player and player.OnWeldTarget then
                        player:OnWeldTarget(target)
                    end
                  end


                success = prevHealthScalar ~= target:GetHealthScalar()
                
                if success then
                
                    local addAmount = (target:GetHealth() - prevHealth) + (target:GetArmor() - prevArmor)
                    player:AddContinuousScore("WeldHealth", addAmount, kAmountHealedForPoints, kHealScoreAdded)
                    
                    -- weld owner as well
                    player:SetArmor(player:GetArmor() + kWelderFireDelay * kSelfWeldAmount)
                    
                end
                
            end
            
            if HasMixin(target, "Construct")  then
                target:Construct(kWelderFireDelay, player)
            end
            
        end
        
    end
    
    if success then    
        return endPoint
    end
    
end

function ExoWelder:GetRepairRate(repairedEntity)

    local repairRate = kPlayerWeldRate
    if repairedEntity.GetReceivesStructuralDamage and repairedEntity:GetReceivesStructuralDamage() then
        repairRate = kStructureWeldRate
    end
    
    return repairRate
    
end


function ExoWelder:GetShowDamageIndicator()
    return true
end


function ExoWelder:OnUpdateAnimationInput(modelMixin)

 PROFILE("ExoWelder:OnUpdateAnimationInput")
    
    local parent = self:GetParent()
    --local sprinting = parent ~= nil and HasMixin(parent, "Sprint") and parent:GetIsSprinting()
    local activity =self.welding  and "primary" or "none"
    --modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
end

function ExoWelder:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)    
end

function ExoWelder:OnUpdatePoseParameters(viewModel)

    PROFILE("ExoWelder:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)
    
end

function ExoWelder:OnUpdateRender()

  PROFILE("ExoWelder:OnUpdateRender")

  --Entity.OnUpdateRender(self)
    
    if self.ammoDisplayUI then
    
        local progress = PlayerUI_GetUnitStatusPercentage()
        self.ammoDisplayUI:SetGlobal("weldPercentage", progress)
        
    end
    
    local parent = self:GetParent()
    if parent and self.welding then

        if (not self.timeLastWeldHitEffect or self.timeLastWeldHitEffect + 0.06 < Shared.GetTime()) then
        
            local viewCoords = parent:GetViewCoords()
        
            local trace = Shared.TraceRay(viewCoords.origin, viewCoords.origin + viewCoords.zAxis * self:GetRange(), CollisionRep.Damage, PhysicsMask.Flame, EntityFilterTwo(self, parent))
            if trace.fraction ~= 1 then
            
                local coords = Coords.GetTranslation(trace.endPoint - viewCoords.zAxis * .1)
                
                local className = nil
                if trace.entity then
                    className = trace.entity:GetClassName()
                end
                
                parent:TriggerEffects("exowelder_hit", { classname = className, effecthostcoords = coords})
                
            end
            
            self.timeLastWeldHitEffect = Shared.GetTime()
            
        end
        
    end
end


function ExoWelder:ModifyDamageTaken(damageTable, attacker, doer, damageType)
  if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
   end
end

function ExoWelder:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function ExoWelder:OnKill()
        DestroyEntity(self)
    end
    
    function ExoWelder:GetSendDeathMessageOverride()
        return false
    end    
    
end

function ExoWelder:GetIsWelding()
    return self.welding
end

function ExoWelder:OnTag(tagName)

    PROFILE("ExoWelder:OnTag")
              
    if not self:GetIsLeftSlot() then
    
    if    tagName == "deploy_end" then
            self.deployed = true
     end
        
    end
    
end







GetEffectManager():AddEffectData("ScattersModEffects", {
    leftexowelder_muzzle = {
        welderMuzzleEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_l_railgun_muzzle"},
            {weapon_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_lrailgunmuzzle"},
        },
    },
    rightexowelder_muzzle = {
        welderMuzzleEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_r_railgun_muzzle"},
            {weapon_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_rrailgunmuzzle"},
        },
    },
    exowelder_hit =
    {
        welderHitEffects =
        {
            {cinematic = "cinematics/marine/welder/exowelder_hit.cinematic"},
        },
    },
})
    

 
    

Shared.LinkClassToMap("ExoWelder", ExoWelder.kMapName, networkVars)