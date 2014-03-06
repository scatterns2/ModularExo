
local animHeatAmount = 0
local animHeatDir = 1

local background = nil

local foreground = nil
local foregroundMask = nil

local alertLight = nil

local idleArrow = nil

local time = 0

local kTexture = "models/marine/exosuit/exosuit_view_panel_mini2.dds"

local offCol = Color(1, 1, 1, 1)
local onCol = Color(0, 0, 1, 1)
local combatCol = Color(1, 1, 0, 1)
local overheatCol1 = Color(1, 0, 0, 1)
local overheatCol2 = Color(1, 1, 0, 1)
local overheatPulseRate = 0.3

function UpdateOverHeat(dt, heatAmount, idleHeatAmount, shieldStatus)

    PROFILE("GUILeftMinigunDisplay:Update")
    
    --heatAmount = math.max(0.4, heatAmount)
    
    foregroundMask:SetSize(Vector(242, 720 * (1 - heatAmount), 0))
    
    local flash = false
    local alertColor = (
            shieldStatus == "off" and offcol
        or  shieldStatus == "on" and onCol
        or  shieldStatus == "combat" and combatCol
        or  shieldStatus == "overheat" and ((time%overheatPulseRate) < overheatPulseRate/2 and overheatCol1 or overheatCol2)
        or  Color(1, 0.6, 0.6, 1)
    )
    alertLight:SetColor(alertColor)
    
    foreground:SetColor(alertColor)
    
    idleArrow:SetPosition(Vector(720+64, 512-idleHeatAmount*512, 0))
    
    time = time + dt
end

function Initialize()

    GUI.SetSize(242, 720)
    
    background = GUI.CreateItem()
    background:SetSize(Vector(242, 720, 0))
    background:SetPosition(Vector(0, 0, 0))
    background:SetTexturePixelCoordinates(0, 0, 230, 512)
    background:SetTexture(kTexture)
    
    foreground = GUI.CreateItem()
    foreground:SetSize(Vector(230, 720, 0))
    foreground:SetPosition(Vector(0, 0, 0))
    --foreground:SetTexturePixelCoordinates(300, 0, 512, 512)
    foreground:SetTexturePixelCoordinates(0, 0, 230, 512)
    foreground:SetTexture(kTexture)
    foreground:SetStencilFunc(GUIItem.Equal)
    
    foregroundMask = GUI.CreateItem()
    foregroundMask:SetSize(Vector(242, 720, 0))
    foregroundMask:SetPosition(Vector(0, 0, 0))
    foregroundMask:SetIsStencil(true)
    foregroundMask:SetClearsStencilBuffer(true)
    
    foregroundMask:AddChild(foreground)
    
    alertLight = GUI.CreateItem()
    alertLight:SetSize(Vector(60, 720, 0))
    alertLight:SetPosition(Vector(0, 0, 0))
    alertLight:SetTexturePixelCoordinates(240, 0, 290, 512)
    alertLight:SetTexture(kTexture)
    
    idleArrow = GUI.CreateItem()
    idleArrow:SetSize(Vector(-64, 64, 0))
    idleArrow:SetPosition(Vector(720+64, 0, 0))
    idleArrow:SetTexturePixelCoordinates(0, 0, 64, 64)
    idleArrow:SetTexture("ui/menu/arrow_horiz.dds")
    
    background:AddChild(foregroundMask)
    background:AddChild(alertLight)
    background:AddChild(idleArrow)
    
end

Initialize()