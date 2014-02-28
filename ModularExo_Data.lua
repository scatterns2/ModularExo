Script.Load("lua/Exo.lua")
Script.Load("lua/Weapons/Marine/Minigun.lua")
Script.Load("lua/Weapons/Marine/Railgun.lua")
Script.Load("lua/Weapons/Marine/Claw.lua")

Script.Load("lua/Weapons/Marine/ModularExo_ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ModularExo_ExoFlamer.lua")
Script.Load("lua/Weapons/Marine/ModularExo_ExoWelder.lua")
Script.Load("lua/Weapons/Marine/ModularExo_ExoShield.lua")

-- The categories of modules
kExoModuleCategories = enum{
    "PowerSupply",
    "Weapon",
    "Armor",
    "Damage",
    "Utility",
}
-- The slots that modules go in
kExoModuleSlots = enum{
    "PowerSupply",
    "RightArm",
    "LeftArm",
    "Armor",
    "Damage",
    "Utility",
}

-- Slot data
kExoModuleSlotsData = {
    [kExoModuleSlots.PowerSupply] = {
        category = kExoModuleCategories.PowerSupply,
        required = true,
    },
    [kExoModuleSlots.LeftArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.RightArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.Armor] = {
        category = kExoModuleCategories.Armor,
        required = false,
    },
    [kExoModuleSlots.Damage] = {
        category = kExoModuleCategories.Damage,
        required = false,
    },
    [kExoModuleSlots.Utility] = {
        category = kExoModuleCategories.Utility,
        required = false,
    },
}

-- Module types
kExoModuleTypes = enum{
    "None",
    "Power1",
    "Power2",
    "Power3",
    "Power4",
    "Power5",
    "Power6",
    "Claw",
    "Minigun",
    "Railgun",
    "Welder",
    "Flamethrower",
    "Shield",
    "Armor1",
    "Armor2",
    "Armor3",
    "Damage1",
    "Damage2",
    "Damage3",
    "Scanner",
}

-- Information to decide which model to use for weapon combos
kExoArmTypes = enum{
    "Claw",
    "Minigun",
    "Railgun",
}

-- Module type data
kExoModuleTypesData = {
    -- Power modules
    [kExoModuleTypes.Power1] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 15,
        resourceCost = 20,
    },
    [kExoModuleTypes.Power2] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 20,
        resourceCost = 30,
    },
    [kExoModuleTypes.Power3] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 25,
        resourceCost = 40,
    },
    [kExoModuleTypes.Power4] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 30,
        resourceCost = 50,
    },
    [kExoModuleTypes.Power5] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 40,
        resourceCost = 60,
    },
	[kExoModuleTypes.Power6] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 50,
        resourceCost = 70,
    },
    
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 5,
        mapName = Claw.kMapName,
        armType = kExoArmTypes.Claw,
    },
    [kExoModuleTypes.Welder] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoWelder.kMapName,
        armType = kExoArmTypes.Railgun,
    }, 
    [kExoModuleTypes.Shield] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoShield.kMapName,
        armType = kExoArmTypes.Claw,
    },     
	[kExoModuleTypes.Minigun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = Minigun.kMapName,
        armType = kExoArmTypes.Minigun,
    }, 
	[kExoModuleTypes.Railgun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = Railgun.kMapName,
        armType = kExoArmTypes.Railgun,
    },
    [kExoModuleTypes.Flamethrower] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoFlamer.kMapName,
        armType = kExoArmTypes.Railgun,
    },
    
    -- Armor modules
    [kExoModuleTypes.Armor1] = {
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
    [kExoModuleTypes.Armor2] = {
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
	[kExoModuleTypes.Armor3] = {
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
    
    -- Damage modules (unused)
    [kExoModuleTypes.Damage1] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
	[kExoModuleTypes.Damage2] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
	[kExoModuleTypes.Damage3] = {
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
    
    -- Utility modules
    [kExoModuleTypes.Scanner] = {
        category = kExoModuleCategories.Utility,
        powerCost = 20,
        mapName = ExoScan.kMapName,
    },
}

-- Model data for weapon combos (data[rightArmType][leftArmType])
kExoWeaponRightLeftComboModels = {
    [kExoArmTypes.Minigun] = {
        [kExoArmTypes.Minigun] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_mm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_mm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_mm_view.model",
			viewAnimGraph = "models/marine/exosuit/exosuit_mm_view.animation_graph",
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cm_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
    [kExoArmTypes.Railgun] = {
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = true,
		    worldModel = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_rr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_rr_view.animation_graph",

        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cr_view.animation_graph",

        },
    },
    [kExoArmTypes.Claw] = {
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid = true, -- if only :P
        },
    },
}
