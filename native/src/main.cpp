// GPL-3.0-or-later with the CommonLibSF linking/modding exceptions.
// Native companion source. Python authoring tools retain their separate license.
#include <SFSE/SFSE.h>
#include <RE/Starfield.h>
#include <chrono>
#include <mutex>
#include <string>
#include <cstdint>
#include <limits>
#include <cmath>
#include <map>
#include <format>
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#include <ShlObj.h>
#include <filesystem>
#include <vector>
#include <algorithm>
#include <Xinput.h>
#ifdef max
#undef max
#endif
#ifdef min
#undef min
#endif
#include "OSFSettings.h"
#include "NavigationState.h"
#include "StatMemory.h"
#include "ArtworkCache.h"
#include "ArtworkTheme.h"



namespace
{
    bool g_useGameplaySettings=false;
    bool g_useInstallerSettings=false;
    void RefreshStandalone() noexcept;
    #include "LSCSettings.inl"
    #include "GameplaySettings.inl"
    constexpr REL::Version kRuntime{1, 16, 244, 0};
    constexpr std::uint32_t kCreditForm = 0x0000000F;
    using Clock = std::chrono::steady_clock;

    struct Snapshot
    {
        // Extra-stat snapshot
        std::map<std::string,std::string> extra;
        bool ready{false};
        bool creditsAvailable{false};
        std::uint64_t credits{0};
        std::uint64_t sequence{0};
        std::uint64_t generation{0};
        std::string character;
        std::string location;
        std::string status{"waiting for loaded gameplay"};
        Clock::time_point captured{};
    };
    std::mutex g_mutex;
    Snapshot g_snapshot;
    struct UIStats
    {
        std::string character;
        double level{0}, xp{0}, nextXP{0};
        std::uint64_t generation{0};
        bool valid{false};
    };
    UIStats g_uiStats;
    bool g_fullPanelActive{false};


    Clock::time_point g_lastAttempt{};
    bool g_started{false};

