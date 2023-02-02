using Sandbox.UI;

namespace BattleMages.UI;


public partial class Crosshair : Panel
{
	public static Crosshair Instance;

	public Crosshair()
	{
		Instance = this;
		StyleSheet.Load( "/ui/Crosshair.scss" );
	}
}
