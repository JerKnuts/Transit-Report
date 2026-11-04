#pragma once
#include <map>
#include <string>
namespace TransitTheme {
inline std::map<std::string,int> ForDisplay(const std::map<std::string,int>& stored)
{
    auto display=stored;
    const auto theme=stored.find("theme");
    const int faction=theme!=stored.end()?theme->second:0;
    for(const char* key:{"badge","spinner","background"}) {
        const auto slot=stored.find(key);
        if(slot!=stored.end() && slot->second==10)
            display[key]=faction>=1 && faction<=7 ? 99+faction : 1;
    }
    return display;
}
}
