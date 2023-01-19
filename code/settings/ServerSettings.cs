using Sandbox;

namespace BattleMages;

public static class ServerSettings
{
    [ConVar.Replicated] 
    public static bool bm_setting_debug_enabled { get; set; } = true;
    
}