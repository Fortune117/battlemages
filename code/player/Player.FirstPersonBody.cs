using System.Collections.Generic;
using Sandbox;

namespace BattleMages;

public partial class Player
{
    private HashSet<string> LegBonesToKeep = new()
    {
        "leg_upper_R_twist",
        "leg_upper_R",
        "leg_upper_L",
        "leg_upper_L_twist",
        "leg_lower_L",
        "leg_lower_R",
        "ankle_L",
        "ankle_R",
        "ball_L",
        "ball_R",
        "leg_knee_helper_L",
        "leg_knee_helper_R",
        "leg_lower_R_twist",
        "leg_lower_L_twist"
    };

    public SceneModel FirstPersonBody { get; set; }
    
    [Net, Local, Change]
    public string FirstPersonArmsModel { get; set; }

    public string DefaultArmsModel => "models/stalker/weapons/gunslinger/hands/gunslinger_hands_default.vmdl";
    
    private void SetUpFirstPersonLegs()
    {
        FirstPersonBody?.Delete();
        FirstPersonBody = new( Game.SceneWorld, Model, Transform );
    }

    [Event.Client.Frame]
    private void UpdateFirstPersonBody()
    {
        if (!FirstPersonBody.IsValid())
            return;

        //TODO: Uncomment when finsihed with appeareance
        //FirstPersonBody.RenderingEnabled = LifeState == LifeState.Alive && CurrentView.Viewer == Game.LocalPawn;
        FirstPersonBody.RenderingEnabled = LifeState == LifeState.Alive && Sandbox.Camera.FirstPersonViewer == Game.LocalPawn;

        FirstPersonBody.SetBodyGroup( "Head", 1 );
        FirstPersonBody.SetBodyGroup( "Chest", 2 );
        FirstPersonBody.SetBodyGroup( "Hands", 1 );
        //FirstPersonBody.SetBodyGroup( "Legs", shouldHideLegs ? 1 : 0 );

        FirstPersonBody.Flags.CastShadows = false;
        FirstPersonBody.Transform = Transform;
        //FirstPersonBody.Position += FirstPersonBody.Rotation.Forward * 2f;

        FirstPersonBody.Update( RealTime.Delta );

        UpdateAnimatedLegBones( FirstPersonBody );
    }
    
    private void UpdateAnimatedLegBones( SceneModel model )
    {
        for ( var i = 0; i < model.Model.BoneCount; i++ )
        {
            var boneName = model.Model.GetBoneName( i );

            if (LegBonesToKeep.Contains(boneName)) 
                continue;
            
            var moveBackBy = 25f;
            if ( boneName == "spine_1" ) moveBackBy = 15f;
            if ( boneName == "spine_0" ) moveBackBy = 15f;
            if ( boneName == "pelvis" ) moveBackBy = 15f;

            var transform = model.GetBoneWorldTransform( i );
            transform.Position += model.Rotation.Backward * moveBackBy;
            transform.Position += model.Rotation.Up * 20f;
           // transform.Position += model.Rotation.Left * 5f;
            model.SetBoneWorldTransform( i, transform );
        }
    }
    
    public override void OnNewModel( Model model )
    {
        base.OnNewModel( model );
        
        if (Game.IsClient && IsLocalPawn)
            SetUpFirstPersonLegs();
    }
    
    private void OnFirstPersonArmsModelChanged(string oldValue, string newValue)
    {
        if (this != Game.LocalPawn)
            return;
        
        Event.Run(PlayerEvents.Client.FirstPersonArmsChanged, newValue);
    }
}