# fxserver-threads
Threads utilities for FXServer

# INSTALLATION

Set it as a dependency in you fxmanifest.lua
Set debuglog = false in threads.lua if you dont want any rubbish message

```
client_script '@threads/threads.lua'
```

It is recommended starting the threads script in resource.cfg
So that you can using Scaleforms and Arrival modules.

# DESCRIPTION

Thread.CreateLoop(actionname,millisecondID,...   make a CreateThread(function while Wait(x) blablabla end end) loop  
Will Group all the same duration actions into one CreateThread
You can delete any action of loop with ```Threads.KillActionOfLoop(actionname)```  
Auto delete and break the while loop when all those actions in that while loop have been killed.  


You can create a custom Loop which can be set or get the delay of next loop with the cb.setter or cb.getter  
```Threads.CreateLoopCustom(actionname,0,function(delay) delay.setter(3000) end)```  
But the Threads.CreateLoopCustom does not group the loops and always create a new CreateThread while loop  
With a setter and getter,Threads.xxxxCustom can be set dynamic wait time for the next loop  .  
You can also pass a Varname into Threads.xxxxCustom params 4  so that you can using Threads.GetLoopCustom and Threads.SetLoopCustom  
to set the wait time in other place   
also you can get the actionname and the total loops if you want to debug something ```Threads.CreateLoop(actionname,millisecondID,function(name,totalofloops) print(name,totalofloops) end)```  
or ```Threads.CreateLoopCustom(actionname,0,function(delay,name,total) print(name,total) delay.setter(3000*math.random()) end)```  
  

```
Threads.CreateLoop
Threads.CreateLoopOnce
Threads.CreateLoopCustom
Threads.CreateLoopOnceCustom
Threads.SetLoopCustom
Threads.GetLoopCustom
```
### EXAMPLE
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
## Modules : Tween  
Tween some properties value of a lua table. It can be tbl.x tbl.y tbl.z tbl.alpha tbl.height tbl.width etc...  
You can Draw it (while wait 0 ) to show how it tween the value like alpha 255 220 190 ... 0  in 3 seconds.    
```
Threads.TweenCFX.removeTween (object)  --cancel a tween
Threads.TweenCFX.endTween (object, forceComplete)  --force to the end of tween
Threads.TweenCFX.to (object, duration, vars)  --from something to the end in the duration time such as alpha
Threads.TweenCFX.delayCall (object, duration, vars) --from something to the end in the duration time such as alpha but not change/tween anything.
```


## Modules : Arrival  
Add positions and callback when you arrived that place. recommanded range <=5.0  
Detect if you arrival somewhere positions.It can be a table array or just a position data.  
When you arrived,callback a data relative to the raw position data.

```
Threads.AddPositions
Threads.AddPosition 
```
[EXAMPLE](https://github.com/negbook/-threads-example-new_banking)  

## Modules : Scaleforms   
When you draw a scaleforms. It will drawing with Threads script.The perfromances is only effected in Threads script.  
So you can directly know how you spent your CPU usage with drawing scaleforms.  
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
