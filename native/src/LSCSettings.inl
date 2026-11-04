// OSF Settings native adapter. Callbacks copy settings only; no engine/UI calls.
constexpr const char* kModId="loading-screen-configurator";
OSFSettings::API::Client g_osf;
OSFSettings::API::Subscription g_osfSubscription{};
std::mutex g_settingsMutex;
std::map<std::string,int> g_displaySettings={{"theme",0},{"badge",1},{"spinner",2},{"background",1},{"character",1},{"progress",1},{"credits",1},{"location",1},{"clock",1},{"tips",1},{"vitals",1},{"carry_weight",1},{"resistances",1},{"condition_capacity",1},{"lifetime_test",1},{"lifetime_mode",1},{"lifetime_general",1},{"lifetime_combat",1},{"lifetime_exploration",1},{"lifetime_crafting",1},{"lifetime_quests",1},{"lifetime_ship",1},{"lifetime_crime",1},{"details",0},{"diagnostics",0},{"name",1},{"level",1},{"xp_bar",1},{"xp_numbers",1},{"health",1},{"oxygen",1},{"co2",1},{"power",1},{"physical_resist",1},{"energy_resist",1},{"em_resist",1},{"experience_raw",0},{"cell",0},{"coordinates",0},{"short",0},{"density",0},{"page_count",2},{"wait_continue",0}};
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
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_mode",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="categories")next["lifetime_mode"]=0;else if(value=="random")next["lifetime_mode"]=1;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_general",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_general"]=0;else if(value=="all")next["lifetime_general"]=1;else if(value=="random")next["lifetime_general"]=2;else if(value=="counter_0")next["lifetime_general"]=100;else if(value=="counter_1")next["lifetime_general"]=101;else if(value=="counter_2")next["lifetime_general"]=102;else if(value=="counter_3")next["lifetime_general"]=103;else if(value=="counter_4")next["lifetime_general"]=104;else if(value=="counter_5")next["lifetime_general"]=105;else if(value=="counter_6")next["lifetime_general"]=106;else if(value=="counter_7")next["lifetime_general"]=107;else if(value=="counter_8")next["lifetime_general"]=108;else if(value=="counter_9")next["lifetime_general"]=109;else if(value=="counter_10")next["lifetime_general"]=110;else if(value=="counter_11")next["lifetime_general"]=111;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_combat",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_combat"]=0;else if(value=="all")next["lifetime_combat"]=1;else if(value=="random")next["lifetime_combat"]=2;else if(value=="counter_12")next["lifetime_combat"]=112;else if(value=="counter_13")next["lifetime_combat"]=113;else if(value=="counter_14")next["lifetime_combat"]=114;else if(value=="counter_15")next["lifetime_combat"]=115;else if(value=="counter_16")next["lifetime_combat"]=116;else if(value=="counter_17")next["lifetime_combat"]=117;else if(value=="counter_18")next["lifetime_combat"]=118;else if(value=="counter_19")next["lifetime_combat"]=119;else if(value=="counter_20")next["lifetime_combat"]=120;else if(value=="counter_21")next["lifetime_combat"]=121;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_exploration",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_exploration"]=0;else if(value=="all")next["lifetime_exploration"]=1;else if(value=="random")next["lifetime_exploration"]=2;else if(value=="counter_22")next["lifetime_exploration"]=122;else if(value=="counter_23")next["lifetime_exploration"]=123;else if(value=="counter_24")next["lifetime_exploration"]=124;else if(value=="counter_25")next["lifetime_exploration"]=125;else if(value=="counter_26")next["lifetime_exploration"]=126;else if(value=="counter_27")next["lifetime_exploration"]=127;else if(value=="counter_28")next["lifetime_exploration"]=128;else if(value=="counter_29")next["lifetime_exploration"]=129;else if(value=="counter_30")next["lifetime_exploration"]=130;else if(value=="counter_31")next["lifetime_exploration"]=131;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_crafting",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_crafting"]=0;else if(value=="all")next["lifetime_crafting"]=1;else if(value=="random")next["lifetime_crafting"]=2;else if(value=="counter_32")next["lifetime_crafting"]=132;else if(value=="counter_33")next["lifetime_crafting"]=133;else if(value=="counter_34")next["lifetime_crafting"]=134;else if(value=="counter_35")next["lifetime_crafting"]=135;else if(value=="counter_36")next["lifetime_crafting"]=136;else if(value=="counter_37")next["lifetime_crafting"]=137;else if(value=="counter_38")next["lifetime_crafting"]=138;else if(value=="counter_39")next["lifetime_crafting"]=139;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_quests",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_quests"]=0;else if(value=="all")next["lifetime_quests"]=1;else if(value=="random")next["lifetime_quests"]=2;else if(value=="counter_40")next["lifetime_quests"]=140;else if(value=="counter_41")next["lifetime_quests"]=141;else if(value=="counter_42")next["lifetime_quests"]=142;else if(value=="counter_43")next["lifetime_quests"]=143;else if(value=="counter_44")next["lifetime_quests"]=144;else if(value=="counter_45")next["lifetime_quests"]=145;else if(value=="counter_46")next["lifetime_quests"]=146;else if(value=="counter_47")next["lifetime_quests"]=147;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_ship",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_ship"]=0;else if(value=="all")next["lifetime_ship"]=1;else if(value=="random")next["lifetime_ship"]=2;else if(value=="counter_48")next["lifetime_ship"]=148;else if(value=="counter_49")next["lifetime_ship"]=149;else if(value=="counter_50")next["lifetime_ship"]=150;else if(value=="counter_51")next["lifetime_ship"]=151;else if(value=="counter_52")next["lifetime_ship"]=152;else if(value=="counter_53")next["lifetime_ship"]=153;else if(value=="counter_54")next["lifetime_ship"]=154;else if(value=="counter_55")next["lifetime_ship"]=155;else if(value=="counter_56")next["lifetime_ship"]=156;else if(value=="counter_57")next["lifetime_ship"]=157;}}
    {std::string value;if(g_osf.GetEnum(kModId,"lifetime_crime",value)==OSFSettings::API::Status::Ok){++readCount;if(value=="off")next["lifetime_crime"]=0;else if(value=="all")next["lifetime_crime"]=1;else if(value=="random")next["lifetime_crime"]=2;else if(value=="counter_58")next["lifetime_crime"]=158;else if(value=="counter_59")next["lifetime_crime"]=159;else if(value=="counter_60")next["lifetime_crime"]=160;else if(value=="counter_61")next["lifetime_crime"]=161;else if(value=="counter_62")next["lifetime_crime"]=162;else if(value=="counter_63")next["lifetime_crime"]=163;else if(value=="counter_64")next["lifetime_crime"]=164;else if(value=="counter_65")next["lifetime_crime"]=165;else if(value=="counter_66")next["lifetime_crime"]=166;}}
    next["lifetime_test"]=next["lifetime_general"]!=0||next["lifetime_combat"]!=0||next["lifetime_exploration"]!=0||next["lifetime_crafting"]!=0||next["lifetime_quests"]!=0||next["lifetime_ship"]!=0||next["lifetime_crime"]!=0;
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
        g_settingsReady=g_osf.IsReady()&&readCount==17;
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
