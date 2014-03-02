
Script.Load("lua/GUIMarineBuyMenu.lua")
Script.Load("lua/GUI/ModularExo_GUIMarineBuyMenu_Data.lua")

-- may the cretaor forgive me for this code...

local orig_MarineBuy_GetCosts = MarineBuy_GetCosts
function MarineBuy_GetCosts(techId)
    if techId == kTechId.Exosuit then
        local minResCost = 1337
        for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData and moduleTypeData.category == kExoModuleCategories.PowerSupply then
                minResCost = math.min(minResCost, moduleTypeData.resourceCost)
            end
        end
        return minResCost
    end
    return orig_MarineBuy_GetCosts(techId)
end

GUIMarineBuyMenu.kConfigAreaXOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kConfigAreaYOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kUpgradeButtonAreaHeight = GUIScale(30)
--GUIMarineBuyMenu.kUpgradeButtonWidth = GUIScale(160)
--GUIMarineBuyMenu.kUpgradeButtonHeight = GUIScale(64)
GUIMarineBuyMenu.kConfigAreaWidth = (
        GUIMarineBuyMenu.kBackgroundWidth
    -   GUIMarineBuyMenu.kPadding*2
)
GUIMarineBuyMenu.kConfigAreaHeight = (
        GUIMarineBuyMenu.kBackgroundHeight
    -   GUIMarineBuyMenu.kUpgradeButtonAreaHeight
    -   GUIMarineBuyMenu.kPadding*3
)
GUIMarineBuyMenu.kSlotPanelBackgroundColor = Color(0.1, 0.4, 1, 0.8)

GUIMarineBuyMenu.kSmallModuleButtonSize = GUIScale(Vector(60, 60, 0))
GUIMarineBuyMenu.kWideModuleButtonSize = GUIScale(Vector(150, 60, 0))
GUIMarineBuyMenu.kWeaponImageSize = GUIScale(Vector(80, 40, 0))
GUIMarineBuyMenu.kModuleButtonGap = GUIScale(7)
GUIMarineBuyMenu.kPanelTitleHeight = GUIScale(35)

