namespace BattleMages.Melee;

public enum SwingType
{
    RightToLeft = 0,
    TopRightToLeft = 1,
    LeftToRight = 2,
    TopLeftToRight = 3,
    Stab = 4
}

public struct SwingData
{
    public SwingType SwingType;
    public Rotation StartRotation;
    public Rotation EndRotation;
    public float WindUpTime;
    public float ActiveTime;
}