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
        label = "EXO_MODULESLOT_POWERSUPPLY", 
        category = kExoModuleCategories.PowerSupply,
        required = true,
    },
    [kExoModuleSlots.LeftArm] = {
        label = "EXO_MODULESLOT_LEFT_ARM",
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.RightArm] = {
        label = "EXO_MODULESLOT_RIGHT_ARM",
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.Armor] = {
        label = "EXO_MODULESLOT_ARMOR",
        category = kExoModuleCategories.Armor,
        required = false,
    },
    [kExoModuleSlots.Damage] = {
        label = "EXO_MODULESLOT_DAMAGE",
        category = kExoModuleCategories.Damage,
        required = false,
    },
    [kExoModuleSlots.Utility] = {
        label = "EXO_MODULESLOT_UTILITY", 
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
        label = "EXO_POWER_1", tooltip = "EXO_POWER_1_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 15,
        resourceCost = 20,
    },
    [kExoModuleTypes.Power2] = {
        label = "EXO_POWER_2", tooltip = "EXO_POWER_2_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 20,
        resourceCost = 30,
    },
    [kExoModuleTypes.Power3] = {
        label = "EXO_POWER_3", tooltip = "EXO_POWER_3_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 25,
        resourceCost = 40,
    },
    [kExoModuleTypes.Power4] = {
        label = "EXO_POWER_4", tooltip = "EXO_POWER_4_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 30,
        resourceCost = 50,
    },
    [kExoModuleTypes.Power5] = {
        label = "EXO_POWER_5", tooltip = "EXO_POWER_5_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 40,
        resourceCost = 60,
    },
	[kExoModuleTypes.Power6] = {
        label = "EXO_POWER_6", tooltip = "EXO_POWER_6_TOOLTIP",
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 50,
        resourceCost = 70,
    },
    
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        label = "Claw", tooltip = "EXO_WEAPON_CLAW_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 5,
        mapName = Claw.kMapName,
        armType = kExoArmTypes.Claw,
    },
    [kExoModuleTypes.Welder] = {
        label = "Welder", tooltip = "EXO_WEAPON_WELDER_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoWelder.kMapName,
        armType = kExoArmTypes.Railgun,
    }, 
    [kExoModuleTypes.Shield] = {
        label = "Shield", tooltip = "EXO_WEAPON_SHIELD_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoShield.kMapName,
        armType = kExoArmTypes.Claw,
    },     
	[kExoModuleTypes.Minigun] = {
        label = "Minigun", tooltip = "EXO_WEAPON_MMINIGUN_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = Minigun.kMapName,
        armType = kExoArmTypes.Minigun,
    }, 
	[kExoModuleTypes.Railgun] = {
        label = "Railgun", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = Railgun.kMapName,
        armType = kExoArmTypes.Railgun,
    },
    [kExoModuleTypes.Flamethrower] = {
        label = "Flamethrower", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
        category = kExoModuleCategories.Weapon,
        powerCost = 15,
        mapName = ExoFlamer.kMapName,
        armType = kExoArmTypes.Railgun,
    },
    
    -- Armor modules
    [kExoModuleTypes.Armor1] = {
        label = "EXO_ARMOR_1", tooltip = "EXO_ARMOR_1_TOOLTIP",
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
    [kExoModuleTypes.Armor2] = {
        label = "EXO_ARMOR_2", tooltip = "EXO_ARMOR_2_TOOLTIP",
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
	[kExoModuleTypes.Armor3] = {
        label = "EXO_ARMOR_3", tooltip = "EXO_ARMOR_3_TOOLTIP",
        category = kExoModuleCategories.Armor,
        powerCost = 3,
        armorBonus = 100,
    },
    [kExoModuleTypes.Damage1] = {
        label = "EXO_DAMAGE_1", tooltip = "EXO_DAMAGE_1_TOOLTIP",
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
	[kExoModuleTypes.Damage2] = {
        label = "EXO_DAMAGE_2", tooltip = "EXO_DAMAGE_2_TOOLTIP",
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
	[kExoModuleTypes.Damage3] = {
        label = "EXO_DAMAGE_3", tooltip = "EXO_DAMAGE_3_TOOLTIP",
        category = kExoModuleCategories.Damage,
        powerCost = 3,
        damageScale = 1.1,
    },
    
    -- Utility modules
    [kExoModuleTypes.Scanner] = {
        label = "EXO_UTILITY_SCANNER", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
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
