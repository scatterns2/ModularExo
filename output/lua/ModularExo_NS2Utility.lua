
Script.Load("lua/NS2Utility.lua")


function GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter, mask)
    
    -- This method is only used by ClipWeapon, so it's safe to default to MarineBullets
    -- If some other mod uses this for an alien attack, it will go through ExoShields!
    mask = mask or PhysicsMask.MarineBullets--PhysicsMask.Bullets
    
    local targets = {}
    local targetIdMap = {}
    local hitPoints = {}
    local trace
    
    local traceFilter = (
            filter and function(test) return targetIdMap[test:GetId()] or filter(test) end
        or             function(test) return targetIdMap[test:GetId()]                 end
    )
    
    for i = 1, 20 do
        trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, mask, traceFilter)
        if not trace.entity then
            -- Limit the box trace to the point where the ray hit as an optimization.
            local boxTraceEndPoint = trace.fraction ~= 1 and trace.endPoint or endPoint
            local extents = GetDirectedExtentsForDiameter(spreadDirection, bulletSize)
            trace = Shared.TraceBox(extents, startPoint, boxTraceEndPoint, CollisionRep.Damage, mask, traceFilter)
        end
        
        if trace.entity and not targetIdMap[trace.entity:GetId()] then
            table.insert(targets, trace.entity)
            targetIdMap[trace.entity:GetId()] = true
            table.insert(hitPoints, trace.endPoint)
        end
        if (not trace.entity or not HasMixin(trace.entity, "SoftTarget")) or trace.fraction == 1 then
            break
        end
    end
    return targets, trace, hitPoints
end
