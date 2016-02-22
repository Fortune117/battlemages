
-- Cool Down types
COOLDOWN_INSTANT 	= 0 -- Cooldown starts as soon as the ability is cast.
COOLDOWN_ONFINISH	= 1 -- Cooldown starts when the ability is finished being cast.

CAST_DELAY 			= 0 -- There is a delay before the main effect of the ability.
CAST_INSTANT 		= 1 -- The ability is activated instantly. 



local ACTIVE = {}

ACTIVE.name 						= "Base Active" 	-- Name
ACTIVE.baseCooldown 				= 2 				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.
ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_DELAY		-- Cast type.
ACTIVE.delay 						= 0.2 				-- The delay when the cast type is set to CAST_DELAY 
ACTIVE.animation 					= PLAYER_ATTACK1	-- Animation that should be played when the ability is cast.
ACTIVE.shouldPlayAnimation 			= true 				-- Determines whether or not the animation should be played.
ACTIVE.viewModelAnimation 			= nil 				-- Specifies a viewmodel animation that should be played.
ACTIVE.shouldPlayViewModelAnimation = false 			-- Determines whether or not the viewmodel animation should play.


function ACTIVE:initInternal( ply ) -- Called internally, you shouldn't need to modify this at all really.
	self.cooldown = 0
end 

function ACTIVE:init( ply ) -- Called when the ability is loaded into the players data table.
end 

function ACTIVE:onBeginCasting( ply ) -- Called when the ability is beginning to be cast, useful for abilities with delayed casts.

end 

function ACTIVE:preCast( ply ) -- Called just before the ability is actually cast.
end 

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	ply:Kill()
end

function ACTIVE:postCast( ply ) -- Called after the ability was cast.
end 

function ACTIVE:canCast( ply ) -- This stuff is mostly internal, but you can overwrite it if you need too. Make sure you read the code before trying though.
	return CurTime() > self:getCooldown() and not self:isCasting()
end 

function ACTIVE:shouldCast( ply ) -- Same as above.
	return CurTime() > self.castDelay 
end 

function ACTIVE:beginCast( ply ) -- Internal, called when the player presses a key for their ability.

	self:onBeginCasting( ply )

	if self.castType == CAST_DELAY then 
		self.castDelay = CurTime() + self.delay
		self:setCasting( true )
	elseif self.castType == CAST_INSTANT then 
		self:preCast( ply )
		self:cast( ply )
		self:postCast( ply )
	end 

	if self.cooldownType == COOLDOWN_INSTANT then 
		self:setCooldown( self.baseCooldown )
	end 
	if self.shouldPlayAnimation then 
		ply:SetAnimation( self.animation )
	end 

end 

function ACTIVE:internalCastThink( ply ) -- Again, mostly internal. This gets run when the player has begun casting their abiltiy - this only runs when the cast type is CAST_DELAY 
	if self:shouldCast( ply ) then 
		self:preCast( ply )
		self:cast( ply )
		self:postCast( ply )
		self:setCasting( false )
		if self:getCooldownType() == COOLDOWN_ONFINISH then 
			self:setCooldown( self.baseCooldown )
		end 
	end 
end  

function ACTIVE:castThink( ply ) -- This is run immediately after the above function. 
end 

function ACTIVE:think( ply ) -- This constantly runs.
end 

function ACTIVE:getCooldownType() -- Gets the cooldown type. 
	return self.cooldownType 
end 

function ACTIVE:getCooldown()
	return self.cooldown 
end 

local cooldownFuncs = 
{
	[ IN_SPEED ] = function( ply, t ) ply:setCooldown1( t ) end,
	[ IN_USE ] = function( ply, t ) ply:setCooldown2( t ) end,
	[ IN_ATTACK2 ] = function( ply, t ) ply:setCooldown3( t ) end,
}

function ACTIVE:setCooldown( t ) -- Sets the cooldown of the ability - can be modifed from outside sources.
	self.cooldown = CurTime() + t 
	cooldownFuncs[ self.key ]( self.player, CurTime() + t )
end 

function ACTIVE:setCasting( b ) -- Sets whether the player is casting or not. Mostly internal. You shouldn't need to use it.
	self.casting = b 
end 

function ACTIVE:isCasting() -- Checks whether the player is casting an ability.
	return self.casting
end 

BM:addPower( "active_base", ACTIVE )