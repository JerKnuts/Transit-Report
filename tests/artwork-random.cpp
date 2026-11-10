#include "ArtworkRandom.h"
#include <cassert>
#include <iostream>
int main() {
    TransitRandom::Picker picker;
    std::string previous;
    for(int i=0;i<1000;++i) {
        const auto next=picker.Pick("theme",{"100","101","102"});
        assert(next=="100"||next=="101"||next=="102");
        assert(next!=previous);
        previous=next;
    }
    assert(picker.Pick("artwork0",{"one"})=="one");
    assert(picker.Pick("artwork0",{"one"})=="one");
    assert(picker.Pick("artwork0",{"one","two"})=="two");
    assert(picker.Pick("artwork1",{"one"})=="one");
    assert(picker.Pick("artwork0",{}).empty());
    assert(picker.Pick("artwork0",{"replacement"})=="replacement");
    assert(picker.Pick("artwork0",{"replacement","other"})=="other");
    std::cout<<"Passed: session-wide random choices avoid consecutive repeats; independent slots, single/empty/changed pools work.\n";
}