GUIMarineBuyMenu.kExoSlotData = {
    [kExoModuleSlots.PowerSupply] = {
        label = "POWER SUPPLY",--label = "EXO_MODULESLOT_POWERSUPPLY", 
        xp = 0, yp = 0, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    StatusPanel = { -- the one that shows weight and power usage
        label = nil,
        xp = 1, yp = 0, anchorX = GUIItem.Right,
    },
    [kExoModuleSlots.RightArm] = {
        label = "RIGHT ARM",--label = "EXO_MODULESLOT_RIGHT_ARM",
        xp = 0, yp = 0.16, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap*0.4,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.RightArm)
        end,
    },
    [kExoModuleSlots.LeftArm] = {
        label = "LEFT ARM",--label = "EXO_MODULESLOT_LEFT_ARM",
        xp = 1, yp = 0.16, anchorX = GUIItem.Right, gap = GUIMarineBuyMenu.kModuleButtonGap*0.4,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.LeftArm)
        end,
    },
    [kExoModuleSlots.Armor] = {
        label = "ARMOR",--label = "EXO_MODULESLOT_ARMOR",
        xp = 0, yp = 0.85, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeArmorModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    --[[
    [kExoModuleSlots.Utility] = {
        label = "UTILITY",--label = "EXO_MODULESLOT_UTILITY",
        xp = 1, yp = 0.85, anchorX = GUIItem.Right, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    ]]
}

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    Print("%s\n", "SetHostStructure")
    if hostStructure:isa("PrototypeLab") then
        Print("%s\n", "PROTOOaaaaO")
        self.exoConfig = {
            [kExoModuleSlots.PowerSupply] = kExoModuleTypes.Power1,
            [kExoModuleSlots.RightArm   ] = kExoModuleTypes.Minigun,
            [kExoModuleSlots.LeftArm    ] = kExoModuleTypes.Claw,
            [kExoModuleSlots.Armor      ] = kExoModuleTypes.None,
            [kExoModuleSlots.Utility    ] = kExoModuleTypes.None,
        }
        self:_InitializeExoModularButtons()
        self:_RefreshExoModularButtons()
    end
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {} -- WWHHYY UWE, WWWHHHHYYYYYY?!?!¿!?
    self.modularExoModuleButtonList = {}
    
    self.modularExoBuyButton = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButton)
    self.modularExoBuyButton:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.modularExoBuyButton:SetSize(Vector(GUIMarineBuyMenu.kButtonWidth*1.5, GUIMarineBuyMenu.kButtonHeight, 0))
    self.modularExoBuyButton:SetPosition(Vector(
        GUIMarineBuyMenu.kBackgroundWidth-GUIMarineBuyMenu.kButtonWidth*2.5-GUIMarineBuyMenu.kPadding,
        GUIMarineBuyMenu.kBackgroundHeight+GUIMarineBuyMenu.kPadding, 0
    ))
    self.modularExoBuyButton:SetTexture(GUIMarineBuyMenu.kButtonTexture)
    self.modularExoBuyButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.modularExoBuyButton)
    
    self.modularExoBuyButtonText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButtonText)
    self.modularExoBuyButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButtonText:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*5, 0, 0))
    self.modularExoBuyButtonText:SetFontName(GUIMarineBuyMenu.kFont)
    self.modularExoBuyButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetText("UPGRADE")
    self.modularExoBuyButtonText:SetFontIsBold(true)
    self.modularExoBuyButtonText:SetColor(GUIMarineBuyMenu.kCloseButtonColor)
    self.modularExoBuyButton:AddChild(self.modularExoBuyButtonText)
    
    self.modularExoCostText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostText)
    self.modularExoCostText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostText:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*7, 0, 0))
    self.modularExoCostText:SetFontName(GUIMarineBuyMenu.kFont)
    self.modularExoCostText:SetTextAlignmentX(GUIItem.Align_Min)
    self.modularExoCostText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoCostText:SetText("69")
    self.modularExoCostText:SetFontIsBold(true)
    self.modularExoCostText:SetColor(GUIMarineBuyMenu.kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostText)
    
    self.modularExoCostIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostIcon)
    self.modularExoCostIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    self.modularExoCostIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostIcon:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*1, -GUIMarineBuyMenu.kResourceIconHeight*0.4, 0))
    self.modularExoCostIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostIcon)
    
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = GUIManager:CreateGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        --panelBackground:SetSize()
        --panelBackground:SetAnchor(slotGUIDetails.anchorX or GUIItem.Left, slotGUIDetails.anchorY or GUIItem.Top)
        --panelBackground:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
        panelBackground:SetTexture(GUIMarineBuyMenu.kButtonTexture)
        panelBackground:SetColor(GUIMarineBuyMenu.kSlotPanelBackgroundColor)
        local panelSize = nil
        if slotType == "StatusPanel" then
            local weightLabel = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, weightLabel)
            weightLabel:SetFontName(GUIMarineBuyMenu.kFont)
            weightLabel:SetFontIsBold(true)
            weightLabel:SetPosition(Vector(0, GUIMarineBuyMenu.kPadding*2.5, 0))
            weightLabel:SetAnchor(GUIItem.Center, GUIItem.Top)
            weightLabel:SetTextAlignmentX(GUIItem.Align_Center)
            weightLabel:SetTextAlignmentY(GUIItem.Align_Min)
            weightLabel:SetColor(GUIMarineBuyMenu.kTextColor)
            weightLabel:SetText("FATTY")--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(weightLabel)
            
            local powerUsageLabel = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, powerUsageLabel)
            powerUsageLabel:SetFontName(GUIMarineBuyMenu.kFont)
            powerUsageLabel:SetFontIsBold(true)
            powerUsageLabel:SetPosition(Vector(GUIMarineBuyMenu.kPadding*3, 0, 0))
            powerUsageLabel:SetAnchor(GUIItem.Center, GUIItem.Center)
            powerUsageLabel:SetTextAlignmentX(GUIItem.Align_Max)
            powerUsageLabel:SetTextAlignmentY(GUIItem.Align_Min)
            powerUsageLabel:SetColor(GUIMarineBuyMenu.kTextColor)
            powerUsageLabel:SetText("47 of 47")--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(powerUsageLabel)
            
            local powerUsageIcon = GUIManager:CreateGraphicItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, powerUsageIcon)
            powerUsageIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
            powerUsageIcon:SetAnchor(GUIItem.Center, GUIItem.Center)
            powerUsageIcon:SetPosition(Vector(GUIMarineBuyMenu.kPadding*3, GUIMarineBuyMenu.kPadding*2-GUIMarineBuyMenu.kResourceIconHeight * 0.4, 0))
            powerUsageIcon:SetTexture("ui/buildmenu.dds")
            local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
            powerUsageIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
            powerUsageIcon:SetColor(GUIMarineBuyMenu.kTextColor)
            panelBackground:AddChild(powerUsageIcon)
            
            panelSize = GUIScale(Vector(GUIScale(160), GUIMarineBuyMenu.kPanelTitleHeight+GUIMarineBuyMenu.kSmallModuleButtonSize.y+GUIMarineBuyMenu.kPadding*2, 0))
            
            self.modularExoWeightLabel = weightLabel
            self.modularExoPowerUsageLabel = powerUsageLabel
        else
            local slotTypeData = kExoModuleSlotsData[slotType]
            
            local panelTitle = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, panelTitle)
            panelTitle:SetFontName(GUIMarineBuyMenu.kFont)
            panelTitle:SetFontIsBold(true)
            panelTitle:SetPosition(Vector(GUIMarineBuyMenu.kPadding*2, GUIMarineBuyMenu.kPadding, 0))
            panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
            panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
            panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
            panelTitle:SetColor(GUIMarineBuyMenu.kTextColor)
            panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(panelTitle)
            
            local buttonCount = 0
            local startOffsetX = GUIMarineBuyMenu.kPadding*1
            local startOffsetY = GUIMarineBuyMenu.kPanelTitleHeight
            local offsetX, offsetY = startOffsetX, startOffsetY
            for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
                local moduleTypeData = kExoModuleTypesData[moduleType]
                local isSameType = (moduleTypeData and moduleTypeData.category == slotTypeData.category)
                if moduleType == kExoModuleTypes.None and not slotTypeData.required then
                    isSameType = true
                    moduleTypeData = {}
                end
                if isSameType then
                    local buttonGraphic, newOffsetX, newOffsetY = slotGUIDetails.makeButton(self, moduleType, moduleTypeData, offsetX, offsetY)
                    if newOffsetX ~= offsetX then offsetX = offsetX+slotGUIDetails.gap end
                    if newOffsetY ~= offsetY then offsetY = offsetY+slotGUIDetails.gap end
                    offsetX, offsetY = newOffsetX, newOffsetY
                    panelBackground:AddChild(buttonGraphic)
                end
            end
            if offsetX == startOffsetX then offsetX = offsetX+GUIMarineBuyMenu.kWideModuleButtonSize.x end -- yolo
            if offsetY == startOffsetY then
                offsetY = offsetY+GUIMarineBuyMenu.kSmallModuleButtonSize.y+GUIMarineBuyMenu.kPadding*0
                panelTitle:SetPosition(Vector(GUIMarineBuyMenu.kPadding*1.85, GUIMarineBuyMenu.kPadding, 0))
            end
            panelSize = Vector(offsetX+GUIMarineBuyMenu.kPadding*1.5, offsetY+GUIMarineBuyMenu.kPadding*1, 0)
            
        end
        panelBackground:SetSize(panelSize)
        local panelX = slotGUIDetails.xp*GUIMarineBuyMenu.kConfigAreaWidth
        local panelY = slotGUIDetails.yp*GUIMarineBuyMenu.kConfigAreaHeight
        if slotGUIDetails.anchorX == GUIItem.Right then
            panelX = panelX-panelSize.x
        end
        panelBackground:SetPosition(Vector(
            GUIMarineBuyMenu.kConfigAreaXOffset+panelX,
            GUIMarineBuyMenu.kConfigAreaYOffset+panelY, 0
        ))
        self.content:AddChild(panelBackground)
    end
