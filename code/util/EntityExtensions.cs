using System;
using System.Collections.Generic;
using Sandbox;

namespace BattleMages;

public static class EntityExtensions
{
    public static bool CanSee(this Entity self, Vector3 point)
    {
        var tr = Trace.Ray( self.WorldSpaceBounds.Center, point )
            .WorldOnly()
            .Radius( 1f )
            .Run();

        return tr.EndPosition.AlmostEqual(point, 5f);
    }

    public static bool CanSee(this Entity self, Entity target)
    {
        return CanSee(self, target.WorldSpaceBounds.Center);
    }

    public static List<Entity> GetEntitiesInCone(Vector3 origin, Vector3 direction, float length, float angle)
    {
        direction = direction.Normal;
        
        var list = new List<Entity>();

        var halfLen = length / 2f;
        var startPos = origin + direction * halfLen;

        var entsInSphere = Entity.FindInSphere(startPos, halfLen);

        foreach (var entity in entsInSphere)
        {
            var directionToEntity = (entity.Position - origin).Normal;
            var deltaAngle = MathF.Acos(directionToEntity.Dot(direction));
            
            if (deltaAngle <= angle)
                list.Add(entity);
        }
        
        return list;
    }

    public static float DistanceToSquared(this Entity self, Entity target)
    {
        return (target.Position - self.Position).LengthSquared;
    }

    public static TraceResult GetEyeTrace(this Entity entity)
    {
        var tr = Trace.Ray(entity.AimRay, 5000f)
            .Ignore(entity)
            .WithoutTags(BMTags.PhysicsTags.Trigger)
            .WorldAndEntities()
            .Run();

        return tr;
    }
}