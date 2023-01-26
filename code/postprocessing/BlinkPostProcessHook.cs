using System;
using Kryz.Tweening;
using Sandbox;
using Sandbox.Effects;

namespace BattleMages.PostProcessing;

[SceneCamera.AutomaticRenderHook]
public class BlinkPostProcessHook : ScreenEffects
{
    public static BlinkPostProcessHook Instance { get; private set; }

    private float vignetteStrength;
    private float blinkFraction;
    private bool isBlinking;
    private bool isHoldingBlink;
    private float warpFraction;
    
    private float vignetteMax => 0.75f;
    private float chromaticAberrationMax => 3f;
    private float chromaticAberrationHold => 0.25f;


    public BlinkPostProcessHook()
    {
        Instance = this;

        Vignette.Roundness = 0f;
        Vignette.Smoothness = 1f;
    }

    public override void OnFrame(SceneCamera target)
    {
        UpdateVignette();
        UpdateChromaticAberration();
        UpdateWarp();
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

    private float wavyFraction;
    private void UpdateWarp()
    {
        if (isHoldingBlink)
        {
            warpFraction = warpFraction.LerpTo(0.5f, Time.Delta * 5f);
            wavyFraction = warpFraction;
        }
        else if (isBlinking)
        {
            warpFraction = EasingFunctions.OutElastic(blinkFraction) * 1f;
            wavyFraction = warpFraction;
        }
        else
        {
            warpFraction = warpFraction.LerpTo(0f, Time.Delta*3f);
            wavyFraction = warpFraction * MathF.Sin(Time.Now*20f);
        }
    }

    public override void OnStage(SceneCamera target, Stage renderStage)
    {
        base.OnStage(target, renderStage);
        
        if ( renderStage == Stage.AfterPostProcess )
        {
            RenderBlinkPP( target );
        }
    }

    private RenderAttributes blinkRenderAttributes = new();
    private void RenderBlinkPP(SceneCamera target)
    {
        blinkRenderAttributes.Set("blink.warp.fraction", wavyFraction);
        blinkRenderAttributes.Set("blink.warp.texture", Texture.Load(FileSystem.Mounted,"materials/postprocessing/blink_warp.png"));
        
        Graphics.GrabFrameTexture("ColorBuffer", blinkRenderAttributes);
        Graphics.GrabDepthTexture("DepthBuffer", blinkRenderAttributes);
        Graphics.Blit(Material.Create("blink_pp", "shaders/postprocess/power_blink_pp.shader"), blinkRenderAttributes);
    }
}