end

function GUIMarineBuyMenu:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kSmallModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local powerSupplyLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerSupplyLabel)
    powerSupplyLabel:SetPosition(Vector(GUIMarineBuyMenu.kPadding*1, GUIMarineBuyMenu.kPadding*0.3, 0))
    powerSupplyLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerSupplyLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    powerSupplyLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerSupplyLabel:SetTextAlignmentY(GUIItem.Align_Min)
    powerSupplyLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerSupplyLabel:SetText("+"..tostring(moduleTypeData.powerSupply))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerSupplyLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kPadding*4, GUIMarineBuyMenu.kPadding*0.4, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    local resCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resCostLabel)
    resCostLabel:SetPosition(Vector(GUIMarineBuyMenu.kPadding*4, GUIMarineBuyMenu.kPadding*-0.3, 0))
    resCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    resCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    resCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    resCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    resCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    resCostLabel:SetText(tostring(moduleTypeData.resourceCost))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(resCostLabel)
    
    local resIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resIcon)
    resIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    resIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    resIcon:SetPosition(Vector(GUIMarineBuyMenu.kPadding*0.8, GUIMarineBuyMenu.kPadding*0.15+GUIMarineBuyMenu.kResourceIconHeight*-1, 0))
    resIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    resIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(resIcon)
    
    table.insert(self.modularExoModuleButtonList, { -- we need to keep this list so it can change their colour
        slotType = kExoModuleSlots.PowerSupply,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        powerSupplyLabel = powerSupplyLabel, powerIcon = powerIcon,
        costLabel = resCostLabel, costIcon = resIcon,
        thingsToRecolor = { powerSupplyLabel, powerIcon, resCostLabel, resIcon },
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kSmallModuleButtonSize.x
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kWideModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local weaponLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponLabel)
    weaponLabel:SetFontName(GUIMarineBuyMenu.kFont)
    weaponLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*2.3, 0, 0))
    weaponLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    weaponLabel:SetTextAlignmentX(GUIItem.Align_Min)
    weaponLabel:SetTextAlignmentY(GUIItem.Align_Min)
    weaponLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    weaponLabel:SetText(tostring(moduleTypeGUIDetails.label))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(weaponLabel)
    
    local weaponImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponImage)
    weaponImage:SetPosition(Vector(GUIMarineBuyMenu.kWeaponImageSize.x*-0.85, GUIMarineBuyMenu.kWeaponImageSize.y*-1, 0))
    weaponImage:SetSize(GUIMarineBuyMenu.kWeaponImageSize)
    weaponImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    weaponImage:SetTexture(moduleTypeGUIDetails.image)
    weaponImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    weaponImage:SetColor(Color(1, 1, 1, 1))
    buttonGraphic:AddChild(weaponImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*2.3, -GUIMarineBuyMenu.kPadding*0.5, 0))
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.powerCost))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*4.3, -GUIMarineBuyMenu.kPadding*0.5+GUIMarineBuyMenu.kResourceIconHeight * -0.8, 0))
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = slotType,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        weaponLabel = weaponLabel, weaponImage = weaponImage,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { weaponLabel, --[[weaponImage,]] powerCostLabel, powerIcon},
    })
    
    offsetY = offsetY+GUIMarineBuyMenu.kWideModuleButtonSize.y
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeArmorModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kSmallModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local armorLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, armorLabel)
    armorLabel:SetPosition(Vector(0, GUIMarineBuyMenu.kPadding*0.45, 0))
    armorLabel:SetFontName(GUIMarineBuyMenu.kFont)
    armorLabel:SetAnchor(GUIItem.Center, GUIItem.Top)
    armorLabel:SetTextAlignmentX(GUIItem.Align_Center)
    armorLabel:SetTextAlignmentY(GUIItem.Align_Min)
    armorLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    armorLabel:SetText("+"..(moduleTypeData.armorBonus or "0"))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(armorLabel)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(0, GUIMarineBuyMenu.kPadding*-0.45, 0))
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Max)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.powerCost))--Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    powerIcon:SetPosition(Vector(0, GUIMarineBuyMenu.kResourceIconHeight*-0.8+GUIMarineBuyMenu.kPadding*-0.5, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = kExoModuleSlots.Armor,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        armorLabel = armorLabel,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { armorLabel, powerCostLabel, powerIcon},
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kSmallModuleButtonSize.x
    return buttonGraphic, offsetX, offsetY
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end
function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    if self.hoveringExo then
        self:_RefreshExoModularButtons()
        if not MarineBuy_IsResearched(kTechId.Exosuit) or PlayerUI_GetPlayerResources() < self.exoConfigResourceCost then
            self.modularExoBuyButton:SetColor(Color(1, 0, 0, 1))
            
            self.modularExoBuyButtonText:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.modularExoCostText:SetColor(GUIMarineBuyMenu.kCannotBuyColor)
            self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kCannotBuyColor)
        else
            if GetIsMouseOver(self, self.modularExoBuyButton) then
                self.modularExoBuyButton:SetColor(Color(1, 1, 1, 1))
            else
                self.modularExoBuyButton:SetColor(Color(0.5, 0.5, 0.5, 1))
            end
            
            self.modularExoBuyButtonText:SetColor(GUIMarineBuyMenu.kCloseButtonColor)
            self.modularExoCostText:SetColor(GUIMarineBuyMenu.kTextColor)
            self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kTextColor)
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    buttonData.buttonGraphic:SetColor(Color(0, 0.7, 1, 1))
                end
            else
                buttonData.buttonGraphic:SetColor(buttonData.col)
            end
        end
    end
