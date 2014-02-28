
Script.Load("lua/GUIMarineBuyMenu.lua")
Script.Load("lua/GUI/ModularExo_GUIMarineBuyMenu_Data.lua")


GUIMarineBuyMenu.kConfigAreaXOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kConfigAreaYOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kUpgradeButtonAreaHeight = GUIScale(20)
GUIMarineBuyMenu.kConfigAreaWidth = (
        GUIMarineBuyMenu.kBackgroundWidth
    -   GUIMarineBuyMenu.kMenuWidth
    -   GUIMarineBuyMenu.kPadding*2
)
GUIMarineBuyMenu.kConfigAreaHeight = (
        GUIMarineBuyMenu.kBackgroundHeight
    -   GUIMarineBuyMenu.kResourceDisplayHeight
    -   GUIMarineBuyMenu.kUpgradeButtonAreaHeight
    -   GUIMarineBuyMenu.kPadding*3
)
GUIMarineBuyMenu.kSlotPanelBackgroundColor = Color(0.5, 0.5, 1, 0.8)

GUIMarineBuyMenu.kSmallModuleButtonSize = GUIScale(Vector(100, 100, 0))
GUIMarineBuyMenu.kWideModuleButtonSize = GUIScale(Vector(190, 100, 0))
GUIMarineBuyMenu.kWeaponImageSize = GUIScale(Vector(100, 70, 0))
GUIMarineBuyMenu.kModuleButtonGap = GUIScale(20)

