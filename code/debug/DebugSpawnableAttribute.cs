using System;

namespace BattleMages.Debug;

[AttributeUsage(AttributeTargets.Class, Inherited = false)]
public class DebugSpawnableAttribute : Attribute
{
    public string Name { get; set; }
    public string Category { get; set; }
}