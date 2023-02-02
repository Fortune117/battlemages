using Sandbox;
using Sandbox.UI.Construct;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using BattleMages.UI;

//
// You don't need to put things in a namespace, but it doesn't hurt.
//
namespace BattleMages;

/// <summary>
/// This is your game class. This is an entity that is created serverside when
/// the game starts, and is replicated to the client. 
/// 
/// You can use this to create things like HUDs and declare which player class
/// to use for spawned players.
/// </summary>
public partial class BMGame : GameManager
{
	public BMGame()
	{
		if (Game.IsClient)
		{
			_ = new BattleMagesHUD();
		}
	}

	/// <summary>
	/// A client has joined the server. Make them a pawn to play with
	/// </summary>
	public override void ClientJoined( IClient client )
	{
		base.ClientJoined( client );

		// Create a pawn for this client to play with
		var pawn = new Player();
		client.Pawn = pawn;
		pawn.Respawn();

		// Get all of the spawnpoints
		var spawnpoints = All.OfType<SpawnPoint>();

		// chose a random one
		var randomSpawnPoint = spawnpoints.MinBy(_ => Guid.NewGuid());

		// if it exists, place the pawn there
		if ( randomSpawnPoint != null )
		{
			var tx = randomSpawnPoint.Transform;
			tx.Position = tx.Position + Vector3.Up * 50.0f; // raise it up
			pawn.Transform = tx;
		}
	}
	
	[ConCmd.Server("noclip")]
	public static void DoPlayerNoclip()
	{
		if (ConsoleSystem.Caller.Pawn is not Player player)
			return;

		if ( player.DevController is NoclipController )
		{
			Log.Info( "Noclip Mode Off" );
			player.DevController = null;
		}
		else
		{
			Log.Info( "Noclip Mode On" );
			player.DevController = new NoclipController();
		}
	}
	

	[ConCmd.Server("kill")]
	public static void DoPlayerSuicide()
	{
		if (ConsoleSystem.Caller.Pawn is not Player player) return;

		player.OnKilled();
	}
}
