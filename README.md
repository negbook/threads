# fxserver-threads
Threads utilities for FXServer

[INSTALLATION]

Set it as a dependency in you fxmanifest.lua
Set debuglog = false in threads.lua if you dont want any rubbish message

```
client_script '@threads/threads.lua'
```

[FUNCTIONS]
```
Threads.CreateLoop(actionname,millisecondID,function) or (namestring,cbfunc) or (function) -- group all the same millisecond loop (with a name)  into a while true do 
Threads.CreateLoopOnce(actionname,millisecondID,function) or (namestring,function) or (function) --  ignore second call of this. it will group into CreateLoop if a loop is already exist
Threads.KillActionOfLoop(actionname)
Threads.CreateLoopCustom(actionname,defaultmillisecondID,function(varname,name,totalofloops),(varname or keeping empty))  -- just like CreateLoop but with delay.setter and delay.getter
Threads.CreateLoopCustomOnce(actionname,defaultmillisecondID,function(varname,name,totalofloops),(varname or keeping empty if you just want to using s/getter))  -- just like CreateLoop but with delay.setter and delay.getter.Will default using functionhash if the varname is empty.
Threads.KillActionOfLoopCustom(actionname) 
Threads.GetLoopCustom(varname)
Threads.SetLoopCustom(varname,millisecond)
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
    Threads.CreateLoop(expandWorldtasks)
    Threads.CreateLoop(500,gametimetasks)
    Threads.CreateLoop(500,othertasks)
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
end)
 >> 
    --Citizen.CreateThread(function()
        --while true do 
            --Citizen.Wait(0)
            expandWorldtasks = function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end 
        --end 
    --end )
    >> 
        expandWorldtasks = function() 
            ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
            ExpandWorldLimits(10000.0, 12000.0, 30.0) 
        end 
        
        Citizen.CreateThread(function()
            Threads.CreateLoop(0,expandWorldtasks)
        end)
or
 >> 
    Citizen.CreateThread(function()
        --while true do 
            --Citizen.Wait(0)
            Threads.CreateLoop(function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end)
        --end 
    end )
    >> 
        Citizen.CreateThread(function()
            Threads.CreateLoop(function() 
                ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
                ExpandWorldLimits(10000.0, 12000.0, 30.0) 
            end)
        end )
```

[HOW TO 2]
```

Citizen.CreateThread(function() --SOMEWHERE
    while true do 
        Citizen.Wait(500)
        print("GAME TIME:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
end )
Citizen.CreateThread(function() --SOMEWHERE2
    while true do 
        Citizen.Wait(500)
        print("GAME TIME2:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
end )

 >>
    gametimetasks = function() --SOMEWHERE.lua
        print("GAME TIME:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
    Citizen.CreateThread(function()
            Threads.CreateLoop(500,gametimetasks)
    end )
    othertasks = function() --SOMEWHERE2.lua
        print("GAME TIME2:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
    Citizen.CreateThread(function()
            Threads.CreateLoop(500,othertasks)
    end )
    
or 
    gametimetasks = function() --SOMEWHERE.lua
        print("GAME TIME:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
    othertasks = function() --SOMEWHERE.lua 
        print("GAME TIME2:"..string.format("%0.2d",GetClockHours())..":"..string.format("%0.2d",GetClockMinutes()))
    end 
    Citizen.CreateThread(function() --LAST LINE OF SOMEWHERE.lua 
        Threads.CreateLoop(500,gametimetasks)
        Threads.CreateLoop(500,othertasks)
    end )
```