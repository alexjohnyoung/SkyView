AddCSLuaFile("shared.lua")
include("shared.lua")

//make dirs to access later
file.CreateDir("skyview")
file.CreateDir("skyview/players")
//

//make net requests possible
util.AddNetworkString("skyview_firstplayerscreen")
//


SkyView = {}

//SkyView Functions

function SkyView:PlayerExists(ply) --check if player exists
	return file.Exists("skyview/players/"..ply.FileID..".txt", "DATA")
end

function SkyView:CreatePlayer(ply) --create player func
	file.Write("skyview/players/"..ply.FileID..".txt", " ")
end 

function SkyView:ShowFirstScreen(ply)
	net.Start("skyview_firstplayerscreen")
	net.Send(ply)
end 

//


//Model Table
local Models = 
{
 "models/player/Group01/Female_01.mdl",
 "models/player/Group01/Female_02.mdl",
 "models/player/Group01/Female_03.mdl",
 "models/player/Group01/Female_04.mdl",
 "models/player/Group01/Female_06.mdl",
 "models/player/group01/male_01.mdl",
 "models/player/Group01/Male_02.mdl",
 "models/player/Group01/male_03.mdl",
 "models/player/Group01/Male_04.mdl",
 "models/player/Group01/Male_05.mdl",
 "models/player/Group01/Male_06.mdl",
 "models/player/Group01/Male_07.mdl",
 "models/player/Group01/Male_08.mdl",
 "models/player/Group01/Male_09.mdl"
}
//

//Base Functions

function GM:PlayerInitialSpawn(ply)
	ply:SetModel(table.Random(Models))
	ply.FileID = ply:SteamID():gsub(":", "-")
	if !SkyView:PlayerExists(ply) then 
		--player doesn't exist 
		SkyView:ShowFirstScreen(ply) --show them the first screen
		SkyView:CreatePlayer(ply) --make their player
	end
end 


function GM:KeyPress(ply, key)
	if key == IN_ATTACK then 
		local prop = ents.Create("prop_physics")
	end 
end 

//
