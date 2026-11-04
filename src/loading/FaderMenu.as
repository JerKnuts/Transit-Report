package
{
   import Shared.AS3.IMenu;
   import Shared.GlobalFunc;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.geom.Matrix;
   import flash.display.MovieClip;
   import flash.display.Loader;
   import flash.display.Bitmap;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;

   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import scaleform.gfx.Extensions;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol9")]
   public class FaderMenu extends IMenu
   {
      
      public var BGSCodeObj:Object;
      
      public var FadeRect_mc:MovieClip;
      
      public var SpinnerIcon_mc:MovieClip;
      
      private var fStartAlpha:Number;
      
      private var fEndAlpha:Number;
      
      private var fFadeDuration:Number;
      
      private var fFadeElapsedSecs:Number;
      
      private var fTotalElapsedSecs:Number;
      
      private var iPostFadeCountdown:int;
      
      private var fMinNumSeconds:Number;
      
      private var bShaderFadeActivated:Boolean;
      
      public var FadeValue:Number;
      
      public var LSCNativeGetSnapshot:Function;
      
      public var LSCCard_mc:MovieClip;
      
      public var LSCInfoFlags_mc:MovieClip;
      
      private var LSCPollTimer:Timer;
      
      private var LSCOptions:Object = {
         "badge":1,
         "spinner":1,
         "background":1,
         "short":1,
         "name":1,
         "level":1,
         "xp_bar":1,
         "xp_numbers":1,
         "credits":1,
         "location":1,
         "tips":1,
         "diagnostics":0,
         "clock":2,
         "density":0,
         "health":1,
         "oxygen":1,
         "co2":1,
         "carry_weight":1,
         "physical_resist":1,
         "energy_resist":1,
         "em_resist":1,
         "power":1,
         "experience_raw":0,
         "cell":0,
         "coordinates":0
      };
      
      private var LSCOSFReady:Boolean = false;
      
      public function FaderMenu()
      {
         super();
         Extensions.enabled = true;
         this.TRArtInit();
         this.BGSCodeObj = new Object();
         this.fStartAlpha = 1;
         this.FadeValue = this.fStartAlpha;
         this.fEndAlpha = 0;
         this.fFadeDuration = 0;
         this.fFadeElapsedSecs = 0;
         this.fTotalElapsedSecs = 0;
         this.fMinNumSeconds = 0;
         this.iPostFadeCountdown = -1;
         this.LSCRefreshOptions();
         this.LSCCard_mc.visible = false;
         this.addEventListener(Event.ENTER_FRAME,this.LSCSyncCard);
         this.LSCCard_mc.mouseEnabled = false;
         this.LSCCard_mc.mouseChildren = false;
         this.LSCCard_mc.Name_mc.text_tf.width = 520;
         this.LSCCard_mc.Credits_mc.text_tf.width = 135;
         this.LSCCard_mc.Location_mc.text_tf.width = 360;
         this.LSCCard_mc.Detail_mc.text_tf.width = 520;
         this.LSCCard_mc.Debug_mc.text_tf.width = 1155;
         this.LSCPollTimer = new Timer(100);
         this.LSCPollTimer.addEventListener(TimerEvent.TIMER,this.LSCRefresh);
         this.LSCPollTimer.start();
      }
      
      private function LSCSyncCard(event:Event) : void
      {
         this.LSCApplyArtwork();
         this.LSCCard_mc.alpha = this.SpinnerIcon_mc.alpha;
         if(!this.SpinnerIcon_mc.visible || this.SpinnerIcon_mc.alpha <= 0.01)
         {
            this.LSCCard_mc.visible = false;
         }
      }
      
      private function LSCRefreshOptions() : void
      {
      }
      
      private function LSCReadOptions(snapshot:Object) : void
      {
         this.TRArtReadSnapshot(snapshot);
         if(snapshot != null && snapshot.settings != null)
         {
            this.LSCOptions = snapshot.settings;
         }
         this.LSCOSFReady = snapshot != null && Boolean(snapshot.settingsReady);
      }
      
      private function LSCClockMode() : int
      {
         return int(this.LSCOptions.clock);
      }
      
      private function LSCClock(snapshot:Object) : String
      {
         if(this.LSCClockMode() == 0 || snapshot == null)
         {
            return "";
         }
         var key:String = this.LSCClockMode() == 1 ? "pcTime12" : "pcTime24";
         return snapshot[key] != null ? String(snapshot[key]) : "";
      }
      
      private function LSCExtraValues(snapshot:Object, clock:Boolean) : Array
      {
         var values:Array = [];
         var clockValue:String = this.LSCClock(snapshot);
         if(clock && clockValue != "")
         {
            values.push({
               "label":"LOCAL PC TIME",
               "value":clockValue
            });
         }
         if(snapshot == null || !snapshot.ready)
         {
            return values;
         }
         var labels:Object = {
            "health":"HEALTH",
            "oxygen":"OXYGEN",
            "co2":"CARBON DIOXIDE",
            "carry_weight":"CARRIED MASS / CAPACITY",
            "physical_resist":"PHYSICAL RESISTANCE",
            "energy_resist":"ENERGY RESISTANCE",
            "em_resist":"EM RESISTANCE",
            "power":"STAR POWER",
            "experience_raw":"RAW EXPERIENCE",
            "cell":"CELL NAME",
            "coordinates":"COORDINATES"
         };
         var keys:Array = ["health","oxygen","co2","carry_weight","physical_resist","energy_resist","em_resist","power","experience_raw","cell","coordinates"];
         for each(var key:String in keys)
         {
            if(this.LSCEnabled(key) && snapshot["stat_" + key] != null && String(snapshot["stat_" + key]) != "")
            {
               values.push({
                  "key":key,
                  "label":labels[key],
                  "value":String(snapshot["stat_" + key])
               });
            }
         }
         return values;
      }
      
      private function LSCWalkArt(parent:DisplayObjectContainer, mode:int) : void
      {
         for(var slot:int = 0;slot < 2;slot++)
         {
            if(parent != null && this.TRArtParents[slot] == parent && this.TRArtHosts[slot] != null && this.TRArtHosts[slot].visible && this.TRArtStates[slot] == 2)
            {
               for(var artIndex:int = 0;artIndex < parent.numChildren;artIndex++)
               {
                  var artChild:DisplayObject = parent.getChildAt(artIndex);
                  artChild.visible = artChild == this.TRArtHosts[slot];
               }
               return;
            }
         }
         if(parent == null)
         {
            return;
         }
         var i:int = 0;
         while(i < parent.numChildren)
         {
            var child:DisplayObject = parent.getChildAt(i);
            if(child.name == "LSCOriginal_mc")
            {
               child.visible = mode == 0;
            }
            else if(child.name == "LSCCustom_mc")
            {
               child.visible = mode == 1;
            }
            else if(child.name == "LSCDigit_mc")
            {
               child.visible = mode == 0;
            }
            else if(child is DisplayObjectContainer)
            {
               this.LSCWalkArt(child as DisplayObjectContainer,mode);
            }
            i++;
         }
      }
      
      private function LSCApplyArtwork() : void
      {
         this.LSCWalkArt(this.SpinnerIcon_mc,int(this.LSCOptions.spinner) >= 3 ? 1 : int(this.LSCOptions.spinner));
      }
      
      private function LSCMetricLabel(key:String) : String
      {
         var labels:Object = {
            "health":"HEALTH",
            "oxygen":"OXYGEN",
            "co2":"CARBON DIOXIDE",
            "carry_weight":"MASS",
            "physical_resist":"PHYS",
            "energy_resist":"ENGY",
            "em_resist":"EM",
            "power":"STAR POWER",
            "experience_raw":"RAW EXPERIENCE",
            "cell":"CELL",
            "coordinates":"COORDINATES"
         };
         return labels[key] != null ? String(labels[key]) : key.toUpperCase();
      }
      
      private function LSCMetricIcon(clip:MovieClip, key:String, width:Number, value:String) : void
      {
         var g:Graphics = clip.graphics;
         g.clear();
         g.lineStyle(1.4,13949659,0.92);
         if(key == "physical_resist")
         {
            var points:Array = [3,31,9,23,6,10,15,23,19,3,23,24,31,17,27,30,34,34,2,34,3,31];
            g.moveTo(points[0],points[1]);
            var i:int = 2;
            while(i < points.length)
            {
               g.lineTo(points[i],points[i + 1]);
               i += 2;
            }
         }
         else if(key == "energy_resist")
         {
            g.moveTo(20,4);
            g.lineTo(8,23);
            g.lineTo(17,23);
            g.lineTo(12,38);
            g.lineTo(29,17);
            g.lineTo(20,17);
            g.lineTo(25,4);
            g.lineTo(20,4);
         }
         else if(key == "em_resist")
         {
            g.moveTo(2,22);
            g.lineTo(34,22);
            var j:int = 0;
            while(j <= 32)
            {
               var y:Number = 22 + Math.sin(j / 32 * Math.PI * 4) * 15;
               if(j == 0)
               {
                  g.moveTo(j + 2,y);
               }
               else
               {
                  g.lineTo(j + 2,y);
               }
               j++;
            }
         }
         else if(key == "health")
         {
            g.drawCircle(18,22,14);
            g.moveTo(18,13);
            g.lineTo(18,31);
            g.moveTo(9,22);
            g.lineTo(27,22);
         }
         else if(key == "oxygen" || key == "co2")
         {
            g.drawCircle(16,21,11);
            g.drawCircle(29,31,key == "oxygen" ? 4 : 5);
            if(key == "co2")
            {
               g.moveTo(11,21);
               g.lineTo(21,21);
            }
         }
         else if(key == "carry_weight")
         {
            g.drawRect(6,14,25,23);
            g.drawRect(13,7,11,7);
            g.moveTo(6,22);
            g.lineTo(31,22);
         }
         else if(key == "power")
         {
            g.moveTo(18,3);
            g.lineTo(22,17);
            g.lineTo(35,22);
            g.lineTo(22,26);
            g.lineTo(18,40);
            g.lineTo(14,26);
            g.lineTo(2,22);
            g.lineTo(14,17);
            g.lineTo(18,3);
         }
         else
         {
            g.drawCircle(18,22,12);
            g.moveTo(18,5);
            g.lineTo(18,39);
            g.moveTo(1,22);
            g.lineTo(35,22);
         }
         g.lineStyle(1,9214366,0.34);
         g.moveTo(43,56);
         g.lineTo(width - 12,56);
         var split:Array = value.split("/");
         if(split.length == 2 && key != "coordinates")
         {
            var maximum:Number = Number(split[1]);
            var current:Number = Number(split[0]);
            if(isFinite(current) && isFinite(maximum) && maximum > 0)
            {
               g.lineStyle(2,13949659,0.9);
               g.moveTo(43,56);
               g.lineTo(43 + (width - 55) * Math.max(0,Math.min(1,current / maximum)),56);
            }
         }
      }
      
      private function LSCEnabled(key:String) : Boolean
      {
         if(key == "diagnostics")return false;
         if(this.LSCOptions.hasOwnProperty(key))
         {
            return int(this.LSCOptions[key]) > 0;
         }
         var flag:MovieClip = this.LSCInfoFlags_mc.getChildByName("flag_" + key) as MovieClip;
         return flag != null && flag.totalFrames > 1;
      }
      
      private function LSCEscape(value:String) : String
      {
         return value.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
      }
      
      private function LSCNumber(value:Number) : String
      {
         var digits:String = Math.floor(value).toString();
         var result:String = "";
         while(digits.length > 3)
         {
            result = "," + digits.substr(digits.length - 3) + result;
            digits = digits.substr(0,digits.length - 3);
         }
         return digits + result;
      }
      
      private function LSCStat(label:String, value:String) : String
      {
         return "<p><font size=\"14\" color=\"#AEB9BE\" letterSpacing=\"0.2\">" + label + "</font></p><p><font size=\"20\" color=\"#E0E5E7\">" + this.LSCEscape(value) + "</font></p>";
      }
      
      private function LSCRefresh(event:TimerEvent = null) : void
      {
         var ready:Boolean;
         var any:Boolean;
         var stats:Boolean;
         var details:String;
         var header:Boolean;
         var body:Boolean;
         var footer:Boolean;
         var clockText:String;
         var extra:Array;
         var headerHeight:Number;
         var extraY:Number;
         var page:int;
         var i:int;
         var clip:MovieClip;
         var at:int;
         var height:Number;
         var bodyY:Number;
         var footerY:Number;
         var snapshot:Object = null;
         var state:String = "absent";
         if(this.LSCNativeGetSnapshot != null)
         {
            try
            {
               snapshot = this.LSCNativeGetSnapshot();
               state = snapshot != null && snapshot.ready ? "ready" : "waiting";
            }
            catch(error:Error)
            {
               state = "error";
            }
         }
         ready = snapshot != null && Boolean(snapshot.ready);
         this.LSCReadOptions(snapshot);
         this.LSCCard_mc.visible = false;
         return;
         any = this.LSCEnabled("name") || this.LSCEnabled("credits") || this.LSCEnabled("location") || this.LSCEnabled("level") || this.LSCEnabled("xp_numbers") || this.LSCEnabled("xp_bar") || this.LSCEnabled("diagnostics") || this.LSCClockMode() > 0 || this.LSCExtraValues(snapshot,false).length > 0;
         this.LSCCard_mc.visible = any && this.SpinnerIcon_mc.visible && this.SpinnerIcon_mc.alpha > 0.01 && (ready || this.LSCEnabled("diagnostics") || this.LSCClockMode() > 0) && !(ready && (snapshot.hideShortPanel || snapshot.loadingMenuOpen));
         this.LSCCard_mc.alpha = this.SpinnerIcon_mc.alpha;
         this.LSCCard_mc.Name_mc.visible = this.LSCEnabled("name");
         this.LSCCard_mc.Credits_mc.visible = this.LSCEnabled("credits");
         this.LSCCard_mc.Location_mc.visible = this.LSCEnabled("location");
         this.LSCCard_mc.Debug_mc.visible = this.LSCEnabled("diagnostics");
         GlobalFunc.SetText(this.LSCCard_mc.Name_mc.text_tf,"<font size=\"22\" color=\"#E0E5E7\">" + this.LSCEscape(ready ? String(snapshot.character) : "Waiting for character data") + "</font>",true);
         GlobalFunc.SetText(this.LSCCard_mc.Credits_mc.text_tf,this.LSCStat("CREDITS",ready && snapshot.creditsAvailable ? this.LSCNumber(Number(snapshot.credits)) : "Unavailable"),true);
         GlobalFunc.SetText(this.LSCCard_mc.Location_mc.text_tf,this.LSCStat("LAST LOCATION",ready && snapshot.location != null && String(snapshot.location) != "" ? String(snapshot.location) : "Unavailable"),true);
         stats = ready && Boolean(snapshot.uiStatsAvailable);
         details = "";
         if(stats && this.LSCEnabled("level"))
         {
            details = "LEVEL " + snapshot.level.toString();
         }
         if(stats && this.LSCEnabled("xp_numbers"))
         {
            details += (details != "" ? "    /    " : "") + "XP " + this.LSCNumber(Number(snapshot.xp)) + " / " + this.LSCNumber(Number(snapshot.nextXP));
         }
         this.LSCCard_mc.Detail_mc.visible = details != "";
         GlobalFunc.SetText(this.LSCCard_mc.Detail_mc.text_tf,"<font size=\"13\" color=\"#AEB9BE\">" + details + "</font>",true);
         this.LSCCard_mc.BarBack_mc.visible = stats && this.LSCEnabled("xp_bar");
         this.LSCCard_mc.BarFill_mc.visible = stats && this.LSCEnabled("xp_bar");
         this.LSCCard_mc.BarFill_mc.width = stats && Number(snapshot.nextXP) > 0 ? 520 * Math.max(0,Math.min(1,Number(snapshot.xp) / Number(snapshot.nextXP))) : 0;
         header = this.LSCEnabled("name");
         body = this.LSCEnabled("credits") || this.LSCEnabled("location");
         footer = stats && (this.LSCEnabled("level") || this.LSCEnabled("xp_numbers") || this.LSCEnabled("xp_bar"));
         clockText = this.LSCClock(snapshot);
         this.LSCCard_mc.Clock_mc.visible = clockText != "";
         this.LSCCard_mc.Clock_mc.x = 390;
         this.LSCCard_mc.Clock_mc.y = 10;
         this.LSCCard_mc.Clock_mc.text_tf.width = 150;
         this.LSCCard_mc.Clock_mc.text_tf.height = 52;
         GlobalFunc.SetText(this.LSCCard_mc.Clock_mc.text_tf,this.LSCStat("LOCAL PC TIME",clockText),true);
         this.LSCCard_mc.Name_mc.text_tf.width = clockText != "" ? 355 : 520;
         header ||= clockText != "";
         extra = this.LSCExtraValues(snapshot,false);
         headerHeight = clockText != "" ? 48 : (header ? 29 : 0);
         extraY = 24 + headerHeight + (body ? 51 : 0) + (footer ? 32 : 0);
         page = extra.length > 2 ? int(getTimer() / 4000) % int(Math.ceil(extra.length / 2)) : 0;
         i = 0;
         while(i < 2)
         {
            clip = this.LSCCard_mc[i == 0 ? "ExtraA_mc" : "ExtraB_mc"] as MovieClip;
            at = page * 2 + i;
            clip.visible = at < extra.length;
            clip.x = 20 + i * 260;
            clip.y = extraY;
            clip.text_tf.x = 38;
            clip.text_tf.width = 212;
            clip.text_tf.height = 52;
            if(clip.visible)
            {
               GlobalFunc.SetText(clip.text_tf,this.LSCStat(this.LSCMetricLabel(extra[at].key),extra[at].value),true);
               this.LSCMetricIcon(clip,extra[at].key,250,extra[at].value);
            }
            i++;
         }
         height = extraY + (extra.length > 0 ? 54 : 0);
         bodyY = 14 + headerHeight;
         footerY = 14 + headerHeight + (body ? 51 : 0);
         this.LSCCard_mc.getChildAt(0).height = height;
         this.LSCCard_mc.getChildAt(1).height = height;
         this.LSCCard_mc.getChildAt(2).height = Math.max(12,height - 44);
         this.LSCCard_mc.Credits_mc.y = bodyY;
         this.LSCCard_mc.Location_mc.y = bodyY;
         this.LSCCard_mc.Location_mc.x = this.LSCEnabled("credits") ? 180 : 20;
         this.LSCCard_mc.Location_mc.text_tf.width = this.LSCEnabled("credits") ? 360 : 520;
         this.LSCCard_mc.Detail_mc.y = footerY;
         this.LSCCard_mc.BarBack_mc.y = footerY + 26;
         this.LSCCard_mc.BarFill_mc.y = footerY + 26;
         this.LSCCard_mc.Debug_mc.y = height + 6;
         this.LSCCard_mc.y = Extensions.visibleRect.y + Extensions.visibleRect.height - height - 64;
         GlobalFunc.SetText(this.LSCCard_mc.Debug_mc.text_tf,"OSF=" + (this.LSCOSFReady ? "connected" : "defaults") + " N=" + state + (ready ? " #" + snapshot.sequence.toString() + " Age=" + Math.round(Number(snapshot.ageMs) / 1000).toString() + "s" : ""));
      }
      
      override protected function onSetSafeRect() : void
      {
         this.LSCCard_mc.x = Extensions.visibleRect.x + 64;
         this.LSCCard_mc.y = Extensions.visibleRect.y + Extensions.visibleRect.height - 200;
         this.FadeRect_mc.x = Extensions.visibleRect.x;
         this.FadeRect_mc.y = Extensions.visibleRect.y;
         this.FadeRect_mc.width = Extensions.visibleRect.width;
         this.FadeRect_mc.height = Extensions.visibleRect.height;
      }
      
      public function SetImmediateWhiteFullFade() : *
      {
         this.FadeValue = 1;
         this.FadeRect_mc.alpha = 1;
         this.FadeRect_mc.visible = true;
         var _loc1_:ColorTransform = this.FadeRect_mc.transform.colorTransform;
         _loc1_.redOffset = 255;
         _loc1_.greenOffset = 255;
         _loc1_.blueOffset = 255;
         this.FadeRect_mc.transform.colorTransform = _loc1_;
         this.SpinnerIcon_mc.visible = false;
      }
      
      public function EnsureFaderMenuIsHidden() : *
      {
         this.SpinnerIcon_mc.alpha = 1;
         this.FadeRect_mc.alpha = 1;
         this.fStartAlpha = 1;
         this.FadeValue = this.fStartAlpha;
         this.fEndAlpha = 1;
         this.fFadeDuration = 0;
         this.fFadeElapsedSecs = 0;
         this.fTotalElapsedSecs = 0;
         this.fMinNumSeconds = -1;
         this.iPostFadeCountdown = -1;
      }
      
      public function initFade(param1:Boolean, param2:Boolean, param3:Number, param4:Number, param5:Boolean, param6:Boolean) : *
      {
         if(!param1 && int(this.LSCOptions.spinner) == 3)this.TRArtChoose(1,-1);
         this.bShaderFadeActivated = param5;
         if(this.FadeRect_mc.alpha > 0 && this.FadeRect_mc.alpha < 1)
         {
            if(param1)
            {
               this.fFadeElapsedSecs = (1 - this.FadeRect_mc.alpha) / 1 * param3;
            }
            else
            {
               this.fFadeElapsedSecs = this.FadeRect_mc.alpha / 1 * param3;
            }
         }
         else
         {
            this.fFadeElapsedSecs = 0;
            this.fTotalElapsedSecs = 0;
         }
         if(!param1)
         {
            this.fStartAlpha = 0;
            this.fEndAlpha = 1;
            this.FadeRect_mc.alpha = 0;
         }
         else
         {
            this.fStartAlpha = 1;
            this.fEndAlpha = 0;
            this.FadeRect_mc.alpha = 1;
         }
         var _loc7_:ColorTransform = this.FadeRect_mc.transform.colorTransform;
         _loc7_.redOffset = param2 ? 0 : 255;
         _loc7_.greenOffset = param2 ? 0 : 255;
         _loc7_.blueOffset = param2 ? 0 : 255;
         this.FadeRect_mc.transform.colorTransform = _loc7_;
         this.fFadeDuration = param3;
         this.fMinNumSeconds = param4;
         this.SpinnerIcon_mc.visible = param2 && !param6;
         this.FadeValue = this.fStartAlpha;
         if(this.bShaderFadeActivated)
         {
            this.FadeRect_mc.alpha = 0;
            this.SpinnerIcon_mc.alpha = 0;
         }
         else
         {
            this.FadeRect_mc.alpha = this.fStartAlpha;
            this.SpinnerIcon_mc.alpha = this.fStartAlpha;
         }
      }
      
      public function setSpinnerVisibility(param1:Boolean) : *
      {
         this.SpinnerIcon_mc.visible = param1;
      }
      
      public function updateFade(param1:Number) : *
      {
         this.fTotalElapsedSecs += param1;
         if(this.iPostFadeCountdown > 0)
         {
            --this.iPostFadeCountdown;
            if(this.iPostFadeCountdown == 0)
            {
               this.iPostFadeCountdown = -1;
               this.BGSCodeObj.onFadeDone();
            }
         }
         else if(this.fTotalElapsedSecs >= this.fMinNumSeconds)
         {
            this.fFadeElapsedSecs = Math.min(this.fFadeElapsedSecs + param1,this.fFadeDuration);
            this.FadeValue = GlobalFunc.MapLinearlyToRange(this.fStartAlpha,this.fEndAlpha,0,this.fFadeDuration,this.fFadeElapsedSecs,true);
            if(this.fFadeElapsedSecs >= this.fFadeDuration)
            {
               this.FadeValue = this.fEndAlpha;
               this.iPostFadeCountdown = 1;
            }
            if(this.bShaderFadeActivated)
            {
               this.FadeRect_mc.alpha = 0;
               this.SpinnerIcon_mc.alpha = 0;
            }
            else
            {
               this.FadeRect_mc.alpha = this.FadeValue;
               this.SpinnerIcon_mc.alpha = this.FadeValue;
            }
         }
      }
      private function TRArtIsFullScreen() : Boolean{return false;}
      private function TRArtTarget(index:int) : DisplayObjectContainer{return index == 1 ? this.SpinnerIcon_mc : null;}
      private function TRArtBackgroundVisible() : Boolean{return false;}
      private function TRArtAddBackground(host:Sprite) : void{}
      private function TRArtHideBuiltInBackground() : void{}
      // Runtime-loaded, plugin-generated still-image caches. No authoring tool required.
      private var TRArtLoaders:Array = [null,null,null];
      private var TRArtContents:Array = [null,null,null];
      private var TRArtHosts:Array = [null,null,null];
      private var TRArtParents:Array = [null,null,null];
      private var TRArtHidden:Array = [null,null,null];
      private var TRArtStates:Array = [0,0,0];
      private var TRArtWidths:Array = [0,0,0];
      private var TRArtHeights:Array = [0,0,0];
      private var TRArtNames:Array = ["badge","indicator","wallpaper"];
      private var TRArtShade:Sprite;
      private var TRArtUsingDefaults:Array = [false,false,false];
      private var TRArtDisposed:Boolean = false;
      private var TRArtRequested:Array = [-1,-1,-1];
      private var TRArtFiles:Array = [[],[],[]];
      private var TRArtSelected:Array = [null,null,null];
      private var TRArtManifestReady:Boolean = false;
      private var TRArtWasFullActive:Boolean = false;

      private function TRArtInit() : void
      {
         this.addEventListener(Event.ENTER_FRAME,this.TRArtFrame);
         this.addEventListener(Event.EXIT_FRAME,this.TRArtFinalize);
         this.addEventListener(Event.RENDER,this.TRArtFinalize);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.TRArtRemove);
      }
      private function TRArtReadSnapshot(snapshot:Object) : void
      {
         if(this.TRArtManifestReady || snapshot == null || !snapshot.hasOwnProperty("artworkWallpaperFiles"))return;
         var keys:Array = ["artworkBadgeFiles","artworkIndicatorFiles","artworkWallpaperFiles"];
         for(var i:int = 0;i < 3;i++)
         {
            var value:String = snapshot[keys[i]] != null ? String(snapshot[keys[i]]) : "";
            this.TRArtFiles[i] = value.length > 0 ? value.split("|") : [];
         }
         this.TRArtManifestReady = true;
      }
      private function TRArtRandomFilename(index:int) : String
      {
         if(this.TRArtSelected[index] != null)return String(this.TRArtSelected[index]);
         var files:Array = this.TRArtFiles[index] as Array;
         if(files == null || files.length == 0)return "";
         var selected:int = int(Math.random()*files.length);
         this.TRArtSelected[index] = String(files[selected]);
         return String(this.TRArtSelected[index]);
      }
      private function TRArtLoad(index:int,useDefault:Boolean = false) : void
      {
         if(this.TRArtDisposed || this.TRArtStates[index] != 0)return;
         if(!useDefault && !this.TRArtManifestReady)return;
         this.TRArtStates[index] = 1;this.TRArtUsingDefaults[index] = useDefault;
         var loader:Loader = new Loader();this.TRArtLoaders[index] = loader;
         var failed:Function = function(event:Event):void
         {
            if(TRArtDisposed || TRArtLoaders[index] != loader)return;
            TRArtStates[index] = -1;
         };
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(event:Event):void
         {
            if(TRArtDisposed || TRArtLoaders[index] != loader)return;
            var content:DisplayObject = loader.content;
            if(content == null || content.width <= 0 || content.height <= 0)
            {failed(null);return;}
            TRArtContents[index] = content;
            var bounds:Rectangle = content.getBounds(content);
            // Use authored SWF stage dimensions; a moving glint must not resize the badge.
            var stageWidth:Number = Number(loader.contentLoaderInfo.width);
            var stageHeight:Number = Number(loader.contentLoaderInfo.height);
            TRArtWidths[index] = stageWidth > 0 ? stageWidth : bounds.width;
            TRArtHeights[index] = stageHeight > 0 ? stageHeight : bounds.height;
            TRArtStates[index] = 2;
         });
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,failed);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,failed);
         var folder:String = useDefault ? "Defaults" : "Cache";
         var filename:String = useDefault ? this.TRArtNames[index]+".swf" : this.TRArtRandomFilename(index);
         var preset:int = int(this.TRArtRequested[index]);
         if(useDefault && index < 2 && (preset == 6 || preset == 9))
            filename = preset == 6 ? "badge-jump-gate.swf" : "badge-signal-star.swf";
         if(useDefault && index == 2 && preset == 8)
            filename = "background-survey-sweep.swf";
         if(useDefault && preset == 100)filename = index < 2 ? "constellation-coin.swf" : "constellation-wallpaper.swf";
         if(useDefault && preset == 101)filename = index < 2 ? "crimson-fleet-coin.swf" : "crimson-fleet-wallpaper.swf";
         if(useDefault && preset == 102)filename = index < 2 ? "freestar-collective-coin.swf" : "freestar-collective-wallpaper.swf";
         if(useDefault && preset == 103)filename = index < 2 ? "house-varuun-coin.swf" : "house-varuun-wallpaper.swf";
         if(useDefault && preset == 104)filename = index < 2 ? "ryujin-industries-coin.swf" : "ryujin-industries-wallpaper.swf";
         if(useDefault && preset == 105)filename = index < 2 ? "trackers-alliance-coin.swf" : "trackers-alliance-wallpaper.swf";
         if(useDefault && preset == 106)filename = index < 2 ? "united-colonies-coin.swf" : "united-colonies-wallpaper.swf";
         if(filename == ""){this.TRArtStates[index] = -1;return;}
         try{loader.load(new URLRequest("TransitReport/"+folder+"/"+filename));}
         catch(error:Error){failed(null);}
      }
      private function TRArtChoose(index:int,mode:int) : void
      {
         if(this.TRArtRequested[index] == mode)return;
         this.TRArtRequested[index] = mode;
         this.TRArtSelected[index] = null;
         this.TRArtRestore(index);
         var host:Sprite = this.TRArtHosts[index] as Sprite;
         if(host != null && host.parent != null)host.parent.removeChild(host);
         var loader:Loader = this.TRArtLoaders[index] as Loader;
         this.TRArtLoaders[index] = null;
         if(loader != null){try{loader.close();}catch(error:Error){}}
         this.TRArtHosts[index] = null;this.TRArtParents[index] = null;this.TRArtContents[index] = null;
         this.TRArtStates[index] = 0;this.TRArtWidths[index] = 0;this.TRArtHeights[index] = 0;
      }
      private function TRArtFind(parent:DisplayObjectContainer) : DisplayObjectContainer
      {
         if(parent == null)return null;
         for(var i:int = 0;i < parent.numChildren;i++)
         {
            var child:DisplayObject = parent.getChildAt(i);
            if(child.name == "LSCCustom_mc" && child is DisplayObjectContainer)return child as DisplayObjectContainer;
            if(child is DisplayObjectContainer)
            {
               var found:DisplayObjectContainer = this.TRArtFind(child as DisplayObjectContainer);
               if(found != null)return found;
            }
         }
         return null;
      }
      private function TRArtRestore(index:int) : void
      {
         var host:Sprite = this.TRArtHosts[index] as Sprite;
         if(host != null)host.visible = false;
         var hidden:Array = this.TRArtHidden[index] as Array;
         if(hidden != null)
         {
            for each(var item:Object in hidden)if(item.child != null)item.child.visible = item.visible;
            this.TRArtHidden[index] = null;
            this.LSCApplyArtwork();
         }
      }
      private function TRArtPlace(index:int,parent:DisplayObjectContainer) : void
      {
         if(parent == null)return;
         var content:DisplayObject = this.TRArtContents[index] as DisplayObject;
         if(content == null)return;
         var host:Sprite = this.TRArtHosts[index] as Sprite;
         if(host == null || this.TRArtParents[index] != parent)
         {
            this.TRArtRestore(index);
            if(host != null && host.parent != null)host.parent.removeChild(host);
            var custom:DisplayObjectContainer = this.TRArtFind(parent);
            if(custom == null)return;
            var bounds:Rectangle = custom.getBounds(parent);
            if(bounds.width <= 0 || bounds.height <= 0)return;
            host = new Sprite();host.mouseEnabled = false;host.mouseChildren = false;
            var scale:Number = Math.min(bounds.width/this.TRArtWidths[index],bounds.height/this.TRArtHeights[index]);
            host.scaleX = scale;host.scaleY = scale;
            host.x = bounds.x+(bounds.width-this.TRArtWidths[index]*scale)/2;
            host.y = bounds.y+(bounds.height-this.TRArtHeights[index]*scale)/2;
            host.addChild(content);parent.addChild(host);
            this.TRArtHosts[index] = host;this.TRArtParents[index] = parent;
         }
         if(this.TRArtHidden[index] == null)
         {
            var saved:Array = [];
            for(var i:int = 0;i < parent.numChildren;i++)
            {var child:DisplayObject = parent.getChildAt(i);if(child != host)saved.push({child:child,visible:child.visible});}
            this.TRArtHidden[index] = saved;
         }
         // Timeline clips may be recreated after the first placement.
         for(var current:int = 0;current < parent.numChildren;current++)
         {
            var currentChild:DisplayObject = parent.getChildAt(current);
            if(currentChild != host)currentChild.visible = false;
         }
         host.visible = true;
         if(index == 1 && !Boolean(this.TRArtUsingDefaults[index]) && (!(this.TRArtContents[index] is MovieClip) || MovieClip(this.TRArtContents[index]).totalFrames <= 1))
         {
            var w:Number = Number(this.TRArtWidths[index]);var h:Number = Number(this.TRArtHeights[index]);
            var spin:Matrix = new Matrix();spin.translate(-w/2,-h/2);spin.rotate(getTimer()/1000*0.9);spin.translate(w/2,h/2);
            content.transform.matrix = spin;
         }
      }
      private function TRArtBackground() : Boolean
      {
         if(!this.TRArtIsFullScreen())return false;
         var mode:int = int(this.LSCOptions.background);
         this.TRArtChoose(2,mode);
         var active:Boolean = (mode == 4 || mode == 8 || mode == 100 || mode == 101 || mode == 102 || mode == 103 || mode == 104 || mode == 105 || mode == 106) && this.TRArtBackgroundVisible();
         var host:Sprite = this.TRArtHosts[2] as Sprite;
         if(host != null)host.visible = active;
         if(!active)return false;
         this.TRArtLoad(2,mode != 4);
         if(this.TRArtStates[2] != 2)return false;
         var content:DisplayObject = this.TRArtContents[2] as DisplayObject;
         if(host == null)
         {
            host = new Sprite();host.mouseEnabled = false;host.mouseChildren = false;
            host.addChild(content);this.TRArtShade = new Sprite();host.addChild(this.TRArtShade);
            this.TRArtHosts[2] = host;this.TRArtAddBackground(host);
         }
         host.visible = true;this.TRArtHideBuiltInBackground();
         var r:Rectangle = Extensions.visibleRect;
         var scale:Number = Math.max(r.width/this.TRArtWidths[2],r.height/this.TRArtHeights[2]);
         content.scaleX = scale;content.scaleY = scale;
         content.x = r.x+(r.width-this.TRArtWidths[2]*scale)/2;content.y = r.y+(r.height-this.TRArtHeights[2]*scale)/2;
         var g:Graphics = this.TRArtShade.graphics;g.clear();
         var m:Matrix = new Matrix();m.createGradientBox(r.width,r.height,Math.PI/2,r.x,r.y);
         g.beginGradientFill(GradientType.LINEAR,[0x02070D,0x02070D],[0,0.94],[60,255],m);g.drawRect(r.x,r.y,r.width,r.height);g.endFill();
         return true;
      }
      private function TRArtFrame(event:Event) : void
      {
         if(this.TRArtIsFullScreen())
         {
            var active:Boolean = this.TRArtBackgroundVisible();
            if(active && !this.TRArtWasFullActive)
            {
               if(int(this.LSCOptions.badge) == 3)this.TRArtChoose(0,-1);
               if(int(this.LSCOptions.spinner) == 3)this.TRArtChoose(1,-1);
               if(int(this.LSCOptions.background) == 4)this.TRArtChoose(2,-1);
            }
            this.TRArtWasFullActive = active;
         }
         for(var index:int = 0;index < 2;index++)
         {
            var mode:int = int(index == 0 ? this.LSCOptions.badge : this.LSCOptions.spinner);
            this.TRArtChoose(index,mode);
            if(mode != 3 && mode != 6 && mode != 9 && mode != 100 && mode != 101 && mode != 102 && mode != 103 && mode != 104 && mode != 105 && mode != 106){this.TRArtRestore(index);continue;}
            var parent:DisplayObjectContainer = this.TRArtTarget(index);
            if(parent == null)continue;
            this.TRArtLoad(index,mode >= 4);
            if(this.TRArtStates[index] == 2)this.TRArtPlace(index,parent);
         }
         this.TRArtBackground();
      }
      // Scaleform timelines can restore symbol visibility after ENTER_FRAME.
      // Enforce replacement exclusivity after timeline advancement, immediately before drawing.
      private function TRArtFinalize(event:Event) : void
      {
         if(this.TRArtDisposed)return;
         for(var index:int = 0;index < 2;index++)
         {
            var host:Sprite = this.TRArtHosts[index] as Sprite;
            var parent:DisplayObjectContainer = this.TRArtParents[index] as DisplayObjectContainer;
            var mode:int = int(index == 0 ? this.LSCOptions.badge : this.LSCOptions.spinner);
            if(host == null || parent == null || host.parent != parent || this.TRArtStates[index] != 2 || (mode != 3 && mode != 6 && mode != 9 && mode != 100 && mode != 101 && mode != 102 && mode != 103 && mode != 104 && mode != 105 && mode != 106))continue;
            for(var childIndex:int = 0;childIndex < parent.numChildren;childIndex++)
            {
               var child:DisplayObject = parent.getChildAt(childIndex);
               child.visible = child == host;
            }
         }
      }
      private function TRArtRemove(event:Event) : void
      {
         if(event.target != this)return;
         this.TRArtDisposed = true;
         this.removeEventListener(Event.ENTER_FRAME,this.TRArtFrame);
         this.removeEventListener(Event.EXIT_FRAME,this.TRArtFinalize);
         this.removeEventListener(Event.RENDER,this.TRArtFinalize);
         this.removeEventListener(Event.REMOVED_FROM_STAGE,this.TRArtRemove);
         for(var i:int = 0;i < 3;i++)
         {
            var loader:Loader = this.TRArtLoaders[i] as Loader;
            if(loader != null){try{loader.close();}catch(error:Error){}}
         }
      }

   }
}

