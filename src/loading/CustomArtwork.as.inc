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
         if(index == 1 && !Boolean(this.TRArtUsingDefaults[index]))
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
