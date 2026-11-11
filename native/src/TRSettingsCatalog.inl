struct TRSettingDefinition {const char* key;int initial;std::vector<int> values;};
const std::vector<TRSettingDefinition> g_trDefinitions={
{"lifetime_enabled",1,{0,1}},
{"badge_size",100,{50,75,100,125,150}},
{"indicator_size",100,{50,75,100,125,150}},
{"hide_zero",0,{0,1}},
{"theme",0,{0,1,2,3,4,5,6,7,8}},
{"badge",1,{0,1,6,9,10,2,3}},
{"spinner",2,{0,1,6,9,10,2,3}},
{"background",1,{0,1,3,8,10,11,4}},
{"character",1,{0,1}},
{"progress",1,{0,1}},
{"tips",1,{0,1}},
{"page_count",2,{1,2,3,4,5}},
{"diagnostics",0,{0,1}},
{"clock",1,{0,1,2}},
};
