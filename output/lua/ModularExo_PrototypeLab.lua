
local orig_PrototypeLab_GetItemList = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
    if forPlayer:isa("Exo") then
        return { kTechId.Exosuit }
    end
    return { kTechId.Jetpack, kTechId.Exosuit }
    --return orig_PrototypeLab_GetItemList(self, forPlayer)
end
