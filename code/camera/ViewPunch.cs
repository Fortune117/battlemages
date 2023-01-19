using System;
using Sandbox;
using Sandbox.Utility;

namespace BattleMages.Cameras;

public class ViewPunch
{
    public bool IsFinished => fadeOutTime < 0;

    private Rotation targetRotation = Rotation.Identity;
    private Rotation currentRotation = Rotation.Identity;
    
    private float fadeInTime;
    private float fadeOutTime;
    
    private float fadeInTimeDuration;
    private float fadeOutTimeDuration;

    public ViewPunch()
    {
         
    }
    
    public ViewPunch(float vertMagnitude, float horizMagnitude, float fadeIn, float fadeOut)
    {
        fadeInTime = fadeIn;
        fadeInTimeDuration = fadeIn;
        fadeOutTime = fadeOut;
        fadeOutTimeDuration = fadeOut;

        var noise = Noise.Perlin(Time.Now * 60f);
        var noise2 = Noise.Perlin(0, Time.Now * 60f) - 0.5f;
        noise2 *= 2f;

        var rise = (-vertMagnitude * noise).Clamp(-vertMagnitude, -vertMagnitude / 2f);
        var sway = (horizMagnitude * noise2);

        if (sway > 0)
            sway = sway.Clamp(horizMagnitude / 2f, horizMagnitude);
        else
            sway = sway.Clamp(-horizMagnitude, -horizMagnitude / 2f);

        targetRotation = new Angles(rise, sway, 0).ToRotation();
    }

    public void Add(float vertMagnitude, float horizMagnitude, bool randomHorizontalDirection)
    {        
        var noise = Noise.Perlin(Time.Now * 60f);
        var noise2 = Noise.Perlin(Time.Now * 60f);

        if (randomHorizontalDirection)
        {
            noise2 -= 0.5f;
            noise2 *= 2f;
        }
        
        var rise = (-vertMagnitude * noise).Clamp(-vertMagnitude, -vertMagnitude / 2f);
        var sway = (horizMagnitude * noise2);

        if (sway > 0)
            sway = sway.Clamp(horizMagnitude / 2f, horizMagnitude);
        else
            sway = sway.Clamp(-horizMagnitude, -horizMagnitude / 2f);

        targetRotation *= new Angles(rise, sway, 0).ToRotation();
    }
    
    
    public Rotation UpdateRotation()
    {
        targetRotation = Rotation.Slerp(targetRotation, Rotation.Identity, Time.Delta * 10f);
        currentRotation = Rotation.Slerp(currentRotation, targetRotation, Time.Delta * 10f);
        
        return currentRotation;
    }
}