using Sandbox;
using Sandbox.UI;

namespace BattleMages.UI;

public partial class StaminaBar
{
    public static StaminaBar Instance { get; set; }
    public Panel FillBar { get; set; }
    public Panel BrokenBar { get; set; }
    
    private float staminaFraction;
    private float staminaAbsoluteFraction;
    private float currentStaminaFraction = 1;
    private float brokenFraction;

    private Color Full = Color.FromBytes(42, 95, 125);
    private Color Half = Color.FromBytes(237, 215, 119);
    private Color Low  = Color.FromBytes(240, 81, 81);
    private Color Critical = Color.FromBytes(255, 0, 0);
    
    public StaminaBar()
    {
        Instance = this;
    }

    public void SetFraction(float n)
    {
        staminaFraction = n;
        staminaFraction = staminaFraction.Clamp(0, 1);
        staminaAbsoluteFraction = n;
    }
    
    public void SetBrokenFraction(float n)
    {
        brokenFraction = n;
        BrokenBar.Style.Opacity = n > 0 ? 1 : 0;
        BrokenBar.Style.Width = Length.Percent(n * 100f);
    }

    [Event.Client.Frame]
    private void FrameUpdate()
    {
        currentStaminaFraction = currentStaminaFraction.LerpTo(staminaFraction, Time.Delta * 15f);

        var brokeFrac = 1 - brokenFraction;
        FillBar.Style.Width = Length.Percent(currentStaminaFraction * 100f * brokeFrac - 1); //hacky hack, the -1 make its look a bit nicer when it's broken


        SetClass("visible",
            staminaAbsoluteFraction < 1 && Game.LocalPawn.LifeState == LifeState.Alive || Input.Down(InputButton.Score));

        //funny hardcode :3
        switch (currentStaminaFraction)
        {
            case > 0.5f:
            {
                var delta = (1 - currentStaminaFraction) / 0.5f;
                FillBar.Style.BackgroundColor = Color.Lerp(Full, Half, delta);
                return;
            }
            case > 0.25f:
            {
                var delta = 1 - ((currentStaminaFraction - 0.25f) / 0.25f);
                FillBar.Style.BackgroundColor = Color.Lerp(Half, Low, delta);
                return;
            }
            case > 0f:
            {
                var delta = 1 - (currentStaminaFraction / 0.25f);
                FillBar.Style.BackgroundColor = Color.Lerp(Low, Critical, delta);
                return;
            }
        }
    }
}