    std::mutex g_captureMutex;
    Clock::time_point g_counterReadySince{};
    bool g_counterAttempted{false};
    std::map<std::string,std::string> g_counterValues;
    struct CounterScan
    {
        bool active{false};
        std::uintptr_t table{0};
        std::uint32_t count{0}, cursor{0}, slices{0};
        std::map<std::string,std::string> pending;
        Clock::time_point started{};
        double workMs{0}, peakMs{0};
    };
    CounterScan g_counterScan;
    void CaptureSingleCounter()
    {
        bool enabled=false;
        {std::scoped_lock lock(g_settingsMutex);enabled=g_displaySettings.at("lifetime_test")!=0;}
        if(!enabled){g_counterReadySince={};g_counterScan={};return;}
        if(g_counterAttempted)return;
        if(g_counterReadySince==Clock::time_point{}){g_counterReadySince=Clock::now();return;}
        if(Clock::now()-g_counterReadySince<std::chrono::seconds(3))return;
        // Never traverse the entire table in one game-thread task.
        // Keep game-owned reads on the game thread and publish only a completed scan.
        static REL::Relocation<std::uint32_t*> countAddress{RE::ID::MiscStatManager::EntryCount};
        static REL::Relocation<std::uintptr_t*> tableAddress{RE::ID::MiscStatManager::TableBase};
        std::uint32_t count{};std::uintptr_t table{};
        using namespace LSCStatMemory;
        if(!CopyStatBytes(&count,countAddress.get(),sizeof(count))||count==0||count>512||!CopyStatBytes(&table,tableAddress.get(),sizeof(table)))
        {g_counterScan={};g_counterAttempted=true;return;}
        struct CounterName {const char* name;const char* group;};
        static constexpr CounterName catalog[]={
            {"Hours Slept","general"},
            {"Hours Waiting","general"},
            {"Days Passed","general"},
            {"Credits Found","general"},
            {"Most Credits Carried","general"},
            {"Chests Looted","general"},
            {"Food Eaten","general"},
            {"Chems Taken","general"},
            {"Data Slates Read","general"},
            {"Magazines Found","general"},
            {"Speech Successes","general"},
            {"Powers Learned","general"},
            {"People Killed","combat"},
            {"Creatures Killed","combat"},
            {"Robots Killed","combat"},
            {"Turrets Killed","combat"},
            {"Critical Strikes","combat"},
            {"Legendary Enemies Killed","combat"},
            {"Jet Packs Exploded","combat"},
            {"Sneak Attacks","combat"},
            {"Powers Used","combat"},
            {"Zero G Kills","combat"},
            {"Locations Discovered","exploration"},
            {"Locations Explored","exploration"},
            {"Systems Visited","exploration"},
            {"Planets Scanned","exploration"},
            {"Planets Fully Surveyed","exploration"},
            {"Planets Landed On","exploration"},
            {"Flora Fully Scanned","exploration"},
            {"Fauna Fully Scanned","exploration"},
            {"Unique Creatures Scanned","exploration"},
            {"Temples Found","exploration"},
            {"Food Cooked","crafting"},
            {"Drugs Crafted","crafting"},
            {"Items Scrapped","crafting"},
            {"Items Manufactured","crafting"},
            {"Objects Built","crafting"},
            {"Outposts Built","crafting"},
            {"Cargo Links Established","crafting"},
            {"Workshops Unlocked","crafting"},
            {"Quests Completed","quests"},
            {"Activities Completed","quests"},
            {"Main Quests Completed","quests"},
            {"Side Quests Completed","quests"},
            {"Freestar Collective Quests Completed","quests"},
            {"Crimson Fleet Quests Completed","quests"},
            {"United Colonies Quests Completed","quests"},
            {"Ryujin Industries Quests Completed","quests"},
            {"Grav Jumps","ship"},
            {"Ships Sold","ship"},
            {"Ships Painted","ship"},
            {"Ship Modules Built","ship"},
            {"Ships Docked With","ship"},
            {"Stations Docked With","ship"},
            {"Ships Customized","ship"},
            {"Ship Builder Credits Spent","ship"},
            {"Largest Crew Size","ship"},
            {"Max Ships Owned","ship"},
            {"Times Arrested","crime"},
            {"Trespasses","crime"},
            {"Times Caught With Contraband","crime"},
            {"Total Lifetime Bounty","crime"},
            {"Largest Bounty","crime"},
            {"Acts of Piracy","crime"},
            {"Pockets Picked","crime"},
            {"Locks Picked","crime"},
            {"Items Stolen","crime"},
        };
        static const auto lookup=[] {
            std::map<std::string,std::size_t> result;
            for(std::size_t i=0;i<std::size(catalog);++i)result.emplace(NormalizeStatName(catalog[i].name),i);
            return result;
        }();
        if(!g_counterScan.active)
        {
            g_counterScan={};g_counterScan.active=true;
            g_counterScan.table=table;g_counterScan.count=count;g_counterScan.started=Clock::now();
        }
        // A replaced table must not be combined with entries from the previous table.
        if(table!=g_counterScan.table||count!=g_counterScan.count)
        {g_counterScan={};g_counterReadySince=Clock::now();return;}
        const auto sliceStart=Clock::now();
        unsigned processed=0;
        while(g_counterScan.cursor<count && processed<4)
        {
            RE::MiscStatManager::Entry entry{};
            const auto offset=g_counterScan.cursor++;
            if(!CopyStatBytes(&entry,reinterpret_cast<void*>(table+offset*sizeof(entry)),sizeof(entry)))
            {g_counterScan={};g_counterAttempted=true;return;}
            if(entry.value>=0)
            {
                const auto name=NormalizeStatName(StatPoolString(entry.name));
                if(const auto found=lookup.find(name);found!=lookup.end())
                    g_counterScan.pending["counter_"+std::to_string(found->second)]=std::to_string(entry.value);
            }
            ++processed;
            if(Clock::now()-sliceStart>=std::chrono::microseconds(250))break;
        }
        const double elapsed=std::chrono::duration<double,std::milli>(Clock::now()-sliceStart).count();
        g_counterScan.workMs+=elapsed;g_counterScan.peakMs=std::max(g_counterScan.peakMs,elapsed);++g_counterScan.slices;
        if(g_counterScan.cursor<count)return;
        g_counterValues=std::move(g_counterScan.pending);g_counterAttempted=true;
        REX::INFO("TR lifetime capture: {} counters, {} slices, {:.3f} ms work, {:.3f} ms peak slice, {:.1f} ms elapsed.",
            g_counterValues.size(),g_counterScan.slices,g_counterScan.workMs,g_counterScan.peakMs,
            std::chrono::duration<double,std::milli>(Clock::now()-g_counterScan.started).count());
        g_counterScan.active=false;
    }

