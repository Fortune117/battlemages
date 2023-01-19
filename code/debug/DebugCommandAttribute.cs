using System;

namespace BattleMages.Debug;

public class DebugCommandAttribute : Attribute
{
    public string Title { get; set; }
    public string Description { get; set; }

    public DebugCommandAttribute(string title)
    {
        Title = title;
    }
}