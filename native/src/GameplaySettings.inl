// Transit Report's own standalone settings store; no OSF framework files are changed.
#include "TRSettingsCatalog.inl"

std::filesystem::path TRGameDirectory()
{
    wchar_t name[32768]{};
    const auto length=GetModuleFileNameW(nullptr,name,static_cast<DWORD>(std::size(name)));
    return length&&length<std::size(name)?std::filesystem::path(name).parent_path():std::filesystem::path{};
}
std::filesystem::path TRPreferencePath()
{
    PWSTR documents=nullptr;
    if(FAILED(SHGetKnownFolderPath(FOLDERID_Documents,KF_FLAG_DEFAULT,nullptr,&documents)))return {};
    std::filesystem::path path(documents);CoTaskMemFree(documents);
    return path/L"My Games"/L"Starfield"/L"Transit Report"/L"Settings.ini";
}
bool TRAllowed(const TRSettingDefinition& definition,int value)
{
    return std::find(definition.values.begin(),definition.values.end(),value)!=definition.values.end();
}
void TRAliases(std::map<std::string,int>& values)
{
    values["name"]=values["level"]=values["character"];
    values["xp_bar"]=values["xp_numbers"]=values["progress"];
    for(const char* key:{"short","credits","location","vitals","health","oxygen","co2","power","carry_weight","resistances","physical_resist","energy_resist","em_resist","condition_capacity","details","experience_raw","cell","coordinates","wait_continue","density"})values[key]=0;
    values["lifetime_test"]=values["lifetime_enabled"];values["lifetime_mode"]=1;
    for(const char* category:{"general","combat","exploration","crafting","quests","ship","crime"})
        values[std::string("lifetime_")+category]=1;
}
void RefreshStandalone() noexcept
{
    try
    {
        const auto path=g_useInstallerSettings?std::filesystem::path{}:TRPreferencePath();
        std::map<std::string,int> values;
        for(const auto& definition:g_trDefinitions)
        {
            const std::wstring key(definition.key,definition.key+std::char_traits<char>::length(definition.key));
            const auto file=g_useInstallerSettings
                ?TRGameDirectory()/L"Data"/L"SFSE"/L"Plugins"/L"TransitReport"/L"Installer"/(key+L".ini")
                :path;
            const int loaded=file.empty()?definition.initial:static_cast<int>(GetPrivateProfileIntW(L"Settings",key.c_str(),definition.initial,file.c_str()));
            values[definition.key]=TRAllowed(definition,loaded)?loaded:definition.initial;
        }
        TRAliases(values);
        std::scoped_lock lock(g_settingsMutex);
        g_displaySettings=std::move(values);g_settingsReady=true;
    }
    catch(...){REX::WARN("Transit Report: standalone preference read failed; previous settings retained.");}
}
bool TRSaveValue(const std::string& key,int value)
{
    const auto definition=std::find_if(g_trDefinitions.begin(),g_trDefinitions.end(),[&](const auto& entry){return key==entry.key;});
    if(definition==g_trDefinitions.end()||!TRAllowed(*definition,value))return false;
    const auto path=TRPreferencePath();if(path.empty())return false;
    std::error_code error;std::filesystem::create_directories(path.parent_path(),error);if(error)return false;
    const std::wstring wideKey(key.begin(),key.end()),wideValue=std::to_wstring(value);
    if(!WritePrivateProfileStringW(L"Settings",wideKey.c_str(),wideValue.c_str(),path.c_str()))return false;
    RefreshStandalone();return true;
}
void InitializeSettingsBackend()
{
    const auto root=TRGameDirectory();
    const auto path=root/L"Data"/L"SFSE"/L"Plugins"/L"TransitReportBackend.ini";
    wchar_t backend[32]{};
    GetPrivateProfileStringW(L"Settings",L"Backend",L"osf",backend,static_cast<DWORD>(std::size(backend)),path.c_str());
    g_useGameplaySettings=std::wstring_view(backend)==L"gameplay";
    g_useInstallerSettings=std::wstring_view(backend)==L"installer";
    if(g_useInstallerSettings)
    {
        RefreshStandalone();
        REX::INFO("Transit Report: installer-only backend active; no settings menus registered. Values use Data/SFSE/Plugins/TransitReport/Installer/*.ini.");
    }
    else if(g_useGameplaySettings)
    {
        RefreshStandalone();
        REX::INFO("Transit Report: standalone Gameplay Options backend active. Preferences use Documents/My Games/Starfield/Transit Report/Settings.ini.");
    }
    else
    {
        InitializeOSF();
        REX::INFO("Transit Report: OSF Settings backend active; existing preference ID retained.");
    }
}
class TRSettingsBridge final:public RE::Scaleform::GFx::FunctionHandler
{
public:
    void Call(const Params& args) override
    {
        if(!g_useGameplaySettings||!args.ret||!args.movie||!args.movie->asMovieRoot)return;
        bool ok=true;
        try
        {
            if(args.argCount&&args.args[0].IsString()&&std::string_view(args.args[0].GetString())=="reset")
            {
                const auto path=TRPreferencePath();
                ok=!path.empty();
                if(ok&&std::filesystem::exists(path))ok=WritePrivateProfileStringW(L"Settings",nullptr,nullptr,path.c_str())!=0;
                if(ok)RefreshStandalone();
            }
            if(args.argCount&&args.args[0].IsString()&&std::string_view(args.args[0].GetString())=="set")
            {
                ok=false;
                if(args.argCount>=3&&args.args[1].IsString())
                {
                    const auto& number=args.args[2];
                    const double value=number.IsNumber()?number.GetNumber():number.IsInt()?number.GetInt():number.IsUInt()?number.GetUInt():-1;
                    if(std::isfinite(value)&&value==std::floor(value)&&value>=0&&value<=10000)ok=TRSaveValue(args.args[1].GetString(),static_cast<int>(value));
                }
            }
            auto* root=args.movie->asMovieRoot.get();root->CreateObject(args.ret);
            using Value=RE::Scaleform::GFx::Value;
            args.ret->SetMember("ok",Value(ok));
            std::scoped_lock lock(g_settingsMutex);
            for(const auto& definition:g_trDefinitions)args.ret->SetMember(definition.key,Value(g_displaySettings.at(definition.key)));
        }
        catch(...){REX::WARN("Transit Report: Gameplay Options request failed.");}
    }
};
void BindGameplayBridge(RE::IMenu* menu)
{
    if(!menu||!menu->uiMovie||!menu->uiMovie->asMovieRoot)return;
    auto* handler=new TRSettingsBridge();RE::Scaleform::GFx::Value function;
    menu->uiMovie->asMovieRoot->CreateFunction(&function,handler);handler->Release();
    // Queue directly on the movie. Do not resolve panel members or invoke ActionScript
    // during SFSE's creation callback: the panel's AS3 VM may still be initializing.
    auto* root=menu->uiMovie->asMovieRoot.get();
    std::vector<std::string> paths;
    const auto addPath=[&](const char* prefix)
    {
        if(!prefix||!*prefix)return;
        const std::string path=std::string(prefix)+".SettingsPanel_mc.TRConfig";
        if(std::find(paths.begin(),paths.end(),path)==paths.end())paths.push_back(path);
    };
    addPath(menu->GetRootPath());addPath("root");addPath("_root");
    for(const auto& path:paths)
    {
        const bool available=root->SetVariable(path.c_str(),function,RE::Scaleform::GFx::Movie::SetVarType::kPermanent);
        REX::INFO("Transit Report: deferred panel bridge {} at {} in {}.",available?"assigned":"queued",path,menu->GetName());
    }
}