    void ClearSnapshotLocked(std::string status)
    {
        std::scoped_lock lock(g_mutex);
        const auto generation=g_snapshot.generation+1;
        g_snapshot=Snapshot{};
        g_snapshot.generation=generation;
        g_snapshot.status=std::move(status);
        g_uiStats=UIStats{};
        g_fullPanelActive=false;g_counterReadySince={};g_counterAttempted=false;g_counterValues.clear();g_counterScan={};
    }

    void ClearSnapshot(std::string status)
    {
        std::scoped_lock captureLock(g_captureMutex);
        ClearSnapshotLocked(std::move(status));
    }

    void CaptureGameplaySnapshot()
    {
#ifdef LSC_DIAGNOSTIC_NO_GAMEPLAY_READS
        return;
#endif
        std::unique_lock captureLock(g_captureMutex,std::try_to_lock);
        if(!captureLock.owns_lock())return;
        const auto now=Clock::now();
        if(now-g_lastAttempt<(g_counterScan.active?std::chrono::milliseconds(16):std::chrono::milliseconds(500)))return;
        g_lastAttempt=now;
        struct SampleTiming
        {
            Clock::time_point start{Clock::now()};
            ~SampleTiming()
            {
                const auto ms=std::chrono::duration<double,std::milli>(Clock::now()-start).count();
                if(ms>=5.0)REX::WARN("TR gameplay sample took {:.3f} ms (counter scan active: {}).",ms,g_counterScan.active);
            }
        } sampleTiming;
        auto* ui=RE::UI::GetSingleton();
        if(!ui)return;
        // Preserve a pre-transition snapshot; do not traverse live inventory
        // while the loading/fader menu is active.
        if(ui->IsMenuOpen("LoadingMenu")||ui->IsMenuOpen("FaderMenu"))return;
        if(ui->IsMenuOpen("MainMenu"))
        {
            ClearSnapshotLocked("main menu: no gameplay snapshot");
            return;
        }
        auto* player=RE::PlayerCharacter::GetSingleton();
        if(!player||!player->parentCell)return;
        Snapshot next;
        next.ready=true;
        next.status="pre-transition gameplay snapshot";
        next.captured=now;
        if(const auto* name=player->GetDisplayFullName())next.character=name;
        CaptureSingleCounter();
        for(const auto& [key,value]:g_counterValues)next.extra[key]=value;
        bool first=false;
        {
            std::scoped_lock lock(g_mutex);
            first=!g_snapshot.ready;
            next.sequence=g_snapshot.sequence+1;
            next.generation=g_snapshot.generation;
            g_snapshot=std::move(next);
        }
        if(first)REX::INFO("LSC character snapshot available. Only lifetime counters are collected.");
    }

