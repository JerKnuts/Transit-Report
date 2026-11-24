#pragma once

#include <charconv>
#include <cstdint>
#include <string>

namespace TransitReport
{
    // Accept both save-menu text and the dotted sPlayTime source string.
    inline std::string FormatSavePlaytime(const std::string& value)
    {
        const char* cursor=value.data();
        const char* end=cursor+value.size();
        std::uint64_t parts[3]{};
        int lastUnit=-1;
        while(cursor<end)
        {
            while(cursor<end&&(*cursor=='.'||*cursor==' '||*cursor=='\t'||*cursor=='\r'||*cursor=='\n'))++cursor;
            if(cursor==end)break;
            std::uint64_t number{};
            const auto result=std::from_chars(cursor,end,number);
            if(result.ec!=std::errc{}||number>1000000000)return {};
            cursor=result.ptr;
            while(cursor<end&&*cursor==' ')++cursor;
            if(cursor==end)return {};
            const char suffix=*cursor++;
            const int unit=suffix=='d'||suffix=='D'?0:suffix=='h'||suffix=='H'?1:suffix=='m'||suffix=='M'?2:-1;
            if(unit<=lastUnit)return {};
            parts[unit]=number;lastUnit=unit;
            if(unit==2)break; // The source appends localized long-form text.
        }
        if(lastUnit<0)return {};
        return std::to_string(parts[0]*24+parts[1]+parts[2]/60)+"h "+std::to_string(parts[2]%60)+"m";
    }
}
