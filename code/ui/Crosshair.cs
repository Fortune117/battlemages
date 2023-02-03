using System;
using Sandbox;
using Sandbox.UI;

namespace BattleMages.UI;


public partial class Crosshair : Panel
{
	public static Crosshair Instance;
	
	private Panel Compass { get; set; }
	private float CompassRotation { get; set; }
	
	private bool CompassLocked { get; set; }

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


	public void LockCompass()
	{
		Instance.CompassLocked = true;
	}
	
	public void UnlockCompass()
	{
		Instance.CompassLocked = false;
	}
	
	public override void Tick()
	{
		if (CompassLocked)
			return;
		
		CompassRotation = CompassRotation.NormalizeDegrees();
		
		var pt = new PanelTransform();

		pt.AddTranslateX( Length.Pixels( -3.5f ) );
		pt.AddTranslateY( Length.Percent( -50f ) );
		pt.AddRotation( 0, 0, CompassRotation + 180);

		Compass.Style.Transform = pt;
	}
}
