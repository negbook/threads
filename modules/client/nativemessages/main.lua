DrawText2D = function(text,scale,x,y,alpha)
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
local hudmessage_handle = 1
local hudmessage_handles = {}

local hudmessage = function(text,xper,yper,scale,durationIn,durationHold,durationOut,cb)
    local object = {}
        object._text = text
        object._x = xper
        object._y = yper
        object._alpha = 0
        object._scale = scale

        if durationIn == nil then durationIn = 1500 end 
        if durationHold == nil then durationHold = 2500 end 
        if durationOut == nil then durationOut = 1500 end 
        durationIn = durationIn / 1000
        durationHold = durationHold / 1000
        durationOut = durationOut / 1000
        if hudmessage_handle > 65530 then hudmessage_handle = 1 end 
        hudmessage_handle = hudmessage_handle + 1
        hudmessage_handles[hudmessage_handle] = true 
        
        Threads.TweenCFX.to(object,durationIn,{_alpha=255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage_handle,cb)
            Threads.TweenCFX.delayCall(object,durationHold,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage_handle,cb)
                Threads.TweenCFX.to(object,durationOut,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage_handle,cb)
                    hudmessage_handles[hudmessage_handle] = nil
                    if cb then 
                        cb(object)
                    end
                end ,onCompleteArgs={object,hudmessage_handle,cb}})
            end ,onCompleteArgs={object,hudmessage_handle,cb}})
            
        end ,onCompleteArgs={object,hudmessage_handle,cb}})
    
    
        hudmessage_handles[hudmessage_handle] = true 
        
        Threads.CreateLoop("hudmessage"..hudmessage_handle,0,function(Break)
            if hudmessage_handles[hudmessage_handle] then 
                DrawNextOrder(hudmessage_handle)
                DrawText2D(object._text,object._scale,object._x,object._y,math.floor(object._alpha))
            else 
                Break()
            end 
        end )
end

local hudmessage2_handle = 1
local hudmessage2_handles = {}
local hudmessage2 = function(text,coords,duration,cb)
   
    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
    if bool then 
        local object = {}
        object._text = text
        object._x = xper
        object._y = yper
        object._alpha = 0
        object._scale = 15
        local durationIn,durationHold,durationOut
        if durationIn == nil then durationIn = duration end 
        if durationHold == nil then durationHold = 0 end 
        if durationOut == nil then durationOut = duration end 
        durationIn = durationIn / 1000
        durationHold = durationHold / 1000
        durationOut = durationOut / 1000
        if hudmessage2_handle > 65530 then hudmessage2_handle = 1 end 
        hudmessage2_handle = hudmessage2_handle + 1
        hudmessage2_handles[hudmessage2_handle] = true 
        Threads.TweenCFX.to(object,durationIn,{_alpha=255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage2_handle,cb)
            --Threads.TweenCFX.delayCall(object,durationHold,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage2_handle,cb)
                Threads.TweenCFX.to(object,durationOut,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,hudmessage2_handle,cb)
                    hudmessage2_handles[hudmessage2_handle] = nil
                    if cb then 
                        cb(object)
                    end
                end ,onCompleteArgs={object,hudmessage2_handle,cb}})
            --end ,onCompleteArgs={object,hudmessage2_handle,cb}})
            
        end ,onCompleteArgs={object,hudmessage2_handle,cb}})
        
        hudmessage2_handles[hudmessage2_handle] = true 
        Threads.CreateLoop("hudmessage2"..hudmessage2_handle,0,function(Break)
            
            if hudmessage2_handles[hudmessage2_handle] then 
                DrawNextOrder(hudmessage2_handle)
                DrawText2D(object._text,object._scale,object._x,object._y,math.floor(object._alpha))
            else 
                Break()
            end 
            
            
        end )
    end 
end

local entitymessage_handle = 1
local entitymessage_handles = {}

