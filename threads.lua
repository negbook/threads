Threads = {}
debuglog = false
busyspin = true

Threads_Custom_Handle = 0
Threads_Custom_Handles = {}
Threads_Custom_Alive = {}
Threads_Custom_Timers = {}
Threads_Custom_VarTimer = {}
Threads_Custom_Functions = {}
Threads_Custom_Once = {}
Threads_Custom_ActionTables = {}
local function Threads_Custom_IsActionTableCreated(timer) return Threads_Custom_ActionTables[timer]  end 
Threads.loop_custom = function()error("Outdated",2) end 
Threads.loop2_custom = function(_name,_timer,_func,_varname)
    if Threads_Custom_Once[_name] then return end 
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop2 timer is nil on "..GetCurrentResourceName())
	end 
    local name = _name or tostring(_func)
    local timer = _timer>=0 and _timer or 0
    local IsThreadCreated = Threads_Custom_IsActionTableCreated(timer) --Threads_Custom_ActionTables[timer] Exist
	if IsThreadCreated then  
        if Threads_Custom_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
        end 
        Threads_Custom_Alive[name] = true 
        Threads_Custom_Functions[name] = _func
        Threads_Custom_Timers[name] = timer 
        table.insert(Threads_Custom_ActionTables[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if Threads_Custom_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
        end 
       
        Threads_Custom_Alive[name] = true 
        Threads_Custom_Functions[name] = _func
        Threads_Custom_Timers[name] = timer 
        Threads_Custom_ActionTables[timer] = {}	
		local actiontable = Threads_Custom_ActionTables[timer] 
        local vt = timer
		table.insert(Threads_Custom_ActionTables[timer] , name)
		CreateThread(function() 
			while true do
                
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    local function this()
                    local v = actiontable[i]
                        if Threads_Custom_Alive[v] and Threads_Custom_Functions[v] and Threads_Custom_Timers[v] == timer then 
                            local predelaySetter = {setter=setmetatable({},{__call = function(t,data) Threads.SetLoopCustom(_varname,data) end}),getter=function(t,data) return Threads.GetLoopCustom(_varname) end}
                            local delaySetter = predelaySetter
                            Threads_Custom_Functions[v](_varname and delaySetter,v,#actiontable or v,#actiontable)
                        else 
                            if actiontable and actiontable[i] then 
                                table.remove(actiontable ,i) 
                                if #actiontable == 0 then 
                                    Threads.KillLoopCustom(name,timer)
                                    return 
                                end 
                            end 
                        end 
                    end 
                    this()
                    
				end 
                if _varname and Threads_Custom_VarTimer[_varname] then 
                    vt = Threads_Custom_VarTimer[_varname]
                end 
                Wait(vt>0 and vt or 0)
            end 
            return 
		end)
	end 
end
--pass Varname into parameters[4] with using Threads.SetLoopCustom(Varname,millisecond)/Threads.GetLoopCustom(Varname) to set/get the Delay or just using functionhash with setter/getter instead.
Threads.CreateLoopCustom = function(...) --actionname,defaulttimer(and ID of timer.will stack actions into the sameID),func,varname(link a custom name to this timer)
    local tbl = {...}
    local length = #tbl
    local func,varname,name,defaulttimer
    if length == 4 then
        name = tbl[1]
        defaulttimer = tbl[2]
        func = tbl[3]
        varname = tbl[4]
    elseif length == 3 then 
        name = tbl[1]
        defaulttimer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        defaulttimer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        defaulttimer = 0
        func = tbl[1]
    end 
    if not varname then 
        --error("Threads.CreateLoopCustom(actionname,defaulttimer,func,varname)") 
        local shash = tostring(debug.getinfo(2,'S').source)..'line'..tostring(debug.getinfo(2).currentline)
        varname = shash
    end 
    Threads_Custom_VarTimer[varname] = defaulttimer
    if debuglog then 
        print("Linked VarName '"..varname .. "' to a Custom Timer")
        print('threads:CreateLoopCustom:Varname:'..varname,"actionname: ".. name) 
    end
    Threads.loop2_custom(name,defaulttimer,func,varname)
    if Threads_Custom_Handle >= 65530 then Threads_Custom_Handle = 0 end 
    Threads_Custom_Handle = Threads_Custom_Handle + 1
    Threads_Custom_Handles[Threads_Custom_Handle] = name
    return Threads_Custom_Handle
end
Threads.CreateLoopOnceCustom = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,varname,name,defaulttimer
    if length == 4 then
        name = tbl[1]
        defaulttimer = tbl[2]
        func = tbl[3]
        varname = tbl[4]
    elseif length == 3 then 
        name = tbl[1]
        defaulttimer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        defaulttimer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        defaulttimer = 0
        func = tbl[1]
    end 
    if not Threads_Custom_Once[name] then 
    if not varname then 
        --error("Threads.CreateLoopCustom(actionname,defaulttimer,func,varname)") 
        local shash = tostring(debug.getinfo(2,'S').source)..'line'..tostring(debug.getinfo(2).currentline)
        varname = shash
    end 
    Threads_Custom_VarTimer[varname] = defaulttimer
    if debuglog then 
        print("Linked VarName '"..varname .. "' to a Custom Timer")
        print('threads:CreateLoopOnceCustom:Varname:'..varname,"actionname: ".. name) 
    end
        if debuglog then print('threads:CreateLoopOnce:CreateThread:'..defaulttimer, name) end
        Threads.loop2_custom(name,defaulttimer,func,varname)
        Threads_Custom_Once[name] = true 
    end 
    if Threads_Custom_Handle >= 65530 then Threads_Custom_Handle = 0 end 
    Threads_Custom_Handle = Threads_Custom_Handle + 1
    Threads_Custom_Handles[Threads_Custom_Handle] = name
    return Threads_Custom_Handle
end
Threads.CreateLoopCustomOnce =  Threads.CreateLoopOnceCustom
Threads.GetLoopCustom = function(varname)
    if not Threads_Custom_VarTimer[varname] then error("VarTimer not found.Make sure set varname in the last of Threads.CreateLoopCustom(actionname,defaulttimer,func,varname)",2) end 
    return Threads_Custom_VarTimer[varname]
end 
Threads.SetLoopCustom = function(varname,totimer)
    if not Threads_Custom_VarTimer[varname] then error("VarTimer not found.Make sure set varname in the last of Threads.CreateLoopCustom(actionname,defaulttimer,func,varname)",2) end 
    Threads_Custom_VarTimer[varname] = totimer 
end 
Threads.KillLoopCustom = function(name,timer)
    Threads_Custom_Alive[name] = nil 
    Threads_Custom_Functions[name] = nil
    Threads_Custom_Timers[name] = nil 
    Threads_Custom_ActionTables[timer] = nil	
    Threads_Custom_Once[name]  = nil
    if debuglog then print('threads:KillLoopCustom:'..name,timer) end
end 
Threads.KillActionOfLoopCustom = function(name)
    for timer,_name in pairs (Threads_Custom_ActionTables) do 
        if _name == name then 
            for i=1,#Threads_Custom_ActionTables[timer] do 
                if Threads_Custom_ActionTables[timer][i] == name then 
                    table.remove(Threads_Custom_ActionTables[timer] ,i) 
                    if #Threads_Custom_ActionTables[timer] == 0 then 
                        Threads.KillLoopCustom(name,timer)
                        return 
                    end 
                end 
            end 
        end 
    end 
    Threads_Custom_Alive[name] = false 
    Threads_Custom_Once[name] = false 
    Threads_Custom_Functions[name] = nil
    if debuglog then print('threads:KillActionOfLoopCustom:'..name) end
end 
Threads.KillHandleOfLoopCustom = function(handle)
    if Threads_Custom_Handle[handle] then 
        Threads.KillActionOfLoopCustom(Threads_Custom_Handle[handle])
    end 
end 
Threads.IsActionOfLoopAliveCustom = function(name)
    return Threads_Custom_Alive[name] and true or false 
end 
Threads.IsLoopAliveCustom = function(name)
    return Threads_Custom_Functions[name] and true or false 
end 


--debug 
if debuglog then 
local thisname = "threads"
CreateThread(function()
	if IsDuplicityVersion() then 
		if GetCurrentResourceName() ~= thisname then 
			print('\x1B[32m[server-utils]\x1B[0m'..thisname..' is used on '..GetCurrentResourceName().." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(GetCurrentResourceName())..'\x1B[0m')
		end 
		RegisterServerEvent(thisname..':log')
		AddEventHandler(thisname..':log', function(strings,sourcename)
			print(strings.." player:"..GetPlayerName(source).." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(sourcename)..'\x1B[0m')
		end)
	else 
		if GetCurrentResourceName() ~= thisname then 
			TriggerServerEvent(thisname..':log','\x1B[32m[client-utils]\x1B[0m'..thisname..'" is used on '..GetCurrentResourceName(),GetCurrentResourceName())
		end 
	end 
end)
end 


Threads_OnceThread = {}
Threads.CreateThreadOnce = function(fn)
    if Threads_OnceThread[tostring(fn)] then 
        return 
    end 
    Threads_OnceThread[tostring(fn)] = true
    CreateThread(fn)
end 
Threads.ClearThreadOnce = function(name)
    Threads_OnceThread[name] = nil 
end 
Threads.CreateLoad = function(thing,loadfunc,checkfunc,cb)
    if debuglog then print('threads:CreateLoad:'..thing) end
    local handle = loadfunc(thing)
    local SinceTime = GetGameTimer()
    local failed = false
    local nowcb = nil     
    while true do 
        if not(checkfunc(thing)) and GetGameTimer() > SinceTime + 1000 then 
            if busyspin then 
            AddTextEntry("TEXT_LOAD", "Loading...(by threads)")
            BeginTextCommandBusyspinnerOn("TEXT_LOAD")
            EndTextCommandBusyspinnerOn(4)
            end 
        end 
        if not(checkfunc(thing)) and GetGameTimer() > SinceTime + 5000 then 
            failed = true 
        end 
        if HasScaleformMovieLoaded ~= checkfunc then 
            if checkfunc(thing) then 
                nowcb = thing 
            end 
        else 
            local handle = loadfunc(thing)
            if checkfunc(handle) then 
                nowcb = handle 
            end 
        end 
        if failed then 
            break 
        elseif nowcb then  
            break
        end 
        Wait(33)
    end 
    if busyspin then 
        BusyspinnerOff()
    end 
    if failed then
        if debuglog then print('threads:CreateLoad:'..thing.."Loading Failed") end
    elseif nowcb then  
        cb(nowcb)
    end 
end
--stable:
local function Threads_IsActionTableCreated(timer) return Threads_ActionTables[timer]  end 
Threads_Handle = 0
Threads_Handles = {}
Threads_Alive = {}
Threads_Timers = {}
Threads_Functions = {}
Threads_Once = {}
Threads_ActionTables = {}
Threads.loop = function()error("Outdated",2) end 
Threads.loop2 = function(_name,_timer,_func)
    if Threads_Once[_name] then return end 
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop2 timer is nil on "..GetCurrentResourceName())
	end 
    local name = _name or tostring(_func)
    local timer = _timer>=0 and _timer or 0
    local IsThreadCreated = Threads_IsActionTableCreated(timer) --Threads_ActionTables[timer] Exist
	if IsThreadCreated then  
        if Threads_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
        end 
        Threads_Alive[name] = true 
        Threads_Functions[name] = _func
        Threads_Timers[name] = timer 
        table.insert(Threads_ActionTables[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if Threads_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
        end 
        Threads_Alive[name] = true 
        Threads_Functions[name] = _func
        Threads_Timers[name] = timer 
        Threads_ActionTables[timer] = {}	
		local actiontable = Threads_ActionTables[timer] 
        local vt = timer
		table.insert(Threads_ActionTables[timer] , name)
		CreateThread(function() 
			while true do
                
                
                if #actiontable == 0 then 
                    return 
                end 
                
				for i=1,#actiontable do 
                    local function this()
                        local v = actiontable[i]
                        if Threads_Alive[v] and Threads_Functions[v] and Threads_Timers[v] == timer then 
                            Threads_Functions[v](v,#actiontable)
                        else 
                            
                            if actiontable and actiontable[i] then 
                                table.remove(actiontable ,i) 
                                if #actiontable == 0 then 
                                    Threads.KillLoop(name,timer)
                                    return 
                                end 
                            end 
                        end 
                    end 
                    this()
                    
				end 
                Wait(vt)
            end 
            return 
		end)
	end 
end
Threads.CreateLoop = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if debuglog then print('threads:CreateLoop:CreateThread:'..timer, name) end
    Threads.loop2(name,timer,func)
    if Threads_Handle >= 65530 then Threads_Handle = 0 end 
    Threads_Handle = Threads_Handle + 1
    Threads_Handles[Threads_Handle] = name
    return Threads_Handle
end
Threads.CreateLoopOnce = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if not Threads_Once[name] then 
        if debuglog then print('threads:CreateLoopOnce:CreateThread:'..timer, name) end
        Threads.loop2(name,timer,func)
        Threads_Once[name] = true 
    end 
    if Threads_Handle >= 65530 then Threads_Handle = 0 end 
    Threads_Handle = Threads_Handle + 1
    Threads_Handles[Threads_Handle] = name
    return Threads_Handle
end
Threads.IsActionOfLoopAlive = function(name)
    return Threads_Alive[name] and true or false
end 
Threads.IsLoopAlive = function(name)
    return Threads_Functions[name] and true or false
end 
Threads.KillLoop = function(name,timer)
    Threads_Alive[name] = nil 
    Threads_Functions[name] = nil
    Threads_Timers[name] = nil 
    Threads_ActionTables[timer] = nil	
    Threads_Once[name]  = nil

    if debuglog then print('threads:KillLoop:'..name,timer) end
end 
Threads.KillActionOfLoop = function(name)
    for timer,_name in pairs (Threads_ActionTables) do 
        if _name == name then 
            for i=1,#Threads_ActionTables[timer] do 
                if Threads_ActionTables[timer][i] == name then 
                    table.remove(Threads_ActionTables[timer] ,i) 
                    if #Threads_ActionTables[timer] == 0 then 
                        Threads.KillLoop(name,timer)
                        return 
                    end 
                end 
            end 
        end 
    end 
    Threads_Alive[name] = nil 
    Threads_Once[name] = nil 
    Threads_Functions[name] = nil
    
    if debuglog then print('threads:KillLoop:'..name) end
end 
Threads.KillHandleOfLoop = function(handle)
    if Threads_Handles[handle] then 
        Threads.KillActionOfLoop(Threads_Handles[handle])
    end 
end 

if GetResourceState("threads")=="started" or GetResourceState("threads")=="starting" then 
    Threads.AddPositions = function(actionname,datas,rangeorcb,_cb)
        exports.threads:AddPositions(actionname,datas,rangeorcb,_cb)
    end 

    Threads.AddPosition = function(actionname,data,rangeorcb,_cb)
        exports.threads:AddPosition(actionname,data,rangeorcb,_cb)
    end 
    
    this = {}
    this.scriptName = "threads"
    SendScaleformValues = function (...)
        local tb = {...}
        for i=1,#tb do
            if type(tb[i]) == "number" then 
                if math.type(tb[i]) == "integer" then
                        ScaleformMovieMethodAddParamInt(tb[i])
                else
                        ScaleformMovieMethodAddParamFloat(tb[i])
                end
            elseif type(tb[i]) == "string" then ScaleformMovieMethodAddParamTextureNameString(tb[i])
            elseif type(tb[i]) == "boolean" then ScaleformMovieMethodAddParamBool(tb[i])
            end
        end 
    end

    Threads.Scaleforms = {}
    if GetCurrentResourceName() ~= this.scriptName then 
    
    ThisScriptsScaleforms = {}
    end 

    AddEventHandler('onResourceStop', function(resourceName)
       
      if (GetCurrentResourceName() ~= resourceName) then
        return
      end
      --print(this.scriptName,resourceName,GetCurrentResourceName() ,ThisScriptsScaleforms)
      --print('The resource ' .. resourceName .. ' was stopped.')
      if resourceName ~= this.scriptName then 
          for i,v in pairs( ThisScriptsScaleforms ) do 
            --print(i,v)
            Threads.Scaleforms.End(i)
          end 
      end 
    end)

    Threads.Scaleforms.Call = function(scaleformName,cb) 
        if GetCurrentResourceName() ~= this.scriptName then 
            ThisScriptsScaleforms[scaleformName] = true 
        end 
        local handle = exports.threads:CallScaleformMovie(scaleformName) 
        local inputfunction = function(sfunc) PushScaleformMovieFunction(handle,sfunc) end
        cb(inputfunction,SendScaleformValues,PopScaleformMovieFunctionVoid,handle)
    end
    Threads.Scaleforms.Draw = function(scaleformName,...)
        exports.threads:DrawScaleformMovie(scaleformName,...)
    end
    Threads.Scaleforms.DrawDuration = function(scaleformName,duration,...)
        exports.threads:DrawScaleformMovieDuration(scaleformName,duration,...)
    end
    Threads.Scaleforms.End = function(scaleformName)
        exports.threads:EndScaleformMovie(scaleformName)
    end; Threads.Scaleforms.Kill = Threads.Scaleforms.End
    
    Threads.Scaleforms.RequestCallback = function(scaleformName,SfunctionName,...) 
        exports.threads:RequestScaleformCallbackAny(scaleformName,SfunctionName,...) 
    end
    
    Threads.Scaleforms.DrawPosition = function(scaleformName,...) 
        exports.threads:DrawScaleformMoviePosition(scaleformName,...) 
    end
    Threads.Scaleforms.DrawPosition2 = function(scaleformName,...) 
        exports.threads:DrawScaleformMoviePosition2(scaleformName,...) 
    end
    Threads.Scaleforms.DrawPositionDuration = function(scaleformName,duration,...)
        exports.threads:DrawScaleformMoviePositionDuration(scaleformName,duration,...)
    end
    Threads.Scaleforms.DrawPosition2Duration = function(scaleformName,duration,...)
        exports.threads:DrawScaleformMoviePosition2Duration(scaleformName,duration,...)
    end

    Threads.Scaleforms.Draw3DSpeical = function(scaleformName,ped,...) 
        exports.threads:DrawScaleformMovie3DSpeical(scaleformName,ped,...) 
    end

    Threads.Scaleforms.GetTotal = function()
        return exports.threads:GetTotal()
    end

    Threads.GetTween = function()
        return exports.threads:GetTween()
    end 
    
    
else 
    print("Threads:Due to local sciprts,modules is disabled.")
end 

