AddCSLuaFile("shared.lua") --send to clients
AddCSLuaFile("shared/sh_config.lua")
//make dirs to access later
file.CreateDir("skyview")
file.CreateDir("skyview/players")
//

//make net requests possible
util.AddNetworkString("skyview_firstplayerscreen")
//


--Gamemode Includes
include("shared/sh_config.lua") --load our config file
include("shared.lua") --load shared.lua file
//


//Some tables
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

//Prop Models Table
local PropModels =
{
 "models/props_c17/FurnitureBathtub001a.mdl",
 "models/props_borealis/bluebarrel001.mdl",
 "models/props_c17/furnitureStove001a.mdl",
 "models/props_c17/FurnitureFridge001a.mdl",
 "models/props_c17/oildrum001.mdl",
 "models/props_c17/oildrum001_explosive.mdl",
 "models/props_junk/PlasticCrate01a.mdl",
 "models/props_c17/FurnitureSink001a.mdl",
 "models/props_c17/FurnitureCouch001a.mdl",
 "models/Combine_Helicopter/helicopter_bomb01.mdl",
 "models/props_combine/breenglobe.mdl",
 "models/props_combine/breenchair.mdl",
 "models/props_docks/dock01_cleat01a.mdl",
 "models/props_interiors/VendingMachineSoda01a.mdl",
 "models/props_interiors/Furniture_Couch01a.mdl",
 "models/props_junk/plasticbucket001a.mdl",
 "models/props_lab/filecabinet02.mdl",
 "models/props_trainstation/trashcan_indoor001a.mdl",
 "models/props_vehicles/apc_tire001.mdl",
 "models/props_wasteland/light_spotlight01_lamp.mdl",
 "models/props_junk/TrafficCone001a.mdl"
}


//When a shield is hit sounds
local ShieldHitSounds =
{
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
}
//

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

function SkyView:RandomShieldSound()
	local soundO, key = table.Random(ShieldHitSounds)
	return soundO
end

//Base Functions

function GM:PlayerInitialSpawn(ply)
	if SkyView.Config.FirstPerson then
    	ply:SetWalkSpeed(700)
        ply:SetRunSpeed(600)
        ply:SetGravity(0.2)
       end
	ply:SetModel(table.Random(Models))
	ply.ShieldMade = false
	ply.PropCD = 0
	ply.InAir = false  
	ply.Jumped = false 
	ply.JumpTime = 0
	ply.Shield = nil 
	ply.FileID = ply:SteamID():gsub(":", "-")
	if !SkyView:PlayerExists(ply) then 
		--player doesn't exist 
		SkyView:ShowFirstScreen(ply) --show them the first screen
		SkyView:CreatePlayer(ply) --make their player
	end
end 

function GM:PlayerSpawn(ply)
	ply.PropCD = CurTime()+0.2 
end 

function GM:KeyPress(ply, key)
	if ply:Alive() then
		print(ply.PropCD)
		if key == IN_ATTACK and !ply.ShieldMade then
			if ply.PropCD == 0 or ply.PropCD > 0 and CurTime() >= ply.PropCD then
				local prop = ents.Create("prop_physics")
				local pos = ply:GetPos()
				local forward = ply:GetForward()
				prop:SetPos(ply:EyePos() + ply:GetVelocity()*0.1 + forward*60)
				prop:SetModel(table.Random(PropModels))
				prop:Spawn()
				local obj = prop:GetPhysicsObject()
				prop:AddCallback("PhysicsCollide", function(prop, data)
					local ent = data.HitEntity 
					local vel = SkyView:ReflectVector(data.OurOldVelocity, data.HitNormal, SkyView.Config.ReflectNum)
					if !ent:IsWorld() and !string.find(ent:GetClass(), "func") then 
						if ent.MeShield then 
							ent:EmitSound(SkyView:RandomShieldSound())
							obj:SetVelocity(vel)
						end 
					elseif ent:IsWorld() or string.find(ent:GetClass(), "func") then 
						obj:SetVelocity(vel)
					end 
				end )

				if SkyView.Config.FirstPerson then
					obj:SetVelocity(ply:GetAimVector()*2000) 
				elseif !SkyView.Config.FirstPerson then 
					obj:SetVelocity(ply:GetForward()*2000)
					--Why we did the thing above? Because when we're in the sky view, we can't aim where we shoot.
				end
				timer.Simple(SkyView.Config.RemovePropTime, function()
					if IsValid(prop) then prop:Remove() end
				end )
				ply.PropCD = CurTime()+SkyView.Config.PropSpawnCoolDown
			end 
		end
	end
end 

function GM:Think()
	for k,v in pairs(player.GetAll()) do 
		if v:Alive() then
			if v:KeyDown(IN_ATTACK2) then
				if !v.ShieldMade then
					v.ShieldMade = true 
					local shield = ents.Create("prop_physics")
					shield:SetPos(v:EyePos()+v:GetForward()*50)
					shield:SetAngles(v:GetAngles())
					shield:SetModel("models/props_interiors/VendingMachineSoda01a_door.mdl")
					shield:Spawn()
					local obj = shield:GetPhysicsObject()
					obj:SetMass(90000)
					shield.MeShield = true 
					v.Shield = shield 
				end
			elseif !v:KeyDown(IN_ATTACK2) and v.ShieldMade then 
				v.Shield:Remove()
				v.ShieldMade = false 
			end 
			if v.ShieldMade and v.Shield != nil then
				v.Shield:SetPos(v:EyePos()+v:GetForward()*50)
				v.Shield:SetAngles(v:GetAngles())
			end
			if v:KeyPressed(IN_JUMP) and !v:IsOnGround() and !v.InAir then 
				v.InAir = true 
			end 
			if v:KeyPressed(IN_JUMP) and v.InAir and !v.Jumped then 
				if v.JumpTime == 0 then 
					v.JumpTime = CurTime()+SkyView.Config.DoubleJumpTime
				 end 
				 if CurTime() >= v.JumpTime and v.InAir then 
				 	v.Jumped = true 
				 	v:SetVelocity(Vector(0,0,200))
				 	v.JumpTime = 0
				 end 
			end 
			if v:OnGround() then 
				v.InAir = false 
				v.Jumped = false 
				v.JumpTime = 0
			end
		end
	end 
end 

//
