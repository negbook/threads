local TweenCFX = {}

TweenCFX.tweenDepth = 1;
TweenCFX.Back = {}
    TweenCFX.Back.easeIn = function (t, b, c, d, s)
       if not s then 
          s = 1.70158;
       end
       t = t / d
       return c * (t) * t * ((s + 1) * t - s) + b;
    end 
    TweenCFX.Back.easeOut = function (t, b, c, d, s)
       if not s then 
          s = 1.70158;
       end 
       t = t / d - 1
       return c * ((t) * t * ((s + 1) * t + s) + 1) + b;
    end
    TweenCFX.Back.easeInOut = function (t, b, c, d, s)
       if not s then 
          s = 1.70158;
       end 
       t = t / (d * 0.5)
       if t < 1 then 
          s = s * 1.525
          return c * 0.5 * (t * t * (((s) + 1) * t - s)) + b;
       end 
       t = t - 2
       s = s * 1.525
       return c * 0.5 * ((t) * t * (((s) + 1) * t + s) + 2) + b;
    end
TweenCFX.Circ = {}
    TweenCFX.Circ.easeIn = function (t, b, c, d)
       t = t / d
       return (- c) * (math.sqrt(1 - (t) * t) - 1) + b;
    end
    TweenCFX.Circ.easeOut = function (t, b, c, d)
       t = t / d - 1
       return c * math.sqrt(1 - (t) * t) + b;
    end
    TweenCFX.Circ.easeInOut = function (t, b, c, d)
       t = t / (d / 2)
       if((t) < 1) then 
          return (- c) / 2 * (math.sqrt(1 - t * t) - 1) + b;
       end
       t = t - 2
       return c / 2 * (math.sqrt(1 - (t) * t) + 1) + b;
    end
TweenCFX.Cubic = {}
    TweenCFX.Cubic.easeIn = function (t, b, c, d)
       t = t / d
       return c * (t) * t * t + b;
    end 
    TweenCFX.Cubic.easeOut = function (t, b, c, d)
       t = t / d - 1
       return c * ((t) * t * t + 1) + b;
    end
    TweenCFX.Cubic.easeInOut = function (t, b, c, d)
       t = t / (d / 2)
       if((t) < 1) then
          return c / 2 * t * t * t + b;
       end
       t = t - 2
       return c / 2 * ((t) * t * t + 2) + b;
    end
TweenCFX.Linear = {}
    TweenCFX.Linear._temp_ = function (t, b, c, d)
       return c * t / d + b;
    end 
    TweenCFX.Linear.easeNone = TweenCFX.Linear._temp_
    TweenCFX.Linear.easeIn = TweenCFX.Linear._temp_
    TweenCFX.Linear.easeOut = TweenCFX.Linear._temp_
    TweenCFX.Linear.easeInOut = TweenCFX.Linear._temp_
TweenCFX.Quad = {}
   TweenCFX.Quad.easeIn = function (t, b, c, d)
      t = t / d
      return c * (t) * t + b;
   end
   TweenCFX.Quad.easeOut = function (t, b, c, d)
      t = t / d
      return (- c) * (t) * (t - 2) + b;
   end
   TweenCFX.Quad.easeInOut = function (t, b, c, d)
      t = t / (d / 2)
      if((t) < 1) then 
         return c / 2 * t * t + b;
      end
      t = t - 1
      return (- c) / 2 * ((t) * (t - 2) - 1) + b;
   end
TweenCFX.Quart = {}
   TweenCFX.Quart.easeIn = function (t, b, c, d)
      t = t / d
      return c * (t) * t * t * t + b;
   end
   TweenCFX.Quart.easeOut = function (t, b, c, d)
      t = t / d - 1
      return (- c) * ((t) * t * t * t - 1) + b;
   end
   TweenCFX.Quart.easeInOut = function (t, b, c, d)
      t = t / (d / 2)
      if((t) < 1) then 
         return c / 2 * t * t * t * t + b;
      end
      t = t - 2
      return (- c) / 2 * ((t) * t * t * t - 2) + b;
   end
TweenCFX.Sine = {}
   TweenCFX.Sine.easeIn = function (t, b, c, d)
      return (- c) * math.cos(t / d * 1.5707963267948966) + c + b;
   end
   TweenCFX.Sine.easeOut = function (t, b, c, d)
      return c * math.sin(t / d * 1.5707963267948966) + b;
   end
   TweenCFX.Sine.easeInOut = function (t, b, c, d)
      return (- c) / 2 * (math.cos(3.141592653589793 * t / d) - 1) + b;
   end
