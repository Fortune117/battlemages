
function BM:addPassive( name, tbl, base )
	self.passives[ name ] = tbl
	self.passives[ name ].class = name
	if base then
		if not self.passives[ base ] then ErrorNoHalt( "Attempted to add passive "..name.." with invalid base "..base.."." ) end
		setmetatable( self.passives[ name ], { __index = self.passives[ base ] } )
		self.passives[ name ].baseClass = self.passives[ base ]
	end
end

function BM:addPower( name, tbl, base )
	self.powers[ name ] = tbl
	self.powers[ name ].class = name
	if base then
		if not self.powers[ base ] then ErrorNoHalt( "Attempted to add power "..name.." with invalid base "..base.."." ) end
		setmetatable( self.powers[ name ], { __index = self.powers[ base ] } )
		self.powers[ name ].baseClass = self.powers[ base ]
	end
end

include 	( "powers/base/active_base.lua" )
AddCSLuaFile( "powers/base/active_base.lua" )
include 	( "powers/base/passive_base.lua" )
AddCSLuaFile( "powers/base/passive_base.lua" )
include 	( "powers/base/aura_base.lua" )
AddCSLuaFile( "powers/base/aura_base.lua" )
include 	( "powers/base/channel_base.lua" )
AddCSLuaFile( "powers/base/channel_base.lua" )

local classes = file.Find( "battlemages/gamemode/powers/*", "LUA" )
for k,v in pairs( classes ) do
	include( "powers/"..v )
	AddCSLuaFile( "powers/"..v )
end


local PLY = FindMetaTable( "Player" )

function PLY:getPassives()
	return player_manager.RunClass( self, "getPassives" )
end

function PLY:getMaxUltCharge()
	return player_manager.RunClass( self, "getMaxUltCharge" )
end

function PLY:canUlt()
	local alive = self:Alive()
	local charged = (self:getUltCharge() >= self:getMaxUltCharge())
	return alive and charged 
end
