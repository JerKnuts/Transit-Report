#pragma once
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#include <cstdint>
#include <cstring>
#include <cctype>
#include <string>
namespace LSCStatMemory
{
inline bool CopyStatBytes(void* output,const void* input,std::size_t size) noexcept
{
    const auto address=reinterpret_cast<std::uintptr_t>(input);
    if(address<0x10000||size==0||size>0x20000||address+size<address)return false;
    auto cursor=address;
    while(cursor<address+size)
    {
        MEMORY_BASIC_INFORMATION region{};
        if(!VirtualQuery(reinterpret_cast<void*>(cursor),&region,sizeof(region))||region.State!=MEM_COMMIT||(region.Protect&(PAGE_NOACCESS|PAGE_GUARD)))return false;
        const auto end=reinterpret_cast<std::uintptr_t>(region.BaseAddress)+region.RegionSize;
        if(end<=cursor)return false;
        cursor=end;
    }
    __try {std::memcpy(output,input,size);return true;}
    __except(EXCEPTION_EXECUTE_HANDLER){return false;}
}
inline std::string StatPoolString(std::uintptr_t pointer)
{
    struct Header {std::uint64_t left,rightOrLength;std::uint32_t refs;std::uint8_t flags,pad[3];};
    static_assert(sizeof(Header)==0x18);
    for(unsigned depth=0;depth<8;depth++)
    {
        Header h{};
        if(!CopyStatBytes(&h,reinterpret_cast<void*>(pointer),sizeof(h)))return {};
        if(h.flags&2){pointer=h.rightOrLength;continue;}
        const auto length=static_cast<std::uint32_t>(h.rightOrLength);
        if(length==0||length>256)return {};
        char buffer[257]{};
        if(!CopyStatBytes(buffer,reinterpret_cast<void*>(pointer+sizeof(h)),length+1)||buffer[length]!='\0')return {};
        return std::string(buffer,length);
    }
    return {};
}
inline std::string NormalizeStatName(const std::string& name)
{
    std::string result;
    for(unsigned char c:name)if(std::isalnum(c))result.push_back(static_cast<char>(std::tolower(c)));
    return result;
}
}
