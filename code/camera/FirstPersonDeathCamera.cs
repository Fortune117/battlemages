using Sandbox;

namespace BattleMages.Cameras;

public class FirstPersonDeathCamera : BaseCamera
{
    protected override void OnActivate()
    {
        base.OnActivate();
        ShrinkHead();
    }

    protected override void OnDeactivate()
    {
        base.OnDeactivate();
        ResetHead();
    }

    private void ShrinkHead()
    {
        if ( Game.LocalPawn is not Player player || !player.Corpse.IsValid() )
            return;

        player.Corpse.ShrinkHead();
    }

    private void ResetHead()
    {
        if ( Game.LocalPawn is not Player player || !player.Corpse.IsValid() )
            return;

        player.Corpse.ResetHead();
    }
    
    protected override void Update()
    {
        var transform = GetCamTransform();

        Position = transform.Item1 + transform.Item2.Up*4f;
        Rotation = transform.Item2;

        // base.FrameUpdate();
    }

    protected override void SetupCamera()
    {
        Camera.Position = Position;
        Sandbox.Camera.Rotation = Rotation;
        Sandbox.Camera.ZNear = 1f;
        Sandbox.Camera.FirstPersonViewer = null;   
    }

    public virtual (Vector3, Rotation) GetCamTransform()
    {
        if ( Game.LocalPawn is Player player && player.Corpse.IsValid() )
        {
            var attachment = player.Corpse.GetAttachment("hat");
            if (attachment != null)
            {
                return (attachment.Value.Position, attachment.Value.Rotation);
            }
        }

        return (Game.LocalPawn.Position, Input.AnalogLook.ToRotation());
    }
}