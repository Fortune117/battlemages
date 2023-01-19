using Sandbox;

namespace BattleMages;

public static class ClientSettings
{
    [ConVar.ClientData]
    public static bool stalker_setting_toggle_sights { get; set; } = true;

    [ConVar.ClientData]
    public static float stalker_setting_aim_sensitivity_mult { get; set; } = 0.65f;
}