end

function GUIMarineBuyMenu:_RefreshExoModularButtons()
    local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
    self.exoConfigResourceCost = resourceCost
    self.modularExoCostText:SetText(tostring(resourceCost))
    self.modularExoPowerUsageLabel:SetText(tostring(powerCost).." of "..tostring(powerSupply))
    --self.modularExoWeightLabel
    
    for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
        local current = self.exoConfig[buttonData.slotType]
        local col = nil
        if current == buttonData.moduleType then
            if PlayerUI_GetPlayerResources() < self.exoConfigResourceCost then
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kCannotBuyColor)
                col = GUIMarineBuyMenu.kCannotBuyColor
            else
                buttonData.state = "selected"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kEnabledColor)
                col = GUIMarineBuyMenu.kEnabledColor
            end
        else
            self.exoConfig[buttonData.slotType] = buttonData.moduleType
            local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
            if buttonData.slotType == kExoModuleSlots.PowerSupply then
                if isValid and PlayerUI_GetPlayerResources() < resourceCost then
                    isValid = false
                elseif badReason == "not enough power" then
                    isValid = true
                    buttonData.forceToDefaultConfig = true
                else
                    buttonData.forceToDefaultConfig = false
                end
            end
            if buttonData.slotType == kExoModuleSlots.RightArm and badReason == "bad model left" then
                isValid = true
                buttonData.forceLeftToClaw = true
            else
                buttonData.forceLeftToClaw = false
            end
            if isValid then
                buttonData.state = "enabled"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kDisabledColor)
                col = GUIMarineBuyMenu.kDisabledColor
            else
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kDisabledColor)
                col = GUIMarineBuyMenu.kCannotBuyColor
            end
            if not isValid and (badReason == "bad model right" or badReason == "bad model left") then
                col = Color(0.2, 0.2, 0.2, 0.4)
                buttonData.weaponImage:SetColor(Color(0.2, 0.2, 0.2, 0.4))
            elseif buttonData.weaponImage ~= nil then
                buttonData.weaponImage:SetColor(Color(1, 1, 1, 1))
            end
            self.exoConfig[buttonData.slotType] = current
        end
        buttonData.col = col
        for thingI, thing in ipairs(buttonData.thingsToRecolor) do
            thing:SetColor(col)
        end
    end
