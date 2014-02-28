
Script.Load("lua/GUIMarineBuyMenu.lua")

--[[ (Z = lightning bolt icon, R = res icon)
                  0%|                                    80%-padding| |80%             |100% (Width)
    ╔═════════════╤═════════════════════════════════════════════════════════════════════╗ ─0%
    ║             │ ┌───────────────────────────────────────────────┐ ┌───────────────┐ ║ 
    ║ Jetpack     │ │ POWER MODULE                                  │ │     HEAVY     │ ║
    ║             │ │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │ │               │ ║ 
    ╟─────────────┤ │ │ +20P │ │ +20P │ │ +20P │ │ +20P │ │ +20P │  │ │     20Z/      │ ║ 
    ║             │ │ │ -40R │ │ -40R │ │ -40R │ │ -40R │ │ -40R │  │ │       /40Z    │ ║ 
    ║  │Exo│      │ │ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │ │               │ ║
    ║             │ └───────────────────────────────────────────────┘ └───────────────┘ ║ ─15%
    ╟─────────────┤ ┌───────────────┐                                 ┌───────────────┐ ║
    ║             │ │ RIGHT ARM     │                                 │ LEFT ARM      │ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ CLAW        ││                                 ││ CLAW        ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ WELDER      ││                                 ││ WELDER      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│             ( PIC )             │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ SHIELD      ││                                 ││ SHIELD      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ MINIGUN     ││                                 ││ MINIGUN     ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ RAILGUN     ││                                 ││ RAILGUN     ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ FLAMER      ││                                 ││ FLAMER      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ └───────────────┘                                 └───────────────┘ ║ ─15%+right/left arm panel height
    ║             │ ┌─────────────────────────────┐  ┌────────────────────────────────┐ ║ ─85%
    ║             │ │ ARMOR MODULE                │  │ UTILITY MODULE                 │ ║
    ║             │ │ ┌──────┐ ┌──────┐ ┌──────┐  │  │ ┌──────┐ ┌───────┐ ┌─────────┐ │ ║
    ║             │ │ │ +100 │ │ +100 │ │ +100 │  │  │ │ None │ │Scanner│ │Thrusters│ │ ║
    ║             │ │ │  10Z │ │  10Z │ │  10Z │  │  │ │      │ │  10Z  │ │  10Z    │ │ ║
    ║             │ │ └──────┘ └──────┘ └──────┘  │  │ └──────┘ └───────┘ └─────────┘ │ ║
    ║             │ └─────────────────────────────┘  └────────────────────────────────┘ ║ ─100% (Height-UpgradeButtonSize)
    ║             │                                                         ┌─────────┐ ║ 
    ║             │                                                    40R ─┤ UPGRADE │ ║
    ║             │                                                         └─────────┘ ║ ─
    ╚═════════════╧═════════════════════════════════════════════════════════════════════╝
                  0%|         0%+armor panel width|  |100%-utiltiy panel width         |100%
]]

GUIMarineBuyMenu.kExoModuleData = {
    -- Power modules
    [kExoModuleTypes.Power1] = {
        label = "EXO_POWER_1", tooltip = "EXO_POWER_1_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Power2] = {
        label = "EXO_POWER_2", tooltip = "EXO_POWER_2_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Power3] = {
        label = "EXO_POWER_3", tooltip = "EXO_POWER_3_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Power4] = {
        label = "EXO_POWER_4", tooltip = "EXO_POWER_4_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Power5] = {
        label = "EXO_POWER_5", tooltip = "EXO_POWER_5_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
	[kExoModuleTypes.Power6] = {
        label = "EXO_POWER_6", tooltip = "EXO_POWER_6_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        label = "Claw", tooltip = "EXO_WEAPON_CLAW_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Welder] = {
        label = "Welder", tooltip = "EXO_WEAPON_WELDER_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    }, 
    [kExoModuleTypes.Shield] = {
        label = "Shield", tooltip = "EXO_WEAPON_SHIELD_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },     
	[kExoModuleTypes.Minigun] = {
        label = "Minigun", tooltip = "EXO_WEAPON_MMINIGUN_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    }, 
	[kExoModuleTypes.Railgun] = {
        label = "Railgun", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Flamethrower] = {
        label = "Flamethrower", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    
    -- Armor modules
    [kExoModuleTypes.Armor1] = {
        label = "EXO_ARMOR_1", tooltip = "EXO_ARMOR_1_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Armor2] = {
        label = "EXO_ARMOR_2", tooltip = "EXO_ARMOR_2_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
	[kExoModuleTypes.Armor3] = {
        label = "EXO_ARMOR_3", tooltip = "EXO_ARMOR_3_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    [kExoModuleTypes.Damage1] = {
        label = "EXO_DAMAGE_1", tooltip = "EXO_DAMAGE_1_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
	[kExoModuleTypes.Damage2] = {
        label = "EXO_DAMAGE_2", tooltip = "EXO_DAMAGE_2_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
	[kExoModuleTypes.Damage3] = {
        label = "EXO_DAMAGE_3", tooltip = "EXO_DAMAGE_3_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
    
    -- Utility modules
    [kExoModuleTypes.Scanner] = {
        label = "EXO_UTILITY_SCANNER", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
        image = GUIMarineBuyMenu.kBigIconTexture, imageSize = GUIMarineBuyMenu.kBigIconSize,
        imageTexCoords = GetBigIconPixelCoords(kTechId.Axe),
    },
}
