
Script.Load("lua/ModularExo_Shared.lua")

Script.Load("lua/ModularExo_ConsoleCommands_Server.lua")

local function OnMessageExoModularBuy(client, message)
    local player = client:GetControllingPlayer()
    if player and player:GetIsAllowedToBuy() and player.ProcessExoModularBuyAction then
        player:ProcessExoModularBuyAction(message)
    end
end
Server.HookNetworkMessage("ExoModularBuy", OnMessageExoModularBuy)

function ModularExo_FindExoSpawnPoint(self)
    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            
        local weapons 

        if spawnPoint then
            return spawnPoint
        end
    end
end

function ModularExo_HandleExoModularBuy(self, message)
    local exoConfig = ModularExo_ConvertNetMessageToConfig(message)
    
    local isValid, badReason, resCost = ModularExo_GetIsConfigValid(exoConfig)
    if not isValid or resCost > self:GetResources() then
        return
    end
    
    local discount = 0
    if self:isa("Exo") then
        local isValid, badReason, resCost = ModularExo_GetIsConfigValid(ModularExo_ConvertNetMessageToConfig(self))
        discount = resCost
    end
    self:AddResources(-resCost+discount)
    
    local spawnPoint = ModularExo_FindExoSpawnPoint(self)
    if spawnPoint == nil then
        return
    end
    
    local weapons = self:GetWeapons()
    for i = 1, #weapons do            
        weapons[i]:SetParent(nil)            
    end
    Print("WTF %s", tostring(message.utilityModuleType))
    local exoVariables = message
    
    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, exoVariables)
    exo.prevPlayerMapName = self:GetMapName()
    exo.prevPlayerHealth = self:GetHealth()
    exo.prevPlayerMaxArmor = self:GetMaxArmor()
    exo.prevPlayerArmor = self:GetArmor()      
    
    if not exo then
        return
    end
    
    for i = 1, #weapons do
        exo:StoreWeapon(weapons[i])
    end
    
    exo:TriggerEffects("spawn_exo")
    
end



