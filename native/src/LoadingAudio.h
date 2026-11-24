#pragma once

#include <Windows.h>
#include <xaudio2.h>
#include <algorithm>
#include <array>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <string_view>
#include <vector>

namespace TransitReport
{
    class LoadingAudio
    {
    public:
        bool Prepare(const std::filesystem::path& path)
        {
            std::ifstream file(path, std::ios::binary);
            // The installer supplies a canonical 24 kHz, 16-bit stereo PCM WAV.
            constexpr std::array<unsigned char, 16> expectedFormat{
                1, 0, 2, 0, 0xC0, 0x5D, 0, 0, 0, 0x77, 1, 0, 4, 0, 16, 0};
            std::array<unsigned char, 44> header{};
            if (!file.read(reinterpret_cast<char*>(header.data()), header.size()) ||
                std::string_view(reinterpret_cast<const char*>(header.data()), 4) != "RIFF" ||
                std::string_view(reinterpret_cast<const char*>(header.data() + 8), 8) != "WAVEfmt " ||
                header[16] != 16 || header[17] || header[18] || header[19] ||
                !std::equal(expectedFormat.begin(), expectedFormat.end(), header.begin() + 20) ||
                std::string_view(reinterpret_cast<const char*>(header.data() + 36), 4) != "data")
                return false;
            const auto bytes = std::uint32_t(header[40]) | (std::uint32_t(header[41]) << 8) |
                               (std::uint32_t(header[42]) << 16) | (std::uint32_t(header[43]) << 24);
            if (bytes == 0 || bytes > 8 * 1024 * 1024 || bytes % 4 != 0)
                return false;
            std::scoped_lock lock(m_mutex);
            m_pcm.resize(bytes);
            if (!file.read(reinterpret_cast<char*>(m_pcm.data()), bytes))
                return false;
            WAVEFORMATEX format{WAVE_FORMAT_PCM, 2, 24000, 96000, 4, 16, 0};
            if (FAILED(XAudio2Create(&m_engine)) ||
                FAILED(m_engine->CreateMasteringVoice(&m_master)) ||
                FAILED(m_engine->CreateSourceVoice(&m_voice, &format)))
                return false;
            XAUDIO2_BUFFER buffer{};
            buffer.AudioBytes = bytes;
            buffer.pAudioData = m_pcm.data();
            buffer.LoopCount = XAUDIO2_LOOP_INFINITE;
            m_ready = SUCCEEDED(m_voice->SetVolume(0.0825f)) &&
                      SUCCEEDED(m_voice->SubmitSourceBuffer(&buffer));
            return m_ready;
        }

        void SetPlaying(bool play)
        {
            std::scoped_lock lock(m_mutex);
            if (!m_ready || m_playing == play)
                return;
            const auto result = play ? m_voice->Start() : m_voice->Stop();
            if (SUCCEEDED(result))
                m_playing = play;
        }

        ~LoadingAudio()
        {
            if (m_voice) m_voice->DestroyVoice();
            if (m_master) m_master->DestroyVoice();
            if (m_engine) m_engine->Release();
        }

    private:
        std::mutex m_mutex;
        std::vector<BYTE> m_pcm;
        IXAudio2* m_engine{};
        IXAudio2MasteringVoice* m_master{};
        IXAudio2SourceVoice* m_voice{};
        bool m_ready{};
        bool m_playing{};
    };
}
