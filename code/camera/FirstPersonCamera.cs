using Sandbox;

namespace BattleMages.Cameras;

public class FirstPersonCamera : BaseCamera
{
	private Vector3 lastPos;
	
	private bool doingPsyboltEffect;
	private Entity psyBoltTarget;
	private float psyBoltZoomInTime => 0.75f;
	private float psyBoltZoomOutTime => 0.3f;
	private float psyBoltHoverTime => 0.3f;
	private Vector3 velocity;
	private TimeSince timeSincePsyBolyStarted;
	private Vector3 absolutePosition;

	protected override void OnActivate()
	{
		absolutePosition = Entity.AimRay.Position;
		Position = Entity.AimRay.Position;
		Rotation = Entity.ViewAngles.ToRotation();

		lastPos = Position;
	}

	protected override void Update()
	{
		if (Entity is null)
			return;
		
		DefaultUpdate();
		
		base.Update();
	}
	

	private void DefaultUpdate()
	{
		var eyePos = Entity.AimRay.Position;
		if ( eyePos.Distance( lastPos ) < 300 ) // TODO: Tweak this, or add a way to invalidate lastpos when teleporting
		{
			absolutePosition = Vector3.Lerp( eyePos.WithZ( lastPos.z ), eyePos, 40.0f * Time.Delta );
			Position = Vector3.Lerp( eyePos.WithZ( lastPos.z ), eyePos, 40.0f * Time.Delta );
		}
		else
		{
			absolutePosition = eyePos;
			Position = eyePos;
		}

		Position = absolutePosition;
		Rotation = Entity.ViewAngles.ToRotation();

		lastPos = absolutePosition;
	}
	
	protected override void SetupCamera()
	{
		Camera.Position = Position;
		Camera.Rotation = Rotation;
		Camera.FirstPersonViewer = Entity;
		Camera.FieldOfView = Screen.CreateVerticalFieldOfView(Game.Preferences.FieldOfView);
		Camera.ZNear = 1f;
		Camera.ZFar = 200000f;
	}
}

