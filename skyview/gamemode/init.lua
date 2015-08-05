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

function SkyView:ReflectVector( vec, normal, bounce )
return bounce * ( -2 * ( vec:Dot( normal ) ) * normal + vec );
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
	ply.ShieldMade = false 
	ply.Shield = nil 
	ply.FileID = ply:SteamID():gsub(":", "-")
	if !SkyView:PlayerExists(ply) then 
		--player doesn't exist 
		SkyView:ShowFirstScreen(ply) --show them the first screen
		SkyView:CreatePlayer(ply) --make their player
	end
end 


function GM:KeyPress(ply, key)
	if ply:Alive() then
		if key == IN_ATTACK and !ply.ShieldMade then 
			local prop = ents.Create("prop_physics")
			local pos = ply:GetPos()
			local forward = ply:GetForward()
			prop:SetPos(ply:EyePos() + ply:GetVelocity()*0.1 + ply:GetForward()*50)
			prop:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
			prop:SetColor(Color(0, 0, 0))
			prop:Spawn()
			prop:AddCallback("PhysicsCollide", function(prop, data)
				local ent = data.HitEntity 
				if !ent:IsWorld() then 
					if ent.MeShield then 
						local vel = SkyView:ReflectVector(data.OurOldVelocity, data.HitNormal, 1)
						prop:SetVelocity(vel)
					end 
				elseif ent:IsWorld() then 
					prop:Remove()
				end 
			end )

			local obj = prop:GetPhysicsObject()
			obj:SetVelocity(ply:GetForward()*1000)
		end 
	end
end 

function GM:Think()
	for k,v in pairs(player.GetAll()) do 
		if v:Alive() and v:KeyDown(IN_ATTACK2) then 
			if !v.ShieldMade then
				v.ShieldMade = true 
				local shield = ents.Create("prop_physics")
				shield:SetPos(v:EyePos()+v:GetVelocity()*0.1+v:GetForward()*50)
				shield:SetColor(Color(0, 0, 0))
				shield:SetAngles(v:GetAngles())
				shield:SetModel("models/props_interiors/VendingMachineSoda01a_door.mdl")
				shield:Spawn()
				shield.MeShield = true 
				v.Shield = shield 
			end
		elseif !v:KeyDown(IN_ATTACK2) and v.ShieldMade then 
			v.Shield:Remove()
			v.ShieldMade = false 
		end 
		if v.ShieldMade and v.Shield != nil then
			v.Shield:SetPos(v:EyePos()+v:GetVelocity()*0.1+v:GetForward()*50)
			v.Shield:SetAngles(v:GetAngles())
		end
	end 
end 

//
