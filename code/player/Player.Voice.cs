using Sandbox;

namespace BattleMages;

public partial class Player
{
    private Sound CurrentSound { get; set; }
    private TimeUntil TimeUntilSoundCanChange;
    private TimeSince timeSinceLastPain;
    public void VoiceTakeDamage()
    {
        PlayVoiceSound("human.pain");
        TimeUntilSoundCanChange = 1f;
        timeSinceLastPain = 0;
    }

    public void VoiceOnKilled()
    {
        StopSound();
    }

    private void PlayVoiceSound(string sfx)
    {
        if (TimeUntilSoundCanChange > 0)
            return;
        
        CurrentSound.Stop();
        CurrentSound = PlaySound(sfx);
    }

    private void StopSound()
    {
        CurrentSound.Stop();
    }

    private float breathingVolume => 0.01f; 
    private float addedBreathingVolume => 0.35f; 
    private float timeBetweenRunningBreaths => 1.25f;
    private float staminaFractionForBreathing => 0.15f;
    private TimeUntil timeUntilNextBreath;
    private void PlayRunningBreath()
    {
        PlayVoiceSound("human.run");
        CurrentSound.SetVolume(breathingVolume + addedBreathingVolume * (1 - StaminaFraction));
        timeUntilNextBreath = timeBetweenRunningBreaths;
        timeUntilNextLowHealthSound += 2f;
    }

    private bool CanDoRunningBreath()
    {
        var staminaFraction = StaminaFraction;
        if (staminaFraction > staminaFractionForBreathing)
            return false;

        return timeUntilNextBreath < 0 && TimeUntilSoundCanChange < 0 &&
               (IsRunning || staminaFraction < staminaFractionForBreathing);
    }

    private void UpdateRunningBreathing()
    {
        if (!CanDoRunningBreath())
            return;
        
        PlayRunningBreath();
    }

    private void PlayLowHealthSound()
    {
        PlayVoiceSound("human.breathing_low_health");
        TimeUntilSoundCanChange = 2f;
        timeUntilNextLowHealthSound = 7f;
    }

    private bool CanDoLowHealthSounds()
    {
        if (Health > 25)
            return false;

        if (timeSinceLastPain < 2f)
            return false;
        
        return timeUntilNextLowHealthSound < 0 && TimeUntilSoundCanChange < 0 && !IsRunning;
    }
    
    private TimeUntil timeUntilNextLowHealthSound;
    private void UpdateLowHealthSounds()
    {
        if (!CanDoLowHealthSounds())
            return;

        PlayLowHealthSound();
    }

    public void SimulateVoice(IClient client)
    {
        if (LifeState != LifeState.Alive)
        {
            CurrentSound.Stop();
            return;
        }
        
        UpdateRunningBreathing();
        UpdateLowHealthSounds();
    }
}