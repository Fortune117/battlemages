using System;
using BattleMages.UI;
using Sandbox;

namespace BattleMages;

public partial class Player
{
    [ClientInput]
    public float MeleeInputAngle { get; set; }

    private void MeleeInput()
    {
        if (Input.AnalogLook.IsNearlyZero(0.05f))
            return;
        
        var deltaAngle = (ViewAngles - OriginalViewAngles).Normal;
        var angle = MathF.Atan2(-Input.AnalogLook.pitch, Input.AnalogLook.yaw).RadianToDegree();

        //Log.Info(angle);
        
        Crosshair.SetCrosshairCompassRotation(angle);
    }
}