#nullable enable
using System.Threading.Tasks;
using Sandbox;
using BattleMages.Cameras;
using StalkerRP;

// ReSharper disable UnassignedGetOnlyAutoProperty
#pragma warning disable CS8618

namespace BattleMages;

public partial class Player : BasePlayer
{
	private DamageInfo lastDamage;
	
	[BindComponent]
	public HeadMovementComponent HeadMovementComponent { get; }
	
	public PlayerStatsResource Stats { get; set; } = BMResource.Get<PlayerStatsResource>("default");

	public TimeSince TimeSinceStartedRunning { get; set; }
	public TimeSince TimeSinceGroundEntityWasNull { get; set; }
	
	[Net, Predicted]
	public bool InSights { get; set; }

	private Vector3 EyeOffset => Controller?.EyeLocalPosition ?? 0;
	
	[Net, Predicted]
	private Rotation AimRotation { get; set; }

	public override Ray AimRay => new(Position + EyeOffset, AimRotation.Forward);

	public Player()
	{
	}
	
	[Net]
	public string MovementAdditionalNoise { get; set; }
    

	public void PlayMovementNoise(float volume = 1f)
	{
		if (string.IsNullOrWhiteSpace(MovementAdditionalNoise))
			return;
        
		var sound = PlaySound( MovementAdditionalNoise );
		sound.SetVolume( volume );
	}
	
	public void DoFallDamage(float speed)
	{
		if (speed < Stats.Movement.FallDamageThreshold)
		{
			if (speed > 30f)
			{
				Sound.FromWorld("human.fall", Position);
			}

			return;
		}
        
		var speedDiff = (speed - Stats.Movement.FallDamageThreshold);
		var frac = Stats.Movement.FallDamageCurve.Evaluate(speedDiff / Stats.Movement.FallDamageKillThreshold);

		var damage = Stats.Health.Max * frac;

		Sound.FromWorld("human.fall_damage", Position);
		Sound.FromWorld("cloth.fall", Position);
        
		if (!Game.IsServer)
			return;

		using (Prediction.Off())
		{
			TakeDamage(DamageInfo.Generic(damage));
		}
	}
	
	public override void Spawn()
	{
		Tags.Add(BMTags.PhysicsTags.Player);
		
		Components.Create<HeadMovementComponent>();
		
		Health = Stats.Health.Max;
		
		SurroundingBoundsMode = SurroundingBoundsType.Hitboxes;

		base.Spawn();
	}

	private bool hasGibbed = false;
	public override void Respawn()
	{
		base.Respawn();
		
		InSights = false;
		hasGibbed = false;
		
		ResetStamina();

		SetCloudModel();

		AddStartingItems();

		Controller = new WalkController();
		Animator = new StandardPlayerAnimator();

		if ( DevController is NoclipController )
		{
			DevController = null;
		}

		EnableAllCollisions = true;
		EnableDrawing = true;
		EnableHideInFirstPerson = true;
		EnableShadowInFirstPerson = true;
		
		Camera = new FirstPersonCamera();

		OnRespawnClient(To.Single(Client));
	}

	[ClientRpc]
	private void OnRespawnClient()
	{
		
	}
	
	private async Task SetCloudModel()
	{
		Log.Info("-----------------------FETCHING MODEL-----------------------");
		var package = await Package.Fetch("https://asset.party/sboxmp/adam_mp", false);

		var model = package.GetMeta( "PrimaryAsset", "models/dev/error.vmdl" );

		await package.MountAsync();
		
		Log.Info(model);
		SetModel(model);
	}

	public override PawnController GetActiveController()
	{
		if ( DevController != null ) return DevController;

		return base.GetActiveController();
	}

	public override void Simulate( IClient client )
	{
		if ( LifeState == LifeState.Dead && Game.IsServer)
		{
			if ( TimeSinceDied > 3  )
			{
				Respawn();
			}
			return;
		}

		//UpdatePhysicsHull();

		var groundEntityWasValid = GroundEntity != null;
		
		var controller = GetActiveController();
		controller?.Simulate( client, this, GetActiveAnimator() );
		
		AimRotation = ViewAngles.ToRotation();

		if (groundEntityWasValid && !GroundEntity.IsValid())
			TimeSinceGroundEntityWasNull = 0;

		if ( LifeState != LifeState.Alive )
			return;
		
		if ( controller != null )
			EnableSolidCollisions = !controller.HasTag( "noclip" );
		
		Animator.SetAnimParameter("b_sprint", IsRunning);
		
		//EquipmentComponent.Simulate(cl);

		SimulateCarryInventory(client);
		TickPlayerUse();
		SimulateActiveChild(client, ActiveChild);
		StaminaSimulate(client);
		SimulateVoice(client);
	}

	public override float FootstepVolume()
	{
		var speed = Velocity.WithZ(0).Length;

		var value = speed.LerpInverse( 0.0f, 150.0f, false ) * 15f;

		if (speed <= 120)
			value /= 2f;

		return value;
	}
	
	TimeSince timeSinceLastFootstep = 0;

	/// <summary>
	/// A foostep has arrived!
	/// </summary>
	public override void OnAnimEventFootstep( Vector3 pos, int foot, float volume )
	{
		if ( LifeState != LifeState.Alive )
			return;

		if ( !Game.IsClient )
			return;

		if ( timeSinceLastFootstep < 0.2f )
			return;

		volume *= FootstepVolume();

		timeSinceLastFootstep = 0;

		if ( !TryFootstepSound(foot, volume) ) 
			return;

		PlayMovementNoise(volume * 0.025f);
		
		ActiveCarry?.OnFootStep();
	}

	public bool TryFootstepSound(int foot = 0, float volume = 1)
	{
		var tr = Trace.Ray( Position, Position + Vector3.Down * 20 )
			.Radius( 1 )
			.Ignore( this )
			.Run();

		if ( !tr.Hit ) 
			return false;

		tr.Surface.DoFootstep( this, tr, foot, volume );

		return true;
	}
	
	[ConCmd.Server("bm_toggle_view")]
	private static void ChangeView()
	{
		if (ConsoleSystem.Caller.Pawn is not Player player)
			return;
		
		if (!ServerSettings.bm_setting_debug_enabled)  
			return;

		if ( player.Camera is ThirdPersonCamera )
		{
			player.Camera = new FirstPersonCamera();
		}
		else
		{
			player.Camera = new ThirdPersonCamera();
		}
	}

	protected override void OnDestroy()
	{
		base.OnDestroy();
		
		FirstPersonBody?.Delete();
	}

	public override void FrameSimulate(IClient cl)
	{
		Camera?.FrameSimulate();
		
		base.FrameSimulate(cl);
	}
	
	/// <summary>
	/// Called from the gamemode, clientside only.
	/// </summary>
	public override void BuildInput()
	{
		OriginalViewAngles = ViewAngles;
		InputDirection = Input.AnalogMove;

		if ( Input.StopProcessing )
			return;

		var look = Input.AnalogLook;

		if ( ViewAngles.pitch > 90f || ViewAngles.pitch < -90f )
		{
			look = look.WithYaw( look.yaw * -1f );
		}

		var viewAngles = ViewAngles;
		viewAngles += look;
		viewAngles.pitch = viewAngles.pitch.Clamp( -89f, 89f );
		viewAngles.roll = 0f;
		ViewAngles = viewAngles.Normal;

		MeleeInput();
		ActiveChild?.BuildInput();

		GetActiveController()?.BuildInput();

		if ( Input.StopProcessing )
			return;

		GetActiveAnimator()?.BuildInput();
	}
}
