
Script.Load("lua/Exo.lua")

Script.Load("lua/Mixins/JumpMoveMixin.lua")

local networkVars = {
	rightArmModuleType = "enum kExoModuleTypes",
	leftArmModuleType = "enum kExoModuleTypes",
	hasThrusters = "boolean",
    armorBonus = "float (0 to 2045 by 1)",
}

AddMixinNetworkVars(JumpMoveMixin, networkVars)


local orig_Exo_OnCreate = Exo.OnCreate
function Exo:OnCreate()
	orig_Exo_OnCreate(self)
    
    InitMixin(self, JumpMoveMixin)
    
    self.leftArmModuleType = self.leftArmModuleType or kExoModuleTypes.Claw
    self.rightArmModuleType = self.rightArmModuleType or kExoModuleTypes.Minigun
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
    HandleExoModularBuy(message)
end

local orig_Exo_InitExoModel = Exo.InitExoModel
function Exo:InitExoModel()
    local leftArmType = kExoModuleTypesData[self.leftArmModuleType].armType
    local rightArmType = kExoModuleTypesData[self.rightArmModuleType].armType
    local modelData = kExoWeaponRightLeftComboModels[rightArmType][leftArmType]
    local modelName = modelData.worldModel
    local graphName = modelData.worldAnimGraph
    self:SetModel(modelName, graphName)
    self.viewModelName = modelData.viewModel
    self.viewModelGraphName = modelData.viewAnimGraph
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
    self.inventoryWeight = weaponHolder:GetInventoryWeight(self)
    self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
end


Class_Reload("Exo", networkVars)
