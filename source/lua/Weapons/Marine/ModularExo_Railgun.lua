
Script.Load("lua/Weapons/Marine/Railgun.lua")

Railgun.kChargeTime  = Railgun.kChargeTime  or GetLocal(GetLocal(GetLocal(Railgun.OnTag, "Shoot"), "ExecuteShot"), "kChargeTime" )
Railgun.kBulletSize  = Railgun.kBulletSize  or GetLocal(GetLocal(GetLocal(Railgun.OnTag, "Shoot"), "ExecuteShot"), "kBulletSize" )

ReplaceLocals(GetLocal(Railgun.OnTag, "Shoot"), {
    ExecuteShot = function(self, startPoint, endPoint, player)
        local filter = EntityFilterTwo(player, self)
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.MarineBullets, EntityFilterAllButIsa("Tunnel"))
        local hitPointOffset = trace.normal * 0.3
        local direction = (endPoint - startPoint):GetUnit()
        local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / self.kChargeTime) * kRailgunChargeDamage
        
        local extents = GetDirectedExtentsForDiameter(direction, self.kBulletSize)
        
        if trace.fraction < 1 then
            local hitEntities = {}
            for i = 1, 20 do
                local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.MarineBullets, filter)
                if capsuleTrace.entity then
                    if not table.find(hitEntities, capsuleTrace.entity) then
                        table.insert(hitEntities, capsuleTrace.entity)
                        self:DoDamage(damage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)
                    end
                end
                if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
                    break
                end
                startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
            end
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
            self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
        end
    end
})
