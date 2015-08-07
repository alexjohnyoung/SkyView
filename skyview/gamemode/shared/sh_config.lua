SkyView = {}
SkyView.Config = {}
/////////////////////////////////////////////////////////////////////////
SkyView.Config.FirstPerson = true --Set to true to use firstperson
--[[
	On the topic of First Person in this gamemode:
	- If first person is enabled, the props will shoot where you are looking. 
	- If first person is disabled, the props will shoot where you are facing.
]]--
SkyView.Config.ReflectNum = 1 --Set how much it reflects
--[[
	The lower it is, the less crazy it is.
--]]
SkyView.Config.RemovePropTime = 2 --Set how quick it removes props after spawned in
--[[
	The thing with this is that the higher it is, the more lag your server will have.
]]--
SkyView.Config.DoubleJumpTime = 0.3 --Set how long the player can double jump after jumping (In seconds, 0.3 is miliseconds)
--[[
	The lower this is, the quicker players will be able to double jump
--]]
SkyView.Config.PropSpawnCoolDown = 0.5 --Set how long until a player can spawn another prop
--[[
	For more chaos, decrease this variable
--]]
