
    /*if shouldDisplayAsViewModel then
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
            local coords = viewModel.boneCoords:Get(6-1)
            
            local modelMiddleCoords = Coords.GetIdentity()
            modelMiddleCoords.origin = Vector(0, 0.05, 0)
            
            coords = coords*modelMiddleCoords
            
            coords:Scale(-0.3)
            
            self.shieldModel:SetCoords(coords)
        end
    end
    
    local coords = player._renderModel and player._renderModel:GetCoords() or Coords.GetIdentity()
    
    coords = coords*player.boneCoords:Get(63-1)
    
    local modelMiddleCoords = Coords.GetIdentity()
    modelMiddleCoords.origin = Vector(0, 0.05, 0)
    
    coords = coords*modelMiddleCoords
    
    coords:Scale(-0.3)
    if not shouldDisplayAsViewModel then
        self.shieldModel:SetCoords(coords)
    end
    self.clawLight:SetCoords(coords)*/