local entitymessage = function(entity,text,duration,cb)
        
        local coords = GetEntityCoords(entity)
        local model = GetEntityModel(entity)
        local z1,z2 = GetModelDimensions(model)
        local heightz = IsEntityAPed(entity) and 0 or math.max(z1.z,z2.z) 
        local height = GetEntityHeightAboveGround(entity) + heightz
        local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z + height )
        if bool then 
            local object = {}
            object._text = text
            object._x = xper
            object._y = yper
            object._alpha = 0
            object._scale = 15
            local durationIn,durationHold,durationOut
            if durationIn == nil then durationIn = duration end 
            if durationHold == nil then durationHold = 0 end 
            if durationOut == nil then durationOut = duration end 
            durationIn = durationIn / 1000
            durationHold = durationHold / 1000
            durationOut = durationOut / 1000
            if entitymessage_handle > 65530 then entitymessage_handle = 1 end 
            entitymessage_handle = entitymessage_handle + 1
            entitymessage_handles[entitymessage_handle] = true 
            Threads.TweenCFX.to(object,durationIn,{_alpha=255,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entitymessage_handle,cb)
                --Threads.TweenCFX.delayCall(object,durationHold,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entitymessage_handle,cb)
                    Threads.TweenCFX.to(object,durationOut,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entitymessage_handle,cb)
                        entitymessage_handles[entitymessage_handle] = nil
                        if cb then 
                            cb(object)
                        end
                        
                    end ,onCompleteArgs={object,entitymessage_handle,cb}})
                --end ,onCompleteArgs={object,entitymessage_handle,cb}})
                
            end ,onCompleteArgs={object,entitymessage_handle,cb}})

            entitymessage_handles[entitymessage_handle] = entity 
            Threads.CreateLoop("entitymessage"..entitymessage_handle,0,function(Break)
                if entitymessage_handles[entitymessage_handle] then 
                    local coords = GetEntityCoords(entity)
                    
                    local model = GetEntityModel(entity)
                    local z1,z2 = GetModelDimensions(model)
                    local heightz = IsEntityAPed(entity) and 0 or math.max(z1.z,z2.z) 
                    local height = GetEntityHeightAboveGround(entity) + heightz
                    local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z + height )
                    if bool then 
                        object._x,object._y = xper,yper
                    end 
                    DrawNextOrder(entitymessage_handle)
                    DrawText2D(object._text,object._scale,object._x,object._y,math.floor(object._alpha))
                else 
                    Break()
                end 
               
                
            end)
        end 
       
end

local entitymessageend = function(entity,cb)
    for i,v in pairs(entitymessage_handles) do 
        if v == entity then 
            entitymessage_handles[entitymessage_handle] = nil
            break 
        end 
    end 
end



local entityquickmessage_handle = 1
local entityquickmessage_handles = {}

local entityquickmessage = function(entity,text,duration,cb)
        
        local coords = GetEntityCoords(entity)
        local model = GetEntityModel(entity)
        local z1,z2 = GetModelDimensions(model)
        local heightz = IsEntityAPed(entity) and 0 or math.max(z1.z,z2.z) 
        local height = GetEntityHeightAboveGround(entity) + heightz
        local bool,xper,yper = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z + height )
        if bool then 
            local object = {}
            object._text = text
            object._x = xper
            object._y = yper
            object._alpha = 255
            object._scale = 15
            local durationIn,durationHold,durationOut
            if durationIn == nil then durationIn = duration end 
            if durationHold == nil then durationHold = 0 end 
            if durationOut == nil then durationOut = duration end 
            durationIn = durationIn / 1000
            durationHold = durationHold / 1000
            durationOut = durationOut / 1000
            if entityquickmessage_handle > 65530 then entityquickmessage_handle = 1 end 
            entityquickmessage_handle = entityquickmessage_handle + 1
            entityquickmessage_handles[entityquickmessage_handle] = true 
            
            Threads.TweenCFX.to(object,durationIn,{_y = object._y - 0.05,_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entityquickmessage_handle,cb)
                --Threads.TweenCFX.delayCall(object,durationHold,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entityquickmessage_handle,cb)
                    
                    --Threads.TweenCFX.to(object,durationOut,{_alpha=0,ease=Threads.TweenCFX.Ease.LinearNone,onCompleteScope=function(object,entityquickmessage_handle,cb)
                        entityquickmessage_handles[entityquickmessage_handle] = nil
                        if cb then 
                            cb(object)
                        end
                        
                    --end ,onCompleteArgs={object,entityquickmessage_handle,cb}})
                --end ,onCompleteArgs={object,entityquickmessage_handle,cb}})
                
            end ,onCompleteArgs={object,entityquickmessage_handle,cb}})

            entityquickmessage_handles[entityquickmessage_handle] = entity 
            Threads.CreateLoop("entityquickmessage"..entityquickmessage_handle,0,function(Break)
                if entityquickmessage_handles[entityquickmessage_handle] then 
                    DrawNextOrder(entityquickmessage_handle)
                   
                    DrawText2D(object._text,object._scale,object._x,object._y,math.floor(object._alpha))
                else 
                    Break()
                end 
               
            end)
        end 
end

exports('hudmessage', function (...)
    return hudmessage(...)
end )
exports('hudmessage2', function (...)
    return hudmessage2(...)
end )
exports('entityquickmessage', function (...)
    return entityquickmessage(...)
end )
exports('entitymessage', function (...)
    return entitymessage(...)
end )
exports('entitymessageend', function (...)
    return entitymessageend(...)
end )