end

ReplaceLocals(GUIMarineBuyMenu.SendKeyEvent, {
    HandleItemClicked = function(self, mouseX, mouseY) -- why is this a local? :|
        for i = 1, #self.itemButtons do
            local item = self.itemButtons[i]
            if item.TechId ~= kTechId.Exosuit and GetIsMouseOver(self, item.Button) then
                local researched, researchProgress, researching = self:_GetResearchInfo(item.TechId)
                local itemCost = MarineBuy_GetCosts(item.TechId)
                local canAfford = PlayerUI_GetPlayerResources() >= itemCost
                local hasItem = PlayerUI_GetHasItem(item.TechId)
                if researched and canAfford and not hasItem then
                    MarineBuy_PurchaseItem(item.TechId)
                    MarineBuy_OnClose()
                    return true, true
                end
            end
        end
        if self.hoveringExo then
            if GetIsMouseOver(self, self.modularExoBuyButton) and MarineBuy_IsResearched(kTechId.Exosuit) then
                Client.SendNetworkMessage("ExoModularBuy", ModularExo_ConvertConfigToNetMessage(self.exoConfig))
                MarineBuy_OnClose()
                return true, true
            end
            for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
                if GetIsMouseOver(self, buttonData.buttonGraphic) then
                    if buttonData.state == "enabled" then
                        self.exoConfig[buttonData.slotType] = buttonData.moduleType
                        if buttonData.forceToDefaultConfig then
                            self.exoConfig[kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun
                            self.exoConfig[kExoModuleSlots.LeftArm ] = kExoModuleTypes.Claw
                            self.exoConfig[kExoModuleSlots.Armor   ] = kExoModuleTypes.None
                            self.exoConfig[kExoModuleSlots.Utility ] = kExoModuleTypes.None
                        end
                        if buttonData.forceLeftToClaw then
                            self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                        end
                        self:_RefreshExoModularButtons()
                    end
                end
            end
        end
        
        return false, false
    end,
})

local orig_GUIMarineBuyMenu__UpdateContent = GUIMarineBuyMenu._UpdateContent
function GUIMarineBuyMenu:_UpdateContent(deltaTime)
    if self.hoverItem == kTechId.Exosuit or (self.hoverItem == nil and self.hoveringExo) then
        self.hoveringExo = true
        self.portrait:SetIsVisible(false)
        self.itemName:SetIsVisible(false)
        self.itemDescription:SetIsVisible(false)
        
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
        
        return
    end
    if self.modularExoGraphicItemsToDestroyList then
        self.hoveringExo = false
        self.modularExoConfigActive = false
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(false)
        end
    end
    return orig_GUIMarineBuyMenu__UpdateContent(self, deltaTime)
end


function GetIsMouseOver(self, overItem) -- WHY IS THIS NOT GLOBAL OR A CLASS METHOD?!?!?

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end


















