
Script.Load("lua/Weapons/Marine/Minigun.lua")

Minigun.kMinigunRange = GetLocal(Minigun.Shoot, "kMinigunRange") -- wtf uwe, this does not count as "moddable"
Minigun.kMinigunSpread = GetLocal(Minigun.Shoot, "kMinigunSpread")
Minigun.kBulletSize = GetLocal(Minigun.Shoot, "kBulletSize")

ReplaceLocals(Mingiun.OnTag, {
    Shoot = function(self, leftSide)
        local player = self:GetParent()
        if self.minigunAttacking and player then
            if Server and not self.spinSound:GetIsPlaying() then
                self.spinSound:Start()
            end    
            
            local viewAngles = player:GetViewAngles()
            local shootCoords = viewAngles:GetCoords()
            
            local filter = EntityFilterTwo(player, self)
            local startPoint = player:GetEyePos()
            
            local spreadDirection = CalculateSpread(shootCoords, self.kMinigunSpread, NetworkRandom)
            
            local range = self.kMinigunRange
            if GetIsVortexed(player) then
                range = 5
            end
            
            local endPoint = startPoint + spreadDirection * range
            
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.MarineBullets, filter)
            if not trace.entity then
                local extents = GetDirectedExtentsForDiameter(spreadDirection, self.kBulletSize)
                trace = Shared.TraceBox(extents, startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            end
            
            if trace.fraction < 1 or GetIsVortexed(player) then
                local direction = (trace.endPoint - startPoint):GetUnit()
                local impactPoint = trace.endPoint - direction * kHitEffectOffset
                
                local impactPoint = trace.endPoint - GetNormalizedVector(endPoint - startPoint) * kHitEffectOffset
                local surfaceName = trace.surface
                
                local effectFrequency = self:GetTracerEffectFrequency()
                local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
                
                self:ApplyBulletGameplayEffects(player, trace.entity, impactPoint, direction, kMinigunDamage, trace.surface, showTracer)
                
                if Client and showTracer then
                    TriggerFirstPersonTracer(self, trace.endPoint)
                end
            end
            self.shooting = true
        end
    end
})
