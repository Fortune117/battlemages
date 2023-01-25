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

    private TraceResult GetBlinkTrace()
    {
        TraceResult tr;
        
        if (Game.IsClient)
        {
            tr = Trace.Ray(FortuneUtil.GetCameraRay(), BlinkRange)
                .Ignore(Player)
                .Radius(7f)
                .WithoutTags(BMTags.PhysicsTags.Trigger)
                .WorldAndEntities()
                .Run();

            if (bm_debug_powers)
                DebugOverlay.TraceResult(tr, 0f);
            
            return tr;
        }
        
        
        tr = Trace.Ray(Player.AimRay, BlinkRange)
            .Ignore(Player)
            .Radius(7f)
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
        
        var tr = Trace.Ray(startPos, startPos + Vector3.Down * BlinkFallRange)
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
    
    private void UpdateBlinkVFX()
    {
        BlinkPostProcessHook.Instance?.SetBlinkFraction(TimeUntilBlinkFinished.Fraction);
        
        if (BlinkTarget is null)
            return;

        var blinkTrace = GetBlinkTrace();
        BlinkTarget.SetPosition(0, blinkTrace.EndPosition + blinkTrace.Normal * 3f);
        BlinkTarget.SetPosition(1, GetDownTrace(blinkTrace).EndPosition);
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
        endParticles.SetPosition(1, BlinkDirection * BlinkSpeed);
        
        BlinkPostProcessHook.Instance?.SetBlinking(false);
    }
    
}