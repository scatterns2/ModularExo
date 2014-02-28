
Script.Load("lua/GUIMarineBuyMenu.lua")

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    if hostStructure:isa("PrototypeLab") then
       self:_InitializeExoModularButtons()
    end
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end
function GUIMarineBuyMenu:_UpdateExoModularButtons()
    
end

