using Sandbox;
using BattleMages.UI;

namespace BattleMages;

public partial class Player
{
    [Net, Local, Predicted]
    public float Stamina { get; set; }

    [Net, Local] 
    public float MaxStaminaMultiplier { get; set; } = 1;

    [Net, Local, Predicted]
    public TimeSince TimeSinceStartedSprinting { get; set; }
    
    [Net, Local, Predicted]
    public TimeSince TimeSinceStoppedSprinting { get; set; }
    
    [Net, Local, Predicted]
    private TimeSince TimeSinceStaminaDecreased { get; set; }
    
    [Net, Predicted] 
    public bool IsRunning { get; private set; }

    public float StaminaFraction => Stamina.LerpInverse(0, MaxStamina);
    public float MaxStamina => Stats.Stamina.Max * MaxStaminaMultiplier;
    
    public void ResetStamina()
    {
        MaxStaminaMultiplier = 1;
        Stamina = Stats.Stamina.Max;
        TimeSinceStaminaDecreased = 0;
    }
    
    public void StaminaSimulate(IClient client)
    {
        UpdateRunning();
        UpdateStamina();
        Stamina = Stamina.Clamp(0, MaxStamina);
        StaminaBar.Instance?.SetFraction(StaminaFraction);
        StaminaBar.Instance?.SetBrokenFraction(1 - MaxStaminaMultiplier);
    }

    public void AddStaminaMultiplier(float n)
    {
        MaxStaminaMultiplier += n;
    }

    private float secondWindForgivenessWindow => 0.5f;
    private float oldTimeSinceStartedSprintingTime;
    private bool oldIsRunning;
    private void UpdateRunning()
    {
        oldIsRunning = IsRunning;
        IsRunning = Input.Down(InputButton.Run) && CanRun() && Velocity.Length > 200f;

        if (IsRunning && oldIsRunning != IsRunning)
        {
            if (TimeSinceStoppedSprinting < secondWindForgivenessWindow)
                TimeSinceStartedSprinting = oldTimeSinceStartedSprintingTime;
            else
                TimeSinceStartedSprinting = 0;
        }
        else if (!IsRunning && oldIsRunning != IsRunning)
        {
            TimeSinceStoppedSprinting = 0;
            oldTimeSinceStartedSprintingTime = TimeSinceStartedSprinting.Relative;
        }

    }

    private void UpdateStamina()
    {
        if (IsRunning)
        {
            //stop deecreasing stamina if we hit our second wind
            if (TimeSinceStartedSprinting < Stats.Stamina.SecondWindDelay)
                Stamina -= Stats.Stamina.SprintCost * Time.Delta;
            
            TimeSinceStaminaDecreased = 0;
        }
        else if (TimeSinceStaminaDecreased > Stats.Stamina.RechargeDelay)
        {
            Stamina += Stats.Stamina.RechargeRate * Time.Delta;
        }
    }
    
    public bool CanRun()
    {
        //prevent trying to run if were aren't running and our stamina is less than 10%
        if (!IsRunning && StaminaFraction < 0.1)
            return false;
        
        return Stamina > 0 && GroundEntity != null;
    }

    public bool CanJump()
    {
        return Stamina >= Stats.Stamina.JumpCost;
    }

    public void OnJump()
    {
        TryFootstepSound(0, 50f);
        TryFootstepSound(1, 50f);
        PlayMovementNoise(2f);
        
        ActiveCarry?.OnJump();
        
        if (Stats.Movement.AutoJump)
            return;
        
        Stamina -= Stats.Stamina.JumpCost;
        TimeSinceStaminaDecreased = 0;
    }

    public void OnJumpQueued()
    {
        PlayMovementNoise(0.5f);
    }
    
    public void StaminaDamage(DamageInfo info)
    {
        if (info.HasTag(BMTags.Damage.NoStamina))
            return;
        
        Stamina -= info.Damage * Stats.Stamina.DamageToStaminaLossRatio;
        TimeSinceStaminaDecreased = 0;
    }
}