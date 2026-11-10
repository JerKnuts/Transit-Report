// OSF Settings native adapter. Callbacks copy settings only; no engine/UI calls.
constexpr const char* kModId="loading-screen-configurator";
OSFSettings::API::Client g_osf;
OSFSettings::API::Subscription g_osfSubscription{};
std::mutex g_settingsMutex;
std::map<std::string,int> g_displaySettings={{"lifetime_enabled",1},{"badge_size",100},{"indicator_size",100},{"hide_zero",0},{"theme",0},{"badge",1},{"spinner",2},{"background",1},{"character",1},{"progress",1},{"credits",1},{"location",1},{"clock",1},{"tips",1},{"vitals",1},{"carry_weight",1},{"resistances",1},{"condition_capacity",1},{"lifetime_test",1},{"lifetime_mode",1},{"lifetime_general",1},{"lifetime_combat",1},{"lifetime_exploration",1},{"lifetime_crafting",1},{"lifetime_quests",1},{"lifetime_ship",1},{"lifetime_crime",1},{"details",0},{"diagnostics",0},{"name",1},{"level",1},{"xp_bar",1},{"xp_numbers",1},{"health",1},{"oxygen",1},{"co2",1},{"power",1},{"physical_resist",1},{"energy_resist",1},{"em_resist",1},{"experience_raw",0},{"cell",0},{"coordinates",0},{"short",0},{"density",0},{"page_count",2},{"wait_continue",0}};
bool g_settingsReady{false};
void RefreshOSF() noexcept
{
    if(g_useGameplaySettings||g_useInstallerSettings){RefreshStandalone();return;}
    try
    {
        std::map<std::string,int> next;
        unsigned readCount=0;
        {std::scoped_lock lock(g_settingsMutex);next=g_displaySettings;}
    {std::string value; if(g_osf.GetEnum(kModId,"theme",value)==OSFSettings::API::Status::Ok){++readCount;
        if(value=="individual")next["theme"]=0;
        else if(value=="constellation")next["theme"]=1;
        else if(value=="crimson-fleet")next["theme"]=2;
        else if(value=="freestar-collective")next["theme"]=3;
        else if(value=="house-varuun")next["theme"]=4;
        else if(value=="ryujin-industries")next["theme"]=5;
        else if(value=="trackers-alliance")next["theme"]=6;
        else if(value=="united-colonies")next["theme"]=7;
        else if(value=="random")next["theme"]=8;
    }}
    {std::string value; if(g_osf.GetEnum(kModId,"badge",value)==OSFSettings::API::Status::Ok){++readCount;
        if(value=="theme")next["badge"]=10;
        else if(value=="original")next["badge"]=0;
        else if(value=="custom")next["badge"]=1;
        else if(value=="hidden")next["badge"]=2;
        else if(value=="folder")next["badge"]=3;
        else if(value=="jump-gate")next["badge"]=6;
        else if(value=="signal-star")next["badge"]=9;
    }}
    {std::string value; if(g_osf.GetEnum(kModId,"spinner",value)==OSFSettings::API::Status::Ok){++readCount;
        if(value=="theme")next["spinner"]=10;
        else if(value=="original")next["spinner"]=0;
        else if(value=="custom")next["spinner"]=1;
        else if(value=="hidden")next["spinner"]=2;
        else if(value=="folder")next["spinner"]=3;
        else if(value=="jump-gate")next["spinner"]=6;
        else if(value=="signal-star")next["spinner"]=9;
    }}
    {std::string value; if(g_osf.GetEnum(kModId,"background",value)==OSFSettings::API::Status::Ok){++readCount;
        if(value=="theme")next["background"]=10;
        else if(value=="original")next["background"]=0;
        else if(value=="orbital")next["background"]=1;
        else if(value=="grav")next["background"]=3;
        else if(value=="custom")next["background"]=4;
        else if(value=="survey-sweep")next["background"]=8;
    }}
    {bool value; if(g_osf.GetBool(kModId,"character",&value)==OSFSettings::API::Status::Ok){next["character"] = value?1:0;++readCount;}}
    {bool value; if(g_osf.GetBool(kModId,"progress",&value)==OSFSettings::API::Status::Ok){next["progress"] = value?1:0;++readCount;}}
    {std::string value; if(g_osf.GetEnum(kModId,"clock",value)==OSFSettings::API::Status::Ok){++readCount;
        if(value=="off")next["clock"]=0;
        else if(value=="12h")next["clock"]=1;
        else if(value=="24h")next["clock"]=2;
    }}
    {bool value; if(g_osf.GetBool(kModId,"tips",&value)==OSFSettings::API::Status::Ok){next["tips"] = value?1:0;++readCount;}}
    {std::string value;if(g_osf.GetEnum(kModId,"badge_size",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="extra-small")next["badge_size"] =50;else if(value=="small")next["badge_size"]=75;else if(value=="normal")next["badge_size"]=100;else if(value=="large")next["badge_size"]=125;else if(value=="extra-large")next["badge_size"]=150;}}
    {std::string value;if(g_osf.GetEnum(kModId,"indicator_size",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="extra-small")next["indicator_size"] =50;else if(value=="small")next["indicator_size"]=75;else if(value=="normal")next["indicator_size"]=100;else if(value=="large")next["indicator_size"]=125;else if(value=="extra-large")next["indicator_size"]=150;}}
    {bool value;if(g_osf.GetBool(kModId,"hide_zero",&value)==OSFSettings::API::Status::Ok){++readCount;next["hide_zero"]=value?1:0;}}
    {bool value;if(g_osf.GetBool(kModId,"lifetime_enabled",&value)==OSFSettings::API::Status::Ok){++readCount;next["lifetime_enabled"]=value?1:0;}}
    next["diagnostics"]=0;
    next["name"]=next["character"];
    next["level"]=next["character"];
    next["xp_bar"]=next["progress"];
    next["xp_numbers"]=next["progress"];
    next["health"]=next["vitals"];
    next["oxygen"]=0;
    next["co2"]=0;
    next["power"]=0;
    next["physical_resist"]=0;
    next["energy_resist"]=0;
    next["em_resist"]=0;
    next["experience_raw"]=next["details"];
    next["cell"]=next["details"];
    next["coordinates"]=next["details"];
    next["lifetime_test"]=next["lifetime_enabled"];next["lifetime_mode"]=1;
    for(const char* category:{"general","combat","exploration","crafting","quests","ship","crime"})next[std::string("lifetime_")+category]=1;
    {std::string value;if(g_osf.GetEnum(kModId,"page_count",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="1")next["page_count"]=1;else if(value=="2")next["page_count"]=2;else if(value=="3")next["page_count"]=3;else if(value=="4")next["page_count"]=4;else if(value=="5")next["page_count"]=5;}}
    next["resistances"]=0;next["condition_capacity"]=0;
    next["carry_weight"]=0;
    next["cell"]=0;
    next["coordinates"]=0;
    next["credits"]=0;
    next["details"]=0;
    next["experience_raw"]=0;
    next["health"]=0;
    next["location"]=0;
    next["vitals"]=0;
    next["short"]=0;next["density"]=0;
        std::scoped_lock lock(g_settingsMutex);
        g_displaySettings=std::move(next);
        g_settingsReady=g_osf.IsReady()&&readCount==13;
        if(!g_settingsReady)REX::WARN("LSC OSF schema incomplete: {} settings read.",readCount);
    }
    catch(...){REX::WARN("LSC settings refresh failed; previous settings retained.");}
}
void OnOSFChanged(const char*,const char*,void*) noexcept {RefreshOSF();}
void InitializeOSF()
{
    if(!g_osf.Init()||!g_osf.IsReady())
    {
        REX::WARN("LSC OSF Settings API unavailable. Defaults remain active; install OSF Settings to configure this mod.");
        return;
    }
    const auto status=g_osf.Subscribe(kModId,OnOSFChanged,nullptr,&g_osfSubscription);
    if(status!=OSFSettings::API::Status::Ok)REX::WARN("LSC OSF subscription failed: {}",static_cast<unsigned>(status));
    RefreshOSF();
    REX::INFO("LSC OSF Settings initialized. Live changes are read without game or save writes.");
}
