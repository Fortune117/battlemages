using BattleMages.Cameras;
using Sandbox;

namespace StalkerRP.Cameras;

public class FloatingCamera : BaseCamera
{
	protected override void OnActivate()
	{
		base.OnActivate();
		
		var pawn = Game.LocalPawn;
		if ( pawn == null ) return;

		Position = pawn.AimRay.Position;
		Rotation = Input.AnalogLook.ToRotation();
		
		ZNear = 5f;
	}

	protected override void Update()
	{
		var pawn = Game.LocalPawn;
		if ( pawn == null ) return;

		Rotation = Input.AnalogLook.ToRotation();

		base.Update();
	}

	protected override void SetupCamera()
	{
		Camera.Rotation = Rotation;
		Camera.FirstPersonViewer = null;
	}
}

