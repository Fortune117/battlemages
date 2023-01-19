using Sandbox;
using Sandbox.UI;

namespace BattleMages.Debug.UI;

public partial class DebugMenu
{
    public static DebugMenu Instance;
    
    protected DebugCommandsPanel CommandsPanel { get; set; }

    private bool isOpen;
    
    
    public DebugMenu()
    {
        Instance = this;
    }
    
    public void SetOpen(bool open)
    {
        Popup.CloseAll();
        
        CommandsPanel.SetClass("open", open);
        
        isOpen = open;
    } 

    private void ToggleMenu()
    {
        SetOpen(!isOpen);
    }

    [Event.Client.BuildInput]
    private void ProcessClientInput()
    {
        if (!isOpen && !ServerSettings.bm_setting_debug_enabled)
            return;
        
        if (Input.Pressed(InputButton.View))
            ToggleMenu();
    }
}