// GPL-3.0-or-later with the project's linking/modding exceptions.
// Converts still images and composited GIF animations into script-free SWF timelines.
#pragma once
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#include <wincodec.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cwctype>
#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace TransitArtwork
{
    using Bytes=std::vector<std::uint8_t>;
    inline void u16(Bytes& out,std::uint32_t n){out.push_back(n&255);out.push_back((n>>8)&255);}
    inline void u32(Bytes& out,std::uint32_t n){u16(out,n&65535);u16(out,n>>16);}
    inline void append(Bytes& out,const Bytes& value){out.insert(out.end(),value.begin(),value.end());}
    struct Bits
    {
        Bytes data;unsigned used=0;
        void put(std::int32_t value,unsigned count)
        {
            for(unsigned i=count;i>0;--i)
            {
                if(!used)data.push_back(0);
                data.back()|=((static_cast<std::uint32_t>(value)>>(i-1))&1)<<(7-used);
                used=(used+1)%8;
            }
        }
    };
    inline unsigned width(std::int32_t value)
    {
        unsigned n=2;while(value>=(1<<(n-1))||value<-(1<<(n-1)))++n;return n;
    }
    inline Bytes rect(int w,int h)
    {
        Bits b;const auto n=std::max(width(w),width(h));b.put(n,5);
        b.put(0,n);b.put(w,n);b.put(0,n);b.put(h,n);return b.data;
    }
    inline Bytes matrix(int scale)
    {
        Bits b;b.put(scale!=1,1);
        if(scale!=1){const int s=scale*65536;const auto n=width(s);b.put(n,5);b.put(s,n);b.put(s,n);}
        b.put(0,1);b.put(2,5);b.put(0,2);b.put(0,2);return b.data;
    }
    inline Bytes edges(int w,int h)
    {
        Bits b;b.put(1,4);b.put(0,4);b.put(0,1);b.put(5,5);b.put(1,5);b.put(0,1);b.put(0,1);b.put(1,1);
        for(const auto& edge:std::vector<std::pair<int,int>>{{w,0},{0,h},{-w,0},{0,-h}})
        {
            const auto n=std::max(width(edge.first),width(edge.second));
            if(n>17)throw std::runtime_error("SWF image exceeds shape bounds");
            b.put(1,1);b.put(1,1);b.put(n-2,4);b.put(0,1);b.put(edge.second!=0,1);b.put(edge.second?edge.second:edge.first,n);
        }
        b.put(0,6);return b.data;
    }
    inline Bytes zlibStored(const Bytes& pixels)
    {
        Bytes out{0x78,0x01};std::uint32_t a=1,b=0;
        for(auto value:pixels){a=(a+value)%65521;b=(b+a)%65521;}
        for(std::size_t offset=0;offset<pixels.size();)
        {
            const auto n=std::min<std::size_t>(65535,pixels.size()-offset);
            out.push_back(offset+n==pixels.size()?1:0);u16(out,n);u16(out,static_cast<std::uint16_t>(~n));
            out.insert(out.end(),pixels.begin()+offset,pixels.begin()+offset+n);offset+=n;
        }
        const auto checksum=(b<<16)|a;
        for(int shift=24;shift>=0;shift-=8)out.push_back((checksum>>shift)&255);
        return out;
    }
    inline void tag(Bytes& out,unsigned code,const Bytes& body)
    {
        u16(out,(code<<6)|std::min<std::size_t>(63,body.size()));
        if(body.size()>=63)u32(out,static_cast<std::uint32_t>(body.size()));append(out,body);
    }
    inline Bytes swf(unsigned w,unsigned h,Bytes rgba)
    {
        for(std::size_t i=0;i<rgba.size();i+=4)
        {
            const auto r=rgba[i],g=rgba[i+1],b=rgba[i+2],a=rgba[i+3];
            rgba[i]=a;rgba[i+1]=(r*a+127)/255;rgba[i+2]=(g*a+127)/255;rgba[i+3]=(b*a+127)/255;
        }
        Bytes body=rect(w*20,h*20);u16(body,30*256);u16(body,1);
        tag(body,69,Bytes{8,0,0,0});
        Bytes bitmap;u16(bitmap,1);bitmap.push_back(5);u16(bitmap,w);u16(bitmap,h);append(bitmap,zlibStored(rgba));tag(body,36,bitmap);
        Bytes shape;u16(shape,2);append(shape,rect(w*20,h*20));append(shape,Bytes{1,0x41});u16(shape,1);append(shape,matrix(20));shape.push_back(0);append(shape,edges(w*20,h*20));tag(body,32,shape);
        Bytes place{6};u16(place,1);u16(place,2);append(place,matrix(1));tag(body,26,place);tag(body,1,{});tag(body,0,{});
        Bytes file{'F','W','S',10};u32(file,static_cast<std::uint32_t>(body.size()+8));append(file,body);return file;
    }
    inline void check(HRESULT hr){if(FAILED(hr))throw std::runtime_error("Windows image decoder error "+std::to_string(static_cast<unsigned long>(hr)));}
    inline Bytes decode(const std::filesystem::path& path,unsigned& w,unsigned& h)
    {
        using Microsoft::WRL::ComPtr;
        ComPtr<IWICImagingFactory> factory;check(CoCreateInstance(CLSID_WICImagingFactory,nullptr,CLSCTX_INPROC_SERVER,IID_PPV_ARGS(&factory)));
        ComPtr<IWICBitmapDecoder> decoder;check(factory->CreateDecoderFromFilename(path.c_str(),nullptr,GENERIC_READ,WICDecodeMetadataCacheOnDemand,&decoder));
        ComPtr<IWICBitmapFrameDecode> frame;check(decoder->GetFrame(0,&frame));check(frame->GetSize(&w,&h));
        if(!w||!h||w>8192||h>8192||std::uint64_t(w)*h>16777216)throw std::runtime_error("Image exceeds 16-megapixel limit");
        ComPtr<IWICBitmapSource> source;check(frame.As(&source));
        if(w>2560||h>2560)
        {
            const double scale=std::min(2560.0/w,2560.0/h);w=std::max(1u,static_cast<unsigned>(std::lround(w*scale)));h=std::max(1u,static_cast<unsigned>(std::lround(h*scale)));
            ComPtr<IWICBitmapScaler> scaler;check(factory->CreateBitmapScaler(&scaler));check(scaler->Initialize(source.Get(),w,h,WICBitmapInterpolationModeFant));check(scaler.As(&source));
        }
        ComPtr<IWICFormatConverter> converter;check(factory->CreateFormatConverter(&converter));
        check(converter->Initialize(source.Get(),GUID_WICPixelFormat32bppRGBA,WICBitmapDitherTypeNone,nullptr,0,WICBitmapPaletteTypeCustom));
        Bytes rgba(std::size_t(w)*h*4);check(converter->CopyPixels(nullptr,w*4,static_cast<UINT>(rgba.size()),rgba.data()));return rgba;
    }

    inline unsigned metadata(IWICMetadataQueryReader* reader,const wchar_t* key,unsigned fallback=0)
    {
        PROPVARIANT value{};unsigned result=fallback;
        if(reader && SUCCEEDED(reader->GetMetadataByName(key,&value))) {
            if(value.vt==VT_UI1)result=value.bVal;
            else if(value.vt==VT_UI2)result=value.uiVal;
            else if(value.vt==VT_UI4)result=value.ulVal;
        }
        PropVariantClear(&value);return result;
    }
    inline Bytes animatedGif(const std::filesystem::path& path,unsigned& w,unsigned& h)
    {
        using Microsoft::WRL::ComPtr;
        ComPtr<IWICImagingFactory> factory;check(CoCreateInstance(CLSID_WICImagingFactory,nullptr,CLSCTX_INPROC_SERVER,IID_PPV_ARGS(&factory)));
        ComPtr<IWICBitmapDecoder> decoder;check(factory->CreateDecoderFromFilename(path.c_str(),nullptr,GENERIC_READ,WICDecodeMetadataCacheOnDemand,&decoder));
        UINT count{};check(decoder->GetFrameCount(&count));
        if(!count||count>240)throw std::runtime_error("GIF limit: 240 source frames");
        ComPtr<IWICMetadataQueryReader> global;check(decoder->GetMetadataQueryReader(&global));
        w=metadata(global.Get(),L"/logscrdesc/Width");h=metadata(global.Get(),L"/logscrdesc/Height");
        if(!w||!h||w>2048||h>2048||std::uint64_t(w)*h*count>16777216)throw std::runtime_error("GIF decoded pixel limit exceeded (16 megapixels total; 2048px canvas)");
        // Composite source rectangles before scaling; transparent pixels leave prior content intact.
        // Disposal 2 clears the previous rectangle; disposal 3 restores its previous canvas.
        Bytes canvas(std::size_t(w)*h*4,0),restore;

        const double scale=std::min(1.0,512.0/std::max(w,h));
        const unsigned targetW=std::max(1u,static_cast<unsigned>(std::lround(w*scale))),targetH=std::max(1u,static_cast<unsigned>(std::lround(h*scale)));

        Bytes records;tag(records,69,Bytes{8,0,0,0});unsigned ticks=0,centiseconds=0;
        for(unsigned i=0;i<count;++i) {
            ComPtr<IWICBitmapFrameDecode> frame;check(decoder->GetFrame(i,&frame));UINT fw{},fh{};check(frame->GetSize(&fw,&fh));
            ComPtr<IWICMetadataQueryReader> query;check(frame->GetMetadataQueryReader(&query));
            const unsigned left=metadata(query.Get(),L"/imgdesc/Left"),top=metadata(query.Get(),L"/imgdesc/Top");
            const unsigned delay=std::max(2u,metadata(query.Get(),L"/grctlext/Delay",10)),disposal=metadata(query.Get(),L"/grctlext/Disposal");
            if(!fw||!fh||left>w||top>h||fw>w-left||fh>h-top)throw std::runtime_error("GIF frame outside canvas");
            if(centiseconds+delay>6000)throw std::runtime_error("GIF duration limit: 60 seconds");
            if(disposal==3)restore=canvas;
            ComPtr<IWICFormatConverter> converter;check(factory->CreateFormatConverter(&converter));
            check(converter->Initialize(frame.Get(),GUID_WICPixelFormat32bppRGBA,WICBitmapDitherTypeNone,nullptr,0,WICBitmapPaletteTypeCustom));
            Bytes pixels(std::size_t(fw)*fh*4);check(converter->CopyPixels(nullptr,fw*4,static_cast<UINT>(pixels.size()),pixels.data()));
            for(unsigned y=0;y<fh;++y)for(unsigned x=0;x<fw;++x){const auto from=(std::size_t(y)*fw+x)*4,to=(std::size_t(y+top)*w+x+left)*4;if(pixels[from+3])std::copy_n(pixels.data()+from,4,canvas.data()+to);}
            Bytes rgba;
            if(targetW==w&&targetH==h)rgba=canvas;
            else {
                ComPtr<IWICBitmap> bitmap;check(factory->CreateBitmapFromMemory(w,h,GUID_WICPixelFormat32bppRGBA,w*4,static_cast<UINT>(canvas.size()),canvas.data(),&bitmap));
                ComPtr<IWICBitmapScaler> scaler;check(factory->CreateBitmapScaler(&scaler));check(scaler->Initialize(bitmap.Get(),targetW,targetH,WICBitmapInterpolationModeFant));
                rgba.resize(std::size_t(targetW)*targetH*4);check(scaler->CopyPixels(nullptr,targetW*4,static_cast<UINT>(rgba.size()),rgba.data()));
            }
            // Reuse the still-image writer's premultiplied bitmap and shape tags.
            const auto single=swf(targetW,targetH,std::move(rgba));
            const auto rectLength=(5+4*(single[8]>>3)+7)/8;
            std::size_t at=8+rectLength+4;
            while(at<single.size()) {
                unsigned head=single[at]|(single[at+1]<<8);at+=2;const unsigned type=head>>6;unsigned length=head&63;
                if(length==63){length=single[at]|(single[at+1]<<8)|(single[at+2]<<16)|(single[at+3]<<24);at+=4;}
                Bytes body(single.begin()+at,single.begin()+at+length);at+=length;
                if(type==36){body[0]=(i*2+1)&255;body[1]=(i*2+1)>>8;tag(records,36,body);}
                if(type==32){body[0]=(i*2+2)&255;body[1]=(i*2+2)>>8;const auto n=(5+4*(body[2]>>3)+7)/8;body[2+n+2]=(i*2+1)&255;body[2+n+3]=(i*2+1)>>8;tag(records,32,body);}
            }
            Bytes place{static_cast<std::uint8_t>(i?7:6)};u16(place,1);u16(place,i*2+2);append(place,matrix(1));tag(records,26,place);
            centiseconds+=delay;const unsigned endTick=std::max(ticks+1,static_cast<unsigned>(std::lround(centiseconds*0.30)));
            for(;ticks<endTick;++ticks)tag(records,1,{});
            if(disposal==2)for(unsigned y=top;y<top+fh;++y)std::fill_n(canvas.data()+(std::size_t(y)*w+left)*4,fw*4,0);
            else if(disposal==3)canvas=restore;
        }
        tag(records,0,{});w=targetW;h=targetH;Bytes body=rect(w*20,h*20);u16(body,30*256);u16(body,ticks);append(body,records);
        Bytes result{'F','W','S',10};u32(result,static_cast<std::uint32_t>(body.size()+8));append(result,body);return result;
    }
    struct Result{std::string kind,status;};
    inline std::string fingerprint(const std::filesystem::path& input)
    {
        std::ifstream file(input,std::ios::binary);if(!file)throw std::runtime_error("Cannot read source artwork");
        std::uint64_t hash=14695981039346656037ull;char block[16384];
        while(file.read(block,sizeof(block))||file.gcount())
            for(std::streamsize i=0;i<file.gcount();++i){hash^=static_cast<unsigned char>(block[i]);hash*=1099511628211ull;}
        if(!file.eof())throw std::runtime_error("Artwork fingerprint read failed");
        return "bitmap-cache-v2:"+std::to_string(hash);
    }
    inline std::array<std::vector<std::string>,3> artworkFiles;
    inline std::string manifest(unsigned index)
    {
        std::string result;
        for(const auto& name:artworkFiles.at(index)){if(!result.empty())result+='|';result+=name;}
        return result;
    }
    inline std::vector<Result> prepare(const std::filesystem::path& data,const std::filesystem::path& artwork={})
    {
        const auto hr=CoInitializeEx(nullptr,COINIT_MULTITHREADED);
        struct Cleanup{bool active;~Cleanup(){if(active)CoUninitialize();}} cleanup{SUCCEEDED(hr)};
        for(auto& files:artworkFiles)files.clear();
        if(FAILED(hr)&&hr!=RPC_E_CHANGED_MODE)return {{"startup","COM initialization failed"}};
        std::vector<Result> results;
        for(const auto& entry:std::vector<std::pair<std::string,std::string>>{{"Backgrounds","wallpaper"},{"Badges","badge"},{"Indicators","indicator"}})
        {
            const unsigned index=entry.second=="badge"?0:entry.second=="indicator"?1:2;
            auto& prepared=artworkFiles[index];
            const auto cache=data/L"Interface"/L"TransitReport"/L"Cache";
            const auto prefix=entry.second+"-v2-";
            try
            {
                const auto folder=artwork.empty()?data/L"Interface"/L"TransitReport"/entry.first:artwork/entry.first;
                if(!artwork.empty())std::filesystem::create_directories(folder);
                std::vector<std::filesystem::path> images;
                if(std::filesystem::is_directory(folder))for(const auto& item:std::filesystem::directory_iterator(folder))
                {
                    if(!item.is_regular_file())continue;
                    auto ext=item.path().extension().wstring();std::transform(ext.begin(),ext.end(),ext.begin(),[](wchar_t c){return std::towlower(c);});
                    if(ext==L".png"||ext==L".jpg"||ext==L".jpeg"||ext==L".gif")images.push_back(item.path());
                }
                std::sort(images.begin(),images.end());
                if(images.size()>64){images.resize(64);results.push_back({entry.second,"folder limited to first 64 supported images"});}
                for(const auto& input:images)
                {
                    try
                    {
                        if(std::filesystem::file_size(input)>64*1024*1024)throw std::runtime_error("Source file exceeds 64 MB");
                        const auto signature=fingerprint(input);
                        const auto name=prefix+signature.substr(signature.find(':')+1)+".swf";
                        if(std::find(prepared.begin(),prepared.end(),name)!=prepared.end())continue;
                        const auto output=cache/name;
                        bool valid=false;
                        if(std::filesystem::is_regular_file(output))
                        {
                            char header[8]{};std::ifstream file(output,std::ios::binary);file.read(header,8);
                            const auto length=static_cast<unsigned char>(header[4])|(static_cast<unsigned char>(header[5])<<8)|(static_cast<unsigned char>(header[6])<<16)|(static_cast<unsigned char>(header[7])<<24);
                            valid=file&&header[0]=='F'&&header[1]=='W'&&header[2]=='S'&&length==std::filesystem::file_size(output);
                        }
                        if(valid){prepared.push_back(name);results.push_back({entry.second,"cached artwork reused"});continue;}
                        unsigned w{},h{};auto ext=input.extension().wstring();std::transform(ext.begin(),ext.end(),ext.begin(),[](wchar_t c){return std::towlower(c);});
                        Bytes bytes;if(ext==L".gif")bytes=animatedGif(input,w,h);else {auto rgba=decode(input,w,h);bytes=swf(w,h,std::move(rgba));}
                        std::filesystem::create_directories(cache);auto temp=output;temp+=L".tmp";
                        {std::ofstream file(temp,std::ios::binary|std::ios::trunc);file.write(reinterpret_cast<const char*>(bytes.data()),bytes.size());if(!file)throw std::runtime_error("Cannot write artwork cache");}
                        if(!MoveFileExW(temp.c_str(),output.c_str(),MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH))throw std::runtime_error("Cannot finalize artwork cache");
                        prepared.push_back(name);results.push_back({entry.second,"prepared "+std::to_string(w)+"x"+std::to_string(h)+" image"});
                    }
                    catch(const std::exception& error){results.push_back({entry.second,error.what()});}
                }
                // Prune only this feature's fixed generated names, never original images.
                if(std::filesystem::is_directory(cache))for(const auto& file:std::filesystem::directory_iterator(cache))
                {
                    const auto name=file.path().filename().string();
                    const bool old=name==entry.second+".swf"||name==entry.second+".fingerprint"||(name.starts_with(entry.second+"-v1-")&&file.path().extension()==L".swf");
                    const bool stale=name.starts_with(prefix)&&file.path().extension()==L".swf"&&std::find(prepared.begin(),prepared.end(),name)==prepared.end();
                    if(file.is_regular_file()&&(old||stale)){std::error_code error;std::filesystem::remove(file.path(),error);}
                }
                results.push_back({entry.second,std::to_string(prepared.size())+" custom images available"});
            }
            catch(const std::exception& error){prepared.clear();results.push_back({entry.second,error.what()});}
        }
        return results;
    }
}
