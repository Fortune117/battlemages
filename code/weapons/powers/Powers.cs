using Sandbox;

namespace BattleMages;

public partial class Powers : Carriable
{
    [Net, Predicted]
    public bool IsUsingPower { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceStartedUsingPower { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceReleasedPower { get; set; }
    
    private float MinimumPowerHoldTime => 0.1f;
    private float Cooldown => 0.25f;
    
    private Player Player => Owner as Player;

    public override string ViewModelPath => "models/arms/arms_simple.vmdl";

    public override void Simulate(IClient client)
    {
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.MoveSpeed, Player.Velocity.Length);

        var powerInput = Input.Down(InputButton.SecondaryAttack);
        
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
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsUsingPower, true);
        TimeSinceStartedUsingPower = 0;
    }

    private void ReleasePower()
    {
        IsUsingPower = false;
        TimeSinceReleasedPower = 0;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsUsingPower, false);
    }
}