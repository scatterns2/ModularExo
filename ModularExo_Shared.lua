
Script.Load("lua/ModularExo_Data.lua")

Script.Load("lua/ModularExo_NetworkMessages.lua")

Script.Load("lua/ModularExo_Exo.lua")
Script.Load("lua/ModularExo_Marine.lua")

Script.Load("lua/ModularExo_ExoScanner.lua")



-- Exo config utilities

--[[ Example config format:
    local exoConfig = {
        [kExoModuleSlots.PowerSupply] = kExoModuleTypes.Power1,
        [kExoModuleSlots.RightArm   ] = kExoModuleTypes.Minigun,
        [kExoModuleSlots.LeftArm    ] = kExoModuleTypes.Claw,
        [kExoModuleslots.Armor      ] = kExoModuleTypes.Armor1,
        [kExoModuleslots.Utility    ] = kExoModuleTypes.Scanner,
    }
    Utility slot may be nil (because it's an optional slot).
]]

function Exo_Modular_GetIsConfigValid(config)
    local powerCost = 0
    local powerSupply = nil -- We don't know yet
    local leftArmType = nil
    local rightArmType = nil
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType == nil then
            if slotTypeData.required then
                -- The config MUST give a module type for this slot type
                return false -- not a valid config
            else
                -- This slot type is optional, so it's OK to leave it out
            end
        else
            -- The config has module type for this slot type
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData.category ~= slotTypeData.category then
                -- They have provided the wrong category of module type for this slot type
                -- For example, an armor module in a weapon slot
                return false -- not a valid config
            end
            -- Here, we can safely assume that the type is right (else the above would have returned)
            if moduleTypeData.powerCost then
                -- This module type uses power
                powerCost = powerCost+moduleTypeData.powerCost
            elseif moduleTypeData.powerSupply then
                -- This module type supplies power
                if powerSupply ~= nil then
                    -- We've already seen a module that supplies power!
                    return false 
                else
                    -- We know our power supply!
                    powerSupply = moduleTypeData.powerSupply
                end
            end
            if slotType == kExoModuleSlots.LeftArm then
                leftArmType = moduleTypeData.armType
            elseif slotType == kExoModuleSlots.RightArm then
                rightArmType = moduleTypeData.armType
            end
        end
    end
    -- Ok, we've iterated over certain module types and it seems OK
    if powerCost > powerSupply then
        -- This config uses more power than the supply can handle!
        return false
    end
    local exoTexturePath = nil
    local modelDataForRightArmType = kExoWeaponRightLeftComboModels[rightArmType]
    if modelDataForRightArmType == nil then
        -- This means we don't have model data for the situation where the arm type is on the right
        -- Which means, this isn't a valid config! (e.g: claw selected for right arm)
        return false
    else
        local modelData = modelDataForRightArmType[leftArmType]
        if modelData == nil then
            -- The left arm type is not supported for the given right arm type
            return false
        else
            -- This combo of right and left arm types is supported!
            exoTexturePath = modelData.imageTexturePath
        end
    end
    -- This config is valid
    -- Return true, to indicate that
    -- Also return the power supply and power cost, in case the GUI needs those values
    -- Also return the image texture path, in case the GUI needs that!
    return true, powerSupply, powerCost, exoTexturePath
end

