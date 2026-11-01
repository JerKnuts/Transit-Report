package
{
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.IMenu;
   import Shared.Components.ContentLoaders.ImageLoaderClip;
   import Shared.GlobalFunc;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import scaleform.gfx.Extensions;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol200")]
   public class LoadingMenu extends IMenu
   {
      
      private static const TIME_TO_HIDE_PROGRESS_BAR_AFTER_COMPLETION:Number = 1000;
      
      private static const REFRESH_RATE_SECONDS:Number = 20;
      
      private static const LEVEL_ICON_START_WIDTH:Number = 95;
      
      private static const LEVEL_ICON_SCALE:Number = 0.7;
      
      public var BuildingShaders_mc:MovieClip;
      
      public var LeftText_mc:MovieClip;
      
      public var BlackRect_mc:MovieClip;
      
      public var Spinner_mc:MovieClip;
      
      public var PlayerName_mc:MovieClip;
      
      public var Texture_mc:ImageLoaderClip;
      
      public var Gradient_mc:MovieClip;
      
      private var InMinimalMode:Boolean;
      
      private var ScreenWidth:uint = 0;
      
      private var ScreenHeight:uint = 0;
      
      private var LoadingTexture:String = "";
      
      private var PhotoModeScreen:Boolean = false;
      
      private var StartPlayerNameLevel_x:Number = 0;
      
      private var ShaderProgressWidth:Number = 0;
      
      private var TotalPipelinesToGenerate:uint = 0;
      
      private var HideProgressBarTimer:Timer;
      
      public var LSCNativeGetSnapshot:Function;
      public var LSCCard_mc:MovieClip;
      private var LSCCompactTimer:Timer;
      private var LSCShortMode:Boolean = false;
      private var LSCPollTimer:Timer;
      private var LSCNativeState:String = "absent";
      private var LSCNativeSequence:Number = -1;
      private var LSCNativeGeneration:Number = -1;
      private var LSCNativeAge:Number = -1;
      private var LSCNativeHadSnapshot:Boolean = false;
      private var LSCNeedsStatsPost:Boolean = false;

      private var LSCLevel:uint = 0;
      private var LSCCoins:Number = -1;
      private var LSCPlace:String = "";
      private var LSCLastName:String = "";
      private var LSCLoadEvents:uint = 0;
      private var LSCInventoryEvents:uint = 0;
      private var LSCMapEvents:uint = 0;
      private var LSCSubscribeErrors:uint = 0;
      private var LSCInventoryKeys:String = "none";
      private var LSCMapKeys:String = "none";
      private var LSCXP:Number = 0;
      private var LSCNextXP:Number = 0;
      private var LSCInventoryTime:int = -1;
      private var LSCMapTime:int = -1;

      public function LoadingMenu()
      {
         super();
         Extensions.enabled = true;
         this.InMinimalMode = true;
         BSUIDataManager.Subscribe("LoadingMenuData",this.OnLoadingMenuDataUpdate);
         GlobalFunc.SetText(this.LeftText_mc.LoadScreenText_tf," ",false);
         GlobalFunc.SetText(this.LeftText_mc.PlayerName_mc.text_tf,"");
         GlobalFunc.SetText(this.LeftText_mc.PlayerLevel_mc.text_tf,"");
         this.BuildingShaders_mc.visible = false;
         this.ShaderProgressWidth = this.BuildingShaders_mc.Meter_mc.Fill_mc.width;
         this.HideProgressBarTimer = new Timer(TIME_TO_HIDE_PROGRESS_BAR_AFTER_COMPLETION,1);
         this.HideProgressBarTimer.addEventListener(TimerEvent.TIMER,this.OhHideProgressBar);
         this.StartPlayerNameLevel_x = this.LeftText_mc.PlayerName_mc.x;
         var _loc1_:Timer = new Timer(REFRESH_RATE_SECONDS * 1000);
         _loc1_.addEventListener(TimerEvent.TIMER,this.refreshLoadingText);
         _loc1_.start();
         this.LeftText_mc.visible = false;
         this.Texture_mc.onLoadAttemptComplete = this.onImageLoadAttemptComplete;
         this.LSCRefreshOptions();
         this.LSCCard_mc.visible = false;
         this.addEventListener(Event.ENTER_FRAME,this.LSCSyncCompactCard);
         this.LSCCard_mc.mouseEnabled = false;
         this.LSCCard_mc.mouseChildren = false;
         this.LSCCard_mc.Name_mc.text_tf.width = 520;
         this.LSCCard_mc.Credits_mc.text_tf.width = 135;
         this.LSCCard_mc.Location_mc.text_tf.width = 360;
         this.LSCCard_mc.Detail_mc.text_tf.width = 520;
         this.LSCCard_mc.Debug_mc.text_tf.width = 1155;
         this.LSCCompactTimer = new Timer(100);
         this.LSCCompactTimer.addEventListener(TimerEvent.TIMER,this.LSCRefreshCompact);
         this.LSCCompactTimer.start();

         this.LSCPollTimer = new Timer(100);
         this.LSCPollTimer.addEventListener(TimerEvent.TIMER, this.PollLSCNative);
         this.LSCPollTimer.start();
         GlobalFunc.SetText(this.LeftText_mc.LSCCredits_mc.text_tf, "");
         GlobalFunc.SetText(this.LeftText_mc.LSCLocation_mc.text_tf, "");
         GlobalFunc.SetText(this.LeftText_mc.LSCDebug_mc.text_tf, "");
         this.LeftText_mc.LSCCredits_mc.visible = false;
         this.LeftText_mc.LSCLocation_mc.visible = false;
         this.LeftText_mc.LSCCredits_mc.x = 725;
         this.LeftText_mc.LSCCredits_mc.y = 74.5;
         this.LeftText_mc.LSCCredits_mc.text_tf.width = 215;
         this.LeftText_mc.LSCCredits_mc.text_tf.height = 72;
         this.LeftText_mc.LSCLocation_mc.x = 990;
         this.LeftText_mc.LSCLocation_mc.y = 74.5;
         this.LeftText_mc.LSCLocation_mc.text_tf.width = 365;
         this.LeftText_mc.LSCLocation_mc.text_tf.height = 72;
         for each(var ribbonName:String in ["PlayerName_mc","PlayerLevel_mc","Player_Level_Icon","LSCXPBack_mc","LSCXPFill_mc","LSCXPText_mc","LSCCredits_mc","LSCLocation_mc"])
         {
            var ribbonChild:DisplayObject = this.LeftText_mc[ribbonName] as DisplayObject;
            if(ribbonChild != null)ribbonChild.y -= 135;
         }
         this.LeftText_mc.LSCDebug_mc.y = 164;
         this.LeftText_mc.LSCDebug_mc.text_tf.width = 1260;
         this.LeftText_mc.LSCDebug_mc.text_tf.textColor = 0x81929D;
         try
         {
            BSUIDataManager.Subscribe("PlayerInventoryData", this.OnLSCInventoryData);
         }
         catch(error:Error)
         {
            this.LSCSubscribeErrors++;
            trace("LSC inventory subscription error: " + error.toString());
         }
         try
         {
            BSUIDataManager.Subscribe("DataMenuData", this.OnLSCMapData);
         }
         catch(error:Error)
         {
            this.LSCSubscribeErrors++;
            trace("LSC location subscription error: " + error.toString());
         }

      }
      
      private function onImageLoadAttemptComplete() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Rectangle = null;
         if(this.Texture_mc.imageInstance != null)
         {
            _loc1_ = this.Texture_mc.width != 0 ? this.ScreenWidth / this.Texture_mc.width : 1;
            _loc2_ = this.Texture_mc.height != 0 ? this.ScreenHeight / this.Texture_mc.height : 1;
            _loc3_ = Math.min(_loc1_,_loc2_);
            _loc3_ = this.PhotoModeScreen ? Math.min(_loc3_,1) : _loc3_;
            _loc4_ = this.ScreenWidth != 0 ? stage.stageWidth / this.ScreenWidth : 1;
            _loc5_ = this.ScreenHeight != 0 ? stage.stageHeight / this.ScreenHeight : 1;
            _loc6_ = Math.min(_loc4_,_loc5_);
            _loc7_ = _loc3_ * _loc6_;
            this.Texture_mc.scaleX = _loc7_;
            this.Texture_mc.scaleY = _loc7_;
            _loc8_ = Extensions.visibleRect;
            this.Texture_mc.x = (stage.stageWidth - this.Texture_mc.width) * 0.5 + _loc8_.x;
            this.Texture_mc.y = (stage.stageHeight - this.Texture_mc.height) * 0.5 + _loc8_.y;
         }
      }
      
      private function OnLoadingMenuDataUpdate(param1:FromClientDataEvent) : void
      {
         var _loc2_:uint = 0;
         this.LSCNeedsStatsPost = true;
         this.LSCLoadEvents++;
         if(this.LSCLoadEvents == 1)
         {
            trace("LSC LoadingMenuData keys: " + this.LSCKeys(param1.data));
         }
         this.LSCLevel = uint(param1.data.uLevel);
         this.LSCXP = Number(param1.data.fLevelXP);
         this.LSCNextXP = Number(param1.data.fNextLevelXP);
         if(this.LSCLastName != "" && this.LSCLastName != String(param1.data.sPlayerName))
         {
            this.LSCCoins = -1;
            this.LSCPlace = "";
         }
         this.LSCLastName = String(param1.data.sPlayerName);
         this.LSCShortMode = Boolean(param1.data.bSpinnerOnly) || Boolean(param1.data.bMinimalMode);
         this.InMinimalMode = param1.data.bMinimalMode;
         this.ScreenWidth = param1.data.uScreenWidth;
         this.ScreenHeight = param1.data.uScreenHeight;
         this.PhotoModeScreen = param1.data.bPhotoModeScreen;
         if(param1.data.bSpinnerOnly)
         {
            this.SpinnerOnly();
         }
         else if(this.InMinimalMode)
         {
            this.SetMinimalMode();
         }
         else
         {
            this.LeftText_mc.visible = true;
            GlobalFunc.SetText(this.LeftText_mc.PlayerLevel_mc.text_tf,"$$Level " + param1.data.uLevel.toString());
            if(!this.InMinimalMode && param1.data.uLevel > 0)
            {
               this.LeftText_mc.Player_Level_Icon.visible = true;
               this.LeftText_mc.PlayerName_mc.visible = true;
               this.LeftText_mc.Player_Level_Icon.Initialize(param1.data.uLevel,false,LEVEL_ICON_SCALE);
               GlobalFunc.SetText(this.LeftText_mc.PlayerName_mc.text_tf,param1.data.sPlayerName);
               this.LeftText_mc.PlayerName_mc.x = this.StartPlayerNameLevel_x + (this.LeftText_mc.Player_Level_Icon.width - LEVEL_ICON_START_WIDTH);
               this.LeftText_mc.PlayerLevel_mc.x = this.StartPlayerNameLevel_x + (this.LeftText_mc.Player_Level_Icon.width - LEVEL_ICON_START_WIDTH);
            }
            else
            {
               this.LeftText_mc.Player_Level_Icon.visible = false;
               this.LeftText_mc.PlayerName_mc.visible = false;
            }
            this.SetLoadingText(param1.data.sLoadText);
            if(this.LoadingTexture != param1.data.sTextureName)
            {
               if(param1.data.sTextureName != "")
               {
                  this.Texture_mc.LoadImage(param1.data.sTextureName);
               }
               else
               {
                  this.Texture_mc.Unload();
               }
               this.Texture_mc.visible = true;
            }
            this.LoadingTexture = param1.data.sTextureName;
         }
         this.ApplyLSCInformation();
         this.PollLSCNative();
         if(param1.data.ShowPipelineGenerationProgress)
         {
            this.BuildingShaders_mc.visible = true;
            this.HideProgressBarTimer.stop();
            _loc2_ = param1.data.uTotalNumOfPipelinesToGenerate - param1.data.uNumOfRemainingPipelines;
            this.TotalPipelinesToGenerate = param1.data.uTotalNumOfPipelinesToGenerate > 0 ? uint(param1.data.uTotalNumOfPipelinesToGenerate) : 1;
            GlobalFunc.SetText(this.BuildingShaders_mc.Amount_tf,_loc2_.toString() + "/" + this.TotalPipelinesToGenerate.toString());
            this.BuildingShaders_mc.Meter_mc.Fill_mc.width = Math.min(this.ShaderProgressWidth,_loc2_ / this.TotalPipelinesToGenerate * this.ShaderProgressWidth);
         }
         else if(this.BuildingShaders_mc.visible)
         {
            this.HideProgressBarTimer.stop();
            this.HideProgressBarTimer.reset();
            this.HideProgressBarTimer.start();
            GlobalFunc.SetText(this.BuildingShaders_mc.Amount_tf,this.TotalPipelinesToGenerate.toString() + "/" + this.TotalPipelinesToGenerate.toString());
            this.BuildingShaders_mc.Meter_mc.Fill_mc.width = this.ShaderProgressWidth;
         }
      }
      
      private function PollLSCNative(event:TimerEvent = null) : void
      {
         if(this.LSCNativeGetSnapshot == null)
         {
            this.LSCNativeState = "absent";
            return;
         }
         try
         {
            var snapshot:Object;
            if(this.LSCNeedsStatsPost)
            {
               snapshot = this.LSCNativeGetSnapshot({character:this.LSCLastName, level:this.LSCLevel, xp:this.LSCXP, nextXP:this.LSCNextXP, panelActive:!this.InMinimalMode && !this.LSCShortMode && this.LeftText_mc.visible});
               this.LSCNeedsStatsPost = false;
            }
            else
            {
               snapshot = this.LSCNativeGetSnapshot();
            }
            this.LSCReadOptions(snapshot);
            this.LSCDrawExtras(snapshot);
            if(snapshot == null || !snapshot.ready)
            {
               this.LSCNativeState = "waiting";
               if(this.LSCNativeHadSnapshot)
               {
                  this.LSCCoins = -1;
                  this.LSCPlace = "";
               }
               this.ApplyLSCInformation();
               return;
            }
            if(snapshot.character != null && String(snapshot.character) != "" && this.LSCLastName != "" && String(snapshot.character) != this.LSCLastName)
            {
               this.LSCNativeState = "name-mismatch";
               this.LSCCoins = -1;
               this.LSCPlace = "";
               this.ApplyLSCInformation();
               return;
            }
            this.LSCNativeState = "ready";
            this.LSCNativeHadSnapshot = true;
            this.LSCNativeSequence = Number(snapshot.sequence);
            this.LSCNativeGeneration = Number(snapshot.generation);
            this.LSCNativeAge = Number(snapshot.ageMs);
            var coins:Number = Number(snapshot.credits);
            this.LSCCoins = snapshot.creditsAvailable && !isNaN(coins) && isFinite(coins) && coins >= 0 ? coins : -1;
            this.LSCPlace = snapshot.location != null ? String(snapshot.location) : "";
            this.ApplyLSCInformation();
         }
         catch(error:Error)
         {
            this.LSCNativeState = "error";
            trace("LSC native snapshot error: " + error.toString());
         }
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
            digits = digits.substr(0, digits.length - 3);
         }
         return digits + result;
      }

      private function LSCStatHTML(label:String, value:String) : String
      {
         return "<p><font size=\"14\" color=\"#AEB9BE\" letterSpacing=\"0.2\">" + label + "</font></p><p><font size=\"24\" color=\"#E0E5E7\">" + this.LSCEscape(value) + "</font></p>";
      }

      private var LSCOptions:Object = {"badge": 1, "spinner": 2, "background": 1, "short": 1, "name": 1, "level": 1, "xp_bar": 1, "xp_numbers": 1, "credits": 1, "location": 1, "tips": 1, "diagnostics": 0, "clock": 1, "density": 0, "health": 1, "oxygen": 1, "co2": 1, "carry_weight": 1, "physical_resist": 1, "energy_resist": 1, "em_resist": 1, "power": 1, "experience_raw": 0, "cell": 0, "coordinates": 0};
      private var LSCOSFReady:Boolean = false;
      private function LSCRefreshOptions() : void {}
      private function LSCReadOptions(snapshot:Object) : void
      {
         if(snapshot != null && snapshot.hasOwnProperty("pageOffset"))
         {
            var offset:Number = Number(snapshot.pageOffset);
            if(isFinite(offset) && offset != this.LSCTestNativeOffset)
            {
               this.LSCTestPage += int(offset-this.LSCTestNativeOffset);
               this.LSCTestManual = true;
               this.LSCTestNativeOffset = offset;
            }
         }
         if(snapshot != null && snapshot.settings != null)this.LSCOptions = snapshot.settings;
         this.LSCOSFReady = snapshot != null && snapshot.settingsReady;
      }
      private function LSCClockMode() : int
      {
         return int(this.LSCOptions.clock);
      }
      private function LSCClock(snapshot:Object) : String
      {
         if(this.LSCClockMode() == 0 || snapshot == null)return "";
         var key:String = this.LSCClockMode() == 1 ? "pcTime12" : "pcTime24";
         return snapshot[key] != null ? String(snapshot[key]) : "";
      }
      private function LSCExtraValues(snapshot:Object,clock:Boolean) : Array
      {return [];}
      private function LSCWalkArt(parent:DisplayObjectContainer,mode:int) : void
      {
         if(parent == null)return;
         for(var i:int = 0;i < parent.numChildren;i++)
         {
            var child:DisplayObject = parent.getChildAt(i);
            if(child.name == "LSCOriginal_mc")child.visible = mode == 0;
            else if(child.name == "LSCCustom_mc")child.visible = mode == 1;
            else if(child.name == "LSCDigit_mc")child.visible = mode == 0;
            else if(child is DisplayObjectContainer)this.LSCWalkArt(child as DisplayObjectContainer,mode);
         }
      }
      private function LSCReadabilityBackground() : void
      {
         if(this.LSCReadabilityPanel == null)
         {
            this.LSCReadabilityPanel = new Sprite();this.LSCReadabilityPanel.mouseEnabled = false;
            this.LeftText_mc.addChildAt(this.LSCReadabilityPanel,0);
         }
         this.LSCReadabilityPanel.visible = int(this.LSCOptions.background) == 0 && !this.InMinimalMode && !this.LSCShortMode && this.LeftText_mc.visible;
         var g:Graphics = this.LSCReadabilityPanel.graphics;g.clear();
         if(!this.LSCReadabilityPanel.visible)return;
         var bounds:Rectangle = null;
         if(this.LSCStatPagesPresent)bounds = new Rectangle(-15,-90,1410,345);
         else
         {
            for each(var name:String in ["PlayerName_mc","PlayerLevel_mc","Player_Level_Icon","LSCXPBack_mc","LSCXPFill_mc","LSCXPText_mc","LSCLocalClock_mc"])
            {
               var item:DisplayObject = this.LeftText_mc[name] as DisplayObject;
               if(item != null && item.visible)
               {
                  var itemBounds:Rectangle = item.getBounds(this.LeftText_mc);
                  bounds = bounds == null ? itemBounds : bounds.union(itemBounds);
               }
            }
            if(bounds == null){this.LSCReadabilityPanel.visible = false;return;}
            bounds.inflate(18,16);
         }
         g.lineStyle();g.beginFill(0x041019,0.86);g.drawRect(bounds.x,bounds.y,bounds.width,bounds.height);g.endFill();
      }

      private function LSCCompactInitialLayout() : void
      {
         var offset:Number = this.LSCStatPagesPresent ? 0 : 100;
         for each(var name:String in ["PlayerName_mc","PlayerLevel_mc","Player_Level_Icon","LSCXPBack_mc","LSCXPFill_mc","LSCXPText_mc"])
         {
            var item:DisplayObject = this.LeftText_mc[name] as DisplayObject;
            if(item == null)continue;
            if(!this.LSCIdentityBaseY.hasOwnProperty(name))this.LSCIdentityBaseY[name] = item.y;
            item.y = Number(this.LSCIdentityBaseY[name])+offset;
         }
      }

      private function LSCApplyArtwork() : void
      {
         this.LSCUpdateBackground();
         this.LSCCompactInitialLayout();
         this.LSCReadabilityBackground();
         this.LSCWalkArt(this.LeftText_mc.Player_Level_Icon,int(this.LSCOptions.badge));
         this.LSCWalkArt(this.Spinner_mc,int(this.LSCOptions.spinner));
      }
      private function LSCDrawExtras(snapshot:Object) : void
      {
         var groups:Array = [];
         if(snapshot != null && snapshot.ready && (this.LSCLastName == "" || String(snapshot.character) == this.LSCLastName))
         {
            var lifetimeCatalog:Array = [{"label": "Hours Slept", "group": "general", "key": "counter_0"}, {"label": "Hours Waiting", "group": "general", "key": "counter_1"}, {"label": "Days Passed", "group": "general", "key": "counter_2"}, {"label": "Credits Found", "group": "general", "key": "counter_3"}, {"label": "Most Credits Carried", "group": "general", "key": "counter_4"}, {"label": "Chests Looted", "group": "general", "key": "counter_5"}, {"label": "Food Eaten", "group": "general", "key": "counter_6"}, {"label": "Chems Taken", "group": "general", "key": "counter_7"}, {"label": "Data Slates Read", "group": "general", "key": "counter_8"}, {"label": "Magazines Found", "group": "general", "key": "counter_9"}, {"label": "Speech Successes", "group": "general", "key": "counter_10"}, {"label": "Powers Learned", "group": "general", "key": "counter_11"}, {"label": "People Killed", "group": "combat", "key": "counter_12"}, {"label": "Creatures Killed", "group": "combat", "key": "counter_13"}, {"label": "Robots Killed", "group": "combat", "key": "counter_14"}, {"label": "Turrets Killed", "group": "combat", "key": "counter_15"}, {"label": "Critical Strikes", "group": "combat", "key": "counter_16"}, {"label": "Legendary Enemies Killed", "group": "combat", "key": "counter_17"}, {"label": "Jet Packs Exploded", "group": "combat", "key": "counter_18"}, {"label": "Sneak Attacks", "group": "combat", "key": "counter_19"}, {"label": "Powers Used", "group": "combat", "key": "counter_20"}, {"label": "Zero G Kills", "group": "combat", "key": "counter_21"}, {"label": "Locations Discovered", "group": "exploration", "key": "counter_22"}, {"label": "Locations Explored", "group": "exploration", "key": "counter_23"}, {"label": "Systems Visited", "group": "exploration", "key": "counter_24"}, {"label": "Planets Scanned", "group": "exploration", "key": "counter_25"}, {"label": "Planets Fully Surveyed", "group": "exploration", "key": "counter_26"}, {"label": "Planets Landed On", "group": "exploration", "key": "counter_27"}, {"label": "Flora Fully Scanned", "group": "exploration", "key": "counter_28"}, {"label": "Fauna Fully Scanned", "group": "exploration", "key": "counter_29"}, {"label": "Unique Creatures Scanned", "group": "exploration", "key": "counter_30"}, {"label": "Temples Found", "group": "exploration", "key": "counter_31"}, {"label": "Food Cooked", "group": "crafting", "key": "counter_32"}, {"label": "Drugs Crafted", "group": "crafting", "key": "counter_33"}, {"label": "Items Scrapped", "group": "crafting", "key": "counter_34"}, {"label": "Items Manufactured", "group": "crafting", "key": "counter_35"}, {"label": "Objects Built", "group": "crafting", "key": "counter_36"}, {"label": "Outposts Built", "group": "crafting", "key": "counter_37"}, {"label": "Cargo Links Established", "group": "crafting", "key": "counter_38"}, {"label": "Workshops Unlocked", "group": "crafting", "key": "counter_39"}, {"label": "Quests Completed", "group": "quests", "key": "counter_40"}, {"label": "Activities Completed", "group": "quests", "key": "counter_41"}, {"label": "Main Quests Completed", "group": "quests", "key": "counter_42"}, {"label": "Side Quests Completed", "group": "quests", "key": "counter_43"}, {"label": "Freestar Collective Quests Completed", "group": "quests", "key": "counter_44"}, {"label": "Crimson Fleet Quests Completed", "group": "quests", "key": "counter_45"}, {"label": "United Colonies Quests Completed", "group": "quests", "key": "counter_46"}, {"label": "Ryujin Industries Quests Completed", "group": "quests", "key": "counter_47"}, {"label": "Grav Jumps", "group": "ship", "key": "counter_48"}, {"label": "Ships Sold", "group": "ship", "key": "counter_49"}, {"label": "Ships Painted", "group": "ship", "key": "counter_50"}, {"label": "Ship Modules Built", "group": "ship", "key": "counter_51"}, {"label": "Ships Docked With", "group": "ship", "key": "counter_52"}, {"label": "Stations Docked With", "group": "ship", "key": "counter_53"}, {"label": "Ships Customized", "group": "ship", "key": "counter_54"}, {"label": "Ship Builder Credits Spent", "group": "ship", "key": "counter_55"}, {"label": "Largest Crew Size", "group": "ship", "key": "counter_56"}, {"label": "Max Ships Owned", "group": "ship", "key": "counter_57"}, {"label": "Times Arrested", "group": "crime", "key": "counter_58"}, {"label": "Trespasses", "group": "crime", "key": "counter_59"}, {"label": "Times Caught With Contraband", "group": "crime", "key": "counter_60"}, {"label": "Total Lifetime Bounty", "group": "crime", "key": "counter_61"}, {"label": "Largest Bounty", "group": "crime", "key": "counter_62"}, {"label": "Acts of Piracy", "group": "crime", "key": "counter_63"}, {"label": "Pockets Picked", "group": "crime", "key": "counter_64"}, {"label": "Locks Picked", "group": "crime", "key": "counter_65"}, {"label": "Items Stolen", "group": "crime", "key": "counter_66"}];
            var lifetimeGroups:Array = [];
            var randomPool:Array = [];
            var categoryKeys:Array = ["general", "combat", "exploration", "crafting", "quests", "ship", "crime"];
            var categoryTitles:Array = ["GENERAL", "COMBAT", "EXPLORATION", "CRAFTING & OUTPOSTS", "QUESTS", "SHIPS", "CRIME"];
            for(var categoryIndex:int = 0;categoryIndex < categoryKeys.length;categoryIndex++)
            {
               var mode:int = int(this.LSCOptions["lifetime_"+categoryKeys[categoryIndex]]);
               if(mode == 0)continue;
               var readings:Array = [];
               for(var counterIndex:int = 0;counterIndex < lifetimeCatalog.length;counterIndex++)
               {
                  var definition:Object = lifetimeCatalog[counterIndex];
                  if(definition.group != categoryKeys[categoryIndex] || snapshot["stat_"+definition.key] == null)continue;
                  if(mode >= 100 && definition.key != "counter_"+(mode-100).toString())continue;
                  var reading:Object = {key:"lifetime",label:definition.label.toUpperCase(),value:String(snapshot["stat_"+definition.key]),rank:(Math.sin((counterIndex+1)*12.9898+this.LSCLifetimeSeed)*43758.5453)%1};
                  readings.push(reading);randomPool.push(reading);
               }
               if(mode == 2){readings.sortOn("rank",Array.NUMERIC);readings = readings.slice(0,4);}
               for(var first:int = 0;first < readings.length;first+=4)
                  lifetimeGroups.push({title:categoryTitles[categoryIndex],items:readings.slice(first,first+4)});
            }
            if(int(this.LSCOptions.lifetime_mode) == 1)
            {
               randomPool.sortOn("rank",Array.NUMERIC);
               var randomPageLimit:int = this.LSCOptions.hasOwnProperty("page_count") ? Math.max(1,Math.min(5,int(this.LSCOptions.page_count))) : 2;
               randomPool=randomPool.slice(0,randomPageLimit*4);
               lifetimeGroups=[];groups=[];
               for(var randomStart:int = 0;randomStart < randomPool.length;randomStart+=4)
                  lifetimeGroups.push({title:"RANDOM HIGHLIGHTS",items:randomPool.slice(randomStart,randomStart+4)});
            }
            groups = groups.concat(lifetimeGroups);
         }
         var pageLimit:int = this.LSCOptions.hasOwnProperty("page_count") ? Math.max(1,Math.min(5,int(this.LSCOptions.page_count))) : 2;
         if(groups.length > pageLimit)
         {
            var candidates:Array = [];
            for(var candidateIndex:int = 0;candidateIndex < groups.length;candidateIndex++)
               candidates.push({index:candidateIndex,rank:(Math.sin((candidateIndex+1)*78.233+this.LSCLifetimeSeed)*43758.5453)%1});
            candidates.sortOn("rank",Array.NUMERIC);
            candidates=candidates.slice(0,pageLimit);candidates.sortOn("index",Array.NUMERIC);
            var limitedGroups:Array = [];
            for each(var candidate:Object in candidates)limitedGroups.push(groups[int(candidate.index)]);
            groups=limitedGroups;
         }
         this.LSCStatPagesPresent = groups.length > 0;

         var expanded:Boolean = false;
         var page:int = groups.length > 0 ? (this.LSCTestManual ? ((this.LSCTestPage%groups.length)+groups.length)%groups.length : int(getTimer()/4000)%groups.length) : 0;
         if(!this.LSCTestManual)this.LSCTestPage = page;
         var selected:Array = groups.length > 0 ? groups[page].items : [];
         var title:String = groups.length > 0 ? String(groups[page].title) : "";
         var columns:int = 4;
         var count:int = Math.min(4,selected.length);
         var rows:int = Math.ceil(count/columns);
         rows = 1;
         var width:Number = 1250/columns;
         var height:Number = 116;
         var top:Number = 42;
         var clock:String = this.LSCClock(snapshot);
         var active:Boolean = !this.InMinimalMode && !this.LSCShortMode && this.LeftText_mc.visible && (groups.length > 0 || clock != "");
         var back:MovieClip = this.LeftText_mc.LSCExtraBack_mc;
         back.visible = active && groups.length > 0;back.scaleX = 1;back.scaleY = 1;back.x = 95;back.y = top;
         back.graphics.clear();back.graphics.lineStyle(1,0x8C999E,0.45);
         back.graphics.moveTo(0,26);back.graphics.lineTo(1260,26);
         this.LeftText_mc.LSCSection_mc.visible = active && groups.length > 0;
         this.LeftText_mc.LSCSection_mc.x = 105;this.LeftText_mc.LSCSection_mc.y = top;
         this.LeftText_mc.LSCSection_mc.text_tf.width = 650;this.LeftText_mc.LSCSection_mc.text_tf.height = 26;
         GlobalFunc.SetText(this.LeftText_mc.LSCSection_mc.text_tf,"<font size=\"16\" color=\"#C9D0D2\">"+title+"</font>",true);
         this.LeftText_mc.LSCPage_mc.visible = active && !expanded && groups.length > 1;
         this.LeftText_mc.LSCPage_mc.x = 780;this.LeftText_mc.LSCPage_mc.y = top;
         this.LeftText_mc.LSCPage_mc.x = 640;this.LeftText_mc.LSCPage_mc.text_tf.width = 300;this.LeftText_mc.LSCPage_mc.text_tf.height = 26;
         GlobalFunc.SetText(this.LeftText_mc.LSCPage_mc.text_tf,"<p align=\"right\"><font size=\"14\" color=\"#8C999E\">"+"A/D | D-PAD   "+(page+1).toString()+" / "+groups.length.toString()+"</font></p>",true);
         this.LeftText_mc.LSCLocalClock_mc.visible = active && clock != "";
         this.LeftText_mc.LSCLocalClock_mc.x = 955;this.LeftText_mc.LSCLocalClock_mc.y = top;
         this.LeftText_mc.LSCLocalClock_mc.text_tf.width = 400;this.LeftText_mc.LSCLocalClock_mc.text_tf.height = 26;
         GlobalFunc.SetText(this.LeftText_mc.LSCLocalClock_mc.text_tf,"<p align=\"right\"><font size=\"16\" color=\"#C9D0D2\">LOCAL TIME   "+this.LSCEscape(clock)+"</font></p>",true);
         for(var i:int = 0;i < 12;i++)
         {
            var clip:MovieClip = this.LeftText_mc["LSCExtra"+i.toString()+"_mc"] as MovieClip;
            clip.visible = active && i < count;
            clip.x = 105+i%columns*width;clip.y = top+34+int(i/columns)*66;
            clip.text_tf.x = 0;clip.text_tf.width = width-18;clip.text_tf.height = 80;clip.text_tf.wordWrap = true;clip.text_tf.multiline = true;
            if(clip.visible)
            {
               GlobalFunc.SetText(clip.text_tf,this.LSCMetricHTML(selected[i].label != null ? String(selected[i].label) : this.LSCMetricLabel(selected[i].key),selected[i].value,width-18),true);
               clip.graphics.clear();
            }
         }
         this.LSCApplyArtwork();
      }

      private function LSCMetricHTML(label:String,value:String,width:Number) : String
      {
         var labelSize:int = label.length > 28 ? 16 : 18;
         var valueSize:int = Math.max(20,Math.min(30,Math.floor(width/Math.max(1,value.length)/0.65)));
         return "<p><font size=\""+labelSize.toString()+"\" color=\"#AEB9BE\">"+this.LSCEscape(label)+"</font></p><p><font size=\""+valueSize.toString()+"\" color=\"#E0E5E7\">"+this.LSCEscape(value)+"</font></p>";
      }
      private function LSCMetricLabel(key:String) : String
      {
         var labels:Object = {health:"HEALTH",oxygen:"OXYGEN",co2:"CARBON DIOXIDE",carry_weight:"MASS",physical_resist:"PHYS",energy_resist:"ENGY",em_resist:"EM",power:"STAR POWER",experience_raw:"RAW EXPERIENCE",cell:"CELL",coordinates:"COORDINATES"};
         var samples:Object = {people_killed:"PEOPLE KILLED",health_percent:"HEALTH REMAINING",missing_health:"MISSING HEALTH",oxygen_percent:"OXYGEN REMAINING",free_capacity:"FREE CARRY CAPACITY",carry_percent:"CARRY LOAD",over_capacity:"OVER CAPACITY",test_locations:"LOCATIONS DISCOVERED",test_days:"DAYS PASSED",test_sleep:"HOURS SLEPT",test_people:"PEOPLE KILLED",test_ships:"SHIPS DESTROYED",test_quests:"QUESTS COMPLETED"};
         if(samples[key] != null)return String(samples[key]);
         return labels[key] != null ? String(labels[key]) : key.toUpperCase();
      }
      private function LSCMetricIcon(clip:MovieClip,key:String,width:Number,value:String) : void
      {
         var g:Graphics = clip.graphics;
         g.clear();
         g.lineStyle(1.4,0xD4DADB,0.92);
         if(key == "physical_resist")
         {
            var points:Array = [3,31,9,23,6,10,15,23,19,3,23,24,31,17,27,30,34,34,2,34,3,31];
            g.moveTo(points[0],points[1]);
            for(var i:int = 2;i < points.length;i+=2)g.lineTo(points[i],points[i+1]);
         }
         else if(key == "energy_resist")
         {
            g.moveTo(20,4);g.lineTo(8,23);g.lineTo(17,23);g.lineTo(12,38);g.lineTo(29,17);g.lineTo(20,17);g.lineTo(25,4);g.lineTo(20,4);
         }
         else if(key == "em_resist")
         {
            g.moveTo(2,22);g.lineTo(34,22);
            for(var j:int = 0;j <= 32;j++)
            {
               var y:Number = 22 + Math.sin(j / 32 * Math.PI * 4) * 15;
               if(j == 0)g.moveTo(j+2,y);else g.lineTo(j+2,y);
            }
         }
         else if(key == "health")
         {
            g.drawCircle(18,22,14);g.moveTo(18,13);g.lineTo(18,31);g.moveTo(9,22);g.lineTo(27,22);
         }
         else if(key == "oxygen" || key == "co2")
         {
            g.drawCircle(16,21,11);g.drawCircle(29,31,key == "oxygen" ? 4 : 5);
            if(key == "co2"){g.moveTo(11,21);g.lineTo(21,21);}
         }
         else if(key == "carry_weight")
         {
            g.drawRect(6,14,25,23);g.drawRect(13,7,11,7);g.moveTo(6,22);g.lineTo(31,22);
         }
         else if(key == "power")
         {
            g.moveTo(18,3);g.lineTo(22,17);g.lineTo(35,22);g.lineTo(22,26);g.lineTo(18,40);g.lineTo(14,26);g.lineTo(2,22);g.lineTo(14,17);g.lineTo(18,3);
         }
         else
         {
            g.drawCircle(18,22,12);g.moveTo(18,5);g.lineTo(18,39);g.moveTo(1,22);g.lineTo(35,22);
         }
         g.lineStyle(1,0x8C999E,0.34);g.moveTo(43,56);g.lineTo(width-12,56);
         var split:Array = value.split("/");
         if(split.length == 2 && key != "coordinates")
         {
            var maximum:Number = Number(split[1]);
            var current:Number = Number(split[0]);
            if(isFinite(current) && isFinite(maximum) && maximum > 0)
            {
               g.lineStyle(2,0xD4DADB,0.9);g.moveTo(43,56);g.lineTo(43+(width-55)*Math.max(0,Math.min(1,current/maximum)),56);
            }
         }
      }

      private var LSCLifetimeSeed:Number = Math.random()*10000;

      private var LSCReadabilityPanel:Sprite;
      private var LSCStatPagesPresent:Boolean = false;
      private var LSCIdentityBaseY:Object = {};
      private var LSCTestPage:int = 0;
      private var LSCTestManual:Boolean = false;
      private var LSCTestNativeOffset:Number = 0;
      private var LSCTestMotion:Sprite;
      private var LSCTestFrame:int = -1;
      private function LSCTestAnimate(r:Rectangle) : void
      {
         var frame:int = int(getTimer()/100);
         if(frame == this.LSCTestFrame)return;
         this.LSCTestFrame = frame;
         if(this.LSCTestMotion == null)
         {
            this.LSCTestMotion = new Sprite();
            this.LSCTestMotion.mouseEnabled = false;
            this.LSCBackground_mc.addChild(this.LSCTestMotion);
         }
         var g:Graphics = this.LSCTestMotion.graphics;g.clear();
         var cx:Number = r.x+r.width*0.67;
         var cy:Number = r.y+r.height*0.36;
         var radius:Number = r.height*0.245;
         var phase:Number = getTimer()/24000*Math.PI*2;
         for(var meridian:int = 0;meridian < 8;meridian++)
         {
            var angle:Number = phase+meridian*Math.PI/4;
            g.lineStyle(1,0xA9BEC6,Math.cos(angle)>0 ? 0.22 : 0.06);
            for(var step:int = 0;step <= 32;step++)
            {
               var latitude:Number = -Math.PI/2+step/32*Math.PI;
               var x:Number = cx+Math.sin(angle)*Math.cos(latitude)*radius;
               var y:Number = cy+Math.sin(latitude)*radius;
               if(step == 0)g.moveTo(x,y);else g.lineTo(x,y);
            }
         }
         var ex:Number = Math.cos(phase)*radius*1.7;
         var ey:Number = Math.sin(phase)*radius*0.42;
         g.beginFill(0xDAE9EF,0.8);
         g.drawCircle(cx+ex*Math.cos(-0.3)-ey*Math.sin(-0.3),cy+ex*Math.sin(-0.3)+ey*Math.cos(-0.3),2.5);g.endFill();
      }

      private var LSCBackground_mc:Sprite;
      private var LSCBackgroundSize:String = "";
      private var LSCCosmicFrame:int = -1;
      private var LSCCosmicMode:int = -1;
      private function LSCCosmicBackground(mode:int) : void
      {
         if(this.LSCBackground_mc == null)
         {
            this.LSCBackground_mc = new Sprite();this.LSCBackground_mc.mouseEnabled = false;
            this.addChildAt(this.LSCBackground_mc,this.getChildIndex(this.Texture_mc)+1);
         }
         this.LSCBackground_mc.visible = true;this.Texture_mc.visible = false;
         if(this.LSCTestMotion != null)this.LSCTestMotion.visible = false;
         var frame:int = int(getTimer()/100);
         if(frame == this.LSCCosmicFrame && mode == this.LSCCosmicMode)return;
         this.LSCCosmicFrame = frame;this.LSCCosmicMode = mode;this.LSCBackgroundSize = "";
         var r:Rectangle = Extensions.visibleRect;
         var g:Graphics = this.LSCBackground_mc.graphics;g.clear();
         var cx:Number = r.x+r.width*0.61;var cy:Number = r.y+r.height*0.32;
         var extent:Number = Math.max(r.width,r.height)*0.8;
         var t:Number = getTimer()/1000;
         var matrix:Matrix = new Matrix();
         matrix.createGradientBox(extent*2,extent*1.25,0,cx-extent,cy-extent*0.625);
         g.beginGradientFill(GradientType.RADIAL,mode == 3 ? [0x385668,0x102333,0x030910] : [0x182F40,0x0A1424,0x02070D],[1,1,1],[0,65,255],matrix);
         g.drawRect(r.x,r.y,r.width,r.height);g.endFill();
         // Deterministic, bounded particles: no new timers or native work.
         for(var i:int = 0;i < 190;i++)
         {
            var seed:Number = ((i*137+23)%997)/997;
            var a:Number = i*2.399963+(mode == 2 ? t*0.025 : 0);
            var depth:Number = (seed+t*(mode == 3 ? 0.24 : 0.035))%1;
            var distance:Number = 8+depth*depth*extent;
            var x:Number = cx+Math.cos(a)*distance;
            var y:Number = cy+Math.sin(a)*distance*0.64;
            var length:Number = mode == 3 ? 2+depth*depth*75 : 0.5+depth*2;
            var color:uint = i%5 == 0 ? 0xD0C4E8 : i%3 == 0 ? 0x74B7D0 : 0xD6E8EC;
            g.lineStyle(mode == 3 ? 0.7+depth : 0.8,color,0.12+depth*0.55);
            g.moveTo(x,y);g.lineTo(x+Math.cos(a)*length,y+Math.sin(a)*length*0.64);
         }
         if(mode == 2)
         {
            for(var ring:int = 0;ring < 8;ring++)
            {
               var spin:Number = t*(ring%2 == 0 ? 0.035 : -0.025)+ring*0.37;
               var radius:Number = r.height*(0.12+ring*0.042);
               g.lineStyle(1,ring%2 == 0 ? 0x91C8DB : 0x9C99C8,0.10);
               for(var point:int = 0;point <= 90;point++)
               {
                  var angle:Number = point/90*Math.PI*2;
                  var ex:Number = Math.cos(angle)*radius;
                  var ey:Number = Math.sin(angle)*radius*(0.23+ring*0.045);
                  var px:Number = cx+ex*Math.cos(spin)-ey*Math.sin(spin);
                  var py:Number = cy+ex*Math.sin(spin)+ey*Math.cos(spin);
                  if(point == 0)g.moveTo(px,py);else g.lineTo(px,py);
                  if(point%6 == 0){g.beginFill(0xD1E7EC,0.5);g.drawCircle(px,py,1.1);g.endFill();}
               }
            }
         }
         else
         {
            for(var halo:int = 0;halo < 7;halo++)
            {
               var phase:Number = (halo/7+t*0.17)%1;
               var rad:Number = 15+phase*phase*r.height*0.7;
               g.lineStyle(1.2,0x91BDD5,(1-phase)*0.10);
               g.drawEllipse(cx-rad,cy-rad*0.65,rad*2,rad*1.3);
            }
         }
         g.lineStyle(); // Fill-only glow: do not inherit the halo outline.
         // Small steady core, with no reference-video white-out.
         for(var glow:int = 6;glow > 0;glow--)
         {
            g.beginFill(0xCAE6ED,0.018);g.drawEllipse(cx-glow*6,cy-glow*2,glow*12,glow*4);g.endFill();
         }
         matrix = new Matrix();matrix.createGradientBox(r.width,r.height*0.55,Math.PI/2,r.x,r.y+r.height*0.45);
         g.lineStyle(); // No border across the text-readability overlay.
         g.beginGradientFill(GradientType.LINEAR,[0x02070D,0x02070D],[0,0.96],[0,255],matrix);
         g.drawRect(r.x,r.y+r.height*0.45,r.width,r.height*0.55);g.endFill();
      }

      private function LSCUpdateBackground() : void
      {
         if(int(this.LSCOptions.background) >= 2 && !this.InMinimalMode && !this.LSCShortMode && this.LeftText_mc.visible)
         {
            this.LSCCosmicBackground(int(this.LSCOptions.background));return;
         }
         this.LSCCosmicMode = -1;
         if(this.LSCTestMotion != null)this.LSCTestMotion.visible = true;
         var show:Boolean = int(this.LSCOptions.background) == 1 && !this.InMinimalMode && !this.LSCShortMode && this.LeftText_mc.visible;
         if(this.LSCBackground_mc == null)
         {
            this.LSCBackground_mc = new Sprite();
            this.LSCBackground_mc.mouseEnabled = false;
            this.addChildAt(this.LSCBackground_mc,this.getChildIndex(this.Texture_mc)+1);
         }
         this.LSCBackground_mc.visible = show;
         if(!show)
         {
            if(!this.InMinimalMode && !this.LSCShortMode)this.Texture_mc.visible = true;
            return;
         }
         this.Texture_mc.visible = false;
         var r:Rectangle = Extensions.visibleRect;
         this.LSCTestAnimate(r);
         var size:String = r.toString();
         if(this.LSCBackgroundSize == size)return;
         this.LSCBackgroundSize = size;
         var g:Graphics = this.LSCBackground_mc.graphics;
         g.clear();
         var matrix:Matrix = new Matrix();
         matrix.createGradientBox(r.width*1.5,r.height*1.6,0,r.x-r.width*0.05,r.y-r.height*0.25);
         g.beginGradientFill(GradientType.RADIAL,[0x17313A,0x08141B],[1,1],[0,255],matrix);
         g.drawRect(r.x,r.y,r.width,r.height);g.endFill();
         var cx:Number = r.x+r.width*0.67;
         var cy:Number = r.y+r.height*0.36;
         var radius:Number = r.height*0.245;
         // Restrained chart marks are decorative, not a claim about the player's planet.
         for(var i:int = 0;i < 74;i++)
         {
            var px:Number = r.x+((i*137+83)%997)/997*r.width;
            var py:Number = r.y+((i*233+47)%991)/991*r.height*0.77;
            g.beginFill(0xC7D6DB,i%7 == 0 ? 0.28 : 0.12);g.drawCircle(px,py,i%7 == 0 ? 1.1 : 0.6);g.endFill();
         }
         g.lineStyle(1,0x91ADB8,0.12);
         g.moveTo(r.x+r.width*0.1,cy);g.lineTo(cx-radius*1.3,cy);
         g.moveTo(cx+radius*1.3,cy);g.lineTo(r.x+r.width*0.94,cy);
         g.drawCircle(cx,cy,radius*1.2);
         g.lineStyle(1,0xA9BEC6,0.33);g.drawCircle(cx,cy,radius);
         g.lineStyle(1,0x91ADB8,0.14);
         // Animated meridians are drawn on the separate motion layer.
         for(var latitude:int = -2;latitude <= 2;latitude++)
         {
            var q:Number = latitude/3;
            var half:Number = radius*Math.sqrt(1-q*q);
            g.drawEllipse(cx-half,cy+radius*q-radius*0.07,half*2,radius*0.14);
         }
         g.lineStyle(1,0xA9BEC6,0.23);
         for(var step:int = 0;step <= 120;step++)
         {
            var angle:Number = step/120*Math.PI*2;
            var ex:Number = Math.cos(angle)*radius*1.7;
            var ey:Number = Math.sin(angle)*radius*0.42;
            var ox:Number = cx+ex*Math.cos(-0.3)-ey*Math.sin(-0.3);
            var oy:Number = cy+ex*Math.sin(-0.3)+ey*Math.cos(-0.3);
            if(step == 0)g.moveTo(ox,oy);else g.lineTo(ox,oy);
         }
         for(var tick:int = 0;tick < 48;tick++)
         {
            var a:Number = tick/48*Math.PI*2;
            var outer:Number = radius*(tick%4 == 0 ? 1.235 : 1.215);
            g.moveTo(cx+Math.cos(a)*radius*1.2,cy+Math.sin(a)*radius*1.2);
            g.lineTo(cx+Math.cos(a)*outer,cy+Math.sin(a)*outer);
         }
         g.beginFill(0xC7D6DB,0.65);g.drawCircle(cx+radius*1.2,cy,2.4);g.drawCircle(cx-radius*1.2,cy,2.4);g.endFill();
      }

      private function LSCEnabled(key:String) : Boolean
      {
         if(["credits","location","health","carry_weight","experience_raw","cell","coordinates"].indexOf(key) >= 0)return false;
         if(this.LSCOptions.hasOwnProperty(key))return int(this.LSCOptions[key]) > 0;
         var clip:MovieClip = this.LeftText_mc.LSCInfoFlags_mc.getChildByName("flag_" + key) as MovieClip;
         return clip != null && clip.totalFrames > 1;
      }

      private function LSCKeys(payload:Object) : String
      {
         var result:String = "";
         var count:uint = 0;
         for(var key:String in payload)
         {
            result += (result == "" ? "" : ",") + key;
            count++;
            if(count >= 12)
            {
               break;
            }
         }
         return result == "" ? "empty" : result;
      }

      private function OnLSCInventoryData(event:FromClientDataEvent) : void
      {
         this.LSCInventoryEvents++;
         this.LSCInventoryTime = getTimer();
         this.LSCInventoryKeys = this.LSCKeys(event.data);
         if(event.data.hasOwnProperty("uCoin"))
         {
            var coins:Number = Number(event.data.uCoin);
            if(!isNaN(coins) && isFinite(coins) && coins >= 0)
            {
               this.LSCCoins = coins;
            }
         }
         if(this.LSCInventoryEvents == 1)
         {
            trace("LSC PlayerInventoryData keys: " + this.LSCInventoryKeys);
         }
         this.ApplyLSCInformation();
      }

      private function OnLSCMapData(event:FromClientDataEvent) : void
      {
         this.LSCMapEvents++;
         this.LSCMapTime = getTimer();
         this.LSCMapKeys = this.LSCKeys(event.data);
         var location:String = "";
         var body:String = "";
         if(event.data.hasOwnProperty("sPlayerLocationName") && event.data.sPlayerLocationName != null)
         {
            location = String(event.data.sPlayerLocationName);
         }
         if(event.data.hasOwnProperty("CurrentSystemBodyInfo") && event.data.CurrentSystemBodyInfo != null)
         {
            if(event.data.CurrentSystemBodyInfo.hasOwnProperty("focusedCelestialBodyName") && event.data.CurrentSystemBodyInfo.focusedCelestialBodyName != null)
            {
               body = String(event.data.CurrentSystemBodyInfo.focusedCelestialBodyName);
            }
         }
         if(location != "" || body != "")
         {
            this.LSCPlace = body != "" && location != "" && body != location ? body + " - " + location : body + (body == "" ? location : "");
         }
         if(this.LSCMapEvents == 1)
         {
            trace("LSC DataMenuData keys: " + this.LSCMapKeys);
         }
         this.ApplyLSCInformation();
      }

      private function ApplyLSCInformation() : void
      {
         var active:Boolean = this.LeftText_mc.visible && !this.InMinimalMode && this.LSCLevel > 0;
         this.LeftText_mc.PlayerName_mc.visible = active && this.LSCEnabled("name");
         this.LeftText_mc.PlayerLevel_mc.visible = active && this.LSCEnabled("level");
         this.LeftText_mc.LoadScreenText_tf.visible = !this.InMinimalMode && this.LSCEnabled("tips");
         this.LeftText_mc.LSCXPBack_mc.visible = active && this.LSCEnabled("xp_bar");
         this.LeftText_mc.LSCXPFill_mc.visible = active && this.LSCEnabled("xp_bar");
         this.LeftText_mc.LSCXPText_mc.visible = active && this.LSCEnabled("xp_numbers");
         this.LeftText_mc.LSCXPBack_mc.height = 2;
         this.LeftText_mc.LSCXPFill_mc.height = 2;
         this.LeftText_mc.LSCXPBack_mc.x = this.LeftText_mc.PlayerName_mc.x - 10;
         this.LeftText_mc.LSCXPFill_mc.x = this.LeftText_mc.LSCXPBack_mc.x;
         this.LeftText_mc.LSCXPBack_mc.width = 510;
         this.LeftText_mc.LSCXPFill_mc.width = 510 * (this.LSCNextXP > 0 ? Math.max(0, Math.min(1, this.LSCXP / this.LSCNextXP)) : 0);
         this.LeftText_mc.LSCXPText_mc.x = this.LeftText_mc.LSCXPBack_mc.x + 290;
         this.LeftText_mc.LSCXPText_mc.text_tf.width = 220;
         GlobalFunc.SetText(this.LeftText_mc.LSCXPText_mc.text_tf, "<p align=\"right\"><font>$$XP " + Math.round(this.LSCXP) + " / " + Math.round(this.LSCNextXP) + "</font></p>", true);
         this.LeftText_mc.LSCCredits_mc.visible = false;
         this.LeftText_mc.LSCLocation_mc.visible = false;
         this.LeftText_mc.LSCDebug_mc.visible = active && this.LSCEnabled("diagnostics");
         this.LeftText_mc.LSCLocation_mc.x = this.LeftText_mc.LSCCredits_mc.visible ? 990 : 725;
         this.LeftText_mc.LSCLocation_mc.text_tf.width = this.LeftText_mc.LSCCredits_mc.visible ? 365 : 630;
         GlobalFunc.SetText(this.LeftText_mc.LSCCredits_mc.text_tf, this.LSCStatHTML("CREDITS", this.LSCCoins >= 0 ? this.LSCNumber(this.LSCCoins) : "Unavailable"), true);
         GlobalFunc.SetText(this.LeftText_mc.LSCLocation_mc.text_tf, this.LSCStatHTML("LAST LOCATION", this.LSCPlace != "" ? this.LSCPlace : "Unavailable"), true);
         var debug:String = "LSC OSF=" + (this.LSCOSFReady ? "connected" : "defaults") + " N=" + this.LSCNativeState + " #" + this.LSCNativeSequence + " Age=" + (this.LSCNativeAge < 0 ? "never" : Math.round(this.LSCNativeAge / 1000).toString() + "s") + " | Load=" + this.LSCLoadEvents + " Inv=" + this.LSCInventoryEvents + " Map=" + this.LSCMapEvents + " Errors=" + this.LSCSubscribeErrors;
         debug += " | Coin=" + (this.LSCCoins >= 0 ? "yes" : "no") + " Place=" + (this.LSCPlace != "" ? "yes" : "no");
         debug += " | Age I=" + (this.LSCInventoryTime < 0 ? "never" : Math.round((getTimer() - this.LSCInventoryTime) / 1000).toString() + "s");
         debug += " M=" + (this.LSCMapTime < 0 ? "never" : Math.round((getTimer() - this.LSCMapTime) / 1000).toString() + "s");
         GlobalFunc.SetText(this.LeftText_mc.LSCDebug_mc.text_tf, debug);
      }

      private function LSCSyncCompactCard(event:Event) : void
      {
         this.LSCApplyArtwork();
         this.LSCCard_mc.alpha = this.Spinner_mc.alpha;
         if(!this.Spinner_mc.visible || this.Spinner_mc.alpha <= 0.01)
         {
            this.LSCCard_mc.visible = false;
         }
      }
      private function LSCCompactStat(label:String,value:String) : String
      {
         return "<p><font size=\"14\" color=\"#AEB9BE\" letterSpacing=\"0.2\">" + label + "</font></p><p><font size=\"20\" color=\"#E0E5E7\">" + this.LSCEscape(value) + "</font></p>";
      }
      private function LSCRefreshCompact(event:TimerEvent = null) : void
      {
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
         var ready:Boolean = snapshot != null && snapshot.ready;
         this.LSCReadOptions(snapshot);
         if(true){this.LSCCard_mc.visible = false;return;}
         var any:Boolean = this.LSCEnabled("name") || this.LSCEnabled("credits") || this.LSCEnabled("location") || this.LSCEnabled("level") || this.LSCEnabled("xp_numbers") || this.LSCEnabled("xp_bar") || this.LSCEnabled("diagnostics") || this.LSCClockMode() > 0 || this.LSCExtraValues(snapshot,false).length > 0;
         this.LSCCard_mc.visible = this.LSCShortMode && any && this.Spinner_mc.visible && this.Spinner_mc.alpha > 0.01 && (ready || this.LSCEnabled("diagnostics") || this.LSCClockMode() > 0) && !(ready && snapshot.hideShortPanel);
         this.LSCCard_mc.alpha = this.Spinner_mc.alpha;
         this.LSCCard_mc.Name_mc.visible = this.LSCEnabled("name");
         this.LSCCard_mc.Credits_mc.visible = this.LSCEnabled("credits");
         this.LSCCard_mc.Location_mc.visible = this.LSCEnabled("location");
         this.LSCCard_mc.Debug_mc.visible = this.LSCEnabled("diagnostics");
         GlobalFunc.SetText(this.LSCCard_mc.Name_mc.text_tf, "<font size=\"22\" color=\"#E0E5E7\">" + this.LSCEscape(ready ? String(snapshot.character) : "Waiting for character data") + "</font>", true);
         GlobalFunc.SetText(this.LSCCard_mc.Credits_mc.text_tf, this.LSCCompactStat("CREDITS", ready && snapshot.creditsAvailable ? this.LSCNumber(Number(snapshot.credits)) : "Unavailable"), true);
         GlobalFunc.SetText(this.LSCCard_mc.Location_mc.text_tf, this.LSCCompactStat("LAST LOCATION", ready && snapshot.location != null && String(snapshot.location) != "" ? String(snapshot.location) : "Unavailable"), true);
         var stats:Boolean = ready && snapshot.uiStatsAvailable;
         var details:String = "";
         if(stats && this.LSCEnabled("level"))
         {
            details = "LEVEL " + snapshot.level.toString();
         }
         if(stats && this.LSCEnabled("xp_numbers"))
         {
            details += (details != "" ? "    /    " : "") + "XP " + this.LSCNumber(Number(snapshot.xp)) + " / " + this.LSCNumber(Number(snapshot.nextXP));
         }
         this.LSCCard_mc.Detail_mc.visible = details != "";
         GlobalFunc.SetText(this.LSCCard_mc.Detail_mc.text_tf, "<font size=\"13\" color=\"#AEB9BE\">" + details + "</font>", true);
         this.LSCCard_mc.BarBack_mc.visible = stats && this.LSCEnabled("xp_bar");
         this.LSCCard_mc.BarFill_mc.visible = stats && this.LSCEnabled("xp_bar");
         this.LSCCard_mc.BarFill_mc.width = stats && Number(snapshot.nextXP) > 0 ? 520 * Math.max(0,Math.min(1,Number(snapshot.xp) / Number(snapshot.nextXP))) : 0;
         var header:Boolean = this.LSCEnabled("name");
         var body:Boolean = this.LSCEnabled("credits") || this.LSCEnabled("location");
         var footer:Boolean = stats && (this.LSCEnabled("level") || this.LSCEnabled("xp_numbers") || this.LSCEnabled("xp_bar"));
         var clockText:String = this.LSCClock(snapshot);
         this.LSCCard_mc.Clock_mc.visible = clockText != "";
         this.LSCCard_mc.Clock_mc.x = 390;
         this.LSCCard_mc.Clock_mc.y = 10;
         this.LSCCard_mc.Clock_mc.text_tf.width = 150;
         this.LSCCard_mc.Clock_mc.text_tf.height = 52;
         GlobalFunc.SetText(this.LSCCard_mc.Clock_mc.text_tf,this.LSCCompactStat("LOCAL PC TIME",clockText),true);
         this.LSCCard_mc.Name_mc.text_tf.width = clockText != "" ? 355 : 520;
         header = header || clockText != "";
         var extra:Array = this.LSCExtraValues(snapshot,false);
         var headerHeight:Number = clockText != "" ? 48 : (header ? 29 : 0);
         var extraY:Number = 24 + headerHeight + (body ? 51 : 0) + (footer ? 32 : 0);
         var page:int = extra.length > 2 ? int(getTimer() / 4000) % int(Math.ceil(extra.length / 2)) : 0;
         for(var i:int = 0;i < 2;i++)
         {
            var clip:MovieClip = this.LSCCard_mc[i == 0 ? "ExtraA_mc" : "ExtraB_mc"] as MovieClip;
            var at:int = page * 2 + i;
            clip.visible = at < extra.length;
            clip.x = 20 + i * 260;
            clip.y = extraY;
            clip.text_tf.x = 38;
            clip.text_tf.width = 212;
            clip.text_tf.height = 52;
            if(clip.visible){GlobalFunc.SetText(clip.text_tf,this.LSCCompactStat(this.LSCMetricLabel(extra[at].key),extra[at].value),true);this.LSCMetricIcon(clip,extra[at].key,250,extra[at].value);}
         }
         var height:Number = extraY + (extra.length > 0 ? 54 : 0);
         var bodyY:Number = 14 + headerHeight;
         var footerY:Number = 14 + headerHeight + (body ? 51 : 0);
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
         GlobalFunc.SetText(this.LSCCard_mc.Debug_mc.text_tf, "OSF=" + (this.LSCOSFReady ? "connected" : "defaults") + " N=" + state + (ready ? " #" + snapshot.sequence.toString() + " Age=" + Math.round(Number(snapshot.ageMs) / 1000).toString() + "s" : ""));
      }

      override protected function onSetSafeRect() : void
      {
         var _loc1_:Rectangle = Extensions.visibleRect;
         this.LSCCard_mc.x = _loc1_.x + 64;
         this.LSCCard_mc.y = _loc1_.y + _loc1_.height - 200;
         this.BlackRect_mc.width = _loc1_.width;
         this.BlackRect_mc.height = _loc1_.height;
         this.BlackRect_mc.x = _loc1_.x;
         this.BlackRect_mc.y = _loc1_.y;
         this.Gradient_mc.width = _loc1_.width;
         GlobalFunc.LockToSafeRect(this.Gradient_mc,"BC",SafeX,0,true);
         this.onImageLoadAttemptComplete();
      }
      
      public function SetLoadingText(param1:String) : *
      {
         this.BlackRect_mc.visible = true;
         this.LeftText_mc.LoadScreenText_tf.visible = true;
         var _loc2_:int = int(this.LeftText_mc.LoadScreenText_tf.numLines);
         GlobalFunc.SetText(this.LeftText_mc.LoadScreenText_tf,param1,false);
      }
      
      public function SetMinimalMode() : *
      {
         this.LeftText_mc.visible = false;
         this.Texture_mc.visible = false;
         this.BlackRect_mc.visible = true;
      }
      
      public function SpinnerOnly() : *
      {
         this.SetMinimalMode();
         this.BlackRect_mc.visible = false;
      }
      
      private function refreshLoadingText() : *
      {
         BSUIDataManager.dispatchEvent(new Event("LoadingMenu_RefreshText"));
      }
      
      private function OhHideProgressBar() : *
      {
         this.BuildingShaders_mc.visible = false;
      }
   }
}







