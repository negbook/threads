Threads = {}
debuglog = false
busyspin = true
Threads_Total = 0
local _CreateThread = CreateThread
local CreateThread = function(...)
    Threads_Total = Threads_Total + 1
    if debuglog then 
    print('CreateThread Total By Threads:'..Threads_Total.." on "..GetCurrentResourceName())
    end 
    return _CreateThread(...)
end 

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
                if _varname and Threads_Custom_VarTimer[_varname] then 
                    vt = Threads_Custom_VarTimer[_varname]
                end 
                Wait(vt>0 and vt or 0)
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    if Threads_Custom_Alive[actiontable[i]] and Threads_Custom_Functions[actiontable[i]] and Threads_Custom_Timers[actiontable[i]] == timer then 
                        local predelaySetter = {setter=setmetatable({},{__call = function(t,data) Threads.SetLoopCustom(_varname,data) end}),getter=function(t,data) return Threads.GetLoopCustom(_varname) end}
                        local delaySetter = predelaySetter
                        Threads_Custom_Functions[actiontable[i]](_varname and delaySetter,actiontable[i],#actiontable or actiontable[i],#actiontable,Threads_Total)
                    else 
                        if Threads_Custom_ActionTables[timer] and Threads_Custom_ActionTables[timer][i] then 
                            table.remove(Threads_Custom_ActionTables[timer] ,i) 
                            if #actiontable == 0 then 
                                Threads.KillLoopCustom(name,timer)
                                return 
                            end 
                        end 
                    end 
				end 
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
    collectgarbage("collect")
    if debuglog then print('threads:KillLoopCustom:'..name,timer) end
end 
Threads.KillActionOfLoopCustom = function(name)
    Threads_Custom_Alive[name] = false 
    Threads_Custom_Once[name] = false 
    if debuglog then print('threads:KillActionOfLoopCustom:'..name) end
end 
Threads.IsActionOfLoopAliveCustom = function(name)
    return Threads_Custom_Alive[name] and true or false 
end 
Threads.IsLoopAliveCustom = function(name)
    return Threads_Custom_Functions[name] and true or false 
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
    collectgarbage("collect")
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
--stable:
local function Threads_IsActionTableCreated(timer) return Threads_ActionTables[timer]  end 
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
                Wait(vt)
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    if Threads_Alive[actiontable[i]] and Threads_Functions[actiontable[i]] and Threads_Timers[actiontable[i]] == timer then 
                        Threads_Functions[actiontable[i]](actiontable[i],#actiontable,Threads_Total)
                    else 
                        if Threads_ActionTables[timer] and Threads_ActionTables[timer][i] then 
                            table.remove(Threads_ActionTables[timer] ,i) 
                            if #actiontable == 0 then 
                                Threads.KillLoop(name,timer)
                                return 
                            end 
                        end 
                    end 
				end 
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
end
Threads.IsActionOfLoopAlive = function(name)
    return Threads_Alive[name] and true or false
end 
Threads.IsLoopAlive = function(name)
    return Threads_Functions[name] and true or false
end 
Threads.KillLoop = function(name,timer)
    for i=1,#Threads_ActionTables[timer] do 
        if Threads_ActionTables[timer][i] == name then 
            table.remove(Threads_ActionTables[timer] ,i) 
        end 
    end 
    Threads_Alive[name] = nil 
    Threads_Functions[name] = nil
    Threads_Timers[name] = nil 
    Threads_ActionTables[timer] = nil	
    Threads_Once[name]  = nil
    collectgarbage("collect")
    if debuglog then print('threads:KillLoop:'..name,timer) end
end 
Threads.KillActionOfLoop = function(name)
    for timer,_name in pairs (Threads_ActionTables) do 
        if _name == name then 
            for i=1,#Threads_ActionTables[timer] do 
                if Threads_ActionTables[timer][i] == name then 
                    table.remove(Threads_ActionTables[timer] ,i) 
                end 
            end 
        end 
    end 
    Threads_Alive[name] = nil 
    Threads_Once[name] = nil 
    collectgarbage("collect")
    if debuglog then print('threads:KillLoop:'..name) end
end 