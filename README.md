# fxserver-async
Threads utilities for FXServer

[INSTALLATION]

Set it as a dependency in you __resource.lua

```
server_script '@threads/threads.lua'
```

[USAGE]

```
expandWorldtasks = function() 
		ExpandWorldLimits( -9000.0, -11000.0, 30.0 )  
        ExpandWorldLimits(10000.0, 12000.0, 30.0)  
end

CreateThread(function()
    Threads.loop(expandWorldtasks,0)
end)
