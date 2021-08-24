local threads = {}
Threads = threads
threads.Modules = {}
debuglog = false
busyspin = true
threads.Modules.Tween = true 
threads.Modules.Arrival = true 
threads.Modules.Scaleforms = true 
threads.Modules.Draws = true 
threads.Custom_Handle = 1
threads.Custom_Handles = {}
threads.Custom_Alive = {}
threads.Custom_Timers = {}
threads.Custom_VarTimer = {}
threads.Custom_Functions = {}
threads.Custom_Once = {}
threads.Custom_ActionTables = {}
function threads.Custom_IsActionTableCreated(timer) return threads.Custom_ActionTables[timer]  end 
threads.loop_custom = function()error("Outdated",2) end 
local LoopItCustom = function(_name,_timer,_func,_varname)
    if threads.Custom_Once[_name] then return end 
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some LoopIt timer is nil on "..GetCurrentResourceName())
	end 
    local name = _name or tostring(_func)
    local timer = _timer>=0 and _timer or 0
    local IsThreadCreated = threads.Custom_IsActionTableCreated(timer) --threads.Custom_ActionTables[timer] Exist
	if IsThreadCreated then  
        if threads.Custom_Functions[name] then 
            print('[Warning]threads'..name..' is doubly and replaced')  
        end 
        threads.Custom_Alive[name] = true 
        threads.Custom_Functions[name] = _func
        threads.Custom_Timers[name] = timer 
        table.insert(threads.Custom_ActionTables[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if threads.Custom_Functions[name] then 
            print('[Warning]threads'..name..' is doubly and replaced')  
        end 
        threads.Custom_Alive[name] = true 
        threads.Custom_Functions[name] = _func
        threads.Custom_Timers[name] = timer 
        threads.Custom_ActionTables[timer] = {}	
		local actiontable = threads.Custom_ActionTables[timer] 
        local vt = timer
		table.insert(threads.Custom_ActionTables[timer] , name)
		CreateThread(function() 
			local loop;loop = function()
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    local function this()
                    local v = actiontable[i]
                        if threads.Custom_Alive[v] and threads.Custom_Functions[v] and threads.Custom_Timers[v] == timer then 
                            local predelaySetter = {setter=setmetatable({},{__call = function(t,data) threads.SetLoopCustom(_varname,data) end}),getter=function(t,data) return threads.GetLoopCustom(_varname) end}
                            local delaySetter = predelaySetter
                            local preBreaker = function(t,data) threads.BreakCustom(v) end
                            threads.Custom_Functions[v](_varname and delaySetter,preBreaker,v,#actiontable or preBreaker,v,#actiontable)
                        else 
                            if actiontable and actiontable[i] then 
                                table.remove(actiontable ,i) 
                                if #actiontable == 0 then 
                                    threads.KillLoopCustom(name,timer)
                                    return 
                                end 
                            end 
                        end 
                    end 
                    this()
				end 
                if _varname and threads.Custom_VarTimer[_varname] then 
                    vt = threads.Custom_VarTimer[_varname]
                end 
                SetTimeout(vt>0 and vt or 0,loop)
            end 
			loop()
            return 
		end)
	end 
end
--pass Varname into parameters[4] with using threads.SetLoopCustom(Varname,millisecond)/threads.GetLoopCustom(Varname) to set/get the Delay or just using functionhash with setter/getter instead.
threads.CreateLoopCustom = function(...) --actionname,defaulttimer(and ID of timer.will stack actions into the sameID),func,varname(link a custom name to this timer)
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
        --error("threads.CreateLoopCustom(actionname,defaulttimer,func,varname)") 
        local shash = tostring(debug.getinfo(2,'S').source)..'line'..tostring(debug.getinfo(2).currentline)
        varname = shash
    end 
    threads.Custom_VarTimer[varname] = defaulttimer
    if debuglog then 
        print("Linked VarName '"..varname .. "' to a Custom Timer")
        print('threads(debug):CreateLoopCustom:Varname:'..varname,"actionname: ".. name) 
    end
    LoopItCustom(name,defaulttimer,func,varname)
    if threads.Custom_Handle >= 65530 then threads.Custom_Handle = 1 end 
    threads.Custom_Handle = threads.Custom_Handle + 1
    threads.Custom_Handles[threads.Custom_Handle] = name
    return threads.Custom_Handle
end
threads.CreateLoopOnceCustom = function(...) 
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
    if not threads.Custom_Once[name] then 
    if not varname then 
        --error("threads.CreateLoopCustom(actionname,defaulttimer,func,varname)") 
        local shash = tostring(debug.getinfo(2,'S').source)..'line'..tostring(debug.getinfo(2).currentline)
        varname = shash
    end 
    threads.Custom_VarTimer[varname] = defaulttimer
    if debuglog then 
        print("Linked VarName '"..varname .. "' to a Custom Timer")
        print('threads(debug):CreateLoopOnceCustom:Varname:'..varname,"actionname: ".. name) 
    end
        if debuglog then print('threads(debug):CreateLoopOnce:CreateThread:'..defaulttimer, name) end
        LoopItCustom(name,defaulttimer,func,varname)
        threads.Custom_Once[name] = true 
    end 
    if threads.Custom_Handle >= 65530 then threads.Custom_Handle = 1 end 
    threads.Custom_Handle = threads.Custom_Handle + 1
    threads.Custom_Handles[threads.Custom_Handle] = name
    return threads.Custom_Handle
end
threads.CreateLoopCustomOnce =  threads.CreateLoopOnceCustom
threads.GetLoopCustom = function(varname)
    if not threads.Custom_VarTimer[varname] then error("VarTimer not found.Make sure set varname in the last of threads.CreateLoopCustom(actionname,defaulttimer,func,varname)",2) end 
    return threads.Custom_VarTimer[varname]
end 
threads.SetLoopCustom = function(varname,totimer)
    if not threads.Custom_VarTimer[varname] then error("VarTimer not found.Make sure set varname in the last of threads.CreateLoopCustom(actionname,defaulttimer,func,varname)",2) end 
    threads.Custom_VarTimer[varname] = totimer 
end 
threads.KillLoopCustom = function(name,timer)
    threads.Custom_Alive[name] = nil 
    threads.Custom_Functions[name] = nil
    threads.Custom_Timers[name] = nil 
    threads.Custom_ActionTables[timer] = nil	
    threads.Custom_Once[name]  = nil
    if debuglog then print('threads(debug):KillLoopCustom:'..name,timer) end
end 
threads.KillActionOfLoopCustom = function(name)
    for timer,_name in pairs (threads.Custom_ActionTables) do 
        if _name == name then 
            for i=1,#threads.Custom_ActionTables[timer] do 
                if threads.Custom_ActionTables[timer][i] == name then 
                    table.remove(threads.Custom_ActionTables[timer] ,i) 
                    if #threads.Custom_ActionTables[timer] == 0 then 
                        threads.KillLoopCustom(name,timer)
                        return 
                    end 
                end 
            end 
        end 
    end 
    threads.Custom_Alive[name] = false 
    threads.Custom_Once[name] = false 
    threads.Custom_Functions[name] = nil
    if debuglog then print('threads(debug):KillActionOfLoopCustom:'..name) end
end 
threads.KillHandleOfLoopCustom = function(handle)
    if threads.Custom_Handle[handle] then 
        threads.KillActionOfLoopCustom(threads.Custom_Handle[handle])
    end 
end 
threads.IsActionOfLoopAliveCustom = function(name)
    return threads.Custom_Alive[name] and true or false 
end 
threads.IsLoopAliveCustom = function(name)
    return threads.Custom_Functions[name] and true or false 
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
threads.OnceThread = {}
threads.CreateThreadOnce = function(name,fn)
    if threads.OnceThread[name] then 
        return 
    end 
    threads.OnceThread[name] = true
    CreateThread(fn)
end 
threads.ClearThreadOnce = function(name)
    threads.OnceThread[name] = nil 
end 
threads.CreateLoad = function(thing,loadfunc,checkfunc,cb)
    if debuglog then print('threads(debug):CreateLoad:'..thing) end
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
        if debuglog then print('threads(debug):CreateLoad:'..thing.."Loading Failed") end
    elseif nowcb then  
        cb(nowcb)
    end 
end
--stable:
function threads.IsActionTableCreated(timer) return threads.ActionTables[timer]  end 
threads.Handle = 1
threads.Handles = {}
threads.Alive = {}
threads.Timers = {}
threads.Functions = {}
threads.Once = {}
threads.ActionTables = {}
local LoopIt = function(_name,_timer,_func)
    if threads.Once[_name] then return end 
	if debuglog and not _timer then 
		print("threads(debug):[BAD Hobbits]Some LoopIt timer is nil on "..GetCurrentResourceName())
	end 
    local name = _name or tostring(_func)
    local timer = _timer>=0 and _timer or 0
    local IsThreadCreated = threads.IsActionTableCreated(timer) --threads.ActionTables[timer] Exist
	if IsThreadCreated then  
        if threads.Functions[name] then 
            print('[Warning]threads'..name..' is doubly and replaced')  
        end 
        threads.Alive[name] = true 
        threads.Functions[name] = _func
        threads.Timers[name] = timer 
        table.insert(threads.ActionTables[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if threads.Functions[name] then 
            print('[Warning]threads'..name..' is doubly and replaced')  
        end 
        threads.Alive[name] = true 
        threads.Functions[name] = _func
        threads.Timers[name] = timer 
        threads.ActionTables[timer] = {}	
		local actiontable = threads.ActionTables[timer] 
        local vt = timer
		table.insert(threads.ActionTables[timer] , name)
		CreateThread(function() 
			local loop;loop = function()
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    local function this()
                        local v = actiontable[i]
                        if threads.Alive[v] and threads.Functions[v] and threads.Timers[v] == timer then 
                            local preBreaker = function(t,data) threads.Break(v) end
                            threads.Functions[v](preBreaker,v,#actiontable)
                        else 
                            if actiontable and actiontable[i] then 
                                table.remove(actiontable ,i) 
                                if #actiontable == 0 then 
                                    threads.KillLoop(name,timer)
                                    return 
                                end 
                            end 
                        end 
                    end 
                    this()
				end 
                SetTimeout(vt,loop)
            end 
			loop()
            return 
		end)
	end 
end
threads.CreateLoop = function(...) 
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
    if debuglog then print('threads(debug):CreateLoop:CreateThread:'..timer, name) end
    LoopIt(name,timer,func)
    if threads.Handle >= 65530 then threads.Handle = 1 end 
    threads.Handle = threads.Handle + 1
    threads.Handles[threads.Handle] = name
    return threads.Handle
end
threads.CreateLoopOnce = function(...) 
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
    if not threads.Once[name] then 
        if debuglog then print('threads(debug):CreateLoopOnce:CreateThread:'..timer, name) end
        LoopIt(name,timer,func)
        threads.Once[name] = true 
    end 
    if threads.Handle >= 65530 then threads.Handle = 1 end 
    threads.Handle = threads.Handle + 1
    threads.Handles[threads.Handle] = name
    return threads.Handle
end
threads.IsActionOfLoopAlive = function(name)
    return threads.Alive[name] and true or false
end 
threads.IsLoopAlive = function(name)
    return threads.Functions[name] and true or false
end 
threads.KillLoop = function(name,timer)
    threads.Alive[name] = nil 
    threads.Functions[name] = nil
    threads.Timers[name] = nil 
    threads.ActionTables[timer] = nil	
    threads.Once[name]  = nil
    if debuglog then print('threads(debug):KillLoop:'..name,timer) end
end 
threads.KillActionOfLoop = function(name)
    for timer,_name in pairs (threads.ActionTables) do 
        if _name == name then 
            for i=1,#threads.ActionTables[timer] do 
                if threads.ActionTables[timer][i] == name then 
                    table.remove(threads.ActionTables[timer] ,i) 
                    if #threads.ActionTables[timer] == 0 then 
                        threads.KillLoop(name,timer)
                        return 
                    end 
                end 
            end 
        end 
    end 
    threads.Alive[name] = nil 
    threads.Once[name] = nil 
    threads.Functions[name] = nil
    if debuglog then print('threads(debug):KillLoop:'..name) end
end 
threads.KillHandleOfLoop = function(handle)
    if threads.Handles[handle] then 
        threads.KillActionOfLoop(threads.Handles[handle])
    end 
end 
threads.Break = function(name)
    if threads.IsActionOfLoopAlive(name) then threads.KillActionOfLoop(name) end 
end 
threads.BreakCustom = function(name)
    if threads.IsActionOfLoopAliveCustom(name) then threads.KillActionOfLoopCustom(name) end 
end 
if threads.Modules.Tween then 
	--Tween:
	local TweenCFX = {}
	function TweenCFX:TweenRef(_Thread, _props, _vars)
		self.Thread = _Thread
		self.props = _props
		self.vars = _vars
		return self
	end
	local Back = {}
	Back.easeIn = function(t, b, c, d, s)
		if not s then
			s = 1.70158
		end
		t = t / d
		return c * (t) * t * ((s + 1) * t - s) + b
	end
	Back.easeOut = function(t, b, c, d, s)
		if not s then
			s = 1.70158
		end
		t = t / d - 1
		return c * ((t) * t * ((s + 1) * t + s) + 1) + b
	end
	Back.easeInOut = function(t, b, c, d, s)
		if not s then
			s = 1.70158
		end
		t = t / (d * 0.5)
		if t < 1 then
			s = s * 1.525
			return c * 0.5 * (t * t * (((s) + 1) * t - s)) + b
		end
		t = t - 2
		s = s * 1.525
		return c * 0.5 * ((t) * t * (((s) + 1) * t + s) + 2) + b
	end
	local Circ = {}
	Circ.easeIn = function(t, b, c, d)
		t = t / d
		return (-c) * (math.sqrt(1 - (t) * t) - 1) + b
	end
	Circ.easeOut = function(t, b, c, d)
		t = t / d - 1
		return c * math.sqrt(1 - (t) * t) + b
	end
	Circ.easeInOut = function(t, b, c, d)
		t = t / (d / 2)
		if ((t) < 1) then
			return (-c) / 2 * (math.sqrt(1 - t * t) - 1) + b
		end
		t = t - 2
		return c / 2 * (math.sqrt(1 - (t) * t) + 1) + b
	end
	local Cubic = {}
	Cubic.easeIn = function(t, b, c, d)
		t = t / d
		return c * (t) * t * t + b
	end
	Cubic.easeOut = function(t, b, c, d)
		t = t / d - 1
		return c * ((t) * t * t + 1) + b
	end
	Cubic.easeInOut = function(t, b, c, d)
		t = t / (d / 2)
		if ((t) < 1) then
			return c / 2 * t * t * t + b
		end
		t = t - 2
		return c / 2 * ((t) * t * t + 2) + b
	end
	local Linear = {}
	Linear._temp_ = function(t, b, c, d)
		return c * t / d + b
	end
	Linear.easeNone = Linear._temp_
	Linear.easeIn = Linear._temp_
	Linear.easeOut = Linear._temp_
	Linear.easeInOut = Linear._temp_
	local Quad = {}
	Quad.easeIn = function(t, b, c, d)
		t = t / d
		return c * (t) * t + b
	end
	Quad.easeOut = function(t, b, c, d)
		t = t / d
		return (-c) * (t) * (t - 2) + b
	end
	Quad.easeInOut = function(t, b, c, d)
		t = t / (d / 2)
		if ((t) < 1) then
			return c / 2 * t * t + b
		end
		t = t - 1
		return (-c) / 2 * ((t) * (t - 2) - 1) + b
	end
	local Quart = {}
	Quart.easeIn = function(t, b, c, d)
		t = t / d
		return c * (t) * t * t * t + b
	end
	Quart.easeOut = function(t, b, c, d)
		t = t / d - 1
		return (-c) * ((t) * t * t * t - 1) + b
	end
	Quart.easeInOut = function(t, b, c, d)
		t = t / (d / 2)
		if ((t) < 1) then
			return c / 2 * t * t * t * t + b
		end
		t = t - 2
		return (-c) / 2 * ((t) * t * t * t - 2) + b
	end
	local Sine = {}
	Sine.easeIn = function(t, b, c, d)
		return (-c) * math.cos(t / d * 1.5707963267948966) + c + b
	end
	Sine.easeOut = function(t, b, c, d)
		return c * math.sin(t / d * 1.5707963267948966) + b
	end
	Sine.easeInOut = function(t, b, c, d)
		return (-c) / 2 * (math.cos(3.141592653589793 * t / d) - 1) + b
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
	TweenCFX.Ease.SineIn = 11
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
	}
	TweenCFX.Tween = {}
	function TweenCFX.Tween:New(_sourceobject, _duration, _vars, _isATween)
		local this = setmetatable({}, {__index = self})
		this.object = _sourceobject
		this.vars = _vars
		this.duration = _duration * 1000
		this.startTime = GetGameTimer() + (this.vars.delay and this.vars.delay * 1000 or 0)
		this.ease = TweenCFX.Ease.EaseTable[TweenCFX.Ease.Linear]
		this.props = {}
		if _isATween then
			for abbr, v in pairs(this.vars) do
				if abbr and type(this.object[abbr]) == "number" and abbr ~= "ease" and abbr ~= "delay" then
					table.insert(this.props, {abbr, this.object[abbr], this.vars[abbr]})
				end
			end
			if this.vars.ease then
				if (type(this.vars.ease) == "number") then
					this.ease = TweenCFX.Ease.EaseTable[this.vars.ease]
				end
			end
		end
		this.Thread = {}
		this.Thread.removeThread = function()
			if this.Thread.threadid then
				threads.KillHandleOfLoop(this.Thread.threadid)
				this.Thread.threadid = nil
			end
		end
		this.Thread.tweenUpdateRef = this
		this.Thread.onUpdate = function(this)
			TweenCFX.Tween.updateAll(this)
		end

		if not TweenCFX.tweenDepth or TweenCFX.tweenDepth > 65530 then
			TweenCFX.tweenDepth = 1
		end
		TweenCFX.tweenDepth = TweenCFX.tweenDepth + 1
		this.object.TweenRef = TweenCFX:TweenRef(this.Thread, this.props, this.vars)
		this.Thread.threadid =
			threads.CreateLoopOnce(
			"TSLContainerThread" .. TweenCFX.tweenDepth,
			0,
			function()
				if this.Thread.onUpdate then
					this.Thread.onUpdate(this.Thread.tweenUpdateRef)
				end
			end
		)
		return this
	end
	TweenCFX.Tween.updateAll = function(this)
		local timeDiff = GetGameTimer() - this.startTime
		local timeProgressing = timeDiff / this.duration
		timeProgressing = math.min(timeProgressing, 1)
		for i = 1, #this.props do
			if timeProgressing > 0 then
				if this.props[i] and this.props[i][1] and this.props[i][2] and this.props[i][3] then
					this.object[this.props[i][1]] =
						this.ease(timeProgressing, this.props[i][2], this.props[i][3] - this.props[i][2], 1) --t,b,c,d
				end
			end
		end
		if (timeProgressing == 1) then
			for i = 1, #this.props do
				this.object[this.props[i][1]] = this.props[i][3]
			end
			this.Thread.onUpdate = nil
			this.Thread.removeThread()
			if this.vars.onCompleteScope then
				this.vars.onCompleteScope(table.unpack(this.vars.onCompleteArgs))
			end
			return false
		end
	end
	TweenCFX.Tween.removeTween = function(object)
		local obj = object.TweenRef
		if obj and obj.Thread then
			obj.Thread.onUpdate = nil
			obj.Thread.removeThread()
		end
	end
	TweenCFX.Tween.endTween = function(object, forceComplete)
		local obj = object.TweenRef
		if obj then
			for i = 1, #obj.props do
				local info = obj.props[i]
				object[obj.props[info][0]] = obj.props[info][2]
			end
			if (obj.vars.onCompleteScope and forceComplete) then
				obj.vars.onCompleteScope(table.unpack(obj.vars.onCompleteArgs))
			end
			obj.Thread.onUpdate = nil
			obj.Thread.removeThread()
		end
	end
	TweenCFX.Tween.to = function(object, duration, vars)
		TweenCFX.Tween.removeTween(object)
		local newObj = TweenCFX.Tween:New(object, duration, vars, true)
		return newObj
	end
	TweenCFX.Tween.delayCall = function(object, duration, vars)
		TweenCFX.Tween.removeTween(object)
		local newObj = TweenCFX.Tween:New(object, duration, vars, false)
		return newObj
	end

	threads.TweenCFX = TweenCFX.Tween
	threads.TweenCFX.Ease = TweenCFX.Ease

end 

if GetResourceState("threads")=="started" or GetResourceState("threads")=="starting" then 
    local isClient = function() return not IsDuplicityVersion() end 
    local isServer = function() return IsDuplicityVersion() end 
    local RefreshWarning = function()
        AllDrawsTotal = 0
        if threads.Scaleforms.GetScaleformsTotal and exports.threads:GetScaleformsTotal() > 0 then 
            local num = exports.threads:GetScaleformsTotal()
            if num > 0 then 
                AllDrawsTotal = AllDrawsTotal + num
            end 
        end 
        if threads.Draws.GetDrawsTotal and exports.threads:GetDrawsTotal() > 0 then 
            local num = exports.threads:GetDrawsTotal()
            if num > 0 then 
                AllDrawsTotal = AllDrawsTotal + num
            end 
        end 
        if debuglog then   
        print("threads(debug):Drawing "..AllDrawsTotal.." stuffs in the same time will take about "..string.format("0.%02d~0.%02d",AllDrawsTotal,AllDrawsTotal+1) .. "ms")
        end             
    end 
    local AllDrawsTotal = 0
    if isClient() then --client
        if threads.Modules.Arrival then 
            threads.AddPositions = function(actionname,datas,rangeorcb,_cb)
                exports.threads:AddPositions(actionname,datas,rangeorcb,_cb)
            end 
            threads.AddPosition = function(actionname,data,rangeorcb,_cb)
                exports.threads:AddPosition(actionname,data,rangeorcb,_cb)
            end 
        end 
        if threads.Modules.Scaleforms then 
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
            threads.Scaleforms = {}
            if GetCurrentResourceName() ~= this.scriptName then 
                ThisScriptsScaleforms = {}
            end 
            threads.Scaleforms.Call = function(scaleformName,cb) 
                local handle = exports.threads:CallScaleformMovie(scaleformName) 
                local inputfunction = function(sfunc) PushScaleformMovieFunction(handle,sfunc) end
                if GetCurrentResourceName() ~= this.scriptName then 
                    if not ThisScriptsScaleforms[scaleformName] then 
                        ThisScriptsScaleforms[scaleformName] = true 
                        local num = threads.Scaleforms.GetScaleformsTotal()
                        if debuglog and num > 0 then 
                            print("threads(debug):Drawing "..num.." Scaleforms in the same time will take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                            RefreshWarning()
                        end 
                    end 
                end 
                cb(inputfunction,SendScaleformValues,PopScaleformMovieFunctionVoid,handle)
            end
            threads.Scaleforms.Draw = function(scaleformName,...)
                exports.threads:DrawScaleformMovie(scaleformName,...)
            end
            threads.Scaleforms.DrawDuration = function(scaleformName,duration,...)
                exports.threads:DrawScaleformMovieDuration(scaleformName,duration,...)
            end
            threads.Scaleforms.End = function(scaleformName)
                exports.threads:EndScaleformMovie(scaleformName)
            end; threads.Scaleforms.Kill = threads.Scaleforms.End
            AddEventHandler('onResourceStop', function(resourceName)
              if (GetCurrentResourceName() ~= resourceName) then
                return
              end
              --print(this.scriptName,resourceName,GetCurrentResourceName() ,ThisScriptsScaleforms)
              --print('The resource ' .. resourceName .. ' was stopped.')
              if resourceName ~= this.scriptName then 
                  for i,v in pairs( ThisScriptsScaleforms ) do 
                    print(i,v)
                    threads.Scaleforms.End(i)
                  end 
              end 
            end)
            threads.Scaleforms.RequestCallback = function(scaleformName,SfunctionName,...) 
                exports.threads:RequestScaleformCallbackAny(scaleformName,SfunctionName,...) 
            end
            threads.Scaleforms.DrawPosition = function(scaleformName,...) 
                exports.threads:DrawScaleformMoviePosition(scaleformName,...) 
            end
            threads.Scaleforms.DrawPosition2 = function(scaleformName,...) 
                exports.threads:DrawScaleformMoviePosition2(scaleformName,...) 
            end
            threads.Scaleforms.DrawPositionDuration = function(scaleformName,duration,...)
                exports.threads:DrawScaleformMoviePositionDuration(scaleformName,duration,...)
            end
            threads.Scaleforms.DrawPosition2Duration = function(scaleformName,duration,...)
                exports.threads:DrawScaleformMoviePosition2Duration(scaleformName,duration,...)
            end
            threads.Scaleforms.Draw3DSpeical = function(scaleformName,ped,...) 
                exports.threads:DrawScaleformMovie3DSpeical(scaleformName,ped,...) 
            end
            threads.Scaleforms.GetScaleformsTotal = function()
                return exports.threads:GetScaleformsTotal()
            end
        end 
        if threads.Modules.Draws then 
            threads.Draws = {}
            threads.Draws.PositionText = function(text,coords,duration,ispedrelative,font)
                if GetCurrentResourceName() ~= this.scriptName then 
                    local num = threads.Draws.GetDrawsTotal()
                    if debuglog and num > 0 then 
                        print("threads(debug):Drawing "..num.." Draws are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                        RefreshWarning()
                    end 
                end 
                exports.threads:positiontext(text,coords,duration,ispedrelative,font)
            end 
            threads.Draws.PositionMarker = function(coords,rotations,duration,ispedrelative,isground,stylename,vars)
                if GetCurrentResourceName() ~= this.scriptName then 
                    local num = threads.Draws.GetDrawsTotal()
                    if debuglog and num > 0 then 
                        print("threads(debug):Drawing "..num.." Draws are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                        RefreshWarning()
                    end 
                end 
                exports.threads:positionmarker(coords,rotations,duration,ispedrelative,isground,stylename,vars)
            end 
            threads.Draws.GetDrawsTotal = function()
                return exports.threads:GetDrawsTotal()
            end
        end 
        if GetCurrentResourceName() == this.scriptName and not IsDuplicityVersion() then 
            CreateThread(function()
                while true do 
                    RefreshWarning()
                    Wait(60000)
                end 
                return
            end)
        end 
    elseif isServer() then 
    end 
else 
    print("threads:Due to local sciprts,modules ")
    local isClient = function() return not IsDuplicityVersion() end 
    local isServer = function() return IsDuplicityVersion() end 
    if isClient() then --client
        print("Arrial/Scaleforms/Draws is being localed with same usage.")
        if threads.Modules.Scaleforms then 
            threads.Scaleforms_Local = {}
            threads.Scaleforms_Local.temp_tasks = {}
            threads.Scaleforms_Local.Tasks = {}
            threads.Scaleforms_Local.Handles = {}
            threads.Scaleforms_Local.Kill = {}
            threads.Scaleforms_Local.ReleaseTimer = {}
            local loadScaleform = function(scaleformName)
                local loaded = false 
                if HasScaleformMovieLoaded(threads.Scaleforms_Local.Handles[scaleformName]) then return threads.Scaleforms_Local.Handles[scaleformName] end 
                threads.CreateLoad(scaleformName,RequestScaleformMovie,HasScaleformMovieLoaded,function(handle)
                    threads.Scaleforms_Local.Handles[scaleformName] = handle
                    local count = 0
                    for i,v in pairs(threads.Scaleforms_Local.Handles) do 
                        count = count + 1
                    end 
                    threads.Scaleforms_Local.counts = count
                    loaded = threads.Scaleforms_Local.Handles[scaleformName]
                end)
                while not loaded do Wait(0)
                end 
                return loaded
            end 
            threads.Scaleforms_Local.CallScaleformMovie = function (scaleformName)
                if not threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                return threads.Scaleforms_Local.Handles[scaleformName]
            end 
            threads.Scaleforms_Local.DrawScaleformMovie = function(scaleformName,...)
                if not threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 1 then 
                        threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if threads.Scaleforms_Local.Handles[scaleformName] then 
                                SetScriptGfxDrawOrder(ops[#ops])
                                DrawScaleformMovie(threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                                ResetScriptGfxAlign()
                            else 
                                if threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    elseif #ops == 1 then  
                        threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if threads.Scaleforms_Local.Handles[scaleformName] then 
                                SetScriptGfxDrawOrder(ops[1])
                                DrawScaleformMovieFullscreen(threads.Scaleforms_Local.Handles[scaleformName])
                                ResetScriptGfxAlign()
                            else 
                                if threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    else
                        threads.CreateLoopOnce('scaleforms:draw:'..scaleformName,0,function()
                            if threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovieFullscreen(threads.Scaleforms_Local.Handles[scaleformName])
                            else 
                                if threads.IsActionOfLoopAlive('scaleforms:draw:'..scaleformName) then 
                                    threads.KillActionOfLoop('scaleforms:draw:'..scaleformName);
                                end 
                            end 
                        end)
                    end 
            end 
            threads.Scaleforms_Local.DrawScaleformMovieDuration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    threads.Scaleforms_Local.DrawScaleformMovie(scaleformName,table.unpack(ops))
                    threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    threads.CreateLoopOnce("ScaleformDuration"..scaleformName,333,function()
                        if GetGameTimer() >= threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            threads.KillActionOfLoop("ScaleformDuration"..scaleformName,333);
                        end 
                    end)
                end)
            end
            threads.Scaleforms_Local.EndScaleformMovie = function (scaleformName)
                if not threads.Scaleforms_Local.Handles[scaleformName] then 
                else 
                    SetScaleformMovieAsNoLongerNeeded(threads.Scaleforms_Local.Handles[scaleformName])
                    threads.Scaleforms_Local.Handles[scaleformName] = nil
                end 
            end
            threads.Scaleforms_Local.DrawScaleformMoviePosition = function (scaleformName,...)
                if not threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 0 then 
                        threads.CreateLoopOnce('scaleforms3d:draw'..scaleformName,0,function()
                            if threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovie_3d(threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                            else 
                                if threads.IsActionOfLoopAlive("scaleforms3d:draw"..scaleformName) then 
                                    threads.KillActionOfLoop("scaleforms3d:draw"..scaleformName);
                                end 
                            end 
                        end)
                    end 
            end 
            threads.Scaleforms_Local.DrawScaleformMoviePositionDuration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    threads.Scaleforms_Local.DrawScaleformMoviePosition(scaleformName,table.unpack(ops))
                    threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    threads.CreateLoopOnce("ScaleformDuration3d"..scaleformName,333,function()
                        if GetGameTimer() >= threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            threads.KillActionOfLoop("ScaleformDuration3d"..scaleformName,333);
                        end 
                    end)
                end)
            end
            threads.Scaleforms_Local.DrawScaleformMoviePosition2 = function (scaleformName,...)
                if not threads.Scaleforms_Local.Handles[scaleformName] or not HasScaleformMovieLoaded(threads.Scaleforms_Local.Handles[scaleformName]) then 
                    loadScaleform(scaleformName)
                end 
                    local ops = {...}
                    if #ops > 0 then 
                        threads.CreateLoopOnce('scaleforms3d2:draw'..scaleformName,0,function()
                            if threads.Scaleforms_Local.Handles[scaleformName] then 
                                DrawScaleformMovie_3dSolid(threads.Scaleforms_Local.Handles[scaleformName], table.unpack(ops))
                            else 
                                if threads.IsActionOfLoopAlive("scaleforms3d2:draw"..scaleformName) then 
                                    threads.KillActionOfLoop("scaleforms3d2:draw"..scaleformName);
                                end 
                            end 
                        end)
                    end 
            end 
            threads.Scaleforms_Local.DrawScaleformMoviePosition2Duration = function (scaleformName,duration,...)
            local ops = {...}
                local cb = ops[#ops]
                table.remove(ops,#ops)
                CreateThread(function()
                    threads.Scaleforms_Local.DrawScaleformMoviePosition2(scaleformName,table.unpack(ops))
                    threads.Scaleforms_Local.ReleaseTimer[scaleformName] = GetGameTimer() + duration
                    threads.CreateLoopOnce("ScaleformDuration3d2"..scaleformName,333,function()
                        if GetGameTimer() >= threads.Scaleforms_Local.ReleaseTimer[scaleformName] then 
                            threads.Scaleforms_Local.EndScaleformMovie(scaleformName);
                            if type(cb) == 'function' then 
                                cb()
                            end 
                            threads.KillActionOfLoop("ScaleformDuration3d2"..scaleformName,333);
                        end 
                    end)
                end)
            end
            threads.Scaleforms.Call = function(scaleformName,cb) 
                local handle = threads.Scaleforms_Local.CallScaleformMovie(scaleformName) 
                local inputfunction = function(sfunc) PushScaleformMovieFunction(handle,sfunc) end
                if GetCurrentResourceName() ~= this.scriptName then 
                    if not ThisScriptsScaleforms[scaleformName] then 
                        ThisScriptsScaleforms[scaleformName] = true 
                        local num = threads.Scaleforms.GetScaleformsTotal()
                        if debuglog and num > 0 then 
                          print(GetCurrentResourceName()..":Drawing "..num.." Scaleforms are take about "..string.format("0.%02d~0.%02d",num,num+1) .. "ms")
                        end 
                    end 
                end 
                cb(inputfunction,SendScaleformValues,PopScaleformMovieFunctionVoid,handle)
            end
            threads.Scaleforms.Draw = function(scaleformName,...)
                threads.Scaleforms_Local.DrawScaleformMovie(scaleformName,...)
            end
            threads.Scaleforms.DrawDuration = function(scaleformName,duration,...)
                threads.Scaleforms_Local.DrawScaleformMovieDuration(scaleformName,duration,...)
            end
            threads.Scaleforms.End = function(scaleformName)
                threads.Scaleforms_Local.EndScaleformMovie(scaleformName)
            end; threads.Scaleforms.Kill = threads.Scaleforms.End
            threads.Scaleforms.RequestCallback = function(scaleformName,SfunctionName,...) 
                threads.Scaleforms_Local.RequestScaleformCallbackAny(scaleformName,SfunctionName,...) 
            end
            threads.Scaleforms.DrawPosition = function(scaleformName,...) 
                threads.Scaleforms_Local.DrawScaleformMoviePosition(scaleformName,...) 
            end
            threads.Scaleforms.DrawPosition2 = function(scaleformName,...) 
                threads.Scaleforms_Local.DrawScaleformMoviePosition2(scaleformName,...) 
            end
            threads.Scaleforms.DrawPositionDuration = function(scaleformName,duration,...)
                threads.Scaleforms_Local.DrawScaleformMoviePositionDuration(scaleformName,duration,...)
            end
            threads.Scaleforms.DrawPosition2Duration = function(scaleformName,duration,...)
                threads.Scaleforms_Local.DrawScaleformMoviePosition2Duration(scaleformName,duration,...)
            end
        end
    elseif isServer() then 
    end 
end 
