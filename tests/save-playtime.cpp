#include "SavePlaytime.h"
#include <cassert>

int main()
{
    using TransitReport::FormatSavePlaytime;
    assert(FormatSavePlaytime("1d 2h 15m")=="26h 15m");
    assert(FormatSavePlaytime("1d")=="24h 0m");
    assert(FormatSavePlaytime("1h 51m")=="1h 51m");
    assert(FormatSavePlaytime("0d.23h.59m.0 days.23 hours.59 minutes")=="23h 59m");
    assert(FormatSavePlaytime("1d.0h.0m.1 days.0 hours.0 minutes")=="24h 0m");
    assert(FormatSavePlaytime("12d.3h.9m.12 days.3 hours.9 minutes")=="291h 9m");
    assert(FormatSavePlaytime("0d.0h.0m.0 days.0 hours.0 minutes")=="0h 0m");
    assert(FormatSavePlaytime("999999999999999999999d").empty());
    assert(FormatSavePlaytime("").empty());
    assert(FormatSavePlaytime("-d -h -m").empty());
}
