
Script.Load("lua/GUIMarineBuyMenu.lua")
Script.Load("lua/GUI/ModularExo_GUIMarineBuyMenu_Data.lua")


GUIMarineBuyMenu.kConfigAreaXOffset = (
        GUIMarineBuyMenu.kMenuWidth
    +   GUIMarineBuyMenu.kPadding
)
GUIMarineBuyMenu.kConfigAreaYOffset = (
        GUIMarineBuyMenu.kResourceDisplayHeight
    +   GUIMarineBuyMenu.kPadding
)
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

GUIMarineBuyMenu.kExoSlotData = {
    [kExoModuleSlots.PowerSupply] = {
        xp = 0, yp = 0, anchorX = GUIItem.Left,
    },
    StatusPanel = { -- the one that shows weight and power usage
        xp = 0, yp = 0, anchorX = GUIItem.Left,
    },
    [kExoModuleSlots.RightArm] = {
        xp = 0, yp = 0.15, anchorX = GUIItem.Left,
    },
    [kExoModuleSlots.LeftArm] = {
        xp = 1, yp = 0.15, anchorX = GUIItem.Right,
    },
    [kExoModuleSlots.Armor] = {
        xp = 0, yp = 0.85, anchorX = GUIItem.Left,
    },
    [kExoModuleSlots.Utility] = {
        xp = 1, yp = 0.85, anchorX = GUIItem.Right,
    },
}

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    if hostStructure:isa("PrototypeLab") then
       self:_InitializeExoModularButtons()
    end
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        if slotType == "StatusPanel" then
            
        else
            local slotData = kExoModuleSlotsData[slotType]
            
            
            
        end
    end
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end
function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    
end

