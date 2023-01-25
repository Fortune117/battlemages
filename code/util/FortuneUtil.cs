using System.Collections.Generic;
using Sandbox;
using Sandbox.UI;

namespace BattleMages;

public static class FortuneUtil
{
    public static bool IsMouseInside(this Panel panel)
    {
        var deltaPos = panel.ScreenPositionToPanelPosition(Mouse.Position);
        var width = panel.Box.Rect.Width;
        var height = panel.Box.Rect.Height;
            
        return deltaPos.x >= 0 && deltaPos.y >= 0 && deltaPos.x <= width && deltaPos.y <= height;
    }

    public static T GetRandom<T>(this List<T> list)
    {
        return list[Game.Random.Int(list.Count - 1)];
    }
    
    public static T GetRandom<T>(this IList<T> list)
    {
        return list[Game.Random.Int(list.Count - 1)];
    }

    public static bool WasHeadshot(this ModelEntity entity, DamageInfo info)
    {
        return info.Hitbox.HasTag("head") && info.HasTag(BMTags.Damage.Bullet);
    }
    
    public static void ShrinkHead(this ModelEntity entity)
    {
        var bone = entity.GetBoneTransform("head");
        entity.SetBone("head", new Transform(bone.Position, bone.Rotation, 0f));
    }

    public static void ResetHead(this ModelEntity entity)
    {
        var bone = entity.GetBoneTransform("head");
        entity.SetBone("head", new Transform(bone.Position, bone.Rotation, 1f));
    }

    public static void SetPosition(this Panel panel, Vector2 position)
    {
        panel.Style.Left = position.x;
        panel.Style.Top = position.y;
    }

    public static Ray GetCameraRay()
    {
        Game.AssertClient();

        return new Ray(Camera.Position, Camera.Rotation.Forward);
    }
}