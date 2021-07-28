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

--Tween:
local TweenCFX = {}

    TweenCFX.tweenDepth = 1;
    TweenCFX.Back = {}
        TweenCFX.Back.easeIn = function (t, b, c, d, s)
           if not s then 
              s = 1.70158;
           end
           t = t / d
           return c * (t) * t * ((s + 1) * t - s) + b;
        end 
        TweenCFX.Back.easeOut = function (t, b, c, d, s)
           if not s then 
              s = 1.70158;
           end 
           t = t / d - 1
           return c * ((t) * t * ((s + 1) * t + s) + 1) + b;
        end
        TweenCFX.Back.easeInOut = function (t, b, c, d, s)
           if not s then 
              s = 1.70158;
           end 
           t = t / (d * 0.5)
           if t < 1 then 
              s = s * 1.525
              return c * 0.5 * (t * t * (((s) + 1) * t - s)) + b;
           end 
           t = t - 2
           s = s * 1.525
           return c * 0.5 * ((t) * t * (((s) + 1) * t + s) + 2) + b;
        end
    TweenCFX.Circ = {}
        TweenCFX.Circ.easeIn = function (t, b, c, d)
           t = t / d
           return (- c) * (math.sqrt(1 - (t) * t) - 1) + b;
        end
        TweenCFX.Circ.easeOut = function (t, b, c, d)
           t = t / d - 1
           return c * math.sqrt(1 - (t) * t) + b;
        end
        TweenCFX.Circ.easeInOut = function (t, b, c, d)
           t = t / (d / 2)
           if((t) < 1) then 
              return (- c) / 2 * (math.sqrt(1 - t * t) - 1) + b;
           end
           t = t - 2
           return c / 2 * (math.sqrt(1 - (t) * t) + 1) + b;
        end
    TweenCFX.Cubic = {}
        TweenCFX.Cubic.easeIn = function (t, b, c, d)
           t = t / d
           return c * (t) * t * t + b;
        end 
        TweenCFX.Cubic.easeOut = function (t, b, c, d)
           t = t / d - 1
           return c * ((t) * t * t + 1) + b;
        end
        TweenCFX.Cubic.easeInOut = function (t, b, c, d)
           t = t / (d / 2)
           if((t) < 1) then
              return c / 2 * t * t * t + b;
           end
           t = t - 2
           return c / 2 * ((t) * t * t + 2) + b;
        end
    TweenCFX.Linear = {}
        TweenCFX.Linear._temp_ = function (t, b, c, d)
           return c * t / d + b;
        end 
        TweenCFX.Linear.easeNone = TweenCFX.Linear._temp_
        TweenCFX.Linear.easeIn = TweenCFX.Linear._temp_
        TweenCFX.Linear.easeOut = TweenCFX.Linear._temp_
        TweenCFX.Linear.easeInOut = TweenCFX.Linear._temp_
    TweenCFX.Quad = {}
       TweenCFX.Quad.easeIn = function (t, b, c, d)
          t = t / d
          return c * (t) * t + b;
       end
       TweenCFX.Quad.easeOut = function (t, b, c, d)
          t = t / d
          return (- c) * (t) * (t - 2) + b;
       end
       TweenCFX.Quad.easeInOut = function (t, b, c, d)
          t = t / (d / 2)
          if((t) < 1) then 
             return c / 2 * t * t + b;
          end
          t = t - 1
          return (- c) / 2 * ((t) * (t - 2) - 1) + b;
       end
    TweenCFX.Quart = {}
       TweenCFX.Quart.easeIn = function (t, b, c, d)
          t = t / d
          return c * (t) * t * t * t + b;
       end
       TweenCFX.Quart.easeOut = function (t, b, c, d)
          t = t / d - 1
          return (- c) * ((t) * t * t * t - 1) + b;
       end
       TweenCFX.Quart.easeInOut = function (t, b, c, d)
          t = t / (d / 2)
          if((t) < 1) then 
             return c / 2 * t * t * t * t + b;
          end
          t = t - 2
          return (- c) / 2 * ((t) * t * t * t - 2) + b;
       end
    TweenCFX.Sine = {}
       TweenCFX.Sine.easeIn = function (t, b, c, d)
          return (- c) * math.cos(t / d * 1.5707963267948966) + c + b;
       end
       TweenCFX.Sine.easeOut = function (t, b, c, d)
          return c * math.sin(t / d * 1.5707963267948966) + b;
       end
       TweenCFX.Sine.easeInOut = function (t, b, c, d)
          return (- c) / 2 * (math.cos(3.141592653589793 * t / d) - 1) + b;
       end
    TweenCFX.Ease = {}
       TweenCFX.Ease.Linear = 0;
       TweenCFX.Ease.QuadraticIn = 1;
       TweenCFX.Ease.QuadraticOut = 2;
       TweenCFX.Ease.QuadraticInout = 3;
       TweenCFX.Ease.CubicIn = 4;
       TweenCFX.Ease.CubicOut = 5;
       TweenCFX.Ease.CubicInout = 6;
       TweenCFX.Ease.QuarticIn = 7;
       TweenCFX.Ease.QuarticOut = 8;
       TweenCFX.Ease.QuarticInout = 9;
       TweenCFX.Ease.SineIn = 10;
       TweenCFX.Ease.SineOut = 11;
       TweenCFX.Ease.SineInout = 12;
       TweenCFX.Ease.BackIn = 13;
       TweenCFX.Ease.BackOut = 14;
       TweenCFX.Ease.BackInout = 15;
       TweenCFX.Ease.CircularIn = 16;
       TweenCFX.Ease.CircularOut = 17;
       TweenCFX.Ease.CircularInout = 18;
       TweenCFX.Ease.EaseTable = {
           TweenCFX.Linear.easeNone,
           TweenCFX.Quad.easeIn,
           TweenCFX.Quad.easeOut,
           TweenCFX.Quad.easeInOut,
           TweenCFX.Cubic.easeIn,
           TweenCFX.Cubic.easeOut,
           TweenCFX.Cubic.easeInOut,
           TweenCFX.Quart.easeIn,
           TweenCFX.Quart.easeOut,
           TweenCFX.Quart.easeInOut,
           TweenCFX.Sine.easeIn,
           TweenCFX.Sine.easeOut,
           TweenCFX.Sine.easeInOut,
           TweenCFX.Back.easeIn,
           TweenCFX.Back.easeOut,
           TweenCFX.Back.easeInOut,
           TweenCFX.Circ.easeIn,
           TweenCFX.Circ.easeOut,
           TweenCFX.Circ.easeInOut
       };

    TweenCFX.Tween = setmetatable({
        updateAll = function(this)
           local timeDiff = GetGameTimer() - this.startTime;
           local timeProgressing = timeDiff / this.duration;
           timeProgressing = math.min(timeProgressing,1);
           for i=1,#this.props  do
              if timeProgressing > 0 then 
                if this.props[i] and this.props[i][1] and this.props[i][2] and this.props[i][3] then 
                    this.object[this.props[i][1]] = this.ease(timeProgressing,this.props[i][2],this.props[i][3] - this.props[i][2],1);--t,b,c,d
                end 
              end 
           end
           if(timeProgressing == 1) then 
              for i=1,#this.props  do
                 this.object[this.props[i][1]] = this.props[i][3];
              end
              this.Thread.onUpdate = nil;
              this.Thread.removeThread();
              if this.vars.onCompleteScope then 
                 this.vars.onCompleteScope(table.unpack(this.vars.onCompleteArgs));
              end
              return false;
           end
        end,
        removeTween = function(object)
           local obj = object.TweenRef;
           if obj and obj.Thread then 
              obj.Thread.onUpdate = nil;
              obj.Thread.removeThread();
           end
        end,
        endTween = function(object, forceComplete)
           local obj = object.TweenRef;
           if obj then
              for i=1,#obj.props  do
                 local info = obj.props[i]
                 object[obj.props[info][0]] = obj.props[info][2];
              end
              if(obj.vars.onCompleteScope and forceComplete) then 
                 obj.vars.onCompleteScope(table.unpack(obj.vars.onCompleteArgs));
              end
              obj.Thread.onUpdate = nil;
              obj.Thread.removeThread();
           end
        end,
        to = function(object, duration, vars)
           
           TweenCFX.Tween.removeTween(object);
           local newObj = TweenCFX.Tween(object,duration,vars,true);
           return newObj;
        end,
        delayCall = function(object, duration, vars)
           
           TweenCFX.Tween.removeTween(object);
           local newObj = TweenCFX.Tween(object,duration,vars,false);
           return newObj;
        end 

        },{__call=function(super,_sourceobject, _duration, _vars, _isATween)
       local this = {}
       setmetatable(this,{__index = super})
       this.object = _sourceobject;
       this.vars = _vars;
       this.duration = _duration * 1000;
       this.startTime = GetGameTimer() + (this.vars.delay and this.vars.delay * 1000 or 0);
       this.ease = TweenCFX.Ease.EaseTable[TweenCFX.Ease.Linear+1];
       this.props = {};
       if _isATween then 
          for abbr,v in pairs (this.vars) do
             if abbr and type(this.object[abbr]) == 'number' and abbr~="ease" and abbr~="delay" then 
                table.insert(this.props,{abbr,this.object[abbr],this.vars[abbr]});
             end
          end
          if this.vars.ease then 
             if(type(this.vars.ease) == "number") then 
                this.ease = Ease.EaseTable[this.vars.ease+1];
             end
          end
       end
       this.Thread = {}
       this.Thread.removeThread = function()
          if this.Thread.threadid then 
            Threads.KillHandleOfLoop(this.Thread.threadid);
            this.Thread.threadid = nil
          end
       end 
       this.Thread.tweenUpdateRef = this;
       this.Thread.onUpdate = function(this)
          TweenCFX.Tween.updateAll(this);
       end
       TweenCFX.TweenRef = setmetatable({},{__call=function(super,_Thread, _props, _vars)
           local this = {}
           setmetatable(this,{__index = super})
           this.Thread = _Thread;
           this.props = _props;
           this.vars = _vars;
           return this
       end })
       
       this.object.TweenRef = TweenCFX.TweenRef(this.Thread,this.props,this.vars);
       this.Thread.threadid = Threads.CreateLoopOnce("TSLContainerThread"..TweenCFX.tweenDepth,0,function()
            if this.Thread.onUpdate then 
                this.Thread.onUpdate(this.Thread.tweenUpdateRef )
            end 
       end );
       if TweenCFX.tweenDepth > 65530 then TweenCFX.tweenDepth = 0 end
       TweenCFX.tweenDepth = TweenCFX.tweenDepth + 1
       return this
    end })
    
Threads.TweenCFX = TweenCFX.Tween
Threads.TweenCFX.Ease = TweenCFX.Ease

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
    
else 
    print("Threads:Due to local sciprts,modules ")
    print("Arrial/Scaleforms is disabled.")
end 


