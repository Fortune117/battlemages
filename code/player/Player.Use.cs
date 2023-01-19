using Sandbox;

namespace BattleMages;

public partial class Player
{
	public bool IsUseDisabled()
	{
		return ActiveChild is IUse use && use.IsUsable( this );
	}

	protected override Entity FindUsable()
	{
		if ( IsUseDisabled() )
			return null;

		// First try a direct 0 width line
		var tr = Trace.Ray(AimRay, 85 * Scale)
			.WithAnyTags(BMTags.PhysicsTags.Entity, BMTags.PhysicsTags.Weapon, BMTags.PhysicsTags.Solid)
			.Ignore( this )
			.Run();

		// See if any of the parent entities are usable if we ain't.
		var ent = tr.Entity;
		while ( ent.IsValid() && !IsValidUseEntity( ent ) )
		{
			ent = ent.Parent;
		}

		// Nothing found, try a wider search
		if ( !IsValidUseEntity( ent ) )
		{
			tr = Trace.Ray(AimRay, 85 * Scale)
			.Radius( 2 )
			.WithAnyTags(BMTags.PhysicsTags.Entity, BMTags.PhysicsTags.Weapon, BMTags.PhysicsTags.Solid)
			.Ignore( this )
			.Run();

			// See if any of the parent entities are usable if we ain't.
			ent = tr.Entity;
			while ( ent.IsValid() && !IsValidUseEntity( ent ) )
			{
				ent = ent.Parent;
			}
		}
		
		// Still no good? Bail.
		if ( !IsValidUseEntity( ent ) ) return null;

		return ent;
	}

	protected override void UseFail()
	{
		if ( IsUseDisabled() )
			return;

		base.UseFail();
	}
}
