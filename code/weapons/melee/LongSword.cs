using Sandbox;

namespace BattleMages;

public class LongSword: Carriable
{
    private Player Player => Owner as Player;
    public override string ViewModelPath => "models/longsword/longsword_vm.vmdl";

    public override void Simulate(IClient cl)
    {
        ViewModelEntity?.SetAnimParameter("bSprinting", Player.IsRunning);
        ViewModelEntity?.SetAnimParameter("fMoveSpeed", Player.Velocity.Length);
    }
}