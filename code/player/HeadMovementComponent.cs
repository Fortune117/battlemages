using System;
using Sandbox;

namespace BattleMages;

public class HeadMovementComponent : EntityComponent<Player>
{
    public static HeadMovementComponent Instance;
    public static AnimatedEntity CameraAnimationEntity { get; set; }
    
    [ConVar.Client]
    public bool stalker_viewbob_enabled { get; set; } = true;

    public HeadMovementComponent()
    {
        Instance = this;
    }
    
    protected override void OnActivate()
    {
        if (Game.IsClient)
            CameraAnimationEntity = new AnimatedEntity("models/stalker/camera_animations/camera_headshot.vmdl");
    }
    
    public Rotation GetCameraRotation()
    {
        if (CameraAnimationEntity is null)
            return Rotation.Identity;

        var transform = CameraAnimationEntity.GetAttachment("camera");
        if ( transform != null )
        {
            return transform.Value.Rotation;
        }
        
        return Rotation.Identity;;
    }

    private float GetHeadBobFraction()
    {
        return (Entity.Velocity.Length / Entity.Stats.CameraMotion.ViewBobSpeedThreshold).Clamp(0, 1);
    }

    //This is some nasty ass code innit
    private float limpCycle = 1f;
    private float limpDuration = 0.5f;
    private Vector3 limpOffset;
    public Vector3 GetLimpOffset()
    {
        return Vector3.Zero;
    }
    
    private Vector3 offset;

    /// <summary>
    /// Called every camere build for stalker base cameras.
    /// </summary>
    /// <returns></returns>
    public Vector3 GetOffset()
    {
        if (!stalker_viewbob_enabled || Entity.GroundEntity == null)
            return Vector3.Zero;

        var frac = GetHeadBobFraction();
        var camMotion = Entity.Stats.CameraMotion;
        var runningMult = (Entity.IsRunning ? camMotion.ViewBobRunningMultiplier : 1);

        var sinOffset = MathF.Sin(Time.Now * camMotion.ViewBobFrequency * 2f * runningMult);
        var sinOffset2 = MathF.Sin(Time.Now * camMotion.ViewBobFrequency * runningMult) / 2f;

        var z = Vector3.Up * sinOffset * camMotion.ViewBobMagnitude * frac;
        var y = Entity.ViewAngles.ToRotation().Left.WithZ(0).Normal;
        y *= sinOffset2 * camMotion.ViewBobMagnitude * frac;

        var jumpingOffset = Vector3.Zero;

        if (timeUntilJump >= 0 && totalJumpTime > 0.2f)
        {
            jumpingOffset += Vector3.Up * Entity.Stats.Movement.JumpOffsetCurve.Evaluate((totalJumpTime - timeUntilJump) / totalJumpTime) * 12f;
        }

        if (timeSinceLanded < jumpCooldown)
        {
            jumpingOffset += Vector3.Up * Entity.Stats.Movement.JumpLandingOffsetCurve.Evaluate(timeSinceLanded/jumpCooldown) * 12f;
        }

        return (z + y) * runningMult + jumpingOffset;
    }

    [Event.Client.Frame]
    private void OnFrame()
    {
        timeUntilJump -= Time.Delta;
        timeSinceLanded += Time.Delta;
    }

    private float totalJumpTime;
    private float timeUntilJump;
    public void JumpQueued(float delay)
    {
        totalJumpTime = delay;
        timeUntilJump = delay;
    }

    private float jumpCooldown;
    private float timeSinceLanded;
    public void JumpLanded(float cooldown)
    {
        if (timeSinceLanded < jumpCooldown)
            return;
        
        jumpCooldown = cooldown;
        timeSinceLanded = 0;
    }
}