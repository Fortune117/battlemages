using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using BattleMages.UI;
using Sandbox;

namespace BattleMages.Melee;

public partial class MageSword
{
    [Net, Predicted]
    private bool IsAttacking { get; set; }
    
    [Net, Predicted]
    private bool IsParrying { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceParryStarted { get; set; }
    
    [Net, Predicted]
    private bool AttackActive { get; set; }
    
    [Net, Predicted]
    private SwingData ActiveSwing { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceSwingStarted { get; set; }
    
    
    private float Damage => 60f;
    private float WeaponLength => 80f;
    private int TraceDensity => 9;
    
    private float ParryDuration => 0.375f; //seconds

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

    private string ImpactSound = "data/sounds/weapons/sword.hit_flesh.sound";

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
    
    private void SimulateMelee(IClient client)
    {
        if (IsParrying)
        {
            SimulateParry();
            return;
        }
        
        if (Input.Pressed(InputButton.SecondaryAttack) && !AttackActive)
        {
            Parry();
            return;
        }

        if (IsAttacking && !AttackActive && Input.Pressed(InputButton.Menu))
        {
            Feint();
            return;
        }
        
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

    private readonly HashSet<Entity> swingHitEntities = new();
    private readonly HashSet<Entity> swingParriedPlayers = new();
    private void StartSwing(SwingData swingData)
    {
        Crosshair.Instance?.LockCompass();
        
        IsAttacking = true;
        TimeSinceSwingStarted = 0;
        ActiveSwing = swingData;

        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.SwingType, (int)swingData.SwingType);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, true);
        
        Log.Info($"Chosen Type: {swingData}");
        Log.Info(Player.MeleeInputAngle);
        
        swingHitEntities.Clear();
        swingParriedPlayers.Clear();
        oldTraceOrigins = new Vector3[TraceDensity];
        shouldDoDamageTrace = false;
    }

    private Vector3[] oldTraceOrigins;
    private bool shouldDoDamageTrace = false;
    private void SimulateSwing(IClient client)
    {
        var oldAttackActive = AttackActive;
        
        AttackActive = TimeSinceSwingStarted > ActiveSwing.WindUpTime;

        if (AttackActive && !oldAttackActive)
        {
            if (!string.IsNullOrWhiteSpace(ActiveSwing.Sound))
                Sound.FromEntity(ActiveSwing.Sound, Player);
        }

        if (!AttackActive)
        {
            var dir = (Player.ViewAngles + ActiveSwing.StartAngles).Forward;
            var tempRay = new Ray(Player.AimRay.Position, dir);
            var tr = Trace.Ray(tempRay, WeaponLength)
                .Ignore(Player)
                .Ignore(ParryBox)
                .WithoutTags(BMTags.PhysicsTags.Trigger)
                .WorldAndEntities()
                .UseHitboxes()
                .Run();
            
            DebugOverlay.Line(tr.StartPosition, tr.EndPosition, Color.Red);

            return;
        }


        var activeFrac = TimeSinceSwingStarted - ActiveSwing.WindUpTime;
        activeFrac /= ActiveSwing.ActiveTime;

        var startRot = ActiveSwing.StartAngles.ToRotation();
        var endRot = ActiveSwing.EndAngles.ToRotation();
        
        var swingRotation = Rotation.Lerp(startRot, endRot, activeFrac);

        var swingStartPos = Player.AimRay.Position;
        var swingForward = (Player.ViewAngles + swingRotation.Angles()).Forward;
        
        var swingRay = new Ray(swingStartPos,swingForward);

        for (var i = 0; i < TraceDensity; i++)
        {
            var distance = (WeaponLength / TraceDensity) * i;
            var origin = swingStartPos + swingForward * distance;

            if (ActiveSwing.IsStab)
            {
                var tr = Trace.Ray(swingRay, WeaponLength)
                    .Ignore(Player)
                    .Ignore(ParryBox)
                    .WithAnyTags("parry", "player")
                    //.WithoutTags(BMTags.PhysicsTags.Trigger)
                    .WorldAndEntities()
                    .UseHitboxes()
                    .Run();
            
                DebugOverlay.TraceResult(tr, 3f);

                if (tr.Entity is not null)
                {
                    TryHitEntity(tr, tr.Entity);
                }
            }
            else if (shouldDoDamageTrace)
            {
                var direction = (origin - oldTraceOrigins[i]);
                var tr = Trace.Ray(origin, origin + direction)
                    .Ignore(Player)
                    .Ignore(ParryBox)
                    .WithAnyTags("parry", "player")
                    //.WithoutTags(BMTags.PhysicsTags.Trigger)
                    .WorldAndEntities()
                    .UseHitboxes()
                    .Run();
            
                DebugOverlay.TraceResult(tr, 3f);

                if (tr.Entity is not null)
                {
                    TryHitEntity(tr, tr.Entity);
                }
            }
            
            oldTraceOrigins[i] = origin;
        }

        shouldDoDamageTrace = true;

        if (TimeSinceSwingStarted > ActiveSwing.WindUpTime + ActiveSwing.ActiveTime)
            FinishSwing();
    }

    private void TryHitEntity(TraceResult swingTrace, Entity entity)
    {
        if (swingHitEntities.Contains(entity) || swingParriedPlayers.Contains(entity))
            return;

        if (entity.Tags.Has("parry"))
        {
            OnParried();
        }
        
        if (Game.IsServer)
        {
            if (entity is Player)
                Sound.FromWorld(ImpactSound, swingTrace.HitPosition);

            var damage = new DamageInfo()
                .UsingTraceResult(swingTrace)
                .WithTag(BMTags.Damage.Slash)
                .WithDamage(Damage);

            entity.TakeDamage(damage);
        }

        swingHitEntities.Add(entity);
    }

    private void FinishSwing()
    {
        Crosshair.Instance?.UnlockCompass();
        
        IsAttacking = false;
        AttackActive = false;
        ActiveSwing = null;
        
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, false);
    }

    private void OnParried()
    {
        IsAttacking = false;
        AttackActive = false;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, false);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.Parried, true);

        ParryBox?.PlaySound("sword.parry");
    }
    
    private void Parry()
    {
        IsParrying = true;
        IsAttacking = false;
        AttackActive = false;
        ActiveSwing = null;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, false);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.Parry, true);
        TimeSinceParryStarted = 0;
        
        ParryBox?.Tags.Add("parry");
    }

    private void Feint()
    {
        IsAttacking = false;
        AttackActive = false;
        ActiveSwing = null;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsAttacking, false);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.Feint, true);
    }

    private void SimulateParry()
    {
        
        if (TimeSinceParryStarted > ParryDuration)
            FinishParry();
    }

    private void FinishParry()
    {
        IsParrying = false;
        ParryBox?.Tags.Remove("parry");
    }

    public override void BuildInput()
    {
        if (IsAttacking)
            Input.AnalogLook *= 0.5f;
    }

    protected override void OnDestroy()
    {
        if (Game.IsServer)
            ParryBox?.Delete();;
    }

    public override void OnDeath()
    {
        if (Game.IsServer)
            ParryBox?.Delete();
    }
}