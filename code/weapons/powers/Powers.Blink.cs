using BattleMages.PostProcessing;
using Sandbox;

namespace BattleMages;

public partial class Powers
{
    private Particles BlinkTarget;
    
    private float BlinkRange => 375f;
    private float BlinkFallRange => 90f;

    private float BlinkSpeed => 2000f;
    
    [Net, Predicted]
    private TimeUntil TimeUntilBlinkFinished { get; set; }
    
    [Net, Predicted]
    private bool IsBlinking { get; set; }
    
    [Net, Predicted]
    private Vector3 BlinkStartPosition { get; set; }
    
    [Net, Predicted]
    private Vector3 BlinkEndPosition { get; set; }

    private Vector3 BlinkDirection => (BlinkEndPosition - BlinkStartPosition).Normal;

    private string BlinkWhisperStartSFX => "blink.whisper.start";
    private string BlinkWhisperReleaseSFX => "blink.whisper.release";
    private string BlinkCastStartSFX => "blink.cast.start";
    private string BlinkCastReleaseSFX => "blink.cast.release";

    private string BlinkHoldSFX => "blink.hold";

    private Sound blinkHoldSound;

    /// <summary>
    /// RGBA	0.0666667	0.5843137	0.7764706	1.000
    /// </summary>
    private Vector3 OrbValidColor => new Vector3(0.0666667f, 0.5843137f, 0.7764706f);
    private Vector3 OrbInvalidColor => new Vector3(0.366667f, 0.011f, 0.011f);

    private Vector3 LightValidColor => new Vector3(0.4196078f, 0.8156863f, 1.0000000f);
    private Vector3 LightInvalidColor => new Vector3(0.8196078f, 0.2156863f, 0.200000f);

    private TraceResult GetBlinkTrace()
    {
        var boxHeight = Player.Stats.Movement.BodyHeight / 6f;
            
        var girth = Player.Stats.Movement.BodyGirth*0.25f;
        var mins = new Vector3(-girth, -girth, -boxHeight) * Player.Scale;
        var maxs = new Vector3(+girth, +girth, 0) * Player.Scale;

        var ray = Game.IsClient ? FortuneUtil.GetCameraRay() : Player.AimRay;

        var tr = Trace.Ray(ray, BlinkRange)
            .Ignore(Player)
            .Size(mins, maxs)
            .WithoutTags(BMTags.PhysicsTags.Trigger)
            .WorldAndEntities()
            .Run();
        
        if (bm_debug_powers)
            DebugOverlay.TraceResult(tr, 0f);

        return tr;
    }

    private TraceResult GetDownTrace(TraceResult traceResult)
    {
        var startPos = traceResult.EndPosition + traceResult.Normal * 10f;

        var boxHeight = Player.Stats.Movement.BodyHeight / 10f;

        var playerHull = Player.Controller.GetHull();
        var girth = Player.Stats.Movement.BodyGirth*0.4f;
        var mins = playerHull.Mins.WithZ(-boxHeight) * Player.Scale;
        var maxs = playerHull.Maxs.WithZ(0) * Player.Scale;
        
        var tr = Trace.Ray(startPos, startPos + Vector3.Down * BlinkFallRange)
            .Size(mins, maxs)
            .Ignore(Player)
            .WithoutTags(BMTags.PhysicsTags.Trigger)
            .WorldAndEntities()
            .Run();

        if (bm_debug_powers)
            DebugOverlay.TraceResult(tr, 0f);

        return tr;
    }

    private Vector3 GetBlinkFinalPosition()
    {
        var tr = GetDownTrace(GetBlinkTrace());
        return tr.EndPosition + tr.Normal*2f;
    }

