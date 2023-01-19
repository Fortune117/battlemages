using System.Collections.Generic;
using System.Linq;
using BattleMages.Cameras;
using Sandbox;
using StalkerRP.Cameras;

namespace BattleMages;

internal class SpectatorCamera : BaseCamera
{
	public bool IsFree { get; set; } = false;

	protected virtual float BaseMoveSpeed => 800f;

	// TODO - Input modifiers
	protected float MoveMultiplier = 1f;

	int playerIndex = 0;
	
	private static Player target;
	public static Player Target
	{
		get => target;
		set
		{
			if ( target == value ) return;

			var oldTarget = target;
			target = value;

			Event.Run( "stalker.spectator.changedtarget", oldTarget, target );
		}
	}
	
	public virtual IEnumerable<Player> GetPlayers()
	{
		return Sandbox.Entity.All.OfType<Player>();
	}
	
	public static bool IsSpectator => Target.IsValid() && !Target.IsLocalPawn;
	public static bool IsLocal => !IsSpectator;
	
	public Player SelectPlayerIndex( int index )
	{
		var players = GetPlayers().ToList();

		playerIndex = index;

		if ( playerIndex >= players.Count )
			playerIndex = 0;
		
		if ( playerIndex < 0 )
			playerIndex = players.Count - 1;

		var player = players[playerIndex];
		Target = player;

		// Force freecam off
		IsFree = false;

		return player;
	}
	
	public Player SpectateNextPlayer( bool asc = true )
	{
		return SelectPlayerIndex( asc ? playerIndex + 1 : playerIndex - 1 );
	}

	public void ResetInterpolation()
	{
		// Force eye rotation to avoid lerping when switching targets
		if ( Target.IsValid() )
			Rotation = Target.Rotation;
	}

	protected void ToggleFree()
	{
		IsFree ^= true;

		if ( IsFree )
		{
			if ( Target.IsValid() )
				Position = Target.AimRay.Position;
			
			Camera.FirstPersonViewer = null;
		}
		else
		{
			ResetInterpolation();
			Camera.FirstPersonViewer = Target;
		}
	}

	float GetSpeedMultiplier()
	{
		if ( Input.Down( InputButton.Run ) )
			return 2f;
		if ( Input.Down( InputButton.Duck ) )
			return 0.3f;

		return 1f;
	}

	[Event.Client.BuildInput]
	private void BuildInput( )
	{
		if ( Input.Pressed( InputButton.Jump ) )
			ToggleFree();

		if ( Input.Pressed( InputButton.Menu ) )
			SpectateNextPlayer( false ); 

		if ( Input.Pressed( InputButton.Use ) )
			SpectateNextPlayer();

		MoveMultiplier = GetSpeedMultiplier();

		if ( IsFree )
		{
			MoveInput = Input.AnalogMove;
			LookAngles += Input.AnalogLook;
			LookAngles.roll = 0;
		}
	}

	Angles LookAngles;
	Vector3 MoveInput;


	[Event( "stalker.spectator.changedtarget" )]
	protected void OnTargetChanged( Player oldTarget, Player newTarget )
	{
		ResetInterpolation();
	}

	protected override void Update()
	{
		if ( !Target.IsValid() )
		{
			IsFree = true;
		}

		if ( IsFree )
		{
			var mv = MoveInput.Normal * BaseMoveSpeed * RealTime.Delta * Rotation * MoveMultiplier;
			Position += mv;
			Rotation = Rotation.From( LookAngles );
		}
		else
		{
			if ( Game.LocalPawn is Player player )
				Target = player;

			if ( !Target.IsValid() )
				Target = GetPlayers().FirstOrDefault();

			var target = Target;
			if ( !target.IsValid() )
				return;

			Position = target.AimRay.Position;

			if ( IsLocal )
				Rotation = target.Rotation;
			else
				Rotation = Rotation.Slerp( Rotation, target.Rotation, Time.Delta * 20f );

			Camera.FirstPersonViewer = target;
		}
		
		base.Update();
	}

	protected override void SetupCamera()
	{
		Camera.Position = Position;
		Camera.Rotation = Rotation;
	}
}
