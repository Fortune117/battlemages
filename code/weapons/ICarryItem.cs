namespace BattleMages;

/// <summary>
/// Used to indicate that a base cariable has a swap time when switching to another weapon.
/// </summary>
public interface ICarryItem
{
    public bool IsHolstering { get; set; }
    public float HolsterDelay { get; }

    public bool CanHolster();
    public abstract void Deploy();
    public abstract void Holster();
}