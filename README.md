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
You can delete any action which is in the loop by Threads.KillActionOfLoop(actionname)
Auto delete and break the while loop when all actions have been killed.

You can create a custom Loop which can be set or get the delay of next loop with the cb.setter or cb.getter
Threads.CreateLoopCustom(actionname,0,function(delay) delay.setter(3000) end)

also you can get the actionname and the total loops when debug by Threads.CreateLoop(actionname,millisecondID,function(name,totalofloops) print(name,totalofloops) end)
or Threads.CreateLoopCustom(actionname,0,function(delay,name,total) print(name,total) delay.setter(3000*math.random()) end)

Threads.xxxxCustom is just different with Threads.xxxx by a setter and getter .
You can also pass a Varname into Threads.xxxxCustom params 4  so that you can using Threads.GetLoopCustom and Threads.SetLoopCustom


[FUNCTIONS]
```
Threads.CreateLoop(actionname,millisecondID,function(name,totalofloops)) or (actionname,function(name,totalofloops)) or (function(name,totalofloops)) -- group all the same millisecond loop (with a name)  into a while true do 
Threads.CreateLoopOnce(actionname,millisecondID,function(name,totalofloops)) or (actionname,function(name,totalofloops)) or (function(name,totalofloops)) --  ignore second call of this. it will group into CreateLoop if a loop is already exist
Threads.KillActionOfLoop(actionname)
Threads.KillLoop(actionname,millisecondID) -- this is a dangerous function.kill a timer also all actions.
Threads.CreateLoopCustom(actionname,defaultmillisecondID,function(varname,name,totalofcustomloops),(varname or keeping empty))  -- just like CreateLoop but with delay.setter and delay.getter
Threads.CreateLoopCustomOnce(actionname,defaultmillisecondID,function(varname,name,totalofcustomloops),(varname or keeping empty if you just want to using s/getter))  -- just like CreateLoop but with delay.setter and delay.getter.Will default using functionhash if the varname is empty.
Threads.KillActionOfLoopCustom(actionname) 
Threads.KillLoopCustom(actionname,millisecondID) -- this is a dangerous function.kill a timer also all actions.
Threads.GetLoopCustom(varname)
Threads.SetLoopCustom(varname,millisecond)
```


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