if Citizen and Citizen.CreateThread then
	CreateThread = Citizen.CreateThread
end
if Citizen and Citizen.Wait then
	CWait = Citizen.Wait
end

Threads = {}
tasks = {}
debuglog = true 

Threads.loop = function(func,_timer)
	local timer = _timer or 0
	local actiontable = tasks[timer] or nil 
	if not tasks[timer] then 
		tasks[timer] = {}	
		actiontable = tasks[timer]
		table.insert(actiontable,func)
		CreateThread(function()
			while true do
				CWait(timer)
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