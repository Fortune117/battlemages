
local PLY = FindMetaTable( "Player" )
if SERVER then
	util.AddNetworkString( "syncBuffs" )

	function PLY:syncBuffs()
		local tbl = {}
		for k,v in pairs( self.buffs ) do
			if #v > 0 then
				tbl[ k ] = {}
				for i = 1,#v do
					table.insert( tbl[ k ], i )
				end
			end
		end
		net.Start( "syncBuffs" )
			net.WriteTable( tbl )
		net.Send( self )
	end

	function PLY:giveBuff( name, owner )
		local b = self.buffs[ name ]
		local buff = BM.buffs[ name ]
		if b then
			if buff.canStack then
				table.insert( self.buffs[ name ], table.Copy( buff ) )
				local len = #self.buffs[ name ]
				local targBuff = self.buffs[ name ][ len ]
				targBuff.owner = owner or self
				targBuff.player = self
				targBuff:initInternal()
				targBuff:init()
				targBuff:onApply( self )
				self:syncBuffs()
				return
			else
				local len = #self.buffs[ name ]
				local targBuff = self.buffs[ name ][ len ]
				targBuff._dur = CurTime() + targBuff.duration
				targBuff:onRefresh( self )
			end
		end
		self.buffs[ name ] = { table.Copy( buff ) }
		local targBuff = self.buffs[ name ][ 1 ]
		targBuff.owner = owner or self
		targBuff.player = self
		targBuff:initInternal()
		targBuff:init()
		targBuff:onApply( self )
		self:syncBuffs()
	end

	function PLY:removeBuff( name )
		local b = self.buffs[ name ]
		if b then

			b[ 1 ]:onRemove( self )
			table.remove( b, 1 )


			if #self.buffs[ name ] == 0 then
				self.buffs[ name ] = nil
			end

			self:syncBuffs()
		end
	end

end

if CLIENT then
	net.Receive( "syncBuffs", function( len )
		LocalPlayer().buffs = net.ReadTable()
	end)
end

function PLY:hasBuff( name )
	local b = self.buffs[ name ]
	return b and #b > 0
end

function PLY:getBuffs()
	return self.buffs
end

function BM:addBuff( name, tbl, base )
	self.buffs[ name ] = tbl
	self.buffs[ name ].class = name
	if base then
		if not self.buffs[ base ] then ErrorNoHalt( "Attempted to add buff "..name.." with invalid base "..base.."." ) end
		setmetatable( self.buffs[ name ], { __index = self.buffs[ base ] } )
		self.buffs[ name ].baseClass = self.buffs[ base ]
	end
end


include 	( "buffs/base/buff_base.lua" )
AddCSLuaFile( "buffs/base/buff_base.lua" )
include 	( "buffs/base/buff_aura_base.lua" )
AddCSLuaFile( "buffs/base/buff_aura_base.lua" )

local classes = file.Find( "battlemages/gamemode/buffs/*", "LUA" )
for k,v in pairs( classes ) do
	include( "buffs/"..v )
	AddCSLuaFile( "buffs/"..v )
end
