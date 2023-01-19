using System.Collections.Generic;
using Sandbox;

namespace BattleMages;

public abstract class BMResource : GameResource
{
    private static readonly Dictionary<string, BMResource> assetCache = new();
    
    protected override void PostLoad()
    {
        Log.Info(ResourceName);
        assetCache[ResourceName] = this;
    }

    public static T Get<T>(string name) where T : BMResource
    {
        if (!assetCache.ContainsKey(name))
        {
            Log.Error($"Asset Cache has no value for key {name}");
            return null;
        }
        
        return assetCache[name] as T;
    }

    public static List<T> GetAllResourcesOfType<T>() where T : BMResource
    {
        var list = new List<T>();

        foreach (var value in assetCache.Values)
        {
            if (value is T tValue)
                list.Add(tValue);
        }
        return list;
    }
}