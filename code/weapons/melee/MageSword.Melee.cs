using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;

namespace BattleMages.Melee;

public partial class MageSword
{
    [Net, Predicted]
    private bool IsAttacking { get; set; }
    
    [Net, Predicted]
    private bool AttackActive { get; set; }
    
    [Net, Predicted]
    private SwingData ActiveSwing { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceSwingStarted { get; set; }
    
    
    private float Damage => 60f;
    private float WeaponLength => 70f;
    private int TraceDensity => 8;

    private SwingData LeftToRight =
        ResourceLibrary.Get<SwingData>("data/swingdata/longsword/longsword_left_to_right.swing");
    
    private SwingData RightToLeft =
        ResourceLibrary.Get<SwingData>("data/swingdata/longsword/longsword_right_to_left.swing");
    
    private SwingData TopLeftToRight =
        ResourceLibrary.Get<SwingData>("data/swingdata/longsword/longsword_top_left_to_right.swing");
    
    private SwingData TopRightToLeft =
        ResourceLibrary.Get<SwingData>("data/swingdata/longsword/longsword_top_right_to_left.swing");
    
    private SwingData Stab =
        ResourceLibrary.Get<SwingData>("data/swingdata/longsword/longsword_stab.swing");

    /// <summary>
    /// This uses the angle determined by the players melee input angle and then snaps the swing to
    /// the closest value in the dictionary.
    /// </summary>
    private Dictionary<float, SwingData> SwingMap;
    
    public MageSword()
    {
        SwingMap= new()
        {
            {180f, RightToLeft},
            {145f, TopRightToLeft},
            {0f, LeftToRight},
            {45f, TopLeftToRight}
        };
    }
    
    private SwingData GetSwingData(float meleeAngle)
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
    
    private void SimulateAttacking(IClient client)
    {
        if (IsAttacking)
        {
            SimulateSwing(client);
            return;
        }
        
        if (Input.MouseWheel > 0)
        {
            StartSwing(Stab);
            return;
        }
        
        if (Input.Pressed(InputButton.PrimaryAttack))
        {
            var swingData = GetSwingData(Player.MeleeInputAngle);
            StartSwing(swingData);
        }
    }

    private void StartSwing(SwingData swingData)
    {
        IsAttacking = true;
        TimeSinceSwingStarted = 0;
        ActiveSwing = swingData;

        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.SwingType, (int)swingData.SwingType);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, true);
        
        Log.Info($"Chosen Type: {swingData}");
        Log.Info(Player.MeleeInputAngle);
    }

    private void SimulateSwing(IClient client)
    {
        AttackActive = TimeSinceSwingStarted > ActiveSwing.WindUpTime;

        if (!AttackActive)
            return;

        var activeFrac = TimeSinceSwingStarted - ActiveSwing.WindUpTime;
        activeFrac /= ActiveSwing.ActiveTime;

        var startRot = ActiveSwing.StartAngles.ToRotation();
        var endRot = ActiveSwing.EndAngles.ToRotation();
        
        var swingRotation = Rotation.Lerp(startRot, endRot, activeFrac);

        var swingStartPos = Player.AimRay.Position;
        var swingForward = (Player.ViewAngles + swingRotation.Angles()).Forward;
        
        var swingRay = new Ray(swingStartPos,swingForward);
        
        var tr = Trace.Ray(swingRay, WeaponLength)
            .Ignore(Player)
            .Ignore(this)
            .WithoutTags(BMTags.PhysicsTags.Trigger)
            .WorldAndEntities()
            .Run();
        
        DebugOverlay.TraceResult(tr, 3f);
        
        if (TimeSinceSwingStarted > ActiveSwing.WindUpTime + ActiveSwing.ActiveTime)
            FinishSwing();
    }

    private void FinishSwing()
    {
        IsAttacking = false;
        ActiveSwing = null;
        
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, false);
    }
}