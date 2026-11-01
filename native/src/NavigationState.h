#pragma once
#include <cstdint>

namespace LSCNavigation
{
    // Per loading-menu instance. Offset is cumulative so independent UI polls
    // cannot consume an input intended for the statistics panel.
    struct State
    {
        std::int64_t offset{0};
        bool primed{false}, previousA{false}, previousD{false};

        std::int64_t Update(bool active,bool aDown,bool dDown) noexcept
        {
            if(!active)
            {
                primed=false;
                return offset;
            }
            if(primed)offset+=static_cast<int>(dDown&&!previousD)-static_cast<int>(aDown&&!previousA);
            previousA=aDown;
            previousD=dDown;
            primed=true;
            return offset;
        }
    };
}
