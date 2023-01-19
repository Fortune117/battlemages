using Sandbox;

namespace BattleMages.Debug;

public static class DebugCommands
{
    [ConVar.Replicated] public static bool stalker_debug_npc_nav_drawpath { get; set; } = false;

    [ConVar.Replicated] public static bool stalker_debug_npc_disable_thinking { get; set; } = false;

    [ConVar.Replicated] public static bool stalker_debug_bullets_path { get; set; } = false;
    
    [DebugCommand("God", Description = "Invulnerability")]
    [ConCmd.Server("stalker_debug_god_toggle", Help = "Invulnerability.")]
    public static void ToggleGod()
    {
        if (!ServerSettings.bm_setting_debug_enabled)
            return;
        
        var target = ConsoleSystem.Caller;
        if ( target.Pawn is not Player player )
            return;
        
        player.Tags.Toggle(DebugTags.GodMode);
        
        var toggleString = player.Tags.Has(DebugTags.GodMode) ? "enabled" : "disabled";
        ConsoleSystem.Run($"say '{player.Client.Name} has {toggleString} God mode.'");
    }
    
    [DebugCommand("Suicide", Description = "Perish.")]
    [ConCmd.Server("stalker_debug_suicide", Help = "Die.")]
    public static void Suicide()
    {
        var target = ConsoleSystem.Caller;
        if ( target.Pawn is not Player player )
            return;
        
        player.OnKilled();
    }
    
    [DebugCommand("Kill", Description = "Kill what you're looking at.")]
    [ConCmd.Server("stalker_debug_kill", Help = "Kill what you're looking at.")]
    public static void KillEyeTarget()
    {
        if (!ServerSettings.bm_setting_debug_enabled)
            return;
        
        var target = ConsoleSystem.Caller;
        if ( target.Pawn is not Player player )
            return;

        var tr = player.GetEyeTrace();
        if (tr.Entity is null || tr.Entity.IsWorld)
            return;
        tr.Entity.OnKilled();
    }
    
    [DebugCommand("Delete", Description = "Delete what you're looking at.")]
    [ConCmd.Server("stalker_debug_delete", Help = "Delete what you're looking at.")]
    public static void DeleteEyeTarget()
    {
        if (!ServerSettings.bm_setting_debug_enabled)
            return;
        
        var target = ConsoleSystem.Caller;
        if ( target.Pawn is not Player player )
            return;

        var tr = player.GetEyeTrace();

        if (tr.Entity is Player)
            return;
        
        if (tr.Entity is null || tr.Entity.IsWorld)
            return;
        
        tr.Entity.Delete();
    }
}