TweenCFX.Ease = {}
   TweenCFX.Ease.Linear = 0;
   TweenCFX.Ease.QuadraticIn = 1;
   TweenCFX.Ease.QuadraticOut = 2;
   TweenCFX.Ease.QuadraticInout = 3;
   TweenCFX.Ease.CubicIn = 4;
   TweenCFX.Ease.CubicOut = 5;
   TweenCFX.Ease.CubicInout = 6;
   TweenCFX.Ease.QuarticIn = 7;
   TweenCFX.Ease.QuarticOut = 8;
   TweenCFX.Ease.QuarticInout = 9;
   TweenCFX.Ease.SineIn = 10;
   TweenCFX.Ease.SineOut = 11;
   TweenCFX.Ease.SineInout = 12;
   TweenCFX.Ease.BackIn = 13;
   TweenCFX.Ease.BackOut = 14;
   TweenCFX.Ease.BackInout = 15;
   TweenCFX.Ease.CircularIn = 16;
   TweenCFX.Ease.CircularOut = 17;
   TweenCFX.Ease.CircularInout = 18;
   TweenCFX.Ease.EaseTable = {
       TweenCFX.Linear.easeNone,
       TweenCFX.Quad.easeIn,
       TweenCFX.Quad.easeOut,
       TweenCFX.Quad.easeInOut,
       TweenCFX.Cubic.easeIn,
       TweenCFX.Cubic.easeOut,
       TweenCFX.Cubic.easeInOut,
       TweenCFX.Quart.easeIn,
       TweenCFX.Quart.easeOut,
       TweenCFX.Quart.easeInOut,
       TweenCFX.Sine.easeIn,
       TweenCFX.Sine.easeOut,
       TweenCFX.Sine.easeInOut,
       TweenCFX.Back.easeIn,
       TweenCFX.Back.easeOut,
       TweenCFX.Back.easeInOut,
       TweenCFX.Circ.easeIn,
       TweenCFX.Circ.easeOut,
       TweenCFX.Circ.easeInOut
   };

TweenCFX.Tween = setmetatable({
    updateAll = function(this)
       local timeDiff = GetGameTimer() - this.startTime;
       local timeProgressing = timeDiff / this.duration;
       timeProgressing = math.min(timeProgressing,1);
       for i=1,#this.props  do
          if timeProgressing > 0 then 
            if this.props[i] and this.props[i][1] and this.props[i][2] and this.props[i][3] then 
                this.object[this.props[i][1]] = this.ease(timeProgressing,this.props[i][2],this.props[i][3] - this.props[i][2],1);--t,b,c,d
            end 
          end 
       end
       if(timeProgressing == 1) then 
          for i=1,#this.props  do
             this.object[this.props[i][1]] = this.props[i][3];
          end
          this.Thread.onUpdate = nil;
          this.Thread.removeThread();
          if this.vars.onCompleteScope then 
             this.vars.onCompleteScope(table.unpack(this.vars.onCompleteArgs));
          end
          return false;
       end
    end,
    removeTween = function(object)
       local obj = object.TweenRef;
       if obj and obj.Thread then 
          obj.Thread.onUpdate = nil;
          obj.Thread.removeThread();
       end
    end,
    endTween = function(object, forceComplete)
       local obj = object.TweenRef;
       if obj then
          for i=1,#obj.props  do
             local info = obj.props[i]
             object[obj.props[info][0]] = obj.props[info][2];
          end
          if(obj.vars.onCompleteScope and forceComplete) then 
             obj.vars.onCompleteScope(table.unpack(obj.vars.onCompleteArgs));
          end
          obj.Thread.onUpdate = nil;
          obj.Thread.removeThread();
       end
    end,
    to = function(object, duration, vars)
       
       TweenCFX.Tween.removeTween(object);
       local newObj = TweenCFX.Tween(object,duration,vars,true);
       return newObj;
    end,
    delayCall = function(object, duration, vars)
       
       TweenCFX.Tween.removeTween(object);
       local newObj = TweenCFX.Tween(object,duration,vars,false);
       return newObj;
    end 

    },{__call=function(super,_sourceobject, _duration, _vars, _isATween)
   local this = {}
   setmetatable(this,{__index = super})
   this.object = _sourceobject;
   this.vars = _vars;
   this.duration = _duration * 1000;
   this.startTime = GetGameTimer() + (this.vars.delay and this.vars.delay * 1000 or 0);
   this.ease = TweenCFX.Ease.EaseTable[TweenCFX.Ease.Linear+1];
   this.props = {};
   if _isATween then 
      for abbr,v in pairs (this.vars) do
         if abbr and type(this.object[abbr]) == 'number' and abbr~="ease" and abbr~="delay" then 
            table.insert(this.props,{abbr,this.object[abbr],this.vars[abbr]});
         end
      end
      if this.vars.ease then 
         if(type(this.vars.ease) == "number") then 
            this.ease = Ease.EaseTable[this.vars.ease+1];
         end
      end
   end
   this.Thread = {}
   this.Thread.removeThread = function()
      if this.Thread.threadid then 
        Threads.KillHandleOfLoop(this.Thread.threadid);
      end
   end 
   this.Thread.tweenUpdateRef = this;
   this.Thread.onUpdate = function(this)
      TweenCFX.Tween.updateAll(this);
   end
   TweenCFX.TweenRef = setmetatable({},{__call=function(super,_Thread, _props, _vars)
       local this = {}
       setmetatable(this,{__index = super})
       this.Thread = _Thread;
       this.props = _props;
       this.vars = _vars;
       return this
   end })
   
   this.object.TweenRef = TweenCFX.TweenRef(this.Thread,this.props,this.vars);
   this.Thread.threadid = Threads.CreateLoopOnce("TSLContainerThread"..TweenCFX.tweenDepth,0,function()
        if this.Thread.onUpdate then 
            this.Thread.onUpdate(this.Thread.tweenUpdateRef )
        end 
   end );
   if TweenCFX.tweenDepth > 65530 then TweenCFX.tweenDepth = 0 end
   TweenCFX.tweenDepth = TweenCFX.tweenDepth + 1
   return this
end })
