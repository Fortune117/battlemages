using System;
using Sandbox;
using StalkerRP.Cameras;

namespace BattleMages;

public partial class WalkController
{
    private bool CanJump()
    {
        if (GroundEntity == null)
            return false;
        
        if (TimeSinceLanded < Player.Stats.Movement.JumpCooldown)
            return false;

        if (!Player.CanJump())
            return false;

        return true;
    }
    
    public virtual void CheckJumpButton()
    {
        // If we are in the water most of the way...
        if (Swimming)
        {
            // swimming, not jumping
            ClearGroundEntity();

            Velocity = Velocity.WithZ(100);
            return;
        }

        if (jumpQueued)
            return;
        
        //Can't attempt a new jump while crouching
        if (IsDucking)
            return;

        if (!CanJump())
            return;
        
        QueueJump();
    }

    private void QueueJump()
    {
        jumpQueued = true;
        TimeUntilJump = Velocity.Length < 60f ? JumpDelayIdle : JumpDelayMoving;
        Player.HeadMovementComponent.JumpQueued(TimeUntilJump);
        Player.OnJumpQueued();
    }

    private void PerformJump()
    {
        Player.OnJump();

        ClearGroundEntity();
        
        var flGroundFactor = 1.0f;
        
        var startz = Velocity.z;
        
        Velocity = Velocity.WithZ(startz + JumpPower * flGroundFactor);

        Velocity -= new Vector3(0, 0, Gravity * 0.5f) * Time.Delta;
        
        AddEvent("jump");
    }
    
    private TimeSince TimeSinceLanded { get; set; }
    private TimeUntil TimeUntilJump { get; set; }
    private bool jumpQueued { get; set; }
    
    private void JumpSimulate()
    {
        if (!jumpQueued)
            return;

        if (TimeUntilJump > 0)
            return;
        
        if (CanJump())
            PerformJump();
        
        jumpQueued = false;
    }
    
    private Vector3 oldVelocity;
    private Entity oldGroundEntity;
    protected virtual void CheckFalling()
    {
        if (oldGroundEntity != GroundEntity)
        {
            if (GroundEntity != null)
                OnHitGround(oldVelocity);
        }

        oldVelocity = Velocity;
        oldGroundEntity = GroundEntity;
    }

    protected void OnHitGround(Vector3 fallVelocity)
    {
        TimeSinceLanded = 0;
        Player.Camera.SnapToEyePosition();

        var speed = MathF.Abs(fallVelocity.z);
        var frac = speed.LerpInverse(0f, 500f);
        
        Player.PlayMovementNoise(frac*3f);
        Player.TryFootstepSound(0, frac*50f);
        Player.TryFootstepSound(1, frac*50f);
        
        if (speed > 100f)
            Player.HeadMovementComponent.JumpLanded(Player.Stats.Movement.JumpCooldown);
        
        Player.DoFallDamage(speed);
    } 
}