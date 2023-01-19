using Sandbox;
using Sandbox.Utility;

namespace BattleMages.Cameras;

/*
 * This code is mostly just a copy paste of Ez Camera Shake from Unity.
 */

public class CameraShake
{
    private Vector3 shake;
    private float fadeInDuration;
    private float currentFadeTime;
    private float fadeOutDuration;
    private float magnitude;
    private float roughness;

    private float tick = 0;
    private bool sustain = true;
    
    private float timeUntilFinished;
    private float timeSinceStarted;

    public bool IsFinished => timeUntilFinished < 0;

    public CameraShake(float magnitude, float roughness, float fadeInDuration = 0.1f, float fadeOutDuration = 0.5f)
    {
        timeSinceStarted = 0;
        timeUntilFinished = fadeInDuration + fadeOutDuration;
        tick = Time.Now * roughness;
        this.magnitude = magnitude;
        this.roughness = roughness;
        this.fadeInDuration = fadeInDuration;
        this.fadeOutDuration = fadeOutDuration;
        
        if (fadeInDuration < 0)
        {
            timeUntilFinished = fadeOutDuration;
            sustain = false;
        }
    }
    
    public Vector3 UpdateShake()
    {
        shake.x = Noise.Perlin(tick, 0) - 0.5f;
        shake.y = Noise.Perlin(0, tick) - 0.5f;
        shake.z = Noise.Perlin(tick, tick) - 0.5f;

        timeSinceStarted += Time.Delta;
        timeUntilFinished -= Time.Delta;

        if (fadeInDuration > 0 && sustain)
        {
            if (timeSinceStarted < fadeInDuration)
                currentFadeTime = timeSinceStarted / fadeInDuration;
            else if (fadeOutDuration > 0)
                sustain = false;
        }

        if (!sustain)
            currentFadeTime = timeUntilFinished / fadeOutDuration;

        if (sustain)
            tick = Time.Now * roughness;
        else
            tick = Time.Now * roughness * currentFadeTime;
        
        return shake * magnitude * currentFadeTime;
    }
}