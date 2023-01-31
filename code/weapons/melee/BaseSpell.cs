using Sandbox;

namespace BattleMages.Spells;

public partial class BaseSpell : BaseNetworkable
{
    [ConVar.Replicated]
    public static bool bm_debug_powers { get; set; }
    
    [Net]
    public MageSword Weapon { get; set; }

    [Net, Predicted]
    public bool ShouldSimulate { get; set; }

    protected Player Player => Weapon?.Player;

    public BaseSpell() { }

    public BaseSpell(MageSword weapon)
    {
        Weapon = weapon;
    }
    
    public virtual void Simulate(IClient client) { }

    public virtual void Cancel() {}

    public virtual void BeginCasting() {}
    
    public virtual void FinishCasting() {}

    public virtual void FrameSimulate() {}
}