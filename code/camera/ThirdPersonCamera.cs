using Sandbox;

namespace BattleMages.Cameras;

public class ThirdPersonCamera : BaseCamera
{
	[ConVar.Replicated]
	public static bool thirdperson_orbit { get; set; } = false;

	[ConVar.Replicated]
	public static bool thirdperson_collision { get; set; } = true;

	private Angles orbitAngles;
	private float orbitDistance = 150;
	private float orbitHeight = 0;

	protected override void Update()
	{
		if ( Game.LocalPawn is not AnimatedEntity pawn )
			return;

		Position = pawn.Position;
		Vector3 targetPos;

		var center = pawn.Position + Vector3.Up * 64;

		if ( thirdperson_orbit )
		{
			Position += Vector3.Up * ((pawn.CollisionBounds.Center.z * pawn.Scale) + orbitHeight);
			Rotation = Rotation.From( orbitAngles );

			targetPos = Position + Rotation.Backward * orbitDistance;
		}
		else
		{
			Position = center;
			Rotation = Rotation.FromAxis( Vector3.Up, 4 ) * Entity.ViewAngles.ToRotation();

			float distance = 130.0f * pawn.Scale;
			targetPos = Position + Input.AnalogLook.ToRotation().Right * ((pawn.CollisionBounds.Maxs.x + 15) * pawn.Scale);
			targetPos += Input.AnalogLook.ToRotation().Forward * -distance;
		}

		if ( thirdperson_collision )
		{
			var tr = Trace.Ray( Position, targetPos )
				.WithAnyTags( "solid" )
				.Ignore( pawn )
				.Radius( 8 )
				.Run();

			Position = tr.EndPosition;
		}
		else
		{
			Position = targetPos;
		}

		FieldOfView = 70;

		base.Update();
	}

	protected override void SetupCamera()
	{
		Sandbox.Camera.Position = Position;
		Sandbox.Camera.Rotation = Rotation;
		Sandbox.Camera.FirstPersonViewer = null;
	}


	[Event.Client.BuildInput]
	private void BuildInput()
	{
		if ( thirdperson_orbit && Input.Down( InputButton.Walk ) )
		{
			if ( Input.Down( InputButton.PrimaryAttack ) )
			{
				orbitDistance += Input.AnalogLook.pitch;
				orbitDistance = orbitDistance.Clamp( 0, 1000 );
			}
			else if ( Input.Down( InputButton.SecondaryAttack ) )
			{
				orbitHeight += Input.AnalogLook.pitch;
				orbitHeight = orbitHeight.Clamp( -1000, 1000 );
			}
			else
			{
				orbitAngles.yaw += Input.AnalogLook.yaw;
				orbitAngles.pitch += Input.AnalogLook.pitch;
				orbitAngles = orbitAngles.Normal;
				orbitAngles.pitch = orbitAngles.pitch.Clamp( -89, 89 );
			}

			Input.AnalogLook = Angles.Zero;

			Input.ClearButtons();
			Input.StopProcessing = true;
		}
	}
}

