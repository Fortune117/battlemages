
BM = {}
BM.passives = {}
BM.powers 	= {}
BM.buffs 	= {}

function BM:setPlayerClass( ply, class )
	player_manager.SetPlayerClass( ply, class )
end

function BM:think()
	for k,v in pairs( player.GetAll() ) do
		player_manager.RunClass( v, "think" )
	end
end

function BM:doPlayerDeath( ply, atk, dmginfo )
	player_manager.RunClass( ply, "onDeath", atk, dmginfo )
end

function BM:keyPress( ply, key )
	player_manager.RunClass( ply, "keyPress", key )
end

function BM:onPlayerHitGround( ply, inWater, onFloater, speed )
	player_manager.RunClass( ply, "onHitGround", inWater, onFloater, speed  )
end

function BM:entityTakeDamage( targ, atk, dmginfo )

	local t_IsPlayer = targ:IsPlayer()
	local a_IsPlayer = atk:IsPlayer()
	local isKill = dmginfo:GetDamage() > targ:Health()

	if t_IsPlayer then

		player_manager.RunClass( targ, "onTakeDamage", targ, atk, dmginfo  )

		if atk:GetClass() == "bm_propspamprop" then
			dmginfo:SetAttacker( atk:GetOwner() )
			dmginfo:SetDamage( atk.damage )
		end

		if a_IsPlayer then

			player_manager.RunClass( atk, "onDealDamage", atk, targ, dmginfo  )

			if isKill then

				player_manager.RunClass( targ, "onKilled", targ, atk, dmginfo  )
				player_manager.RunClass( atk, "onKill", atk, targ, dmginfo  )

			end

		end

	elseif a_IsPlayer then
		player_manager.RunClass( atk, "onDealDamage", atk, targ, dmginfo  )
	end

end

function BM:getReloadMod( ply )
	return player_manager.RunClass( ply, "getReloadMod", ply )
end

function BM:onFireWeapon( ply, wep )
	return player_manager.RunClass( ply, "onFireWeapon", ply, wep )
end

if SERVER then
	concommand.Add( "bm_reloadpowers",
	function()
		for k,v in pairs( player.GetAll() ) do
			player_manager.RunClass( v, "loadPowers" )
		end
	end)
end
