
Threads = {}
Threads_Tasks = {}
Threads_Tasks_Custom = {}
Threads_Once = {}
debuglog = true 




Threads.loop = function(func,_timer, _name)
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop timer is nil on "..GetCurrentResourceName())
	end 
	
    local name = _name or 'default'
    if not Threads_Tasks[name] then Threads_Tasks[name] = {} end -- 新建一個名稱表 'default'
    
    local timer = _timer or 0
    local actiontable = Threads_Tasks[name][timer] or nil 
 
	if actiontable then  
        table.insert(actiontable,func)  -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
        
		Threads_Tasks[name][timer] = {}	
		actiontable = Threads_Tasks[name][timer]
		table.insert(actiontable,func)
        
		Citizen.CreateThread(function() 
			while true do
				for i=1,#actiontable do 
                    actiontable[i]()

				end 
                
                if timer >= 0 then Wait(timer) end -- timer -1 -2 -3... is for Custom Wait but want to group all -1 -2 -3 ... loops together
			end 
		end)
	end 
end

Threads.loop_custom = function(func,_timer, _name)
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop timer is nil on "..GetCurrentResourceName())
	end 
	
    local name = _name or 'default'
    if not Threads_Tasks_Custom[name] then Threads_Tasks_Custom[name] = {} end -- 新建一個名稱表 'default'
    
    local timer = _timer or 0
    local actiontable = Threads_Tasks_Custom[name][timer] or nil 
 
	if actiontable then  
        table.insert(actiontable,func)  -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
        
		Threads_Tasks_Custom[name][timer] = {}	
		actiontable = Threads_Tasks_Custom[name][timer]
		table.insert(actiontable,func)
        
		Citizen.CreateThread(function() 
			while true do
                if actiontable or #actiontable >0 then 
				for i=1,#actiontable do 
                    actiontable[i]()
                    
				end 
                else 
                
                Wait(0)
                end 
			end 
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
    Threads.loop(func,timer,name)
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
        Threads_Once[name] = true
        if debuglog then print('threads:CreateLoopOnce:CreateThread:'..timer, name) end
        Threads.loop(func,timer,name)
    end 
end



Threads.CreateLoopCustom = function(...) 
   
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
        if debuglog then print('threads:CreateLoopCustom:CreateThread:'..timer, name) end
        Threads.loop_custom(func,timer,name)

end


--debug 
if debuglog then 
local thisname = "threads"

Citizen.CreateThread(function()
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