    private bool IsValidBlinkPosition(Vector3 position)
    {
        var playerHull = Player.Controller.GetHull();
        
        var tr = Trace.Ray(position, position)
            .Size(playerHull)
            .Ignore(Player)
            .WithoutTags(BMTags.PhysicsTags.Trigger)
            .WorldAndEntities()
            .Run();

        if (bm_debug_powers)
        {
            DebugOverlay.Box(position, Rotation.Identity, playerHull.Mins, playerHull.Maxs, Color.Orange);
        
            if (tr.Hit)
            {
                DebugOverlay.TraceResult(tr, 0f);
            }
        }
        
        return !tr.Hit;
    }
    
    private void UpdateBlinkVFX()
    {
        BlinkPostProcessHook.Instance?.SetBlinkFraction(TimeUntilBlinkFinished.Fraction);
        
        if (BlinkTarget is null)
            return;

        var blinkTrace = GetBlinkTrace();
        BlinkTarget.SetPosition(0, blinkTrace.EndPosition + blinkTrace.Normal * 10f);
        BlinkTarget.SetPosition(1, GetDownTrace(blinkTrace).EndPosition);
        
        var pos = GetBlinkFinalPosition();
        var isValid = IsValidBlinkPosition(pos);
        
        BlinkTarget.Set("orb_color", isValid ? OrbValidColor : OrbInvalidColor);
        BlinkTarget.Set("light_color", isValid ? LightValidColor : LightInvalidColor);
        
    }

    private void BlinkStartSFX()
    {
        Sound.FromEntity(BlinkWhisperStartSFX, Player);

        if (Game.IsServer)
            return;
        
        Sound.FromScreen(BlinkCastStartSFX);
        Sound.FromScreen(BlinkCastStartSFX);
        blinkHoldSound = Sound.FromScreen(BlinkHoldSFX);
    }

    [ClientRpc]
    private void CreateTargetVFX()
    {
        BlinkTarget?.Destroy();
        BlinkTarget = Particles.Create("particles/powers/blink/blink_target.vpcf");
    }
    
    private void BlinkReleaseSFX()
    {
        Sound.FromEntity(BlinkWhisperReleaseSFX, Player);
        Sound.FromEntity(BlinkCastReleaseSFX, Player);
    }

    private void StartBlink()
    {
        BlinkStartSFX();
        CreateTargetVFX();
        BlinkPostProcessHook.Instance?.SetHoldingBlink(true);
    }

    private void ReleaseBlink()
    {
        var finalPos = GetBlinkFinalPosition();

        if (!IsValidBlinkPosition(finalPos))
        {
            CancelBlink();
            return;
        }
        
        BlinkReleaseSFX();
        
        BlinkStartPosition = Player.Position;
        BlinkEndPosition = GetBlinkFinalPosition();
        IsBlinking = true;
        TimeUntilBlinkFinished = BlinkStartPosition.Distance(BlinkEndPosition) / BlinkSpeed;
        
        BlinkTarget?.Destroy(true);
        BlinkTarget = null;
        
        BlinkPostProcessHook.Instance?.SetBlinking(true);
        BlinkPostProcessHook.Instance?.SetHoldingBlink(false);
    }

    private void BlinkSimulate()
    {
        Player.Position = BlinkStartPosition.LerpTo(BlinkEndPosition, TimeUntilBlinkFinished.Fraction);

        if (TimeUntilBlinkFinished <= 0)
            FinishBlink();
    }

    private void CancelBlink()
    {
        BlinkTarget?.Destroy(true);
        BlinkTarget = null;

        blinkHoldSound.Stop();
        BlinkPostProcessHook.Instance?.SetBlinking(false);
        BlinkPostProcessHook.Instance?.SetHoldingBlink(false);
    }
    
    private void FinishBlink()
    {
        IsBlinking = false;
        blinkHoldSound.Stop();

        var endParticles = Particles.Create("particles/powers/blink/blink_end_sparks.vpcf", Player);
        endParticles?.SetPosition(1, BlinkDirection * BlinkSpeed);
        
        BlinkPostProcessHook.Instance?.SetBlinking(false);
    }
    
}