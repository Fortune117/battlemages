using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;
using Sandbox.UI;

// ReSharper disable PossibleNullReferenceException

namespace BattleMages.Debug.UI;

public partial class DebugCommandsPanel
{
    protected CollapsePanel CommandsList { get; set; }
    protected CollapsePanel EntityList { get; set; }
    protected CollapsePanel ItemList { get; set; }

    private Dictionary<string, CollapsePanel> entityCategories = new();

    protected override void OnAfterTreeRender(bool firstTime)
    {
        if (firstTime)
            Initialize();
    }

    private void Initialize()
    {
        CommandsList.Title = "Commands";
        EntityList.Title = "Spawnable";
        ItemList.Title = "Items";
        
        CreateCommandsList();
        CreateEntityList();
    }
    
    private void CreateCommandsList()
    {
        var typeDescription = TypeLibrary.GetType(typeof(DebugCommands));
        
        for (int i = 0; i < typeDescription.Members.Length; i++)
        {
            var memberInf =typeDescription.Members[i];
            
            if (!memberInf.IsMethod)
                continue;
            
            var att = memberInf.Attributes.OfType<DebugCommandAttribute>().FirstOrDefault();
            if (att == null)
                continue;
            
            var conCommandAttribute = memberInf.Attributes.OfType<ConCmd.ServerAttribute>().FirstOrDefault();
            if (conCommandAttribute == null)
                continue;

            var but = new Button(att.Title, null, () => RunCommandButton(att, conCommandAttribute.Name));
            CommandsList.Display.AddChild(but); 
            but.AddClass("command-button");
        }
    }

    private void CreateEntityList()
    {
        var types = TypeLibrary.GetTypes<Entity>();
        var list = new List<(Button, string)>();
        
        foreach (var type in types)
        {
            var attribute = type.GetAttribute<DebugSpawnableAttribute>();
            if (attribute != null)
            {
                if (!entityCategories.ContainsKey(attribute.Category))
                {
                    var panel = EntityList.Display.AddChild<CollapsePanel>();
                    panel.Title = attribute.Category;
                    entityCategories[attribute.Category] = panel;
                }
                    
                list.Add((CreateSpawnButtonForType(type.TargetType, attribute), attribute.Category));
            }
        }

        foreach (var tuple in list.OrderBy(x => x.Item1.Text))
        {
            entityCategories[tuple.Item2].Display.AddChild(tuple.Item1);
        }
    } 
    
    private Button CreateSpawnButtonForType(Type type, DebugSpawnableAttribute attribute)
    {
        var but = new Button(attribute.Name, null, () => SpawnEntity(type));
        but.AddClass("command-button"); 
        return but;
    }

    private void SpawnEntity(Type type)
    {
        //DebugCommands.SpawnEntity(type.Name);
    }

    private void RunCommandButton(DebugCommandAttribute attribute, string conCommand)
    {
        ConsoleSystem.Run(conCommand);
    }
}