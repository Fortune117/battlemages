using System.Collections.Generic;
using Sandbox;

namespace BattleMages.Cameras;

public abstract class BaseCamera : EntityComponent<Player>, ISingletonComponent
{
    private List<CameraShake> cameraShakes = new();
    private List<ViewPunch> viewPunches = new();
    private ViewPunch viewPunch = new ViewPunch();

    public Vector3 CurrentShake { get; set; }
    public Rotation CurrentFlinch { get; set; }
    
    public Vector3 Position { get; set; }
    public Rotation Rotation { get; set; }
    public float FieldOfView { get; set; }
    public float ZNear { get; set; }
    public float ZFar { get; set; }
    
    public void FrameSimulate()
    {
        Update();
        SetupCamera();
    }
    
    protected virtual void Update()
    {
        var offset = CalculateShakeOffset();
        var rotation = CalculateViewPunchRotation();

        offset += GetHeadMotionOffset();
        offset += GetLimpOffset();
        
        CurrentShake = offset;
        CurrentFlinch = rotation;
        Position += offset;
        Rotation *= rotation;
        Rotation *= HeadMovementComponent.Instance.GetCameraRotation();
    }
    

    protected abstract void SetupCamera();

    private Rotation GetHeadRotation()
    {
        if (Entity is not Player player)
            return Rotation.Identity;

        return player.HeadMovementComponent.GetCameraRotation();
    }
    
    private Vector3 GetHeadMotionOffset()
    {
        if (Entity is not Player player)
            return Vector3.Zero;

        return player.HeadMovementComponent.GetOffset();
    }

    private Vector3 GetLimpOffset()
    {
        if (Entity is not Player player)
            return Vector3.Zero;

        return player.HeadMovementComponent.GetLimpOffset();
    }
    
    private Vector3 CalculateShakeOffset()
    {
        var offset = Vector3.Zero;
        for (var i = 0; i < cameraShakes.Count; i++)
        {
            var shake = cameraShakes[i];
            if (shake.IsFinished)
            {
                cameraShakes.RemoveAt(i);
                i--;
                continue;
            }
            
            offset += shake.UpdateShake();
        }

        return offset;
    }

    private Rotation CalculateViewPunchRotation()
    {
        return Rotation.Identity * viewPunch.UpdateRotation();
    }

    public void AddShake(float magnitude, float roughness, float fadeInDuration = 0.1f, float fadeOutDuration = 0.5f)
    {
        cameraShakes.Add(new CameraShake(magnitude, roughness, fadeInDuration, fadeOutDuration));
    }

    public void AddViewPunch(float vertMagnitude, float horizontalMagnitude, bool randomHorizontalDirection = true)
    {
        viewPunch.Add(vertMagnitude, horizontalMagnitude, randomHorizontalDirection);
    }
    
    public void SnapToEyePosition()
    {
        var pawn = Game.LocalPawn;
        if ( pawn == null ) return;

        Position = pawn.AimRay.Position;
    }

}