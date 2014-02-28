
local orig_PrototypeLab_GetItemList = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
    if forPlayer:isa("Exo") then
        return { kTechId.Exosuit }
    end
    return orig_PrototypeLab_GetItemList(self, forPlayer)
end
