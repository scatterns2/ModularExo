
Script.Load("lua/Exo.lua")

Script.Load("lua/Mixins/JumpMoveMixin.lua")

local networkVars = {
    powerModuleType    = "enum kExoModuleTypes",
	rightArmModuleType = "enum kExoModuleTypes",
	leftArmModuleType  = "enum kExoModuleTypes",
    armorModuleType    = "enum kExoModuleTypes",
    utilityModuleType  = "enum kExoModuleTypes",
    
	hasThrusters = "boolean",
	hasScanner = "boolean",
    armorBonus = "float (0 to 2045 by 1)",
}

AddMixinNetworkVars(JumpMoveMixin, networkVars)


local orig_Exo_OnCreate = Exo.OnCreate
function Exo:OnCreate()
	orig_Exo_OnCreate(self)
    
    InitMixin(self, JumpMoveMixin)
end
local orig_Exo_OnInitialized = Exo.OnInitialized
function Exo:OnInitialized()
    self.powerModuleType = self.powerModuleType or kExoModuleTypes.Power1
    self.leftArmModuleType = self.leftArmModuleType or kExoModuleTypes.Claw
    self.rightArmModuleType = self.rightArmModuleType or kExoModuleTypes.Minigun
    self.armorModuleType = self.armorModuleType or kExoModuleTypes.None
    self.utilityModuleType = self.utilityModuleType or kExoModuleTypes.None
    
    local armorModuleData = kExoModuleTypesData[self.armorModuleType]
    self.armorBonus = armorModuleData and armorModuleData.armorBonus or 0
    self.hasScanner = (self.utilityModuleType == kExoModuleTypes.Scanner)
    self.hasThrusters = (self.utilityModuleType == kExoModuleTypes.Thrusters)
    
    orig_Exo_OnInitialized(self)
end

local orig_Exo_InitExoModel = Exo.InitExoModel
function Exo:InitExoModel(overrideAnimGraph)
    local leftArmType = (kExoModuleTypesData[self.leftArmModuleType] or {}).armType
    local rightArmType = (kExoModuleTypesData[self.rightArmModuleType] or {}).armType
    local modelData = (kExoWeaponRightLeftComboModels[rightArmType] or {})[leftArmType] or {}
    local modelName = modelData.worldModel or "models/marine/exosuit/exosuit_rr.model"
    local graphName = modelData.worldAnimGraph or "models/marine/exosuit/exosuit_rr.animation_graph"
    self:SetModel(modelName, overrideAnimGraph or graphName)
    self.viewModelName = modelData.viewModel or "models/marine/exosuit/exosuit_rr_view.model"
    self.viewModelGraphName = modelData.viewAnimGraph or "models/marine/exosuit/exosuit_rr_view.animation_graph"
end

local kDeploy2DSound = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")
local orig_Exo_InitWeapons = Exo.InitWeapons
function Exo:InitWeapons()
    Player.InitWeapons(self)
    
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)   
    end
    
    local leftArmModuleTypeData = kExoModuleTypesData[self.leftArmModuleType]
    local rightArmModuleTypeData = kExoModuleTypesData[self.rightArmModuleType]
    weaponHolder:SetWeapons(leftArmModuleTypeData.mapName, rightArmModuleTypeData.mapName)
    
    weaponHolder:TriggerEffects("exo_login")
    self.inventoryWeight = self:CalculateWeight()
    self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
end

local orig_Exo_GetCanJump = Exo.GetCanJump 
function Exo:GetCanJump()
	return not self.hasThrusters
end

local orig_Exo_GetIsThrusterAllowed = Exo.GetIsThrusterAllowed
function Exo:GetIsThrusterAllowed()
	return self.hasThrusters and orig_Exo_GetIsThrusterAllowed(self)
end
local orig_Exo_GetSlowOnLand = Exo.GetSlowOnLand
function Exo:GetSlowOnLand()
    return true
end
local orig_Exo_GetWebSlowdownScalar = Exo.GetWebSlowdownScalar
function Exo:GetWebSlowdownScalar()
    return 0.6
end

local orig_Exo_GetArmorAmount = Exo.GetArmorAmount 
function Exo:GetArmorAmount()
	return kExosuitArmor + self.armorBonus
end

function Exo:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
    coords.xAxis = coords.xAxis * 1
    coords.yAxis = coords.yAxis * 1
    coords.zAxis = coords.zAxis * 1
    return coords
end

function Exo:ProcessExoModularBuyAction(message)
    ModularExo_HandleExoModularBuy(self, message)
end

function Exo:CalculateWeight()
    return ModularExo_GetConfigWeight(ModularExo_ConvertNetMessageToConfig(self))
end

if Server then
    local orig_Exo_PerformEject = Exo.PerformEject
    function Exo:PerformEject()
        if self:GetIsAlive() then
            -- pickupable version
            local exosuit = CreateEntity(Exosuit.kMapName, self:GetOrigin(), self:GetTeamNumber(), {
                powerModuleType    = self.powerModuleType   ,
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType ,
                armorModuleType    = self.armorModuleType   ,
                utilityModuleType  = self.utilityModuleType ,
            })
            exosuit:SetCoords(self:GetCoords())
            exosuit:SetMaxArmor(self:GetMaxArmor())
            exosuit:SetArmor(self:GetArmor())
            
            local reuseWeapons = self.storedWeaponsIds ~= nil
            
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0), { preventWeapons = reuseWeapons })
            marine:SetHealth(self.prevPlayerHealth or kMarineHealth)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4*3.5)
            initialVelocity.y = 9*2
            marine:SetVelocity(initialVelocity)
            
            if reuseWeapons then
                for _, weaponId in ipairs(self.storedWeaponsIds) do
                    local weapon = Shared.GetEntity(weaponId)
                    if weapon then
                        marine:AddWeapon(weapon)
                    end
                end
            end
            marine:SetHUDSlotActive(1)
            if marine:isa("JetpackMarine") then
                marine:SetFuel(0)
            end
        end
        return false
    end 
end
if Client then
    local orig_Exo_BuyMenu = Exo.BuyMenu
    function Exo:BuyMenu(structure)
        if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
            if not self.buyMenu then
                self.buyMenu = GetGUIManager():CreateGUIScript("GUIModularExoBuyMenu")
                MarineUI_SetHostStructure(structure)
                if structure then
                    self.buyMenu:SetHostStructure(structure)
                end
                self:TriggerEffects("marine_buy_menu_open")
                TEST_EVENT("Exo buy menu displayed")
            end
        end
    end
end


Class_Reload("Exo", networkVars)
