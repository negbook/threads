local Draws_counts = 0
local DrawText3DAlpha = function(object)
    local coords = object._coords
    if object._alpha > 0 then 
        local camCoords = GetGameplayCamCoords()
        local distance = #(coords - camCoords)
        local scale = (object._scale / distance) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        scale = scale or 15
        SetTextScale(scale/24, scale/24)
        SetTextFont(object._font or 0)
        SetTextColour(255, 255, 255, object._alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetDrawOrigin(coords.x,coords.y,coords.z)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(object._text)
        EndTextCommandDisplayText(0.0, 0.0, 0)
        ClearDrawOrigin()
    end 
end
local DrawNextOrder = function(handle)
    return SetScriptGfxDrawOrder(handle%128)
end 
local positiontext_handle = 1
local positiontext_handles = {}
local positiontext = function(text,coords,duration,pedrelative,font)
    Draws_counts = Draws_counts + 1
    local object = {}
    object._text = text
    object._alpha = 0
    local _scale = 15
    object._scale = _scale
    object._coords = coords
    if font then object._font = RegisterFontId(font) end 
    local durationIn,durationHold,durationOut
    if durationIn == nil then durationIn = duration end 
    if durationHold == nil then durationHold = 0 end 
    if durationOut == nil then durationOut = duration end 
    durationIn = durationIn / 1000
    durationHold = durationHold / 1000
    durationOut = durationOut / 1000
    if positiontext_handle > 65530 then positiontext_handle = 1 end 
    positiontext_handle = positiontext_handle + 1
    local positiontext_handle = positiontext_handle
    Threads.AddPosition("positiontext"..positiontext_handle,coords,25.0,function(result)
        if result.action == 'enter' then 
            positiontext_handles[positiontext_handle] = "hide" 
            Threads.CreateLoopOnce("positiontext"..positiontext_handle,0,function(Break)
                if positiontext_handles[positiontext_handle]=="unshow" then 
                    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                    if bool then 
                        DrawNextOrder(positiontext_handle)
                        DrawText3DAlpha(object)
                    end
                elseif positiontext_handles[positiontext_handle]=="show" then 
                    local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                    if distance < 20 then 
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
                                DrawText3DAlpha(object)
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
                    if distance < 20 then 
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
exports('positiontext', function (text,coords,duration,pedrelative,font)
    return positiontext(text,coords,duration,pedrelative,font)
end )
local NormalStyledMarkers = {}
NormalStyledMarkers["door"] = function(object)
    object._type = 0
    object._float = true
    object._pointcam = true
    object._xscale = 1.0
    object._yscale = 1.0
    object._zscale = 1.0
    object._r = 255
    object._g = 255
    object._b = 0
    object._z = object._z + 1.0
end 
NormalStyledMarkers["entrance"] = NormalStyledMarkers["door"]
NormalStyledMarkers["enter"] = NormalStyledMarkers["door"]
NormalStyledMarkers["exit"] = NormalStyledMarkers["door"]
NormalStyledMarkers["dollors"] = function(object)
    object._type = 29
    object._float = false
    object._pointcam = false
    object._xscale = 1.0
    object._yscale = 1.0
    object._zscale = 1.0
    object._r = 0
    object._g = 255
    object._b = 0
    object._spin = true
    object._z = object._z + 1.0
end 
NormalStyledMarkers["money"] = NormalStyledMarkers["dollors"]
NormalStyledMarkers["dollor"] = NormalStyledMarkers["dollors"]
NormalStyledMarkers["targetpoint"] = function(object)
    object._type = 25
    object._float = false
    object._pointcam = false
    object._xscale = 1.0
    object._yscale = 1.0
    object._zscale = 1.0
    object._r = 255
    object._g = 0
    object._b = 0
    object._spin = false
end 
NormalStyledMarkers["ring"] = NormalStyledMarkers["targetpoint"] 
NormalStyledMarkers["default"] = function(object)
    object._type = 1
    object._float = false
    object._pointcam = false
    object._xscale = 1.5
    object._yscale = 1.5
    object._zscale = 1.5
    object._r = 255
    object._g = 0
    object._b = 0
    object._spin = false
end 
NormalStyledMarkers["texture"] = function(object)
    object._type = 8
    object._float = false
    object._pointcam = false
    object._spin = false
end 
NormalStyledMarkers["texture_shadow"] = NormalStyledMarkers["texture"]
NormalStyledMarkers["texture_light"] = function(object)
    object._type = 9
    object._float = false
    object._pointcam = false
    object._spin = false
end 
local DrawMarkerStyledAlpha = function(object)
   
    if object._shadow then 
        DrawMarker(
        object._type or 0, 
        object._x , 
        object._y , 
        object._z-object._shadow , 
        0.0 , 
        0.0 , 
        0.0 , 
        object._xrotation or 0.0, 
        object._yrotation or 0.0, 
        object._zrotation or 0.0, 
        1.1 * (object._xscale or 1.0), 
        1.1 * (object._yscale or 1.0), 
        1.0 * (object._zscale or 1.0), 
        object._r or 255, 
        object._g or 255, 
        object._b or 255, 
        math.floor(object._alpha) or 255, 
        object._float or false , 
        object._pointcam or false , 
        2 , 
        object._spin or false , 
        object._texturedict or 0 , 
        object._texturename or 0, 
        0,
        1
        )
        DrawMarker(
        object._type or 0, 
        object._x , 
        object._y , 
        object._z , 
        0.0 , 
        0.0 , 
        0.0 , 
        object._xrotation or 0.0, 
        object._yrotation or 0.0, 
        object._zrotation or 0.0, 
        object._xscale or 1.0, 
        object._yscale or 1.0, 
        object._zscale or 1.0, 
        20, 
        20, 
        20, 
        120, 
        object._float or false , 
        object._pointcam or false , 
        2 , 
        object._spin or false , 
        object._texturedict or 0 , 
        object._texturename or 0, 
        0,
        1
        )
    else 
        DrawMarker(
        object._type or 0, 
        object._x , 
        object._y , 
        object._z , 
        0.0 , 
        0.0 , 
        0.0 , 
        object._xrotation or 0.0, 
        object._yrotation or 0.0, 
        object._zrotation or 0.0, 
        object._xscale or 1.0, 
        object._yscale or 1.0, 
        object._zscale or 1.0, 
        object._r or 255, 
        object._g or 255, 
        object._b or 255, 
        math.floor(object._alpha) or 255, 
        object._float or false , 
        object._pointcam or false , 
        2 , 
        object._spin or false , 
        object._texturedict or 0 , 
        object._texturename or 0, 
        0,
        1
        )
    end 
end 
local positionmarker_handle = 1
local positionmarker_handles = {}
local positionmarker = function(coords,rotations,duration,pedrelative,isground,stylename,vars)
    Draws_counts = Draws_counts + 1
    local object = {}
    stylename = stylename or "default"
    if vars and vars._texturedict and (stylename~="texture" or stylename ~= "texture_light") then 
        stylename = "texture"
    end 
    local objcoords = coords
    if isground then 
        local topz = coords.z
        local bottomz = GetHeightmapBottomZForPosition(coords.x,coords.y)
        local steps = (topz-bottomz)/100
        local foundGround
        local height = topz + 0.0
        local groundz
        while not foundGround and height > bottomz  do 
            foundGround, groundz = GetGroundZFor_3dCoord(coords.x,coords.y, height,1 )
            height = height - steps
        end 
        objcoords = vector3(coords.x,coords.y,groundz)
    end 
    object._x = objcoords.x 
    object._y = objcoords.y
    object._z = objcoords.z
    object._xrotation = rotations.x
    object._yrotation = rotations.y
    object._zrotation = rotations.z
    if vars then 
        for i,v in pairs(vars) do 
            object[i] = v
        end 
    end 
    object._alpha = 0
    NormalStyledMarkers[stylename:lower()](object)
    local durationIn,durationHold,durationOut
    if durationIn == nil then durationIn = duration end 
    if durationHold == nil then durationHold = 0 end 
    if durationOut == nil then durationOut = duration end 
    durationIn = durationIn / 1000
    durationHold = durationHold / 1000
    durationOut = durationOut / 1000
    if positionmarker_handle > 65530 then positionmarker_handle = 1 end 
    positionmarker_handle = positionmarker_handle + 1
    local positionmarker_handle = positionmarker_handle
    Threads.AddPosition("positionmarker"..positionmarker_handle,coords,25.0,function(result)
        
        if result.action == 'enter' then 
            positionmarker_handles[positionmarker_handle] = "hide" 
            Threads.CreateLoopOnce("positionmarker"..positionmarker_handle,0,function(Break)
                if positionmarker_handles[positionmarker_handle]=="unshow" then 
                    DrawNextOrder(positionmarker_handle)
                    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                    if bool then 
                        DrawMarkerStyledAlpha(object)
                    end
                elseif positionmarker_handles[positionmarker_handle]=="show" then 
                    local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                    if distance < 20 then 
                        local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                        local bool2 = true 
                        if pedrelative then bool2 = IsPedHeadingTowardsPosition(PlayerPedId(), coords.x,coords.y,coords.z,90.0) end 
                        if not bool2 then 
                            positionmarker_handles[positionmarker_handle] = "unshow" 
                            Threads.TweenCFX.to(object,durationIn,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positionmarker_handle,pedrelative)
                                positionmarker_handles[positionmarker_handle] = "hide" 
                            end,onCompleteArgs={object,positionmarker_handle,pedrelative}})
                        else 
                            if bool then 
                                if math.floor(object._alpha) == 0 then 
                                    Threads.TweenCFX.to(object,durationIn,{_alpha=vars and vars._toalpha or 255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positionmarker_handle,pedrelative)
                                    end,onCompleteArgs={object,positionmarker_handle,pedrelative}})
                                end 
                                DrawNextOrder(positionmarker_handle)
                                DrawMarkerStyledAlpha(object)
                            else 
                                Threads.TweenCFX.removeTween(object)
                                object._alpha = 0
                                positionmarker_handles[positionmarker_handle] = "hide" 
                            end 
                        end 
                    else 
                        positionmarker_handles[positionmarker_handle] = "unshow" 
                        Threads.TweenCFX.to(object,durationIn,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positionmarker_handle,pedrelative)
                            positionmarker_handles[positionmarker_handle] = "hide" 
                        end,onCompleteArgs={object,positionmarker_handle,pedrelative}})
                    end 
                elseif positionmarker_handles[positionmarker_handle]=="hide" then 
                    local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                    if distance < 20 then 
                        local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
                        local bool2 = true
                        if pedrelative then bool2 = IsPedHeadingTowardsPosition(PlayerPedId(), coords.x,coords.y,coords.z,90.0) end 
                        if bool and bool2 then 
                            positionmarker_handles[positionmarker_handle] = "unshow" 
                            if math.floor(object._alpha) == 0 then 
                                Threads.TweenCFX.to(object,durationIn,{_alpha=vars and vars._toalpha or 255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,positionmarker_handle,pedrelative)
                                    positionmarker_handles[positionmarker_handle] = "show" 
                                end,onCompleteArgs={object,positionmarker_handle,pedrelative}})
                            end 
                        else 
                            Threads.TweenCFX.removeTween(object)
                            object._alpha = 0
                            positionmarker_handles[positionmarker_handle] = "hide" 
                        end  
                    end
                elseif positionmarker_handles[positionmarker_handle]=="shoudkill" then  
                    Break()
                end 
            end )
        end 
        if result.action == 'exit' then 
            positionmarker_handles[positionmarker_handle] = "shoudkill"
            
        end 
    end)
end
exports('positionmarker', function (coords,rotations,duration,pedrelative,isground,stylename,vars)
   
    return positionmarker(coords,rotations,duration,pedrelative,isground,stylename,vars)
end )

exports('GetDrawsTotal',function()
    return Draws_counts or 0
end)