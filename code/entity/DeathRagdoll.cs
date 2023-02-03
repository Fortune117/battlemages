using Sandbox;

namespace BattleMages;

public partial class DeathRagdoll : ModelEntity
{
	protected virtual float LifeTime => 15f;
	private readonly TimeSince TimeSinceCreated = 0f;
	private float FadeOutTime = 1f; //In FadeOutTime seconds before removal, we fade out to zero alpha.

	public override void Spawn()
	{		
		base.Spawn();
		
		Transmit = TransmitType.Always;

		Tags.Add(BMTags.PhysicsTags.Ragdoll);
		
		PhysicsEnabled = true;

		DeleteAsync( LifeTime );
		SleepAfterDelay();
	}

	private async void SleepAfterDelay()
	{
		await GameTask.DelaySeconds(6f);
		PhysicsEnabled = false;
		EnableHitboxes = true;
	}

	public new void CopyFrom( ModelEntity ent )
	{
		Position = ent.Position;
		Rotation = ent.Rotation;
		Scale = ent.Scale;
		Velocity = ent.Velocity;
			
		SetModel( ent.GetModelName() );
		SetupPhysicsFromModel(PhysicsMotionType.Dynamic);
		
		TakeDecalsFrom( ent );

		// We have to use `this` to refer to the extension methods.
		this.CopyBonesFrom( ent );
		this.SetRagdollVelocityFrom( ent );
		
		SetRagdollVelocity(ent.Velocity);

		SetMaterialGroup( ent.GetMaterialGroup() );
	}

	public void SetRagdollVelocity(Vector3 velocity)
	{
		for (var i = 0; i < BoneCount; i++)
		{
			var body = GetBonePhysicsBody(i);
			if (body == null) 
					continue;

			body.Velocity = velocity;
		}
	}

	public override void TakeDamage( DamageInfo info )
	{
		base.TakeDamage( info );
		if (info.BoneIndex < 0)
			return;
		
		GetBonePhysicsBody( info.BoneIndex )?.ApplyImpulse( info.Force );
	}

	[Event.Client.Frame] 
	protected virtual void FrameUpdate()
	{
		if ( TimeSinceCreated > LifeTime - FadeOutTime )
		{
			var frac = (LifeTime - TimeSinceCreated) / FadeOutTime;
			RenderColor = RenderColor.WithAlpha( frac );
		}

		if (IsClientOnly && Owner == Game.LocalPawn && Game.LocalPawn.LifeState == LifeState.Alive)
			EnableDrawing = false;
		else
			EnableDrawing = true;
	}
}
