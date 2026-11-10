#pragma once
#include <map>
#include <string>
#include <vector>
#include <random>
#include <mutex>
namespace TransitRandom {
class Picker {
 std::map<std::string,std::string> last;
 std::mt19937 engine{std::random_device{}()};
 std::mutex mutex;
public:
 std::string Pick(const std::string& key,const std::vector<std::string>& pool) {
  std::scoped_lock lock(mutex);
  std::vector<std::string> choices;
  for(const auto& item:pool)if(item!=last[key])choices.push_back(item);
  if(choices.empty())choices=pool;
  if(choices.empty())return {};
  const auto selected=choices[std::uniform_int_distribution<std::size_t>(0,choices.size()-1)(engine)];
  last[key]=selected;return selected;
 }
};
}
