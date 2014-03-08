heatAmountright = 0
idleHeatAmountright = 0
shieldStatusright = "off"

function Update(dt)  
    UpdateOverHeat(dt, heatAmountright, idleHeatAmountright, shieldStatusright)
end

Script.Load("lua/ModularExo_GUIShield.lua")