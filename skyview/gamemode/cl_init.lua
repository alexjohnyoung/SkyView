include("shared.lua")

surface.CreateFont("skyview_firstplayerfont", {
	font = "Droid Sans Mono",
	size = ScreenScale(50),
	shadow = true,
	bold = true
} )

surface.CreateFont("skyview_firstplayerfont2", {
	font = "Droid Sans Mono",
	size = ScreenScale(15),
	shadow = true,
	bold = true
} )

local myView = 90

net.Receive("skyview_firstplayerscreen", function(ply)
	local FirstScreenMenu = vgui.Create("DFrame")
	FirstScreenMenu:SetPos(0, 0)
	FirstScreenMenu:SetTitle("")
	FirstScreenMenu:SetSize(ScrW(), ScrH())
	FirstScreenMenu:ShowCloseButton(false)
	FirstScreenMenu:MakePopup()
	FirstScreenMenu.Paint = function() 
		draw.RoundedBox(2, 0, 0, ScrW(), ScrH(), Color(20, 20, 20, 255))
	end 

	local firstTextDone = false 
	local FirstScreenText = vgui.Create("DLabel", FirstScreenMenu)
	FirstScreenText:SetPos(0, ScrH()/4)
	FirstScreenText.Think = function()
		local myposX, myposY = FirstScreenText:GetPos()
		if(myposX < ScrW()/2.6) then 
			FirstScreenText:SetPos(myposX+6, myposY)
		elseif(myposX >= ScrW()/2.6) then
			firstTextDone = true 
		end 
	end

	FirstScreenText:SetText("Welcome to SkyView")
	FirstScreenText:SetFont("skyview_firstplayerfont")
	FirstScreenText:SetTextColor(Color(255, 255, 255))
	FirstScreenText:SizeToContents()

	--ScrH()/2.7
	local readybutton_exist = false 
	local FirstScreenText2 = vgui.Create("DLabel", FirstScreenMenu)
	FirstScreenText2:SetPos(-500, ScrH()/2.8)
	FirstScreenText2:SetText("A game about shooting objects at your enemy")
	FirstScreenText2.Think = function()
		local myposX, myposY = FirstScreenText2:GetPos()
		if firstTextDone then 
			if(myposX < ScrW()/2.6) then 
				FirstScreenText2:SetPos(myposX+7, myposY)
			elseif(myposX >= ScrW()/2.6) then 
				timer.Simple(1.5, function()
					if (!readybutton_exist) then
						readybutton_exist = true 
						local ReadyButton = vgui.Create("DButton", FirstScreenMenu)
						ReadyButton:SetPos(ScrW()/2, ScrH()/2.2)
						ReadyButton:SetFont("skyview_firstplayerfont2")
						ReadyButton:SetWide(ScrW()/6)
						ReadyButton:SetTall(ScrH()/12)
						ReadyButton:SetText("Ready")
						ReadyButton:SetTextColor(Color(255, 255, 255, 255))
						local r_ReadyButton = 0
						local max_ReadyButton = 255
						local goUp_ReadyButton = true 
						local goDown_ReadyButton = false 
						ReadyButton.Paint = function()
							if(r_ReadyButton >= max_ReadyButton && goUp_ReadyButton) then 
								goDown_ReadyButton = true 
								goUp_ReadyButton = false 
							elseif(r_ReadyButton <= 0 && goDown_ReadyButton) then 
								goUp_ReadyButton = true 
								goDown_ReadyButton = false 
							end 
							if(goUp_ReadyButton) then 
								r_ReadyButton = r_ReadyButton + 1
							elseif(goDown_ReadyButton) then 
								r_ReadyButton = r_ReadyButton - 1
							end
							surface.SetDrawColor(r_ReadyButton, 0, 0, 255)
							ReadyButton:DrawOutlinedRect()
						end
						ReadyButton.DoClick = function()
							FirstScreenMenu:Close()
						end
					end
				end )
			end
		end
	end
	FirstScreenText2:SetFont("skyview_firstplayerfont2")
	FirstScreenText2:SetTextColor(Color(109, 34, 206))
	FirstScreenText2:SizeToContents()
end )


function GM:CalcView(ply, pos, angles, fov)
	local view = {}
	local trace_area = {}
	trace_area.start = ply:EyePos()
	trace_area.endpos = ply:EyePos()+Vector(0, 0, 600)
	trace_area.filter = ply 
	local trace = util.TraceLine(trace_area)
	local hitPos = trace.HitPos 
	hitPos.z = hitPos.z*0.95
	view.origin = Vector(hitPos.x, hitPos.y, hitPos.z)
	local angles = ply:GetAngles()
	view.angles = Angle(90, math.NormalizeAngle(angles.y), math.NormalizeAngle(angles.z))
	view.fov = fov

	return view
end

function GM:ShouldDrawLocalPlayer()
	return true 
end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or name == "CHudCrosshair" then 
		return false 
	end 
	return true 
end 
