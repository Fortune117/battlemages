using System;
using Sandbox;
using Sandbox.UI;

namespace BattleMages.UI;


public partial class Crosshair : Panel
{
	public static Crosshair Instance;
	
	private Panel Compass { get; set; }
	private float CompassRotation { get; set; }

	public Crosshair()
	{
		Instance = this;
		StyleSheet.Load( "/ui/Crosshair.scss" );

		Compass = Add.Panel("compass");
	}

	public static void SetCrosshairCompassRotation(float deg)
	{
		Instance.CompassRotation = deg;
	}

	public override void Tick()
	{
		CompassRotation = CompassRotation.NormalizeDegrees();
		
		var pt = new PanelTransform();

		pt.AddTranslateX( Length.Pixels( -3.5f ) );
		pt.AddTranslateY( Length.Percent( -50f ) );
		pt.AddRotation( 0, 0, CompassRotation + 180);

		Compass.Style.Transform = pt;
	}
}