    struct ControllerDirections { bool left{false},right{false},accept{false},cancel{false}; };
    ControllerDirections ReadControllerDirections()
    {
        // Optional Windows XInput backend; no new redistributable dependency.
        using GetState = DWORD (WINAPI*)(DWORD,XINPUT_STATE*);
        static const GetState getState=[]()->GetState {
            for(const wchar_t* library:{L"xinput1_4.dll",L"xinput1_3.dll",L"xinput9_1_0.dll"})
            {
                const auto module=LoadLibraryExW(library,nullptr,LOAD_LIBRARY_SEARCH_SYSTEM32);
                if(!module)continue;
                const auto function=reinterpret_cast<GetState>(GetProcAddress(module,"XInputGetState"));
                if(function)return function;
                FreeLibrary(module);
            }
            return nullptr;
        }();
        ControllerDirections result;
        if(!getState)return result;
        for(DWORD index=0;index<XUSER_MAX_COUNT;++index)
        {
            XINPUT_STATE state{};
            if(getState(index,&state)!=ERROR_SUCCESS)continue;
            result.accept|=(state.Gamepad.wButtons&XINPUT_GAMEPAD_A)!=0;
            result.cancel|=(state.Gamepad.wButtons&XINPUT_GAMEPAD_B)!=0;
            result.left|=(state.Gamepad.wButtons&XINPUT_GAMEPAD_DPAD_LEFT)!=0;
            result.right|=(state.Gamepad.wButtons&XINPUT_GAMEPAD_DPAD_RIGHT)!=0;
        }
        return result;
    }