GUIMarineBuyMenu.kExoSlotData = {
    [kExoModuleSlots.PowerSupply] = {
        label = "EXO_MODULESLOT_POWERSUPPLY", 
        xp = 0, yp = 0, anchorX = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    StatusPanel = { -- the one that shows weight and power usage
        label = nil,
        xp = 0, yp = 0, anchorX = GUIItem.Left,
    },
    [kExoModuleSlots.RightArm] = {
        label = "EXO_MODULESLOT_RIGHT_ARM",
        xp = 0, yp = 0.15, anchorX = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    [kExoModuleSlots.LeftArm] = {
        label = "EXO_MODULESLOT_LEFT_ARM",
        xp = 1, yp = 0.15, anchorX = GUIItem.Right,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    [kExoModuleSlots.Armor] = {
        label = "EXO_MODULESLOT_ARMOR",
        xp = 0, yp = 0.85, anchorX = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeArmorModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    --[[
    [kExoModuleSlots.Utility] = {
        label = "EXO_MODULESLOT_UTILITY",
        xp = 1, yp = 0.85, anchorX = GUIItem.Right,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
    ]]
}

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    if hostStructure:isa("PrototypeLab") then
       self:_InitializeExoModularButtons()
    end
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {} -- WWHHYY UWE, WWWHHHHYYYYYY?!?!¿!?
    self.modularExoModuleButtonList = {}
    self.modularExoPowerModuleButtonList = {}
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = GUIManager:CreateGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        --panelBackground:SetSize()
        panelBackground:SetAnchor(
            slotGUIDetails.anchorX or GUIItem.Left,
            slotGUIDetails.anchorY or GUIItem.Top
        )
        panelBackground:SetPosition(Vector(
            GUIMarineBuyMenu.kConfigAreaXOffset+slotGUIDetails.xp*GUIMarineBuyMenu.kConfigAreaWidth,
            GUIMarineBuyMenu.kConfigAreaYOffset+slotGUIDetails.yp*GUIMarineBuyMenu.kConfigAreaHeight, 0
        ))
        panelBackground:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
        panelBackground:SetColor(GUIMarineBuyMenu.kSlotPanelBackgroundColor)
        
        if slotType == "StatusPanel" then
            local weightLabel = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, weightLabel)
            weightLabel:SetFontName(GUIMarineBuyMenu.kFont)
            weightLabel:SetFontIsBold(true)
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
            powerUsageIcon:SetPosition(Vector(GUIMarineBuyMenu.kResourceIconWidth/2, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
            powerUsageIcon:SetTexture("ui/buildmenu.dds")
            local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
            powerUsageIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
            powerUsageIcon:SetColor(GUIMarineBuyMenu.kTextColor)
            panelBackground:AddChild(powerUsageIcon)
            
            self.modularExoWeightLabel = weightLabel
            self.modularExoPowerUsageLabel = powerUsageLabel
        else
            local slotTypeData = kExoModuleSlotsData[slotType]
            
            local panelTitle = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, panelTitle)
            panelTitle:SetFontName(GUIMarineBuyMenu.kFont)
            panelTitle:SetFontIsBold(true)
            panelTitle:SetPosition(GUIMarineBuyMenu.kPadding, GUIMarineBuyMenu.kPadding)
            panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
            panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
            panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
            panelTitle:SetColor(GUIMarineBuyMenu.kTextColor)
            panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(panelTitle)
            
            local panelWidth, panelHeight = 0, 0
            local buttonCount = 0
            
            for moduleType, moduleTypeData in pairs(kExoModuleTypesData) do
                if moduleTypeData.category == slotTypeData.category then
                    
        
            panelBackground:SetSize()
        end
    end
end

function GUIMarineBuyMenu:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kSmallModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(moduleTypeGUIDetails.image)
    buttonGraphic:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    
    local powerSupplyLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerSupplyLabel)
    powerSupplyLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerSupplyLabel:SetAnchor(GUIItem.Center, GUIItem.Center)
    powerSupplyLabel:SetTextAlignmentX(GUIItem.Align_Max)
    powerSupplyLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerSupplyLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerSupplyLabel:SetText("66")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerSupplyLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Center, GUIItem.Center)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kResourceIconWidth/2, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    local resCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resCostLabel)
    resCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    resCostLabel:SetAnchor(GUIItem.Center, GUIItem.Center)
    resCostLabel:SetTextAlignmentX(GUIItem.Align_Max)
    resCostLabel:SetTextAlignmentY(GUIItem.Align_Min)
    resCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    resCostLabel:SetText("99")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(resCostLabel)
    
    local resIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resIcon)
    resIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    resIcon:SetAnchor(GUIItem.Center, GUIItem.Center)
    resIcon:SetPosition(Vector(GUIMarineBuyMenu.kResourceIconWidth/2, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
    resIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    resIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    resIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(resIcon)
    
    table.insert(self.modularExoPowerModuleButtonList, { -- we need to keep this list so it can change their colour
        buttonGraphic = buttonGraphic,
        powerSupplyLabel = powerSupplyLabel, powerIcon = powerIcon,
        resCostLabel = resCostLabel, resIcon = resIcon,
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kSmallModuleButtonSize.x+GUIMarineBuyMenu.kModuleButtonGap
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kWideModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(moduleTypeGUIDetails.image)
    buttonGraphic:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    
    local weaponLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponLabel)
    weaponLabel:SetFontName(GUIMarineBuyMenu.kFont)
    weaponLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    weaponLabel:SetTextAlignmentX(GUIItem.Align_Min)
    weaponLabel:SetTextAlignmentY(GUIItem.Align_Min)
    weaponLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    weaponLabel:SetText("Explosive Cactus")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(weaponLabel)
    
    local weaponImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponImage)
    weaponImage:SetSize(GUIMarineBuyMenu.kWeaponImageSize)
    weaponImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    weaponImage:SetTexture(moduleTypeGUIDetails.image)
    weaponImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    weaponImage:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(weaponImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText("66")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kResourceIconWidth*2, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        buttonGraphic = buttonGraphic,
        weaponLabel = weaponLabel, weaponImage = weaponImage,
        powerCostLabel = powerCostLabel, powerIcon = powerIcon,
    })
    
    offsetY = offsetY+GUIMarineBuyMenu.kWideModuleButtonSize.y+GUIMarineBuyMenu.kModuleButtonGap
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeArmorModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kSmallModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(moduleTypeGUIDetails.image)
    buttonGraphic:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    
    local armorLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, armorLabel)
    armorLabel:SetFontName(GUIMarineBuyMenu.kFont)
    armorLabel:SetAnchor(GUIItem.Center, GUIItem.Top)
    armorLabel:SetTextAlignmentX(GUIItem.Align_Center)
    armorLabel:SetTextAlignmentY(GUIItem.Align_Center)
    armorLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    armorLabel:SetText("66")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(armorLabel)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Max)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Center)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText("66")--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kResourceIconWidth*2, -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoPowerModuleButtonList, {
        buttonGraphic = buttonGraphic,
        armorLabel = armorLabel,
        powerCostLabel = powerCostLabel, powerIcon = powerIcon,
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kSmallModuleButtonSize.x+GUIMarineBuyMenu.kModuleButtonGap
    return buttonGraphic, offsetX, offsetY
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end
function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    
end

local orig_GUIMarineBuyMenu__UpdateContent = GUIMarineBuyMenu._UpdateContent
function GUIMarineBuyMenu:_UpdateContent(deltaTime)
    if self.hoverItem == kTechId.Exosuit then
        self.portrait:SetIsVisible(false)
        self.itemName:SetIsVisible(false)
        self.itemDescription:SetIsVisible(false)
        
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
    end
    self.modularExoConfigActive = false
    for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
        element:SetIsVisible(false)
    end
    return orig_GUIMarineBuyMenu__UpdateContent(self, deltaTime)
end





















