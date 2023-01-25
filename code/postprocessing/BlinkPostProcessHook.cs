using Kryz.Tweening;
using Sandbox;
using Sandbox.Effects;
using Sandbox.util;

namespace BattleMages.PostProcessing;

[SceneCamera.AutomaticRenderHook]
public class BlinkPostProcessHook : ScreenEffects
{
    public static BlinkPostProcessHook Instance { get; private set; }

    private float vignetteStrength;
    private float blinkFraction;
    private bool isBlinking;
    private bool isHoldingBlink;

    private float vignetteMax => 0.75f;
    private float chromaticAberrationMax => 3f;
    private float chromaticAberrationHold => 0.25f;

    public BlinkPostProcessHook()
    {
        Instance = this;
    }

    public override void OnFrame(SceneCamera target)
    {
        UpdateVignette();
        UpdateChromaticAberration();
    }

    public void SetBlinkFraction(float n)
    {
        blinkFraction = n.Clamp(0, 1);
    }

    public void SetBlinking(bool b)
    {
        isBlinking = b;
    }

    public void SetHoldingBlink(bool b)
    {
        isHoldingBlink = b;
    }

    private void UpdateVignette()
    {
        if (isHoldingBlink)
        {
            Vignette.Intensity = Vignette.Intensity.LerpTo(vignetteMax, Time.Delta * 5f);
        }
        else if (isBlinking)
        {
            Vignette.Intensity = (1 - blinkFraction) * vignetteMax;
        }
        else
        {
            Vignette.Intensity = Vignette.Intensity.LerpTo(0f, Time.Delta * 5f);
        }
    }

    private void UpdateChromaticAberration()
    {
        if (isHoldingBlink)
        {
            ChromaticAberration.Scale = ChromaticAberration.Scale.LerpTo(chromaticAberrationHold, Time.Delta * 5f);
        }
        else if (isBlinking)
        {
            ChromaticAberration.Scale = EasingFunctions.OutElastic(blinkFraction) * chromaticAberrationMax;
        }
        else
        {
            ChromaticAberration.Scale = ChromaticAberration.Scale.LerpTo(0f, Time.Delta * 5f);
        }
    }
}