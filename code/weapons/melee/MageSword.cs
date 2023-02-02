using BattleMages.Spells;
using Sandbox;

namespace BattleMages.Melee;

public partial class MageSword : Carriable
{
    [Net, Predicted]
    public bool IsCasting { get; set; }

    [Net, Predicted]
    private TimeSince TimeSinceStartedUsingPower { get; set; }
    
    [Net, Predicted]
    private TimeSince TimeSinceReleasedPower { get; set; }
    
    [Net, Predicted]
    private bool CancelledSpellInputReleased { get; set; }

    [Net, Predicted]
    private BaseSpell ActiveSpell { get; set; }

    [Net] 
    private Blink BlinkSpell { get; set; }
    
    [Net, Predicted]
    private float Cooldown { get; set; } = 0.5f;
    
    private float MinimumPowerHoldTime => 0.1f;


    public Player Player => Owner as Player;
    public override string ViewModelPath => "models/longsword/longsword_vm.vmdl";

    public override void Spawn()
    {
        base.Spawn();

        SetModel("models/longsword/longsword_wm.vmdl");
        
        BlinkSpell = new Blink(this);
        ActiveSpell = BlinkSpell;
    }

    public override void Simulate(IClient client)
    {
        SimulateAttacking(client);
        
        if (!IsAttacking)
            SimulateCasting(client);
    }
    
    private void SimulateCasting(IClient client)
    {
        if (ActiveSpell is null)
            return;
        
        if (ActiveSpell.ShouldSimulate)
        {
            ActiveSpell.Simulate(client);
            return;
        }

        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.MoveSpeed, Player.Velocity.Length);
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsRunning, Player.IsRunning);

        if (Input.Down(InputButton.Reload) && IsCasting)
        {
            CancelCast();
            return;
        }
        
        var powerInput = Input.Down(InputButton.SecondaryAttack);

        if (!powerInput && !CancelledSpellInputReleased)
            CancelledSpellInputReleased = true;
        
        if (!CancelledSpellInputReleased)
            return;

        if (powerInput && !IsCasting && TimeSinceReleasedPower > Cooldown)
        {
            BeginCasting();
        }
        else if (!powerInput && IsCasting && TimeSinceStartedUsingPower > MinimumPowerHoldTime )
        {
            FinishCast();
        }
    }
    
    private void BeginCasting()
    {
        IsCasting = true;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsCasting, IsCasting);
        TimeSinceStartedUsingPower = 0;

        ActiveSpell.BeginCasting();
    }

    private void CancelCast()
    {
        CancelledSpellInputReleased = false;
        TimeSinceReleasedPower = 0;
        IsCasting = false;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsCasting, false);

        ActiveSpell.Cancel();
    }
    
    private void FinishCast()
    {
        IsCasting = false;
        TimeSinceReleasedPower = 0;
        ViewModelEntity?.SetAnimParameter(BMTags.ViewModelAnims.IsCasting, false);
        
        ActiveSpell.FinishCasting();
    }
    
    public override void FrameSimulate(IClient cl)
    {
        ActiveSpell?.FrameSimulate();
    }
    
    public override void SimulateAnimator( PawnAnimator anim )
    {
        anim.SetAnimParameter( "holdtype", 2 );
        anim.SetAnimParameter( "b_blink", IsCasting );
        anim.SetAnimParameter( "aim_body_weight", 1.0f );
        anim.SetAnimParameter( "holdtype_handedness", 0 );
    }
}