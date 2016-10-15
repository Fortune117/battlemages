
local BUFF = {}

BUFF.name 		= "Propshield" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 8 			-- The duration of the buff.

BUFF.orbitRadius 	= 50			-- Radius of the props to orbit the player.
BUFF.numProps 		= 7
BUFF.propHealth 	= 125
BUFF.orbitSpeed 	= 3
BUFF.height 		= 50


-- Buffs are a great way of adding temporary "passives" to a player. They can shorten ability code by a lot and are generally just really neato.

function BUFF:onApply( ply ) -- Called when the buff is applied.
	self.props = {}
	for i = 1,self.numProps do
		local p = ents.Create( "bm_propshield" )
		self.props[ i ] = p
		p:Spawn()
		p:Activate()
		p:setOrbit( ply, i, self.numProps, self.orbitRadius, self.orbitSpeed, self.height, self.propHealth, true )
	end
end

function BUFF:onRefresh()
	if self.props then
		for i = 1,#self.props do
			if IsValid( self.props[ i ] ) then
				self.props[ i ]:Remove()
			end
		end
	end
end

function BUFF:onRemove( ply ) -- Called when the buff is removed.
	for i = 1,#self.props do
		if IsValid( self.props[ i ] ) then
			self.props[ i ]:Remove()
		end
	end
end

BM:addBuff( "buff_propshield", BUFF, "buff_base" )
