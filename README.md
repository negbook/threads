# fxserver-threads
Threads utilities for FXServer

[INSTALLATION]

Set it as a dependency in you fxmanifest.lua
Set debuglog = false in threads.lua if you dont want any rubbish message

```
client_script '@threads/threads.lua'
```

[DESCRIPTION]

A new Thread.CreateLoop make a CreateThread(function Wait(x) end) loop 
Auto add a action into the while loop Threads.CreateLoop(actionname,millisecondID,...
You can delete any action which is in the loop by ```Threads.KillActionOfLoop(actionname)```
Auto delete and break the while loop when all actions have been killed.

You can create a custom Loop which can be set or get the delay of next loop with the cb.setter or cb.getter
```Threads.CreateLoopCustom(actionname,0,function(delay) delay.setter(3000) end)```

also you can get the actionname and the total loops when debug by ```Threads.CreateLoop(actionname,millisecondID,function(name,totalofloops) print(name,totalofloops) end)```
or ```Threads.CreateLoopCustom(actionname,0,function(delay,name,total) print(name,total) delay.setter(3000*math.random()) end)```

Threads.xxxxCustom is just different with Threads.xxxx by a setter and getter .
You can also pass a Varname into Threads.xxxxCustom params 4  so that you can using Threads.GetLoopCustom and Threads.SetLoopCustom


[EXAMPLE]
```

Threads.CreateLoop("Check",0,function(name)
    print(name)
end)
Threads.CreateLoop("Check2",1000,function(name,total)
    print(name,total)
    Threads.KillActionOfLoop("Check")
end)
Threads.CreateLoop("Check3",3000,function()
    print(9)
end)
Threads.CreateLoopCustom("Check3",3000,function()
    print("hhhh3")
end,"mycar")
Threads.SetLoopCustom("mycar",2000)
Threads.CreateLoopCustom("CheckCustom",3000,function(delay)
    print("hhhh4")
    delay.setter(1500)
end)
Threads.CreateLoopCustom("CheckCustomGetSet",3000,function(delay,name,total)
    print("get:"..name,total,delay.getter())
    delay.setter(100)
    print("get:"..name,total,delay.getter())
end)

```

[Modules : Arrival][EXAMPLE](https://github.com/negbook/-threads-example-new_banking)   
Add positions and callback when you arrived that place. recommanded range <=5.0
```
Threads.AddPositions
Threads.AddPosition 
```

[Modules : Scaleforms]  
```
Threads.Scaleforms.Call
Threads.Scaleforms.Draw
Threads.Scaleforms.DrawDuration
Threads.Scaleforms.End
Threads.Scaleforms.RequestCallback
Threads.Scaleforms.DrawPosition
Threads.Scaleforms.DrawPosition2
Threads.Scaleforms.DrawPositionDuration
Threads.Scaleforms.DrawPosition2Duration
```

