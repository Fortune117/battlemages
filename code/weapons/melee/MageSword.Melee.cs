using System;
using System.Collections.Generic;
using System.Linq;

namespace BattleMages;

public partial class MageSword
{
    private enum SwingType
    {
        RightToLeft = 0,
        TopRightToLeft = 1,
        LeftToRight = 2,
        TopLeftToRight = 3,
        Stab = 4
    }

    /// <summary>
    /// This uses the angle determined by the players melee input angle and then snaps the swing to
    /// the closest value in the dictionary.
    /// </summary>
    private Dictionary<float, SwingType> SwingMap = new()
    {
        {180f, SwingType.RightToLeft},
        {145f, SwingType.TopRightToLeft},
        {0f, SwingType.LeftToRight},
        {45f, SwingType.TopLeftToRight}
    };

    private SwingType GetSwingType(float meleeAngle)
    {
        foreach (var keyValuePair in SwingMap)
        {
            Log.Info($"{keyValuePair.Value} distance from {meleeAngle}: {short_angle_dist(meleeAngle, keyValuePair.Key)}");
        }

        return SwingMap.MinBy(x => MathF.Abs(short_angle_dist(meleeAngle, x.Key))).Value;
    }
    
    private float short_angle_dist(float from, float to)
    {
        var max_angle = 360f;
        var difference = (to - from) % max_angle;
        return ((2 * difference) % max_angle) - difference;
    }
}