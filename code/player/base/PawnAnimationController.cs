using Sandbox;

namespace BattleMages;

public abstract class PawnAnimator : PawnController
{
	public AnimatedEntity AnimPawn => Pawn as AnimatedEntity;

	public SceneModel FirstPersonPawn => (Pawn as Player)?.FirstPersonBody;

	/// <summary>
	/// We'll convert Position to a local position to the players eyes and set
	/// the param on the animgraph.
	/// </summary>
	public virtual void SetLookAt( string name, Vector3 Position )
	{
		var localPos = (Position - Pawn.AimRay.Position) * Rotation.Inverse;
		SetAnimParameter( name, localPos );
	}

	/// <summary>
	/// Sets the param on the animgraph
	/// </summary>
	public virtual void SetAnimParameter( string name, Vector3 val )
	{
		AnimPawn?.SetAnimParameter( name, val );
		FirstPersonPawn?.SetAnimParameter( name, val );
	}

	/// <summary>
	/// Sets the param on the animgraph
	/// </summary>
	public virtual void SetAnimParameter( string name, float val )
	{
		AnimPawn?.SetAnimParameter( name, val );
		FirstPersonPawn?.SetAnimParameter( name, val );
	}

	/// <summary>
	/// Sets the param on the animgraph
	/// </summary>
	public virtual void SetAnimParameter( string name, bool val )
	{
		AnimPawn?.SetAnimParameter( name, val );
		FirstPersonPawn?.SetAnimParameter( name, val );
	}

	/// <summary>
	/// Sets the param on the animgraph
	/// </summary>
	public virtual void SetAnimParameter( string name, int val )
	{
		AnimPawn?.SetAnimParameter( name, val );
		FirstPersonPawn?.SetAnimParameter( name, val );
	}

	/// <summary>
	/// Calls SetParam( name, true ). It's expected that your animgraph
	/// has a "name" param with the auto reset property set.
	/// </summary>
	public virtual void Trigger( string name )
	{
		SetAnimParameter( name, true );
	}

	/// <summary>
	/// Resets all params to default values on the animgraph
	/// </summary>
	public virtual void ResetParameters()
	{
		AnimPawn?.ResetAnimParameters();
		//FirstPersonPawn?.ResetAnimParameters();
	}

}

