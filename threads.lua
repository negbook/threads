
Threads = {}
tasks = {}
debuglog = true 

Threads.loop = function(func,_timer, _name)
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop timer is nil on "..GetCurrentResourceName())
	end 
	local timer = _timer or 0
    local name = _name or 'default'
    if not tasks[name] then tasks[name] = {} end 
    local actiontable = tasks[name][timer] or nil 
	if not tasks[name][timer] then 
		tasks[name][timer] = {}	
		actiontable = tasks[name][timer]
		table.insert(actiontable,func)
        if debuglog then print('threads:CreateThread:'.._timer, _name) end
		CreateThread(function()
			while true do
				Wait(timer)
				for i=1,#actiontable do 
					actiontable[i]()
				end 
			end 
		end)
	else 
		table.insert(actiontable,func)
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