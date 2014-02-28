
Script.Load("lua/MapBlipMixin.lua")


class 'ExoScanner' (Entity)

ExoScanner.kMapName = "ExoScanner"

ExoScanner.kScanEffect = PrecacheAsset("cinematics/marine/observatory/scan.cinematic")
ExoScanner.kScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan")

local scanConeAngle = math.rad(45)
ExoScanner.kScanDistance = 1
local networkVars = {
    
}

function ExoScanner:OnCreate()
    Entity.OnCreate(self)
    StartSoundEffectOnEntity(ExoScanner.kScanSound, self)
end
function ExoScanner:OnScanButton()
	self:PerformScan()
end

function ExoScanner:PerformScan()
    local player = self:GetParent()
    local exoViewAngles = player:GetViewAngles()
    local exoForwardCoords = exoViewAngles:GetCoords()
    local exoForwardVector = exoForwardCoords.zAxis
    local enemyPos = enemy:GetOrigin()
    local exoPos = player:GetViewPosition() 
    local enemyDirectionVector = (enemyPos-exoPos)	     
    enemyDirectionVector:Normalize()
    exoForwardVector.y = 0
    enemyDirectionVector.y = 0	
    
    local owner = self:GetParent()
    local enemies = GetEntitiesWithMixinForTeamWithinRange("LOS", GetEnemyTeamNumber(owner:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)
    for _, enemy in ipairs(enemies)  do
        enemy:SetIsSighted(true)
        if enemy.OnScan then
            enemy:OnScan()
        end
        if HasMixin(enemy, "Detectable") then
            enemy:SetDetected(true)
        end
    end
end

Shared.LinkClassToMap("ExoScanner", ExoScanner.kMapName, networkVars)
