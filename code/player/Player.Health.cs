using BattleMages.Cameras;
using BattleMages.Debug;
using Sandbox;
using StalkerRP.Cameras;

namespace BattleMages;

partial class Player
{
    private float hitFlinchCooldown => 0.25f;
    private TimeSince timeSinceLastHitFlinch = 0;
    private bool wasHeadshot = false;

    private float headDamageCache = 0;
    private TimeUntil timeUntilHeadDamageCacheReset = 0;
    public override void TakeDamage(DamageInfo info)
    {
        Game.AssertServer();
        
        if (Tags.Has(DebugTags.GodMode))
            info.Damage = 0;
        
        lastDamage = info;

        base.TakeDamage( info );
        
        if (info.Hitbox.HasTag(BMTags.HitBox.Head))
        {
            info.Damage *= 2f;
        }
        
        Health -= info.Damage;
        
        if (Health < 0)
            OnKilled();
        
        if (LifeState != LifeState.Alive)
            return;
        
        // Add a score to the killer
        if ( LifeState == LifeState.Dead && info.Attacker != null )
        {
            if ( info.Attacker.Client != null && info.Attacker != this )
            {
                info.Attacker.Client.AddInt( "kills" );
            }
        }
    }

    public void DoDamageReactions()
    {
        TryHitFlinch();   
        VoiceTakeDamage();
    }
    
    private void TryHitFlinch()
    {
        if (timeSinceLastHitFlinch < hitFlinchCooldown)
            return;
        
        timeSinceLastHitFlinch = 0;
    }

    public override void OnKilled()
    {
        if (LifeState != LifeState.Alive)
            return;

        LifeState = LifeState.Dead;
        
        VoiceOnKilled();

        ActiveCarry?.OnDeath();
        ResetCarryInventory();

        if ( lastDamage.HasTag(BMTags.Damage.Vehicle) )
        {
            Particles.Create( "particles/impact.flesh.bloodpuff-big.vpcf", lastDamage.Position );
            Particles.Create( "particles/impact.flesh-big.vpcf", lastDamage.Position );
            PlaySound( "kersplat" );
        }

        CreateCorpse();
        Camera = new FloatingCamera();

        Controller = null;

        EnableAllCollisions = false;
        EnableDrawing = false;

        foreach ( var child in Children )
        {
            child.EnableDrawing = false;
        }
        
        base.OnKilled();
    }

    private void CreateCorpse()
    {
        var ent = new DeathRagdoll();
        ent.CopyFrom(this);
        ent.TakeDamage(lastDamage);
        ent.Owner = this;

        Corpse = ent;
    }

}