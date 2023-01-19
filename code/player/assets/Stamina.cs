namespace BattleMages.Stats;

public struct Stamina
{
    public float Max { get; set; }
    public float RechargeDelay { get; set; }
    public float RechargeRate { get; set; }
    public float SecondWindDelay { get; set; }
    
    public float JumpCost { get; set; }
    public float SprintCost { get; set; }
    public float DamageToStaminaLossRatio { get; set; }
}