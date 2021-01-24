# fxserver-threads
Threads utilities for FXServer

[INSTALLATION]

Set it as a dependency in you fxmanifest.lua

```
client_script '@threads/threads.lua'
```

[USAGE]

```
expandWorldtasks = function() 
        ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
        ExpandWorldLimits(10000.0, 12000.0, 30.0)  
end

gametimetasks = function()
	print("GAME TIME:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
end 

othertasks = function()
	print("GAME TIME2:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
end 

Citizen.CreateThread(function()
    Threads.loop(expandWorldtasks,0)
    Threads.loop(gametimetasks,500)
    Threads.loop(othertasks,500)
end)
```

[HOW TO]
```
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
        ExpandWorldLimits(10000.0, 12000.0, 30.0) 
    end 
end 
 >> 
    --Citizen.CreateThread(function()
        --while true do 
            --Citizen.Wait(0)
            expandWorldtasks = function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end 
        --end 
    --end 
    >> 
        expandWorldtasks = function() 
            ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
            ExpandWorldLimits(10000.0, 12000.0, 30.0) 
        end 
        
        Citizen.CreateThread(function()
            Threads.loop(expandWorldtasks,0)
        end)
or
 >> 
    Citizen.CreateThread(function()
        --while true do 
            --Citizen.Wait(0)
            Threads.loop(function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end,0)
        --end 
    end 
    >> 
        Citizen.CreateThread(function()
            Threads.loop(function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end,0)
        end 
```
