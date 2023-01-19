using Sandbox.UI;

namespace BattleMages.Debug.UI;

[StyleSheet("/debug/ui/CollapsePanel.scss")]
public partial class CollapsePanel : Panel
{
    public string Title { get; set; }
    public Button Header { get; set; }
    public Panel Display { get; set; }

    public CollapsePanel()
    {
        Header = new Button("Title", null, ToggleOpen);
        Header.AddClass("panel-header");
        AddChild(Header);
        Display = AddChild<Panel>("display-panel");
    }

    public override void Tick()
    {
        Header.Text = Title;
    }

    public void ToggleOpen()
    {
        Display.SetClass("open", !Display.HasClass("open"));
    }
}