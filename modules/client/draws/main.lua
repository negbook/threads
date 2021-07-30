local DrawText2D = function(text,scale,x,y,alpha)
    if alpha > 0 then 
    scale = scale or 15
	SetTextScale(scale/24, scale/24)
	SetTextFont(0)
	SetTextColour(255, 255, 255, alpha)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y, 0)
	--ClearDrawOrigin()
    end 
end
local DrawText3D = function(coords,text,scale,x,y,alpha)
    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)
    local scale = (scale / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if alpha > 0 then 
    scale = scale or 15
	SetTextScale(scale/24, scale/24)
	SetTextFont(0)
	SetTextColour(255, 255, 255, alpha)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y, 0)
	--ClearDrawOrigin()
    end 
end
local DrawNextOrder = function(handle)
    return SetScriptGfxDrawOrder(handle%128)
end 
local positiontext_handle = 1
local positiontext_handles = {}
local positiontext = function(text,coords,duration,pedrelative)
    
        local object = {}
        object._text = text
        object._x = xper
        object._y = yper
        object._alpha = 0
        local _scale = 15
        object._scale = _scale
        local durationIn,durationHold,durationOut
        if durationIn == nil then durationIn = duration end 
        if durationHold == nil then durationHold = 0 end 
        if durationOut == nil then durationOut = duration end 
        durationIn = durationIn / 1000
        durationHold = durationHold / 1000
        durationOut = durationOut / 1000
        if positiontext_handle > 65530 then positiontext_handle = 1 end 
        positiontext_handle = positiontext_handle + 1
        Threads.AddPosition("positiontext"..positiontext_handle,coords,10.0,function(result)
            if result.action == 'enter' then 
                positiontext_handles[positiontext_handle] = "hide" 
                    Threads.CreateLoopOnce("positiontext"..positiontext_handle,0,function(Break)
                            if positiontext_handles[positiontext_handle]=="unshow" then 
                                DrawNextOrder(positiontext_handle)
                                local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                                if bool then 
                                    object._x,object._y = xper,yper
                                    DrawText3D(coords,object._text,object._scale,object._x,object._y,math.floor(object._alpha))
                                end
                            elseif positiontext_handles[positiontext_handle]=="show" then 
                                local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                                if distance < 8 then 
                                    
                                    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                                    local bool2 = true 
                                    if pedrelative then bool2 = IsPedHeadingTowardsPosition(PlayerPedId(), coords.x,coords.y,coords.z,90.0) end 
                                    if not bool2 then 
                                            positiontext_handles[positiontext_handle] = "unshow" 
                                        Threads.TweenCFX.to(object,durationIn,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positiontext_handle,pedrelative)
                                            positiontext_handles[positiontext_handle] = "hide" 
                                        end,onCompleteArgs={object,positiontext_handle,pedrelative}})
                                    else 
                                        if bool then 
                                            if math.floor(object._alpha) == 0 then 
                                                Threads.TweenCFX.to(object,durationIn,{_alpha=255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positiontext_handle,pedrelative)
                                                end,onCompleteArgs={object,positiontext_handle,pedrelative}})
                                            end 
                                            object._x,object._y = xper,yper
                                            DrawNextOrder(positiontext_handle)
                                            DrawText3D(coords,object._text,object._scale,object._x,object._y,math.floor(object._alpha))
                                        else 
                                            Threads.TweenCFX.removeTween(object)
                                            object._alpha = 0
                                            positiontext_handles[positiontext_handle] = "hide" 
                                        end 
                                    end 
                                else 
                                    positiontext_handles[positiontext_handle] = "unshow" 
                                    Threads.TweenCFX.to(object,durationIn,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positiontext_handle,pedrelative)
                                        positiontext_handles[positiontext_handle] = "hide" 
                                    end,onCompleteArgs={object,positiontext_handle,pedrelative}})
                                end 
                            elseif positiontext_handles[positiontext_handle]=="hide" then 
                                local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                                if distance < 8 then 
                                    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                                    local bool2 = true
                                    if pedrelative then bool2 = IsPedHeadingTowardsPosition(PlayerPedId(), coords.x,coords.y,coords.z,90.0) end 
                                    if bool and bool2 then 
                                        positiontext_handles[positiontext_handle] = "unshow" 
                                        if math.floor(object._alpha) == 0 then 
                                            Threads.TweenCFX.to(object,durationIn,{_alpha=255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positiontext_handle,pedrelative)
                                                positiontext_handles[positiontext_handle] = "show" 
                                            end,onCompleteArgs={object,positiontext_handle,pedrelative}})
                                        end 
                                    else 
                                        Threads.TweenCFX.removeTween(object)
                                        object._alpha = 0
                                        positiontext_handles[positiontext_handle] = "hide" 
                                    end  
                                end 
                            elseif positiontext_handles[positiontext_handle]=="shoudkill" then  
                                Break()
                                
                            end 
                    end )
            elseif result.action == 'exit' then 
                positiontext_handles[positiontext_handle] = "shoudkill"
            end 
        end)
     
end
exports('positiontext', function (text,coords,duration,pedrelative)
    return positiontext(text,coords,duration,pedrelative)
end )