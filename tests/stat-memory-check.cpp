#include "StatMemory.h"
#include <cassert>
#include <chrono>
#include <iostream>
int main(){
 using namespace LSCStatMemory;
 char output[32]{};const char text[]="People Killed";
 assert(CopyStatBytes(output,text,sizeof(text)));
 assert(std::string(output)==text);
 assert(!CopyStatBytes(output,nullptr,4));
 assert(!CopyStatBytes(output,text,0));
 assert(!CopyStatBytes(output,text,0x20001));
 void* inaccessible=VirtualAlloc(nullptr,4096,MEM_RESERVE|MEM_COMMIT,PAGE_NOACCESS);assert(inaccessible);
 assert(!CopyStatBytes(output,inaccessible,4));VirtualFree(inaccessible,0,MEM_RELEASE);
 struct Header{std::uint64_t left,length;std::uint32_t refs;std::uint8_t flags,pad[3];};
 struct Pooled{Header header;char text[14];};Pooled pool{{0,13,1,0,{0,0,0}},"People Killed"};
 assert(StatPoolString(reinterpret_cast<std::uintptr_t>(&pool))=="People Killed");
 Header cycle{};cycle.flags=2;cycle.length=reinterpret_cast<std::uintptr_t>(&cycle);
 assert(StatPoolString(reinterpret_cast<std::uintptr_t>(&cycle)).empty());
 const auto start=std::chrono::steady_clock::now();
 for(int i=0;i<100000;++i)assert(CopyStatBytes(output,text,sizeof(text)));
 const auto ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
 std::cout<<"Passed: actual protected copies, invalid/no-access rejection, pooled strings, bounded indirection. 100000 copies: "<<ms<<" ms.\n";
}
