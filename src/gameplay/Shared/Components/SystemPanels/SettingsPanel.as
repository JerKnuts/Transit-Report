package Shared.Components.SystemPanels
{
   import Shared.AS3.BSScrollingConfigParams;
   import Shared.AS3.BSScrollingContainer;
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.Events.CustomEvent;
   import Shared.AS3.Events.ScrollingEvent;
   import Shared.Components.ButtonControls.ButtonBar.ButtonBar;
   import Shared.Components.ButtonControls.ButtonData.ButtonBaseData;
   import Shared.Components.ButtonControls.ButtonData.UserEventData;
   import Shared.Components.ButtonControls.ButtonFactory.ButtonFactory;
   import Shared.Components.ButtonControls.Buttons.IButton;
   import Shared.EnumHelper;
   import Shared.GlobalFunc;
   import Shared.InventoryItemUtils;
   import Shared.PlatformUtils;
   import flash.display.MovieClip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol150")]
   public class SettingsPanel extends MovieClip implements IPanel
   {
      
      public var ButtonBar_mc:ButtonBar;
      
      public var CategoryPanel_mc:MovieClip;
      
      public var ControlsPanel_mc:MovieClip;
      
      public var OptionsPanel_mc:MovieClip;
      
      public var PEOPanel_mc:MovieClip;
      
      public var Prompt_mc:MovieClip;
      
      public var Version_mc:MovieClip;
      
      public var Background_mc:MovieClip;
      
      protected var ConfirmButton:IButton = null;
      
      protected var DeleteBindingButton:IButton = null;
      
      protected var DefaultsButton:IButton = null;
      
      protected var BackButton:IButton = null;
      
      protected var ConfirmButtonData:ButtonBaseData;
      
      protected var CancelButtonData:ButtonBaseData;
      
      public var TRConfig:Function;
      private var TRVanillaRows:Array = [];

      private function TRBridgeFrame(event:Event) : void
      {
         if(!this.visible || this.TRConfig == null || this.TRVanillaRows.length == 0)return;
         this.TRRefreshSettings();
         this.removeEventListener(Event.ENTER_FRAME,this.TRBridgeFrame);
      }

      public function TRRefreshSettings() : void
      {
         if(this.TRVanillaRows.length == 0)return;
         var selected:int = this.PEOList_mc.selectedIndex;
         this.PEOList_mc.InitializeEntries(this.TRBuildRows(this.TRVanillaRows));
         this.PEOList_mc.selectedIndex = Math.max(0,selected);
      }
      private var TRDefinitions:Array = [{"key": "theme", "label": "Theme", "hint": "Choose a faction, or Random Each Load to pick one faction per loading screen. Artwork slots set to Theme share that choice. Other artwork choices stay independent.", "values": [0, 1, 2, 3, 4, 5, 6, 7, 8], "labels": ["Individual selections", "Constellation", "Crimson Fleet", "Freestar Collective", "House Va'ruun", "Ryujin Industries", "Trackers Alliance", "United Colonies", "Random Each Load"], "default": 0, "kind": "enum", "group": "Appearance"}, {"key": "badge", "label": "Character badge", "hint": "Theme uses the selected faction artwork (or Orbiting Star/Orbital Chart with Individual selections). All other choices apply independently. Choose a built-in design or Custom. Custom randomly selects a PNG/JPG/JPEG/GIF from Documents/My Games/Starfield/Transit Report/Artwork/Badges each load. Any filenames; up to 64 images. Restart after changes.", "values": [0, 1, 6, 9, 10, 2, 3], "labels": ["Original", "Orbiting Star", "Jump Gate", "Signal Star", "Theme", "Hidden", "Custom"], "default": 1, "kind": "enum", "group": "Appearance"}, {"key": "spinner", "label": "Loading indicator", "hint": "Theme uses the selected faction artwork (or Orbiting Star/Orbital Chart with Individual selections). All other choices apply independently. Choose a built-in design or Custom. Custom randomly selects a PNG/JPG/JPEG/GIF from Documents/My Games/Starfield/Transit Report/Artwork/Indicators each load. Any filenames; up to 64 images. Restart after changes.", "values": [0, 1, 6, 9, 10, 2, 3], "labels": ["Original", "Orbiting Star", "Jump Gate", "Signal Star", "Theme", "Hidden", "Custom"], "default": 2, "kind": "enum", "group": "Appearance"}, {"key": "background", "label": "Loading background", "hint": "Theme uses the selected faction artwork (or Orbiting Star/Orbital Chart with Individual selections). All other choices apply independently. Choose a built-in design or Custom. Custom randomly selects a PNG/JPG/JPEG/GIF from Documents/My Games/Starfield/Transit Report/Artwork/Backgrounds each load. Any filenames; up to 64 images. Restart after changes.", "values": [0, 1, 3, 8, 10, 11, 4], "labels": ["Game images", "Orbital chart", "Grav-jump tunnel", "Survey Sweep", "Theme", "Hidden", "Custom"], "default": 1, "kind": "enum", "group": "Appearance"}, {"key": "badge_size", "label": "Character badge size", "hint": "Scale independently from the enlarged baseline. Normal (100%) equals the previous 150% size.", "values": [50, 75, 100, 125, 150], "labels": ["Extra Small (50%)", "Small (75%)", "Normal (100%)", "Large (125%)", "Extra Large (150%)"], "default": 100, "kind": "enum", "group": "Appearance"}, {"key": "indicator_size", "label": "Loading indicator size", "hint": "Scale independently from the enlarged baseline. Normal (100%) equals the previous 150% size.", "values": [50, 75, 100, 125, 150], "labels": ["Extra Small (50%)", "Small (75%)", "Normal (100%)", "Large (125%)", "Extra Large (150%)"], "default": 100, "kind": "enum", "group": "Appearance"}, {"key": "hide_zero", "label": "Hide zero-value stats", "hint": "Omit numeric zero readings before building pages, including random highlights. Empty pages are not displayed.", "values": [0, 1], "labels": ["Off", "On"], "default": 0, "kind": "bool", "group": "Stats"}, {"key": "character", "label": "Character", "hint": "Name and level.", "values": [0, 1], "labels": ["Off", "On"], "default": 1, "kind": "bool", "group": "Full loading screen"}, {"key": "progress", "label": "Progress", "hint": "XP bar and XP numbers.", "values": [0, 1], "labels": ["Off", "On"], "default": 1, "kind": "bool", "group": "Full loading screen"}, {"key": "lifetime_enabled", "label": "Lifetime stats", "hint": "Show randomized lifetime statistics on full loading screens.", "values": [0, 1], "labels": ["Off", "On"], "default": 1, "kind": "bool", "group": "Full loading screen"}, {"key": "tips", "label": "Loading tips", "hint": "Show loading tips on loading screens.", "values": [0, 1], "labels": ["Off", "On"], "default": 1, "kind": "bool", "group": "Full loading screen"}, {"key": "clock", "label": "Local PC time", "hint": "Your computer clock in its local time zone. Updates during loading.", "values": [0, 1, 2], "labels": ["Hidden", "12-hour", "24-hour"], "default": 1, "kind": "enum", "group": "Full loading screen"}, {"key": "page_count", "label": "Number of stat pages", "hint": "Maximum 1\u20135 pages per full load, with four larger lifetime readings per page. Default: two pages.", "values": [1, 2, 3, 4, 5], "labels": ["1 page", "2 pages", "3 pages", "4 pages", "5 pages"], "default": 2, "kind": "enum", "group": "Stat pages"}];
      private var CategoryRequested:Array;
      
      private var CurrentState:uint;
      
      private var CurrentCategory:uint;
      
      private var RemappingControl:Boolean;
      
      private var WaitingOnControlsValidation:Boolean;
      
      private var HasControlConflicts:Boolean;
      
      private var ActiveList:BSScrollingContainer;
      
      private var HidePromptTimer:Timer = new Timer(750,1);
      
      protected var PromptText:String = "";
      
      protected var RestorablePromptText:String = "";
      
      private const SPS_NONE:int = EnumHelper.GetEnum(0);
      
      private const SPS_CATEGORY:int = EnumHelper.GetEnum();
      
      private const SPS_CONTROLS:int = EnumHelper.GetEnum();
      
      private const SPS_OPTIONS:int = EnumHelper.GetEnum();
      
      private const SPS_PEO:int = EnumHelper.GetEnum();
      
      private const SPS_CONFIRMING_DEFAULTS:int = EnumHelper.GetEnum();
      
      private const SPS_CONFIRMING_CONFLICTS:int = EnumHelper.GetEnum();
      
      protected const CONFLICT_COLUMNS:Number = 1;
      
      protected const CONFLICT_ROWS:Number = 11;
      
      protected const CONFLICT_COLUMNS_SPACING:Number = 0;
      
      protected const CONFLICT_ROWS_SPACING:Number = 2;
      
      protected const DESC_PADDING:Number = 30;
      
      private const FFE_CONTROLS_SAVED_EVENT:String = "SettingsDataModel_ControlsSaved";
      
      private const FFE_SETTINGS_SAVED_EVENT:String = "SettingsDataModel_SettingsSaved";
      
      private const FFE_RESET_TO_DEFAULTS:String = "SettingsDataModel_ResetDefaults";
      
      private const FFE_MISSING_BINDINGS_ERROR:String = "SettingsDataModel_MissingRequiredBindingError";
      
      private const FFE_CONTROLS_VALIDATED_EVENT:String = "SettingsDataModel_ControlsValidatedEvent";
      
      private const PEO_CATEGORY:int = EnumHelper.GetEnum(0);
      
      private const DISPLAY_CATEGORY:int = EnumHelper.GetEnum();
      
      private const INTERFACE_CATEGORY:int = EnumHelper.GetEnum();
      
      private const CONTROLS_CATEGORY:int = EnumHelper.GetEnum();
      
      private const CONTROL_MAPPINGS_CATEGORY:int = EnumHelper.GetEnum();
      
      private const AUDIO_CATEGORY:int = EnumHelper.GetEnum();
      
      private const ACCESSIBILITY_CATEGORY:int = EnumHelper.GetEnum();
      
      private const TOTAL_CATEGORIES:int = EnumHelper.GetEnum();
      
      private var _showPSText:Boolean = false;
      
      protected var DeleteBindingButtonData:ButtonBaseData;
      
      protected var DefaultsButtonData:ButtonBaseData;
      
      protected var BackButtonData:ButtonBaseData;
      
      public function SettingsPanel()
      {
         this.ConfirmButtonData = new ButtonBaseData("$CONFIRM",new UserEventData("Accept",this.onAccept));
         this.CancelButtonData = new ButtonBaseData("$CANCEL",new UserEventData("Cancel",this.onCancel));
         this.DeleteBindingButtonData = new ButtonBaseData("$DELETE_BINDING",new UserEventData("XButton",this.onDeleteBinding));
         this.DefaultsButtonData = new ButtonBaseData("$DEFAULTS",new UserEventData("YButton",this.onResetToDefaults));
         this.BackButtonData = new ButtonBaseData("$BACK",new UserEventData("Cancel",this.onCancel));
         super();
         this.addEventListener(Event.ENTER_FRAME,this.TRBridgeFrame,false,0,true);
         this.ActiveList = null;
         this.CurrentState = this.SPS_NONE;
         this.CurrentCategory = this.PEO_CATEGORY;
         this.RemappingControl = false;
         this.WaitingOnControlsValidation = false;
         this.HasControlConflicts = false;
         this.CategoryRequested = new Array();
         var _loc1_:uint = uint(this.PEO_CATEGORY);
         while(_loc1_ < this.TOTAL_CATEGORIES)
         {
            this.CategoryRequested.push(false);
            _loc1_++;
         }
         this.SetUpLists();
         this.OptionsPanel_mc.Description_mc.Details_mc.Text_mc.Text_tf.autoSize = TextFieldAutoSize.LEFT;
         this.OptionsPanel_mc.Description_mc.Details_mc.Text_mc.Text_tf.multiline = true;
         this.PEOPanel_mc.Description_mc.Details_mc.Text_mc.Text_tf.autoSize = TextFieldAutoSize.LEFT;
         this.PEOPanel_mc.Description_mc.Details_mc.Text_mc.Text_tf.multiline = true;
         BSUIDataManager.Subscribe("SettingsCategoriesData",this.OnSettingsCategoriesDataUpdate);
         BSUIDataManager.Subscribe("SettingsData",this.OnSettingsDataUpdate);
         BSUIDataManager.Subscribe("PEOData",this.OnPEODataUpdate);
         BSUIDataManager.Subscribe("ControlBindingsData",this.OnControlBindingsDataUpdate);
         BSUIDataManager.Subscribe("FireForgetEventData",this.OnFireForgetEvent);
         BSUIDataManager.Subscribe("ControlConflictsData",this.OnControlConflictsUpdate);
         BSUIDataManager.Subscribe("RemapErrorData",this.OnRemapErrorEvent);
         addEventListener(ScrollingEvent.SELECTION_CHANGE,this.OnEntryHover);
         addEventListener(ScrollingEvent.ITEM_PRESS,this.OnEntryPress);
         addEventListener(ScrollingEvent.PLAY_FOCUS_SOUND,this.PlayFocusSound);
         addEventListener(SettingsControlListEntry.ACTIVE_BINDING_CHANGED,this.OnActiveBindingChanged);
         this.HidePromptTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onHideErrorTimerComplete);
         BSUIDataManager.dispatchEvent(new Event("SettingsPanel_OpenSettings",true));
      }
      
      protected function get CategoryList_mc() : BSScrollingContainer
      {
         return this.CategoryPanel_mc.CategoryList_mc;
      }
      
      protected function get ControlsList_mc() : SettingsControlList
      {
         return this.ControlsPanel_mc.ControlsList_mc;
      }
      
      protected function get OptionsList_mc() : SettingsOptionList
      {
         return this.OptionsPanel_mc.OptionsList_mc;
      }
      
      protected function get PEOList_mc() : SettingsOptionList
      {
         return this.PEOPanel_mc.OptionsList_mc;
      }
      
      protected function get CancelButton() : IButton
      {
         return this.ButtonBar_mc.CancelButton_mc;
      }
      
      public function set ShowPSText(param1:Boolean) : void
      {
         this._showPSText = param1;
      }
      
      public function get ShowPSText() : Boolean
      {
         return this._showPSText;
      }
      
      private function get RemapPromptText() : String
      {
         return this.ShowPSText ? "$Remap_Prompt_PS" : "$Remap_Prompt";
      }
      
      protected function get RebindHintText() : String
      {
         return this.ShowPSText ? "$Remap_BindingRequiredHint_PS" : "$Remap_BindingRequiredHint";
      }
      
      public function get activeList() : BSScrollingContainer
      {
         return this.ActiveList;
      }
      
      public function get remappingControl() : Boolean
      {
         return this.RemappingControl;
      }
      
      public function set remappingControl(param1:Boolean) : *
      {
         var _loc2_:String = null;
         if(this.RemappingControl != param1)
         {
            this.RemappingControl = param1;
            _loc2_ = this.RemappingControl ? this.RemapPromptText : "";
            this.SetPromptText(_loc2_);
            this.UpdateButtons();
            this.SetListInteractivity();
            if(!this.RemappingControl)
            {
               this.ControlsList_mc.ClearEntryListenState();
               this.ShowRemapConfirmationPopup(false);
               GlobalFunc.PlayMenuSound("UIMenuGeneralTriggerFire");
            }
            else
            {
               GlobalFunc.PlayMenuSound("UIMenuGeneralTriggerDown");
            }
         }
      }
      
      private function set currentState(param1:uint) : *
      {
         if(this.CurrentState != param1)
         {
            this.ActiveList = null;
            this.CurrentState = param1;
            switch(this.CurrentState)
            {
               case this.SPS_CATEGORY:
                  this.ActiveList = this.CategoryList_mc;
                  if(this.CategoryList_mc.entryCount == 0)
                  {
                     BSUIDataManager.dispatchEvent(new Event("SettingsPanel_OpenSettings",true));
                  }
                  break;
               case this.SPS_CONTROLS:
                  this.ActiveList = this.ControlsList_mc;
                  break;
               case this.SPS_OPTIONS:
                  this.ActiveList = this.OptionsList_mc;
                  break;
               case this.SPS_PEO:
                  this.ActiveList = this.PEOList_mc;
            }
            dispatchEvent(new Event(PanelUtils.ACTIVE_LIST_CHANGED,true,true));
            this.UpdateButtons();
            this.UpdateComponentVisibility();
            this.SetListInteractivity();
         }
      }
      
      public function SetUpLists() : void
      {
         var _loc1_:BSScrollingConfigParams = new BSScrollingConfigParams();
         _loc1_.VerticalSpacing = 2;
         _loc1_.EntryClassName = "Shared.Components.SystemPanels.SettingsCategoryListEntry";
         this.CategoryList_mc.Configure(_loc1_);
         _loc1_.EntryClassName = "Shared.Components.SystemPanels.SettingsControlListEntry";
         this.ControlsList_mc.Configure(_loc1_);
         _loc1_.EntryClassName = "OptionListEntry";
         this.OptionsList_mc.Configure(_loc1_);
         _loc1_.EntryClassName = "Shared.Components.SystemPanels.PEOListEntry";
         _loc1_.TruncateToFit = true;
         this.PEOList_mc.Configure(_loc1_);
         this.ControlsPanel_mc.ConflictsSection_mc.ConflictsList_mc.Configure(SettingsControlConflictEntry,this.CONFLICT_COLUMNS,this.CONFLICT_ROWS,this.CONFLICT_COLUMNS_SPACING,this.CONFLICT_ROWS_SPACING);
         BSUIDataManager.dispatchEvent(new Event("SettingsPanel_OpenSettings",true));
      }
      
      public function SetPlatformSpecificText(param1:uint) : void
      {
         this.ShowPSText = param1 == PlatformUtils.PLATFORM_PS4;
         GlobalFunc.SetText(this.ControlsPanel_mc.BindingHint_mc.text_tf,this.RebindHintText);
      }
      
      public function Open() : void
      {
         this.visible = true;
         this.SetPromptText("");
         if(this.CurrentState == this.SPS_NONE)
         {
            this.currentState = this.SPS_CATEGORY;
         }
      }
      
      public function Close() : void
      {
         this.visible = false;
         this.SetPromptText("");
         this.currentState = this.SPS_NONE;
         this.CategoryList_mc.selectedIndex = 0;
         this.ControlsList_mc.ResetSelection();
         this.OptionsList_mc.selectedIndex = 0;
         this.PEOList_mc.selectedIndex = 0;
         this.ShowRemapConfirmationPopup(false);
      }
      
      public function SetBackground(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.Background_mc.x = param1;
         this.Background_mc.y = param2;
         this.Background_mc.width = param3;
         this.Background_mc.height = param4;
      }
      
      public function PopulateButtonBar(param1:uint, param2:int) : void
      {
         this.ButtonBar_mc.Initialize(param1,param2);
         this.ControlsPanel_mc.ConfirmationPopup_mc.PopulateButtonBar(param1,param2);
         this.ConfirmButton = ButtonFactory.AddToButtonBar("BasicButton",this.ConfirmButtonData,this.ButtonBar_mc);
         this.ButtonBar_mc.AddButtonWithData(this.CancelButton,this.CancelButtonData);
         this.DeleteBindingButton = ButtonFactory.AddToButtonBar("BasicButton",this.DeleteBindingButtonData,this.ButtonBar_mc);
         this.DefaultsButton = ButtonFactory.AddToButtonBar("BasicButton",this.DefaultsButtonData,this.ButtonBar_mc);
         this.BackButton = ButtonFactory.AddToButtonBar("BasicButton",this.BackButtonData,this.ButtonBar_mc);
         this.UpdateButtons();
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         var _loc3_:Boolean = false;
         if(this.ControlsPanel_mc.ConfirmationPopup_mc.active)
         {
            _loc3_ = Boolean(this.ControlsPanel_mc.ConfirmationPopup_mc.ProcessUserEvent(param1,param2));
         }
         if(!_loc3_)
         {
            _loc3_ = this.ProcessEventForButtonBar(param1,param2);
         }
         return _loc3_;
      }
      
      protected function ProcessEventForButtonBar(param1:String, param2:Boolean) : Boolean
      {
         return this.ButtonBar_mc.ProcessUserEvent(param1,param2);
      }
      
      public function OnConfirmDataUpdate(param1:Boolean) : void
      {
      }
      
      public function SetVersion(param1:String) : void
      {
         GlobalFunc.SetText(this.Version_mc.Text_mc.Text_tf,param1);
      }
      
      protected function UpdateButtons() : void
      {
         var _loc1_:Boolean = this.CurrentState == this.SPS_CATEGORY;
         var _loc2_:Boolean = this.CurrentState == this.SPS_CONTROLS;
         var _loc3_:Boolean = this.CurrentState == this.SPS_OPTIONS;
         var _loc4_:Boolean = this.CurrentState == this.SPS_PEO;
         var _loc5_:Boolean = this.CurrentState == this.SPS_CONFIRMING_DEFAULTS;
         var _loc6_:Boolean = this.CurrentState == this.SPS_CONFIRMING_CONFLICTS;
         this.ConfirmButtonData.sButtonText = _loc6_ ? "$EXIT ANYWAY" : "$CONFIRM";
         this.ConfirmButton.SetButtonData(this.ConfirmButtonData);
         this.ConfirmButton.Visible = !this.RemappingControl && (_loc5_ || _loc6_);
         this.ConfirmButton.Enabled = this.ConfirmButton.Visible;
         this.CancelButtonData.sButtonText = _loc6_ ? "$RETURN TO CONTROLS" : "$CANCEL";
         this.CancelButton.SetButtonData(this.CancelButtonData);
         this.CancelButton.Visible = !this.RemappingControl && (_loc5_ || _loc6_);
         this.CancelButton.Enabled = this.CancelButton.Visible;
         this.DefaultsButton.Visible = !this.RemappingControl && (_loc2_ || _loc3_ || _loc4_);
         this.DefaultsButton.Enabled = this.DefaultsButton.Visible;
         this.UpdateDeleteBindingButton();
         this.BackButton.Visible = !this.RemappingControl && (_loc1_ || _loc2_ || _loc3_ || _loc4_);
         this.BackButton.Enabled = this.BackButton.Visible;
         this.ButtonBar_mc.RefreshButtons();
      }
      
      private function UpdateComponentVisibility() : void
      {
         var _loc1_:Boolean = this.CurrentState == this.SPS_CATEGORY;
         var _loc2_:Boolean = this.CurrentState == this.SPS_CONTROLS;
         var _loc3_:Boolean = this.CurrentState == this.SPS_OPTIONS;
         var _loc4_:Boolean = this.CurrentState == this.SPS_PEO;
         var _loc5_:Boolean = this.CurrentState == this.SPS_CONFIRMING_DEFAULTS || this.CurrentState == this.SPS_CONFIRMING_CONFLICTS;
         var _loc6_:uint = this.GetStateGivenCategory();
         this.CategoryPanel_mc.visible = _loc1_;
         this.ControlsPanel_mc.visible = _loc2_ || _loc5_ && _loc6_ == this.SPS_CONTROLS;
         this.OptionsPanel_mc.visible = _loc3_ || _loc5_ && _loc6_ == this.SPS_OPTIONS;
         this.PEOPanel_mc.visible = _loc4_ || _loc5_ && _loc6_ == this.SPS_PEO;
      }
      
      private function SetListInteractivity() : *
      {
         var _loc1_:Boolean = this.RemappingControl || this.CurrentState == this.SPS_CONFIRMING_DEFAULTS || this.CurrentState == this.SPS_CONFIRMING_CONFLICTS;
         this.CategoryList_mc.disableSelection = _loc1_;
         this.CategoryList_mc.disableInput = _loc1_;
         this.ControlsList_mc.disableSelection = _loc1_;
         this.ControlsList_mc.disableInput = _loc1_;
         this.OptionsList_mc.disableSelection = _loc1_;
         this.OptionsList_mc.disableInput = _loc1_;
         this.PEOList_mc.disableSelection = _loc1_;
         this.PEOList_mc.disableInput = _loc1_;
      }
      
      private function OpenCategorySubPanel() : void
      {
         this.currentState = this.GetStateGivenCategory();
         if(this.CurrentState == this.SPS_OPTIONS)
         {
            GlobalFunc.SetText(this.OptionsPanel_mc.Header_mc.Text_mc.Text_tf,this.CategoryList_mc.selectedEntry.sText);
            this.OptionsList_mc.SetFilterComparitor(function(param1:Object):Boolean
            {
               return param1.uCategory != undefined && param1.uCategory == CurrentCategory;
            });
         }
         else if(this.CurrentState == this.SPS_PEO)
         {
            GlobalFunc.SetText(this.PEOPanel_mc.Header_mc.Text_mc.Text_tf,this.CategoryList_mc.selectedEntry.sText);
            this.PEOList_mc.SetFilterComparitor(function(param1:Object):Boolean
            {
               return param1.uCategory != undefined && param1.uCategory == CurrentCategory;
            });
         }
         else if(this.CurrentState == this.SPS_CONTROLS)
         {
            GlobalFunc.SetText(this.ControlsPanel_mc.Header_mc.Text_mc.Text_tf,this.CategoryList_mc.selectedEntry.sText);
         }
         if(!this.CategoryRequested[this.CurrentCategory])
         {
            BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_OpenCategory",{"categoryID":this.CurrentCategory}));
            this.CategoryRequested[this.CurrentCategory] = true;
         }
         else if(this.CurrentCategory == this.DISPLAY_CATEGORY)
         {
            BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_OpenCategory",{"categoryID":this.CurrentCategory}));
            if(this.ActiveList != null)
            {
               this.ActiveList.selectedIndex = 0;
            }
         }
         else if(this.ActiveList != null)
         {
            if(this.ActiveList == this.ControlsList_mc)
            {
               this.ControlsList_mc.ResetSelection();
            }
            else
            {
               this.ActiveList.selectedIndex = 0;
            }
         }
      }
      
      private function GetStateGivenCategory() : uint
      {
         var _loc1_:uint = uint(this.SPS_CATEGORY);
         switch(this.CurrentCategory)
         {
            case this.CONTROL_MAPPINGS_CATEGORY:
               _loc1_ = uint(this.SPS_CONTROLS);
               break;
            case this.PEO_CATEGORY:
               _loc1_ = uint(this.SPS_PEO);
               break;
            default:
               _loc1_ = uint(this.SPS_OPTIONS);
         }
         return _loc1_;
      }
      
      protected function UpdateDeleteBindingButton() : void
      {
         var _loc1_:Boolean = !this.RemappingControl && this.CurrentState == this.SPS_CONTROLS && this.ControlsList_mc.activePriority == ControlBinding.ALT_KEY;
         this.DeleteBindingButton.Visible = _loc1_;
         this.DeleteBindingButton.Enabled = _loc1_;
      }
      
      private function ShowRemapConfirmationPopup(param1:Boolean) : void
      {
         this.ControlsPanel_mc.ConfirmationPopup_mc.active = param1;
      }
      
      private function OnSettingsCategoriesDataUpdate(param1:FromClientDataEvent) : void
      {
         this.CategoryList_mc.InitializeEntries(param1.data.aCategoryHeaders);
         if(this.CategoryList_mc.selectedIndex < 0)
         {
            this.CategoryList_mc.selectedIndex = 0;
         }
      }
      
      private function OnSettingsDataUpdate(param1:FromClientDataEvent) : void
      {
         removeEventListener(SettingsOptionListEntry.VALUE_CHANGE,this.OnSettingValueChange);
         this.OptionsList_mc.InitializeEntries(param1.data.aGeneralSettingsList);
         if(this.OptionsList_mc.selectedIndex < 0)
         {
            this.OptionsList_mc.selectedIndex = 0;
         }
         addEventListener(SettingsOptionListEntry.VALUE_CHANGE,this.OnSettingValueChange);
      }
      
      private function TRBridge() : Function
      {
         return this.TRConfig;
      }
      private function TRBuildRows(vanilla:Array) : Array
      {
         this.TRVanillaRows = vanilla.concat();
         var result:Array = vanilla.concat();
         var bridge:Function = this.TRBridge();
         if(bridge == null)return result;
         var reply:Object = bridge("get");
         if(reply == null || reply.ok !== true)return result;
         result.push({uID:4048551935,uType:5,uCategory:0,sText:"TRANSIT REPORT",sDescription:"Loading screen customization",bIsPEO:false,bEnabled:true,stepperData:{aStepperOptions:[],uIndex:0},checkBoxData:{bChecked:false},sliderData:{fValue:0},peoData:{aRewards:[]}});
         for(var index:int = 0;index < this.TRDefinitions.length;index++)
         {
            var definition:Object = this.TRDefinitions[index];
            var selected:int = definition.values.indexOf(int(reply[definition.key]));
            if(selected < 0)selected = definition.values.indexOf(definition["default"]);
            result.push({uID:4048551936+index,uType:definition.kind == "bool" ? 3 : 2,uCategory:0,sText:definition.label,sDescription:definition.hint,bIsPEO:false,bEnabled:true,bSubSetting:true,_trSetting:true,stepperData:{aStepperOptions:definition.labels,uIndex:selected},checkBoxData:{bChecked:selected == 1,bOffCustomText:false,bOnCustomText:false},sliderData:{fValue:0,sDisplayValue:""},peoData:{aRewards:[]}});
         }
         return result;
      }
      private function TRSettingChange(event:CustomEvent) : Boolean
      {
         var selected:Object = this.PEOList_mc.selectedEntry;
         if(selected == null || selected._trSetting !== true)return false;
         var index:int = int(uint(event.params.id)-4048551936);
         if(index < 0 || index >= this.TRDefinitions.length)return true;
         var definition:Object = this.TRDefinitions[index];
         var choice:int = int(event.params.value);
         if(choice < 0 || choice >= definition.values.length)return true;
         var bridge:Function = this.TRBridge();
         var reply:Object = bridge != null ? bridge("set",definition.key,definition.values[choice]) : null;
         if(reply == null || reply.ok !== true)this.SetPromptText("Transit Report: settings could not be saved.");
         var position:int = this.PEOList_mc.selectedIndex;
         this.PEOList_mc.InitializeEntries(this.TRBuildRows(this.TRVanillaRows));
         this.PEOList_mc.selectedIndex = position;
         return true;
      }

      private function OnPEODataUpdate(param1:FromClientDataEvent) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Object = null;
         removeEventListener(SettingsOptionListEntry.VALUE_CHANGE,this.OnSettingValueChange);
         this.PEOList_mc.InitializeEntries(this.TRBuildRows(param1.data.aGeneralSettingsList));
         if(this.PEOList_mc.selectedIndex < 0)
         {
            this.PEOList_mc.selectedIndex = 0;
         }
         var _loc2_:Number = 0;
         var _loc3_:* = 0;
         while(_loc3_ < param1.data.aGeneralSettingsList.length)
         {
            _loc4_ = uint.MAX_VALUE;
            _loc5_ = param1.data.aGeneralSettingsList[_loc3_];
            switch(_loc5_.uType)
            {
               case SettingsOptionListEntry.SDT_STEPPER:
               case SettingsOptionListEntry.SDT_LARGE_STEPPER:
                  _loc4_ = _loc5_.stepperData.uIndex;
                  break;
               case SettingsOptionListEntry.SDT_CHECKBOX:
                  _loc4_ = _loc5_.checkBoxData.bChecked ? 1 : 0;
                  break;
               case SettingsOptionListEntry.SDT_HEADER:
                  break;
               default:
                  GlobalFunc.TraceWarning("unhandled PEO setting type: " + _loc5_.uType);
            }
            if(_loc4_ != uint.MAX_VALUE)
            {
               _loc2_ += _loc4_ < _loc5_.peoData.aRewards.length ? _loc5_.peoData.aRewards[_loc4_] : 0;
            }
            _loc3_++;
         }
         GlobalFunc.SetText(this.PEOPanel_mc.TotalXP_mc.XPCounter_mc.Text_tf,(_loc2_ >= 0 ? "+" : "") + _loc2_ + "%");
         addEventListener(SettingsOptionListEntry.VALUE_CHANGE,this.OnSettingValueChange);
      }
      
      private function OnControlBindingsDataUpdate(param1:FromClientDataEvent) : void
      {
         this.ControlsList_mc.InitializeEntries(param1.data.aInputSettingsList);
         if(this.ControlsList_mc.selectedIndex < 0)
         {
            this.ControlsList_mc.ResetSelection();
         }
         this.remappingControl = param1.data.bRemappingControl;
         var _loc2_:Boolean = Boolean(param1.data.bShowSecondaryBindings);
         var _loc3_:Boolean = this.ControlsPanel_mc.currentFrameLabel == "showSecondary";
         if(_loc2_ != _loc3_)
         {
            if(_loc2_)
            {
               this.ControlsPanel_mc.gotoAndStop("showSecondary");
            }
            else
            {
               this.ControlsPanel_mc.gotoAndStop("hideSecondary");
            }
         }
         this.ControlsList_mc.EnableAltBindings(_loc2_);
      }
      
      private function OnFireForgetEvent(param1:FromClientDataEvent) : void
      {
         var _loc2_:* = param1.data;
         if(GlobalFunc.HasFireForgetEvent(_loc2_,this.FFE_RESET_TO_DEFAULTS))
         {
            var trReset:Function = this.TRBridge();
            if(this.CurrentCategory == this.PEO_CATEGORY && trReset != null)trReset("reset");
            this.currentState = this.GetStateGivenCategory();
            this.SetPromptText("");
         }
         else if(GlobalFunc.HasFireForgetEvent(_loc2_,this.FFE_CONTROLS_VALIDATED_EVENT))
         {
            this.ControlsValidated(true);
         }
         else if(GlobalFunc.HasFireForgetEvent(_loc2_,this.FFE_MISSING_BINDINGS_ERROR))
         {
            this.ControlsValidated(false);
         }
      }
      
      private function OnControlConflictsUpdate(param1:FromClientDataEvent) : void
      {
         this.ControlsPanel_mc.ConflictsSection_mc.ConflictsList_mc.entryData = param1.data.aAllConflicts;
         this.HasControlConflicts = param1.data.aAllConflicts.length > 0;
      }
      
      private function OnRemapErrorEvent(param1:FromClientDataEvent) : void
      {
         if(param1.data.sErrorText != "")
         {
            this.ShowRemapConfirmationPopup(false);
            this.SetPromptText(param1.data.sErrorText,false);
            GlobalFunc.PlayMenuSound(GlobalFunc.CANCEL_SOUND);
            this.HidePromptTimer.start();
         }
      }
      
      private function ControlsValidated(param1:Boolean) : void
      {
         if(this.WaitingOnControlsValidation)
         {
            this.WaitingOnControlsValidation = false;
            if(param1)
            {
               if(this.HasControlConflicts)
               {
                  this.currentState = this.SPS_CONFIRMING_CONFLICTS;
                  this.SetPromptText("$Remap_BindingConflictsWarning");
               }
               else
               {
                  this.SaveAndCloseControls();
               }
            }
            else
            {
               this.SetPromptText("$Remap_MissingBindingsError");
               GlobalFunc.PlayMenuSound(GlobalFunc.CANCEL_SOUND);
               this.HidePromptTimer.start();
            }
         }
      }
      
      private function SaveAndCloseControls() : void
      {
         this.SetPromptText("");
         BSUIDataManager.dispatchEvent(new Event("SettingsPanel_SaveControls",true));
         this.currentState = this.SPS_CATEGORY;
      }
      
      private function SetPromptText(param1:String, param2:Boolean = true) : void
      {
         this.Version_mc.visible = param1 == "";
         this.PromptText = param1;
         if(param2)
         {
            this.RestorablePromptText = param1;
         }
         this.HidePromptTimer.reset();
         GlobalFunc.SetText(this.Prompt_mc.Text_mc.Text_tf,this.PromptText);
      }
      
      private function onHideErrorTimerComplete() : *
      {
         this.SetPromptText(this.RestorablePromptText);
      }
      
      private function OnEntryHover(param1:Event) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         if(param1.target == this.CategoryList_mc && this.CategoryList_mc.selectedEntry != null)
         {
            this.CurrentCategory = this.CategoryList_mc.selectedEntry.uID;
         }
         else if(param1.target == this.OptionsList_mc && this.OptionsList_mc.selectedEntry != null || param1.target == this.PEOList_mc && this.PEOList_mc.selectedEntry != null)
         {
            _loc2_ = param1.target == this.OptionsList_mc ? this.OptionsPanel_mc : this.PEOPanel_mc;
            _loc3_ = (param1.target == this.OptionsList_mc ? this.OptionsList_mc : this.PEOList_mc).selectedEntry;
            _loc2_.Description_mc.Details_mc.Text_mc.Text_tf.autoSize = TextFieldAutoSize.LEFT;
            _loc2_.Description_mc.Details_mc.Text_mc.Text_tf.multiline = true;
            GlobalFunc.SetText(_loc2_.Description_mc.Header_mc.Text_mc.Text_tf,_loc3_.sText);
            if(param1.target == this.PEOList_mc)
            {
               GlobalFunc.SetText(_loc2_.Description_mc.Details_mc.Text_mc.Text_tf,"$XP");
               _loc4_ = _loc2_.Description_mc.Details_mc.Text_mc.Text_tf.text;
               _loc5_ = "<font color=\"" + InventoryItemUtils.SELECTED_TAB + "\">";
               _loc6_ = _loc3_.peoData;
               _loc7_ = new Array();
               _loc8_ = 0;
               while(_loc8_ < _loc6_.aDescriptions.length)
               {
                  _loc9_ = "";
                  switch(_loc3_.uType)
                  {
                     case SettingsOptionListEntry.SDT_STEPPER:
                     case SettingsOptionListEntry.SDT_LARGE_STEPPER:
                        _loc9_ = _loc3_.stepperData.aStepperOptions[_loc8_];
                        break;
                     case SettingsOptionListEntry.SDT_CHECKBOX:
                        _loc11_ = _loc3_.checkBoxData.bOffCustomText != "" ? _loc3_.checkBoxData.bOffCustomText : "$OFF";
                        _loc12_ = _loc3_.checkBoxData.bOnCustomText != "" ? _loc3_.checkBoxData.bOnCustomText : "$ON";
                        _loc9_ = _loc8_ == SettingsOptionListEntry.CHECKBOX_OFF_VALUE ? _loc11_ : _loc12_;
                  }
                  _loc9_ = _loc5_ + _loc9_ + "</font>";
                  _loc10_ = _loc5_ + "(" + (_loc6_.aRewards[_loc8_] >= 0 ? "+" : "") + _loc6_.aRewards[_loc8_] + "% " + _loc4_ + ")</font>";
                  _loc7_.push(GlobalFunc.DoSubstitutions(_loc6_.aDescriptions[_loc8_],[_loc9_,_loc10_]));
                  _loc8_++;
               }
               GlobalFunc.SetText(_loc2_.Description_mc.Details_mc.Text_mc.Text_tf,_loc3_.sDescription,true,false,0,false,0,_loc7_);
            }
            else
            {
               GlobalFunc.SetText(_loc2_.Description_mc.Details_mc.Text_mc.Text_tf,_loc3_.sDescription);
            }
            this.UpdatePreview(_loc3_.sPreview);
         }
      }
      
      protected function UpdatePreview(param1:String) : void
      {
         this.OptionsPanel_mc.Preview_mc.UpdatePreview(param1);
         this.OptionsPanel_mc.Preview_mc.y = this.OptionsPanel_mc.Description_mc.y + this.OptionsPanel_mc.Description_mc.height + this.DESC_PADDING;
      }
      
      private function OnEntryPress(param1:Event) : void
      {
         if(!this.CategoryList_mc.selectedEntry.bDisabled)
         {
            if(param1.target == this.CategoryList_mc)
            {
               GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
               this.CurrentCategory = this.CategoryList_mc.selectedEntry.uID;
               this.OpenCategorySubPanel();
            }
            else if(param1.target == this.ControlsList_mc)
            {
               GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
               this.ControlsList_mc.OnEntryPressed();
            }
            else if(param1.target == this.OptionsList_mc)
            {
               GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
               this.OptionsList_mc.OnEntryPressed();
            }
            else if(param1.target == this.PEOList_mc)
            {
               GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
               this.PEOList_mc.OnEntryPressed();
            }
         }
      }
      
      private function OnSettingValueChange(param1:CustomEvent) : void
      {
         if(this.TRSettingChange(param1))return;
         switch(param1.params.type)
         {
            case SettingsOptionListEntry.SDT_SLIDER:
               BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_SliderChanged",{
                  "fValue":param1.params.value,
                  "uSettingID":param1.params.id,
                  "bIsPEO":param1.params.isPEO
               }));
               break;
            case SettingsOptionListEntry.SDT_STEPPER:
            case SettingsOptionListEntry.SDT_LARGE_STEPPER:
               BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_StepperChanged",{
                  "uIndex":param1.params.value,
                  "uSettingID":param1.params.id,
                  "bIsPEO":param1.params.isPEO
               }));
               break;
            case SettingsOptionListEntry.SDT_CHECKBOX:
               BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_CheckBoxChanged",{
                  "bChecked":param1.params.value == SettingsOptionListEntry.CHECKBOX_ON_VALUE,
                  "uSettingID":param1.params.id,
                  "bIsPEO":param1.params.isPEO
               }));
               break;
            case SettingsOptionListEntry.SDT_LINK:
               BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_LinkClicked",{"uSettingID":param1.params.id}));
         }
      }
      
      private function PlayFocusSound(param1:Event) : void
      {
         if(this.visible)
         {
            GlobalFunc.PlayMenuSound(GlobalFunc.FOCUS_SOUND);
         }
      }
      
      protected function OnActiveBindingChanged(param1:Event) : void
      {
         this.UpdateDeleteBindingButton();
         this.ButtonBar_mc.RefreshButtons();
      }
      
      private function onAccept() : void
      {
         GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
         switch(this.CurrentState)
         {
            case this.SPS_CONFIRMING_DEFAULTS:
               this.SetPromptText("");
               BSUIDataManager.dispatchEvent(new CustomEvent("SettingsPanel_ResetToDefaults",{"categoryID":this.CurrentCategory}));
               break;
            case this.SPS_CONFIRMING_CONFLICTS:
               this.SaveAndCloseControls();
         }
      }
      
      private function onResetToDefaults() : void
      {
         this.currentState = this.SPS_CONFIRMING_DEFAULTS;
         this.SetPromptText("$Reset settings to default values?");
      }
      
      private function onDeleteBinding() : void
      {
         GlobalFunc.PlayMenuSound(GlobalFunc.OK_SOUND);
         this.ControlsList_mc.OnDeleteBinding();
      }
      
      private function onCancel() : void
      {
         GlobalFunc.PlayMenuSound(GlobalFunc.CANCEL_SOUND);
         switch(this.CurrentState)
         {
            case this.SPS_CATEGORY:
               dispatchEvent(new Event(PanelUtils.CLOSE_PANEL,true,true));
               break;
            case this.SPS_CONTROLS:
               this.WaitingOnControlsValidation = true;
               BSUIDataManager.dispatchEvent(new Event("SettingsPanel_ValidateControls",true));
               break;
            case this.SPS_OPTIONS:
            case this.SPS_PEO:
               BSUIDataManager.dispatchEvent(new Event("SettingsPanel_SaveSettings",true));
               this.currentState = this.SPS_CATEGORY;
               break;
            case this.SPS_CONFIRMING_DEFAULTS:
            case this.SPS_CONFIRMING_CONFLICTS:
               this.currentState = this.GetStateGivenCategory();
               this.SetPromptText("");
         }
      }
   }
}



