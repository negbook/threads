Threads = {}
Threads_Modules = {}
debuglog = false
busyspin = true

Threads_Modules.Tween = true 
Threads_Modules.Arrival = true 
Threads_Modules.Scaleforms = true 
Threads_Modules.Draws = true 

Threads_Custom_Handle = 1
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
                            local preBreaker = function(t,data) Threads.BreakCustom(v) end
                            Threads_Custom_Functions[v](_varname and delaySetter,preBreaker,v,#actiontable or preBreaker,v,#actiontable)
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
    if Threads_Custom_Handle >= 65530 then Threads_Custom_Handle = 1 end 
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
    if Threads_Custom_Handle >= 65530 then Threads_Custom_Handle = 1 end 
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
Threads_Handle = 1
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
                            local preBreaker = function(t,data) Threads.Break(v) end
                           
                            Threads_Functions[v](preBreaker,v,#actiontable)
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
    if Threads_Handle >= 65530 then Threads_Handle = 1 end 
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
    if Threads_Handle >= 65530 then Threads_Handle = 1 end 
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
Threads.Break = function(name)
    if Threads.IsActionOfLoopAlive(name) then Threads.KillActionOfLoop(name) end 
end 
Threads.BreakCustom = function(name)
    if Threads.IsActionOfLoopAliveCustom(name) then Threads.KillActionOfLoopCustom(name) end 
end 

if Threads_Modules.Tween then 
--Tween:
local TweenCFX = {}

    
    local Back = {}
        Back.easeIn = function (t, b, c, d, s)
           if not s then 
              s = 1.70158;
           end
           t = t / d
           return c * (t) * t * ((s + 1) * t - s) + b;
        end 
        Back.easeOut = function (t, b, c, d, s)
           if not s then 
              s = 1.70158;
           end 
           t = t / d - 1
           return c * ((t) * t * ((s + 1) * t + s) + 1) + b;
        end
        Back.easeInOut = function (t, b, c, d, s)
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
    local Circ = {}
        Circ.easeIn = function (t, b, c, d)
           t = t / d
           return (- c) * (math.sqrt(1 - (t) * t) - 1) + b;
        end
        Circ.easeOut = function (t, b, c, d)
           t = t / d - 1
           return c * math.sqrt(1 - (t) * t) + b;
        end
        Circ.easeInOut = function (t, b, c, d)
           t = t / (d / 2)
           if((t) < 1) then 
              return (- c) / 2 * (math.sqrt(1 - t * t) - 1) + b;
           end
           t = t - 2
           return c / 2 * (math.sqrt(1 - (t) * t) + 1) + b;
        end
    local Cubic = {}
        Cubic.easeIn = function (t, b, c, d)
           t = t / d
           return c * (t) * t * t + b;
        end 
        Cubic.easeOut = function (t, b, c, d)
           t = t / d - 1
           return c * ((t) * t * t + 1) + b;
        end
        Cubic.easeInOut = function (t, b, c, d)
           t = t / (d / 2)
           if((t) < 1) then
              return c / 2 * t * t * t + b;
           end
           t = t - 2
           return c / 2 * ((t) * t * t + 2) + b;
        end
    local Linear = {}
        Linear._temp_ = function (t, b, c, d)
           return c * t / d + b;
        end 
        Linear.easeNone = Linear._temp_
        Linear.easeIn = Linear._temp_
        Linear.easeOut = Linear._temp_
        Linear.easeInOut = Linear._temp_
    local Quad = {}
       Quad.easeIn = function (t, b, c, d)
          t = t / d
          return c * (t) * t + b;
       end
       Quad.easeOut = function (t, b, c, d)
          t = t / d
          return (- c) * (t) * (t - 2) + b;
       end
       Quad.easeInOut = function (t, b, c, d)
          t = t / (d / 2)
          if((t) < 1) then 
             return c / 2 * t * t + b;
          end
          t = t - 1
          return (- c) / 2 * ((t) * (t - 2) - 1) + b;
       end
    local Quart = {}
       Quart.easeIn = function (t, b, c, d)
          t = t / d
          return c * (t) * t * t * t + b;
       end
       Quart.easeOut = function (t, b, c, d)
          t = t / d - 1
          return (- c) * ((t) * t * t * t - 1) + b;
       end
       Quart.easeInOut = function (t, b, c, d)
          t = t / (d / 2)
          if((t) < 1) then 
             return c / 2 * t * t * t * t + b;
          end
          t = t - 2
          return (- c) / 2 * ((t) * t * t * t - 2) + b;
       end
    local Sine = {}
       Sine.easeIn = function (t, b, c, d)
          return (- c) * math.cos(t / d * 1.5707963267948966) + c + b;
       end
       Sine.easeOut = function (t, b, c, d)
          return c * math.sin(t / d * 1.5707963267948966) + b;
       end
       Sine.easeInOut = function (t, b, c, d)
          return (- c) / 2 * (math.cos(3.141592653589793 * t / d) - 1) + b;
       end
    TweenCFX.Ease = {}
       TweenCFX.Ease.Linear = 1
       TweenCFX.Ease.QuadraticIn = 2
       TweenCFX.Ease.QuadraticOut = 3
       TweenCFX.Ease.QuadraticInout = 4
       TweenCFX.Ease.CubicIn = 5
       TweenCFX.Ease.CubicOut = 6
       TweenCFX.Ease.CubicInout = 7
       TweenCFX.Ease.QuarticIn = 8
       TweenCFX.Ease.QuarticOut = 9
       TweenCFX.Ease.QuarticInout = 10
       TweenCFX.Ease.SineIn = 11;
       TweenCFX.Ease.SineOut = 12
       TweenCFX.Ease.SineInout = 13
       TweenCFX.Ease.BackIn = 14
       TweenCFX.Ease.BackOut = 15
       TweenCFX.Ease.BackInout = 16
       TweenCFX.Ease.CircularIn = 17
       TweenCFX.Ease.CircularOut = 18
       TweenCFX.Ease.CircularInout = 19
       TweenCFX.Ease.EaseTable = {
           Linear.easeNone,
           Quad.easeIn,
           Quad.easeOut,
           Quad.easeInOut,
           Cubic.easeIn,
           Cubic.easeOut,
           Cubic.easeInOut,
           Quart.easeIn,
           Quart.easeOut,
           Quart.easeInOut,
           Sine.easeIn,
           Sine.easeOut,
           Sine.easeInOut,
           Back.easeIn,
           Back.easeOut,
           Back.easeInOut,
           Circ.easeIn,
           Circ.easeOut,
           Circ.easeInOut
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
       this.ease = TweenCFX.Ease.EaseTable[TweenCFX.Ease.Linear];
       this.props = {};
       if _isATween then 
          for abbr,v in pairs (this.vars) do
             if abbr and type(this.object[abbr]) == 'number' and abbr~="ease" and abbr~="delay" then 
                table.insert(this.props,{abbr,this.object[abbr],this.vars[abbr]});
             end
          end
          if this.vars.ease then 
             if(type(this.vars.ease) == "number") then 
                this.ease = TweenCFX.Ease.EaseTable[this.vars.ease];
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
       if not TweenCFX.tweenDepth or TweenCFX.tweenDepth > 65530 then TweenCFX.tweenDepth = 1 end 
       TweenCFX.tweenDepth =  TweenCFX.tweenDepth + 1
       this.object.TweenRef = TweenCFX.TweenRef(this.Thread,this.props,this.vars);
       this.Thread.threadid = Threads.CreateLoopOnce("TSLContainerThread"..TweenCFX.tweenDepth,0,function()
            if this.Thread.onUpdate then 
                this.Thread.onUpdate(this.Thread.tweenUpdateRef )
            end 
       end );
       
       
       return this
    end })
    
Threads.TweenCFX = TweenCFX.Tween
Threads.TweenCFX.Ease = TweenCFX.Ease

end 


if GetResourceState("threads")=="started" or GetResourceState("threads")=="starting" then 
    local isClient = function() return not IsDuplicityVersion() end 
    local isServer = function() return IsDuplicityVersion() end 
    if isClient() then --client
        if Threads_Modules.Arrival then 
            Threads.AddPositions = function(actionname,datas,rangeorcb,_cb)
                exports.threads:AddPositions(actionname,datas,rangeorcb,_cb)
            end 

            Threads.AddPosition = function(actionname,data,rangeorcb,_cb)
                exports.threads:AddPosition(actionname,data,rangeorcb,_cb)
            end 
        end 
        if Threads_Modules.Scaleforms then 
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
                
                local handle = exports.threads:CallScaleformMovie(scaleformName) 
                local inputfunction = function(sfunc) PushScaleformMovieFunction(handle,sfunc) end
                if GetCurrentResourceName() ~= this.scriptName then 
                    if not ThisScriptsScaleforms[scaleformName] then 
                        ThisScriptsScaleforms[scaleformName] = true 
                        local num = Threads.Scaleforms.GetTotal()
                        if num > 0 then 
                            print("Threads:Drawing "..num.." Scaleforms are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                        end 
                    end 
                end 
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
            
            if GetCurrentResourceName() == this.scriptName and not IsDuplicityVersion() then 
                
                    CreateThread(function()
                        if Threads.Scaleforms.GetTotal and exports.threads:GetTotal() > 0 then 
                            while true do 
                                local num = exports.threads:GetTotal()
                                if num > 0 then 
                                    print("Threads:Drawing "..num.." Scaleforms are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                                end 
                                Wait(60000)
                            end 
                            return 
                        end 
                        return
                    end)
                
            end 
        end 
        if Threads_Modules.Draws then 
            Threads.Draws = {}
            Threads.Draws.PositionText = function(text,coords,duration,cb)
                exports.threads:positiontext(text,coords,duration,cb)
            end 
        end 
    elseif isServer() then 
        
    end 
else 
    print("Threads:Due to local sciprts,modules ")
    local isClient = function() return not IsDuplicityVersion() end 
    local isServer = function() return IsDuplicityVersion() end 
    if isClient() then --client
        print("Arrial/Scaleforms/Draws is being localed with same usage.")
        if Threads_Modules.Arrival then  
            Threads.Arrival_Local = {}
            Threads.Arrival_Local.zonedata_full = {}
            Threads.Arrival_Local.currentzonedata = {}


            Threads.Arrival_Local.ped = nil
            Threads.Arrival_Local.pedcoords = vector3(0.0,0.0,0.0)
            Threads.Arrival_Local.pedzone = ''
            Threads.Arrival_Local.debuglog = true


            Threads.Arrival_Local.AddPositions = function (actionname,datas,rangeorcb,_cb)
                local fntotable = function(fn) return setmetatable({},{__index=function(t,k) return 'isme' end ,__call=function(t,...) return fn(...) end })  end 
                local cooked_cb = function(sdata,action)
                    --local name = actionname
                    --local result = {data=datas[sdata.index],data_arrival=sdata,killer=setmetatable({},{__call = function(t,data) if Threads.IsActionOfLoopAlive(name) then Threads.KillActionOfLoop(name) end  end}),spamer={},action=action}
                    --result.spamkiller = result.killer
                    local result = {actionname=actionname,data=datas[sdata.index],data_arrival=sdata,action=action}
                    
                    return _cb(result) 
                end 
                local range,cb = 1.0,cooked_cb
                if rangeorcb and type(rangeorcb)=='number' then 
                    range = rangeorcb 
                else 
                    cb = rangeorcb 
                end 
                local data = Threads.Arrival_Local.ConvertData(datas)  -- to .x .y .z .index 
                local zonelist,zonedata = Threads.Arrival_Local.CollectZoneData(data,range)
                for i,v in pairs (zonedata) do 
                    local zone = v.zone
                    v.arrival = fntotable(cb)
                    v.range = range
                    if not Threads.Arrival_Local.zonedata_full[zone] then Threads.Arrival_Local.zonedata_full[zone]={} end 
                    table.insert(Threads.Arrival_Local.zonedata_full[zone],v)
                end 
                
                if  GetCurrentResourceName() ~= resourceName or Threads.Arrival_Local.debuglog then
                    Threads.CreateLoopCustomOnce('inits',528,function(delay)
                        Threads.Arrival_Local.ped = PlayerPedId()
                        Threads.Arrival_Local.pedcoords = GetEntityCoords(Threads.Arrival_Local.ped)
                        if Threads.Arrival_Local.pedzone ~= Threads.Arrival_Local.GetHashMethod(Threads.Arrival_Local.pedcoords.x,Threads.Arrival_Local.pedcoords.y,Threads.Arrival_Local.pedcoords.z,range) then 
                            local old = Threads.Arrival_Local.pedzone
                            if old and #old>0 then 
                                local zonedatas = Threads.Arrival_Local.zonedata_full[old]
                                if zonedatas and #zonedatas>0 then 
                                    for i=1,#zonedatas do 
                                        local v = zonedatas[i]
                                        local pos = vector3(v.x,v.y,v.z)
                                        local distance = #(pos-Threads.Arrival_Local.pedcoords)
                                        if distance < v.range then
                                            if not v.enter then 
                                                v.enter = true 
                                                if v.arrival then v.arrival(v,'enter') end 
                                            end 
                                            if v.exit~=nil and v.exit == true then 
                                                v.exit = false 
                                            end 
                                            
                                        else 
                                            if v.enter~=nil and v.enter == true then 
                                                v.enter = false 
                                                v.exit = true
                                                if v.arrival then v.arrival(v,'exit') end 
                                            end 
                                            
                                        end 
                                        local k = distance*15 > 3000 and 3000 or distance*15
                                        delay.setter(528+k)
                                    end 
                                end 
                            end 
                        end 
                        Threads.Arrival_Local.pedzone = Threads.Arrival_Local.GetHashMethod(Threads.Arrival_Local.pedcoords.x,Threads.Arrival_Local.pedcoords.y,Threads.Arrival_Local.pedcoords.z,range)
                        local zonedatas = Threads.Arrival_Local.zonedata_full[Threads.Arrival_Local.pedzone]
                        if zonedatas and #zonedatas>0 then 
                            for i=1,#zonedatas do 
                                local v = zonedatas[i]
                                local pos = vector3(v.x,v.y,v.z)
                                local distance = #(pos-Threads.Arrival_Local.pedcoords)
                                if distance < v.range then
                                    if not v.enter then 
                                        v.enter = true 
                                        if v.arrival then v.arrival(v,'enter') end 
                                    end 
                                    if v.exit~=nil and v.exit == true then 
                                        v.exit = false 
                                    end 
                                    
                                else 
                                    if v.enter~=nil and v.enter == true then 
                                        v.enter = false 
                                        v.exit = true
                                        if v.arrival then v.arrival(v,'exit') end 
                                    end 
                                    
                                end 
                                local k = distance*15 > 3000 and 3000 or distance*15
                                delay.setter(528+k)
                            end 
                        end 
                    end)
                end 
            end 

            Threads.Arrival_Local.AddPosition = function (actionname,data,rangeorcb,_cb)
                Threads.Arrival_Local.AddPositions(actionname,{data},rangeorcb,_cb)
            end 

            Threads.Arrival_Local.getnearzones = function(...)
                local _pos = {...}
                if #{...} == 3 then 
                    _pos = vector3(_pos[1],_pos[2],_pos[3])
                else 
                    _pos = _pos[1]
                end 
                local nearzones = {}
                local included = function(zone) 
                    local found = false 
                    for i=1,#nearzones do 
                        if nearzones[i]==zone then 
                            found = true 
                        end 
                    end 
                    return found 
                end 
                
                    local pos = _pos
                local temp_y = 0.0
              
                    pos = GetObjectOffsetFromCoords(pos,0.0, 0.0, temp_y ,0.0)
                    temp_y = temp_y + 8.0
                if not included(GetNameOfZone(pos)) then table.insert(nearzones,GetNameOfZone(pos)) end 
                local pos = Threads.Arrival_Local.pedcoords
                local temp_x = 0.0
                
                    pos = GetObjectOffsetFromCoords(pos.x,pos.y,pos.z,0.0, temp_x, 0.0 ,0.0)
                    temp_x = temp_x + 8.0
               
                if not included(GetNameOfZone(pos)) then table.insert(nearzones,GetNameOfZone(pos)) end 
                local pos = Threads.Arrival_Local.pedcoords
                local temp_y = 0.0

                    pos = GetObjectOffsetFromCoords(pos,0.0, 0.0, temp_y ,0.0)
                    temp_y = temp_y - 8.0
                
                if not included(GetNameOfZone(pos)) then table.insert(nearzones,GetNameOfZone(pos)) end 
                local pos = Threads.Arrival_Local.pedcoords
                local temp_x = 0.0
             
                    pos = GetObjectOffsetFromCoords(pos,0.0, temp_x, 0.0 ,0.0)
                    temp_x = temp_x - 8.0
             
                if not included(GetNameOfZone(pos)) then table.insert(nearzones,GetNameOfZone(pos)) end 
                return nearzones
            end 
            Threads.Arrival_Local.CollectZoneData = function(datatable,range) --vector3 or {x=1.0,y=2.0,z=3.0}
                local isVector3 = type(datatable[1])=='vector3'
                local zonelist = {}
                local zonedata = {}
                local included = function(zone) 
                    local found = false 
                    for i=1,#zonelist do 
                        if zonelist[i] == zone then 
                            found = true 
                            break 
                        end 
                    end 
                    return found
                end 
                
                for i=1,#datatable do 
                    local v = datatable[i]
                    
                    local zone = Threads.Arrival_Local.GetHashMethod(v.x,v.y,v.z,range)
                    table.insert(zonedata,{data=v.data,index=v.index,x=v.x,y=v.y,z=v.z,zone=zone})
                    if not included(zone) then 
                        table.insert(zonelist,zone) 
                    end 
                end 
                
                return zonelist,zonedata
            end 
            Threads.Arrival_Local.ConvertData = function(datatable) 
                local tp = nil
                local result = {}
                local tofloat = function(x) return tonumber(x)+0.0 end 
                if #datatable > 0 then
                    if type(datatable) == 'table' then 
                        local t = datatable[1]
                        if type(t) == 'vector3' then 
                            tp = 3
                            local rt = {}
                            for i=1,#datatable do 
                                table.insert(rt,{x = tofloat(datatable[i].x),y = tofloat(datatable[i].y),z = tofloat(datatable[i].z),index=i,data=datatable})
                            end 
                            result = rt 
                        elseif t.x and t.y and t.z then 
                            tp = 1
                            local rt = {}
                            for i=1,#datatable do 
                                table.insert(rt,{x = tofloat(datatable[i].x),y = tofloat(datatable[i].y),z = tofloat(datatable[i].z),index=i,data=datatable})
                            end 
                            result = rt 
                        elseif #t >=3 then 
                            local found = false 
                            local i = 2 
                            while not found and i+1 <=#t do 
                                local tl,tm,tr = t[i-1],t[i],t[i+1]
                                if tl and tm and tr then 
                                    if type(tl) == 'number' and type(tm) == 'number' and type(tr) == 'number' then 
                                        if math.type(tl) == 'float' and math.type(tm) == 'float' and math.type(tr) == 'float' then 
                                            tp = 2
                                            found = true 
                                            local rt = {}
                                            for idx=1,#datatable do 
                                                table.insert(rt,{x = tofloat(tl) , y = tofloat(tm) , z = tofloat(tr),index=idx,data=datatable})
                                            end 
                                            result = rt 
                                        else 
                                            found = false 
                                            --error('data style not supported',2)
                                        end 
                                    end 
                                else 
                                    found = false 
                                    --error('data style not supported',2)
                                end 
                                i = i + 1
                            end 
                        end 
                    else 
                        error('Threads.Arrival_Local.ConvertData(table)',2)
                    end 
                else 
                    error('data style not supported',2)
                end 
                if not tp then 
                    error('data style not supported',2)
                else 
                    
                end 

                return result --3 vector3,2 normal,1 .x .y .z
            end 

            Threads.Arrival_Local.GetHashMethod = function(x,y,z,range)
                local pos = vector3(x,y,z)
                local range = range or 1.0
                local range2 = range*4 > 50.0 and 50.0 or range*4
                result = GetNameOfZone(pos) .. tostring(math.floor(GetHeightmapTopZForArea(pos.x-range,pos.y-range,pos.x+range,pos.y+range))) .. tostring(math.floor(GetHeightmapBottomZForArea(pos.x-range*2,pos.y-range*2,pos.x+range*2,pos.y+range*2))) .. tostring(math.floor(GetHeightmapBottomZForArea(pos.x-range2,pos.y-range2,pos.x+range2,pos.y+range2)))
                
                return result 
            end 

            Threads.AddPositions = function(...) --exports.threads:AddPositions
              Threads.Arrival_Local.AddPositions(...)
            end)

            Threads.AddPosition = function(actionname,data,rangeorcb,_cb)  --exports.threads:AddPosition
              Threads.Arrival_Local.AddPosition(actionname,data,rangeorcb,_cb)
            end)

        end 
        if Threads_Modules.Scaleforms then 
            Threads.Scaleforms_Local = {}
            Threads.Scaleforms_Local.temp_tasks = {}
            Threads.Scaleforms_Local.Tasks = {}
            Threads.Scaleforms_Local.Handles = {}
            Threads.Scaleforms_Local.Kill = {}
            Threads.Scaleforms_Local.ReleaseTimer = {}
            local loadScaleform = function(scaleformName)
                local loaded = false 
                if HasScaleformMovieLoaded(Threads.Scaleforms_Local.Handles[scaleformName]) then return Threads.Scaleforms_Local.Handles[scaleformName] end 
                Threads.CreateLoad(scaleformName,RequestScaleformMovie,HasScaleformMovieLoaded,function(handle)
                    Threads.Scaleforms_Local.Handles[scaleformName] = handle
                    local count = 0
                    for i,v in pairs(Threads.Scaleforms_Local.Handles) do 
                        count = count + 1
                    end 
                    Threads.Scaleforms_Local.counts = count
                    loaded = Threads.Scaleforms_Local.Handles[scaleformName]
                end)
                while not loaded do Wait(0)
                
                end 
                return loaded
            end 
            Threads.Scaleforms_Local.CallScaleformMovie = function (scaleformName)
                if not Threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(Threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                return Threads.Scaleforms_Local.Handles[scaleformName]
            end 
            Threads.Scaleforms_Local.DrawScaleformMovie = function(scaleformName,...)
                if not Threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(Threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 1 then 
                        Threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if Threads.Scaleforms_Local.Handles[scaleformName] then 
                                SetScriptGfxDrawOrder(ops[#ops])
                                DrawScaleformMovie(Threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                                ResetScriptGfxAlign()
                            else 
                                if Threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    Threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    elseif #ops == 1 then  
                        Threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if Threads.Scaleforms_Local.Handles[scaleformName] then 
                                SetScriptGfxDrawOrder(ops[1])
                                DrawScaleformMovieFullscreen(Threads.Scaleforms_Local.Handles[scaleformName])
                                ResetScriptGfxAlign()
                            else 
                                if Threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    Threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    else
                        Threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if Threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovieFullscreen(Threads.Scaleforms_Local.Handles[scaleformName])
                            else 
                                if Threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    Threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    end 
                 
            end 
            Threads.Scaleforms_Local.DrawScaleformMovieDuration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    Threads.Scaleforms_Local.DrawScaleformMovie(scaleformName,table.unpack(ops))
                    Threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    Threads.CreateLoopOnce("ScaleformDuration"..scaleformName,333,function()
                        if GetGameTimer() >= Threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            Threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            Threads.KillActionOfLoop("ScaleformDuration"..scaleformName,333);
                        end 
                    end)
                end)
            end
            Threads.Scaleforms_Local.EndScaleformMovie = function (scaleformName)
                if not Threads.Scaleforms_Local.Handles[scaleformName] then 
                else 
                    SetScaleformMovieAsNoLongerNeeded(Threads.Scaleforms_Local.Handles[scaleformName])
                    Threads.Scaleforms_Local.Handles[scaleformName] = nil
                   
                end 
            end
            Threads.Scaleforms_Local.DrawScaleformMoviePosition = function (scaleformName,...)
                if not Threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(Threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 0 then 
                        Threads.CreateLoopOnce('scaleforms3d:draw'..scaleformName,0,function()
                            if Threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovie_3d(Threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                            else 
                                if Threads.IsActionOfLoopAlive("scaleforms3d:draw"..scaleformName) then 
                                    Threads.KillActionOfLoop("scaleforms3d:draw"..scaleformName);
                                end 
                            end 
                        end)
                    end 
                 
            end 
            Threads.Scaleforms_Local.DrawScaleformMoviePositionDuration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    Threads.Scaleforms_Local.DrawScaleformMoviePosition(scaleformName,table.unpack(ops))
                    Threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    Threads.CreateLoopOnce("ScaleformDuration3d"..scaleformName,333,function()
                        if GetGameTimer() >= Threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            Threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            Threads.KillActionOfLoop("ScaleformDuration3d"..scaleformName,333);
                        end 
                    end)
                end)
            end
            Threads.Scaleforms_Local.DrawScaleformMoviePosition2 = function (scaleformName,...)
                if not Threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(Threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 0 then 
                        Threads.CreateLoopOnce('scaleforms3d2:draw'..scaleformName,0,function()
                            if Threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovie_3dSolid(Threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                            else 
                                if Threads.IsActionOfLoopAlive("scaleforms3d2:draw"..scaleformName) then 
                                    Threads.KillActionOfLoop("scaleforms3d2:draw"..scaleformName);
                                end 
                            end 
                        end)
                    end 
                 
            end 
            Threads.Scaleforms_Local.DrawScaleformMoviePosition2Duration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    Threads.Scaleforms_Local.DrawScaleformMoviePosition2(scaleformName,table.unpack(ops))
                    Threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    Threads.CreateLoopOnce("ScaleformDuration3d2"..scaleformName,333,function()
                        if GetGameTimer() >= Threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            Threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            Threads.KillActionOfLoop("ScaleformDuration3d2"..scaleformName,333);
                        end 
                    end)
                end)
            end
            Threads.Scaleforms.Call = function(scaleformName,cb) 
                
                local handle = Threads.Scaleforms_Local.CallScaleformMovie(scaleformName) 
                local inputfunction = function(sfunc) PushScaleformMovieFunction(handle,sfunc) end
                if GetCurrentResourceName() ~= this.scriptName then 
                    if not ThisScriptsScaleforms[scaleformName] then 
                        ThisScriptsScaleforms[scaleformName] = true 
                        local num = Threads.Scaleforms.GetTotal()
                        if num > 0 then 
                          print(GetCurrentResourceName()..":Drawing "..num.." Scaleforms are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                        end 
                    end 
                end 
                cb(inputfunction,SendScaleformValues,PopScaleformMovieFunctionVoid,handle)
            end
            Threads.Scaleforms.Draw = function(scaleformName,...)
                Threads.Scaleforms_Local.DrawScaleformMovie(scaleformName,...)
            end
            Threads.Scaleforms.DrawDuration = function(scaleformName,duration,...)
                Threads.Scaleforms_Local.DrawScaleformMovieDuration(scaleformName,duration,...)
            end
            Threads.Scaleforms.End = function(scaleformName)
                Threads.Scaleforms_Local.EndScaleformMovie(scaleformName)
            end; Threads.Scaleforms.Kill = Threads.Scaleforms.End
            
            Threads.Scaleforms.RequestCallback = function(scaleformName,SfunctionName,...) 
                Threads.Scaleforms_Local.RequestScaleformCallbackAny(scaleformName,SfunctionName,...) 
            end
            
            Threads.Scaleforms.DrawPosition = function(scaleformName,...) 
                Threads.Scaleforms_Local.DrawScaleformMoviePosition(scaleformName,...) 
            end
            Threads.Scaleforms.DrawPosition2 = function(scaleformName,...) 
                Threads.Scaleforms_Local.DrawScaleformMoviePosition2(scaleformName,...) 
            end
            Threads.Scaleforms.DrawPositionDuration = function(scaleformName,duration,...)
                Threads.Scaleforms_Local.DrawScaleformMoviePositionDuration(scaleformName,duration,...)
            end
            Threads.Scaleforms.DrawPosition2Duration = function(scaleformName,duration,...)
                Threads.Scaleforms_Local.DrawScaleformMoviePosition2Duration(scaleformName,duration,...)
            end
        end
    elseif isServer() then 
    
    end 
end 


