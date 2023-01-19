
using Sandbox;

namespace BattleMages.Cameras;

public class SpectateRagdollCamera : BaseCamera
{
	Vector3 FocusPoint;

	protected override void OnActivate()
	{
		base.OnActivate();

		FocusPoint = Camera.Position - GetViewOffset();
		FieldOfView = Game.Preferences.FieldOfView;
	}

	protected override void Update()
	{
		var player = Game.LocalClient;
		if ( player == null ) return;

		// lerp the focus point
		FocusPoint = Vector3.Lerp( FocusPoint, GetSpectatePoint(), Time.Delta * 5.0f );

		Position = FocusPoint + GetViewOffset();
		Rotation = Input.AnalogLook.ToRotation();
		FieldOfView = FieldOfView.LerpTo( 50, Time.Delta * 3.0f );

		base.Update();
	}

	protected override void SetupCamera()
	{
		Camera.Position = Position;
		Camera.Rotation = Rotation;
		Camera.FieldOfView = FieldOfView;
		Camera.FirstPersonViewer = null;
	}

	public virtual Vector3 GetSpectatePoint()
	{
		if ( Game.LocalPawn is Player player && player.Corpse.IsValid() )
		{
			return player.Corpse.PhysicsGroup.MassCenter;
		}

		return Game.LocalPawn.Position;
	}

	public virtual Vector3 GetViewOffset()
	{
		var player = Game.LocalClient;
		if ( player == null ) return Vector3.Zero;

		return Input.AnalogLook.ToRotation().Forward * (-130 * 1) + Vector3.Up * (20 * 1);
	}
}

