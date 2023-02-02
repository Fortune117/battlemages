using Sandbox;

namespace BattleMages.Melee;

public enum SwingType
{
    RightToLeft = 0,
    TopRightToLeft = 1,
    LeftToRight = 2,
    TopLeftToRight = 3,
    Stab = 4
}

[GameResource("Swing Data", "swing", "Contains stats for a melee swing.")]
public class SwingData : GameResource
{
    public bool IsStab { get; set; }
    public SwingType SwingType { get; set; }
    public Rotation StartRotation { get; set; }
    
    [HideIf(nameof(IsStab), true)]
    public Rotation EndRotation { get; set; }
    
    public float WindUpTime { get; set; }
    public float ActiveTime { get; set; }
}