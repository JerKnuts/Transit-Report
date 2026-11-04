from pathlib import Path
r=Path(__file__).resolve().parents[1];s=(r/'native/src/main.cpp').read_text(encoding='utf-8');a=s.index('    struct CounterScan');b=s.index('\n    void ClearSnapshotLocked',a);actual=s[a:b]
p=r/'build/counter-scan-check';p.mkdir(parents=True,exist_ok=True)
p.joinpath('xmake.lua').write_text('set_languages("c++23")\ntarget("scan-check")\n set_kind("binary")\n add_files("main.cpp")\n')
p.joinpath('main.cpp').write_text(r'''
#include <cassert>
#include <chrono>
#include <map>
#include <mutex>
#include <string>
#include <vector>
#include <algorithm>
#include <cstring>
#include <cctype>
#include <iostream>
using Clock=std::chrono::steady_clock;
namespace RE { struct MiscStatManager { struct Entry{std::uintptr_t name;int value;}; }; namespace ID::MiscStatManager {constexpr int EntryCount=1,TableBase=2;} }
std::uint32_t fixtureCount;std::uintptr_t fixtureTable;
namespace REL {template<class T>struct Relocation {int id;Relocation(int v):id(v){} T get(){return reinterpret_cast<T>(id==1?static_cast<void*>(&fixtureCount):static_cast<void*>(&fixtureTable));}};}
namespace REX {template<class... T>void INFO(const char*,T...){} }
namespace LSCStatMemory {
unsigned reads=0;
bool CopyStatBytes(void* out,const void* in,std::size_t n){if(!in)return false;std::memcpy(out,in,n);if(n==sizeof(RE::MiscStatManager::Entry))++reads;return true;}
std::string StatPoolString(std::uintptr_t p){return reinterpret_cast<const char*>(p);}
std::string NormalizeStatName(const std::string& s){std::string out;for(unsigned char c:s)if(std::isalnum(c))out+=char(std::tolower(c));return out;}
}
std::mutex g_settingsMutex;std::map<std::string,int> g_displaySettings{{"lifetime_test",1}};
Clock::time_point g_counterReadySince{};bool g_counterAttempted=false;
std::map<std::string,std::string> g_counterValues;
'''+actual+r'''
int main(){
 std::vector<RE::MiscStatManager::Entry> rows(100,{reinterpret_cast<std::uintptr_t>("Unrelated"),1});
 rows[99]={reinterpret_cast<std::uintptr_t>("People Killed"),42};fixtureCount=100;fixtureTable=reinterpret_cast<std::uintptr_t>(rows.data());
 g_counterReadySince=Clock::now()-std::chrono::seconds(4);
 CaptureSingleCounter();assert(LSCStatMemory::reads<=4);assert(g_counterValues.empty());assert(!g_counterAttempted);
 unsigned steps=1;while(!g_counterAttempted&&steps<200){unsigned previous=LSCStatMemory::reads;CaptureSingleCounter();assert(LSCStatMemory::reads-previous<=4);++steps;}
 assert(g_counterAttempted);assert(g_counterValues.at("counter_12")=="42");assert(steps>=25);
 unsigned doneReads=LSCStatMemory::reads;CaptureSingleCounter();assert(doneReads==LSCStatMemory::reads);
 g_counterAttempted=false;g_counterScan={};g_counterReadySince=Clock::now()-std::chrono::seconds(4);CaptureSingleCounter();assert(g_counterScan.active);
 --fixtureCount;CaptureSingleCounter();assert(!g_counterScan.active);assert(!g_counterAttempted);assert(g_counterValues.at("counter_12")=="42");
 g_counterReadySince=Clock::now()-std::chrono::seconds(4);CaptureSingleCounter();g_displaySettings["lifetime_test"]=0;CaptureSingleCounter();assert(!g_counterScan.active);
 std::cout<<"Passed: actual capture batches <=4, publishes only complete data, captures 42 kills, stops after completion, resets changed tables and cancels disabled scans.\n";
}
''',encoding='utf-8')
print(p)
