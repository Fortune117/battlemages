using Sandbox;

namespace BattleMages;

public partial class Powers : Carriable
{
    [ConVar.Replicated]
    public static bool bm_debug_powers { get; set; }
    
    [Net, Predicted]
    public bool IsUsingPower { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceStartedUsingPower { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceReleasedPower { get; set; }
    
    [Net, Predicted]
    private bool CancelledInputReleased { get; set; }
    
    private float MinimumPowerHoldTime => 0.1f;
    private float Cooldown => 0.5f;
    
    private Player Player => Owner as Player;

    public override string ViewModelPath => "models/arms/arms_simple.vmdl";

    public override void Simulate(IClient client)
    {
        if (IsBlinking)
        {
            BlinkSimulate();
            return;
        }

        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.MoveSpeed, Player.Velocity.Length);

        if (Input.Down(InputButton.Reload) && IsUsingPower)
        {
            CancelPower();
            return;
        }
        
        var powerInput = Input.Down(InputButton.SecondaryAttack);

        if (!powerInput && !CancelledInputReleased)
            CancelledInputReleased = true;
        
        if (!CancelledInputReleased)
            return;

        if (powerInput && !IsUsingPower && TimeSinceReleasedPower > Cooldown)
        {
            BeginUsingPower();   
        }
        else if (!powerInput && IsUsingPower && TimeSinceStartedUsingPower > MinimumPowerHoldTime )
        {
            ReleasePower();
        }
    }

    private void BeginUsingPower()
    {
        IsUsingPower = true;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsUsingPower, IsUsingPower);
        TimeSinceStartedUsingPower = 0;

        StartBlink();
    }

    private void CancelPower()
    {
        CancelledInputReleased = false;
        TimeSinceReleasedPower = 0;
        IsUsingPower = false;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsUsingPower, IsUsingPower);

        CancelBlink();
    }
    
    private void ReleasePower()
    {
        IsUsingPower = false;
        TimeSinceReleasedPower = 0;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsUsingPower, false);
        
        ReleaseBlink();
    }

    public override void FrameSimulate(IClient cl)
    {
        UpdateBlinkVFX();
    }
    
    public override void SimulateAnimator( PawnAnimator anim )
    {
        anim.SetAnimParameter( "holdtype", 3 );
        anim.SetAnimParameter( "b_blink", IsUsingPower );
        anim.SetAnimParameter( "aim_body_weight", 1.0f );
        anim.SetAnimParameter( "holdtype_handedness", 0 );
    }

}