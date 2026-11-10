#include "ArtworkTheme.h"
#include <cassert>
#include <iostream>
int main(){
 std::map<std::string,int> stored{{"theme",1},{"badge",0},{"spinner",2},{"background",8},{"clock",2}};
 for(int faction=0;faction<=7;++faction){
  stored["theme"]=faction;
  assert(TransitTheme::ForDisplay(stored)==stored);
  for(const char* key:{"badge","spinner","background"}){
   auto selected=stored;selected[key]=10;const auto displayed=TransitTheme::ForDisplay(selected);
   assert(displayed.at(key)==(faction?99+faction:1));
   for(const auto& entry:stored)if(entry.first!=key)assert(displayed.at(entry.first)==entry.second);
   assert(selected.at(key)==10);
  }
 }
 stored["badge"]=stored["spinner"]=stored["background"]=10;
 stored["theme"]=8;for(const char* key:{"badge","spinner","background"})assert(TransitTheme::ForDisplay(stored).at(key)==107);
 stored["theme"]=900;for(const char* key:{"badge","spinner","background"})assert(TransitTheme::ForDisplay(stored).at(key)==1);
 stored.erase("theme");assert(TransitTheme::ForDisplay(stored).at("badge")==1);
 std::cout<<"Passed: explicit Theme per slot; Original, Hidden and other choices preserved for all factions; fallback and saved values correct.\n";
}
