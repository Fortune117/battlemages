using System;
using Sandbox;

namespace BattleMages;

public partial class WalkController
{
    [Net, Predicted]
    public bool IsDucking { get; set; } // replicate
    
    private float duckFraction = 1;
    private float activeFraction => 0.75f;

    private float movingOffset => 0.12f;
    

    private float duckTime => 0.35f;
    private float unDuckTime => 0.55f;
    private TimeSince timeSinceDuckChanged = 0;
    public virtual void DuckPreTick()
    {
    	if (Input.Down(InputButton.Run) || Input.Pressed(InputButton.Jump))
    		TryUnDuck();
    	else if (Input.Pressed(InputButton.Duck))
    		ToggleDuck();

    	if ( IsDucking )
    	{
    		SetTag( "ducked" );
    		duckFraction = duckFraction.LerpTo(activeFraction, Time.Delta * 3.5f);
            var offset = Player.Velocity.Length.LerpInverse(0, Player.Stats.Movement.CrouchSpeed) * movingOffset;
            EyeLocalPosition *= duckFraction + offset;
    	}
    	else
    	{
	        var offset = Player.Velocity.Length.LerpInverse(0, Player.Stats.Movement.CrouchSpeed) * movingOffset;
    		duckFraction = duckFraction.LerpTo(1, Time.Delta * 3.5f);
            EyeLocalPosition *= (duckFraction + offset).Clamp(0, 1);
    	}
    }

    protected virtual void ToggleDuck()
    {
    	if (IsDucking)
    		TryUnDuck();
    	else
    		TryDuck();
    }

    protected virtual void TryDuck()
    {
    	if (IsDucking)
    		return;
    	
    	Player.PlayMovementNoise(0.5f);
    	
        IsDucking = true;
    	timeSinceDuckChanged = 0;
    }

    protected virtual void TryUnDuck()
    {
    	var pm = TraceBBox( Position, Position, originalMins, originalMaxs );
    	if ( pm.StartedSolid ) return;

    	if (!IsDucking)
    		return;
    	
    	Player.PlayMovementNoise(0.5f);
    	
        IsDucking = false;
    	timeSinceDuckChanged = 0;
    }

    // Uck, saving off the bbox kind of sucks
    // and we should probably be changing the bbox size in PreTick
    Vector3 originalMins;
    Vector3 originalMaxs;

    public virtual void UpdateDuckBBox( ref Vector3 mins, ref Vector3 maxs, float scale )
    {
    	originalMins = mins;
    	originalMaxs = maxs;

    	if ( IsDucking )
    		maxs = maxs.WithZ( 36 * scale );
    }
    
    // Could we do this in a generic callback too?
    public virtual float GetDuckWishSpeed()
    {
    	if ( !IsDucking ) return -1;
    	return DuckWalkSpeed;
    }
}