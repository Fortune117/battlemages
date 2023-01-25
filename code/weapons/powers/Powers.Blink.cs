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
    
    [ClientRpc]
    private void CreateTargetVFX()
    {
        BlinkTarget?.Destroy();
        BlinkTarget = Particles.Create("particles/powers/blink/blink_target.vpcf");
    }
    
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
        if (BlinkTarget is null)
            return;

        var blinkTrace = GetBlinkTrace();
        BlinkTarget.SetPosition(0, blinkTrace.EndPosition + blinkTrace.Normal * 3f);
        BlinkTarget.SetPosition(1, GetDownTrace(blinkTrace).EndPosition);
    }

    private void StartBlink()
    {
        BlinkStartPosition = Player.Position;
        BlinkEndPosition = GetBlinkFinalPosition();
        IsBlinking = true;
        TimeUntilBlinkFinished = BlinkStartPosition.Distance(BlinkEndPosition) / BlinkSpeed;
        
        BlinkTarget?.Destroy(true);
        BlinkTarget = null;
    }

    private void BlinkSimulate()
    {
        Player.Position = BlinkStartPosition.LerpTo(BlinkEndPosition, TimeUntilBlinkFinished.Fraction);
        
        if (TimeUntilBlinkFinished <= 0)
            EndBlink();
    }

    private void EndBlink()
    {
        IsBlinking = false;
    }
    
}