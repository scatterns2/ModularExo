
Script.Load("lua/Marine.lua")

function Marine:ProcessExoModularBuyAction(message)
    ModularExo_HandleExoModularBuy(self, message)
end

local orig_Marine_BuyMenu = Marine.BuyMenu
function Marine:BuyMenu(structure)
    if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
        if not self.buyMenu then
            self.buyMenu = GetGUIManager():CreateGUIScript("GUIModularExoBuyMenu")
            MarineUI_SetHostStructure(structure)
            if structure then
                self.buyMenu:SetHostStructure(structure)
            end
            self:TriggerEffects("marine_buy_menu_open")
            TEST_EVENT("Marine buy menu displayed")
        end
    end
end
