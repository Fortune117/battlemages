using Sandbox;

namespace BattleMages.Stats;

public struct Movement
{
    public float SprintSpeed { get; set; }
    public float SprintForwardProportionality { get; set; }
    public float DefaultSpeed { get; set; }
    public float WalkSpeed { get; set; }
    public float CrouchSpeed { get; set; }
    public float CrouchChangeSpeed { get; set; }
    public float JumpPower { get; set; }
    public float JumpDelayIdle { get; set; }
    public float JumpDelayMoving { get; set; }
    public Curve JumpOffsetCurve { get; set; }
    public float JumpCooldown { get; set; }
    public Curve JumpLandingOffsetCurve { get; set; }
    public float Acceleration { get; set; }
    public float AccelerationForwardProportionality { get; set; }
    public float AirAcceleration { get; set; }
    public float FallDamageThreshold { get; set; }
    public float FallDamageKillThreshold { get; set; }
    public Curve FallDamageCurve { get; set; }
    public float GroundFriction { get; set; } 
    public float StopSpeed { get; set; }
    public float GroundAngle { get; set; }
    public float StepSize { get; set; }
    public float MaxNonJumpVelocity { get; set; }
    public float BodyGirth { get; set; }
    public float BodyHeight { get; set; }
    public float EyeHeight { get; set; }
    public float Gravity { get; set; }
    public float AirControl { get; set; }
    public bool AutoJump { get; set; }
}