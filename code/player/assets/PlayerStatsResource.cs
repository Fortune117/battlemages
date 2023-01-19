using System.Collections.Generic;
using Sandbox;
using BattleMages.Stats;

namespace BattleMages;

[GameResource("Stats", "stats", "Contains stats for a player.")]
public class PlayerStatsResource : BMResource
{
    public Health Health { get; set; }
    public Stamina Stamina { get; set; }
    public Movement Movement { get; set; }
    public CameraMotion CameraMotion { get; set; }
}