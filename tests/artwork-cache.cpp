#include "ArtworkCache.h"
#include <iostream>
int main(int argc,char** argv)
{
    if(argc!=3)return 2;
    for(const auto& result:TransitArtwork::prepare(std::filesystem::path(argv[1]),std::filesystem::path(argv[2])))
        std::cout<<result.kind<<": "<<result.status<<"\n";
    for(unsigned i=0;i<3;++i)std::cout<<"files"<<i<<": "<<TransitArtwork::manifest(i)<<"\n";
}