    class ReadSnapshot final:public RE::Scaleform::GFx::FunctionHandler
    {
        LSCNavigation::State m_navigation;
        std::mutex m_navigationMutex;
        bool m_loadingMenu{false};
    public:
        explicit ReadSnapshot(bool full):m_loadingMenu(full){}
        void Call(const Params& args) override
        {
            if(!args.ret||!args.movie||!args.movie->asMovieRoot)return;
            Snapshot copy;
            UIStats stats;
            {
                std::scoped_lock lock(g_mutex);
                if(args.argCount>0&&args.args&&args.args[0].IsObject())
                {
                    using Value=RE::Scaleform::GFx::Value;
                    Value active;
                    if(args.args[0].GetMember("panelActive",&active)&&active.IsBoolean())g_fullPanelActive=active.GetBoolean();
                    Value character,level,xp,nextXP;
                    const auto number=[](const Value& value)->double
                    {
                        if(value.IsNumber())return value.GetNumber();
                        if(value.IsUInt())return value.GetUInt();
                        if(value.IsInt())return value.GetInt();
                        return -1;
                    };
                    if(args.args[0].GetMember("character",&character)&&character.IsString()&&
                       args.args[0].GetMember("level",&level)&&args.args[0].GetMember("xp",&xp)&&
                       args.args[0].GetMember("nextXP",&nextXP))
                    {
                        const auto l=number(level),x=number(xp),n=number(nextXP);
                        const char* name=character.GetString();
                        if(name&&*name&&l>0&&l<100000&&x>=0&&x<1e12&&n>0&&n<1e12)
                            g_uiStats=UIStats{name,l,x,n,g_snapshot.generation,true};
                    }
                }
                copy=g_snapshot;
                stats=g_uiStats;
            }
            auto* root=args.movie->asMovieRoot.get();
            root->CreateObject(args.ret);
            using Value=RE::Scaleform::GFx::Value;
            args.ret->SetMember("ready",Value(copy.ready));
            args.ret->SetMember("creditsAvailable",Value(copy.creditsAvailable));
            args.ret->SetMember("credits",Value(static_cast<double>(copy.credits)));
            args.ret->SetMember("sequence",Value(static_cast<double>(copy.sequence)));
            args.ret->SetMember("generation",Value(static_cast<double>(copy.generation)));
            const bool uiValid=stats.valid&&stats.generation==copy.generation&&stats.character==copy.character;
            args.ret->SetMember("uiStatsAvailable",Value(uiValid));
            bool fullActive=false;
            { std::scoped_lock lock(g_mutex);fullActive=g_fullPanelActive; }
            auto* ui=RE::UI::GetSingleton();
            args.ret->SetMember("hideShortPanel",Value(fullActive&&ui&&ui->IsMenuOpen("LoadingMenu")));
            args.ret->SetMember("loadingMenuOpen",Value(ui&&ui->IsMenuOpen("LoadingMenu")));
            args.ret->SetMember("level",Value(uiValid?stats.level:0));
            args.ret->SetMember("xp",Value(uiValid?stats.xp:0));
            args.ret->SetMember("nextXP",Value(uiValid?stats.nextXP:0));
            const auto age=copy.ready?std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now()-copy.captured).count():-1;
            args.ret->SetMember("ageMs",Value(static_cast<double>(age)));
            const auto setString=[&](const char* key,const std::string& text)
            {
                Value value;
                root->CreateString(&value,text.c_str());
                args.ret->SetMember(key,value);
            };
            for(const auto& [key,text]:copy.extra)setString(("stat_"+key).c_str(),text);
            setString("artworkBadgeFiles",TransitArtwork::manifest(0));
            setString("artworkIndicatorFiles",TransitArtwork::manifest(1));
            setString("artworkWallpaperFiles",TransitArtwork::manifest(2));
            // Read the OS clock at each UI request, even before gameplay is ready.
            SYSTEMTIME local{};
            GetLocalTime(&local);
            setString("pcTime24",std::format("{:02}:{:02}",local.wHour,local.wMinute));
            setString("pcTime12",std::format("{}:{:02} {}",local.wHour%12?local.wHour%12:12,local.wMinute,local.wHour>=12?"PM":"AM"));
            Value display;
            root->CreateObject(&display);
            {
                std::scoped_lock lock(g_settingsMutex);
                const auto themed=TransitTheme::ForDisplay(g_displaySettings);
                for(const auto& [key,value]:themed)display.SetMember(key.c_str(),Value(value));
                args.ret->SetMember("settingsReady",Value(g_settingsReady));
            }
            args.ret->SetMember("settings",display);
            DWORD foregroundProcess=0;
            const bool menuActive=m_loadingMenu&&fullActive&&ui&&ui->IsMenuOpen("LoadingMenu")&&!ui->IsMenuOpen("Console");
            if(menuActive)GetWindowThreadProcessId(GetForegroundWindow(),&foregroundProcess);
            const bool active=menuActive&&foregroundProcess==GetCurrentProcessId();
            {
                std::scoped_lock lock(m_navigationMutex);
                const auto controller=active?ReadControllerDirections():ControllerDirections{};
                const bool left=active&&((GetAsyncKeyState('A')&0x8000)!=0||controller.left);
                const bool right=active&&((GetAsyncKeyState('D')&0x8000)!=0||controller.right);
                const auto offset=m_navigation.Update(active,left,right);
                args.ret->SetMember("pageOffset",Value(static_cast<double>(offset)));
            }
            setString("character",copy.character);
            setString("location",copy.location);
            setString("status",copy.status);
            setString("counterStatus",!copy.ready ? "WAITING FOR GAMEPLAY" : copy.extra.contains("counter_12") ? "CAPTURED" : "WAITING / NO CAPTURE");
            setString("version","0.9.7");
        }
    };

    void OnMenuCreated(RE::IMenu* menu)
    {
        const char* name=menu?menu->GetName():nullptr;
        if(name&&g_useGameplaySettings&&(std::string_view(name)=="PauseMenu"||std::string_view(name)=="MainMenu"))
        {BindGameplayBridge(menu);return;}
        if(!name||(std::string_view(name)!="LoadingMenu"&&std::string_view(name)!="FaderMenu"))return;
        if(!menu->uiMovie||!menu->uiMovie->asMovieRoot)
        {
            REX::WARN("LSC LoadingMenu movie/root was unavailable during the creation callback.");
            return;
        }
        if(std::string_view(name)=="LoadingMenu")
        {std::scoped_lock lock(g_mutex);g_fullPanelActive=false;}
        auto* handler=new ReadSnapshot(std::string_view(name)=="LoadingMenu");
        RE::Scaleform::GFx::Value function;
        menu->uiMovie->asMovieRoot->CreateFunction(&function,handler);
        handler->Release();
        const auto bind=[&](RE::Scaleform::GFx::Value& object,const char* path)
        {
            if(!object.IsObject())return false;
            RE::Scaleform::GFx::Value slot;
            if(!object.GetMember("LSCNativeGetSnapshot",&slot))return false;
            const bool bound=object.SetMember("LSCNativeGetSnapshot",function);
            REX::INFO("LSC LoadingMenu binding at {}: {}",path,bound);
            return bound;
        };
        if(bind(menu->menuObj,"menuObj"))return;
        for(const char* path:{menu->GetRootPath(),"root","_root"})
        {
            if(!path||!*path)continue;
            RE::Scaleform::GFx::Value object;
            if(menu->uiMovie->asMovieRoot->GetVariable(&object,path)&&bind(object,path))return;
        }
        REX::WARN("LSC menu has no accessible native bridge slot. Install the matching 0.6 test menu. Root path: {}",menu->GetRootPath()?menu->GetRootPath():"null");
    }

    class LoadSink final:public RE::BSTEventSink<RE::TESLoadGameEvent>
    {
        RE::BSEventNotifyControl ProcessEvent(const RE::TESLoadGameEvent&,RE::BSTEventSource<RE::TESLoadGameEvent>*) override
        {
            ClearSnapshot("save loaded: waiting for fresh gameplay snapshot");
            return RE::BSEventNotifyControl::kContinue;
        }
    };
    LoadSink g_loadSink;

    void OnSFSEMessage(SFSE::MessagingInterface::Message* message)
    {
        if(!message)return;

        if(message->type!=SFSE::MessagingInterface::kPostPostLoad||g_started)return;
        g_started=true;
#ifdef LSC_DIAGNOSTIC_NO_GAMEPLAY_READS
        REX::WARN("LSC 0.9.7 DIAGNOSTIC: all gameplay and lifetime-counter sampling disabled.");
#else
        REX::INFO("LSC 0.9.7: normal lifetime capture; confirmation removed; settings backend selected by installer.");
#endif
        InitializeSettingsBackend();

        if(auto* source=RE::TESLoadGameEvent::GetEventSource())source->RegisterSink(&g_loadSink);
        SFSE::GetTaskInterface()->AddPermanentTask(CaptureGameplaySnapshot);
        REX::INFO("TR snapshot sampler: 500 ms idle; incremental lifetime scan, max four entries / 250 us target per task. No save or inventory writes.");
    }
}

SFSE_PLUGIN_LOAD(const SFSE::LoadInterface* sfse)
{
    if(!sfse||sfse->RuntimeVersion()!=kRuntime)return false;
    SFSE::Init(sfse,{.logName="LSCNativeBridge"});
    const auto preferences=TRPreferencePath();
    const auto artwork=preferences.empty()?std::filesystem::path{}:preferences.parent_path()/L"Artwork";
    for(const auto& result:TransitArtwork::prepare(TRGameDirectory()/L"Data",artwork))
        REX::INFO("Transit Report artwork {}: {}",result.kind,result.status);
    auto* menu=SFSE::GetMenuInterface();
    auto* tasks=SFSE::GetTaskInterface();
    auto* messaging=SFSE::GetMessagingInterface();
    if(!menu||!tasks||!messaging)return false;
    menu->Register(OnMenuCreated);
    messaging->RegisterListener(OnSFSEMessage);
    REX::INFO("LSC native bridge loaded for Starfield {}. Experimental, read-only.",kRuntime.string());
    return true;
}



