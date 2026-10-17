using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace UsMimoTestBench
{
    // Main's legacy settings packet always includes RX: keep its current profile explicit.
    public sealed class ChirpParameters
    {
        public readonly float CenterHz, BandwidthHz, DurationSeconds, Amplitude;
        public static ChirpParameters Defaults { get { return new ChirpParameters(40000, 4000, 20, .25); } }
        public ChirpParameters(double centerHz, double bandwidthHz, double durationMs, double amplitude)
        {
            double[] values = { centerHz, bandwidthHz, durationMs, amplitude };
            foreach (double v in values) if (double.IsNaN(v) || double.IsInfinity(v)) throw new ArgumentException("参数必须是有限数值。");
            if (centerHz < 1 || centerHz > 1000000 || bandwidthHz < 0 || bandwidthHz > 1000000 ||
                centerHz - bandwidthHz / 2 <= 0 || centerHz + bandwidthHz / 2 > 1000000)
                throw new ArgumentException("扫频起止频率须在 0–1000 kHz 内，起始频率须大于 0；带宽为 0 时输出单频正弦。");
            // Existing MainTxController clamps counts >= 2^24; 100 ms stays below that threshold.
            if (durationMs < .01 || durationMs > 100) throw new ArgumentException("当前固件支持的本界面时长范围为 0.01–100 ms。");
            if (amplitude < 0 || amplitude > 1) throw new ArgumentException("幅度系数应为 0–1。");
            CenterHz = (float)centerHz; BandwidthHz = (float)bandwidthHz;
            DurationSeconds = (float)(durationMs / 1000); Amplitude = (float)amplitude;
        }
        public USSensorSettingStruct Settings()
        {
            return new USSensorSettingStruct {
                AutoTriggerEn = false, AutoTriggerPeriod = 0,
                TxSQWaveEn = false, TxDownSampleRate = 0, TxDataResolution = 14,
                TxCenterFreq = CenterHz, TxBandWidth = BandwidthHz, TxTimeLength = DurationSeconds,
                TxDigitalAmplitude = Amplitude, TxMuxSel = 0,
                RxTimeLength = .25f, RxStartDelay = .001f, RxDownSampleRate = 3,
                RxDataResolution = 16, RxMuxSel = 4
            };
        }
        public byte[] Command(bool trigger)
        {
            byte[] settings = Settings().ToComBuffer();
            if (!trigger) return settings;
            byte[] command = new byte[72]; Array.Copy(settings, command, 64);
            byte[] trig = { 0, 90, 0, 90, 165, 255, 165, 255 };
            Array.Copy(trig, 0, command, 64, 8); return command;
        }
        public string Summary { get { return string.Format(CultureInfo.InvariantCulture,
            "TX {0:0.###}–{1:0.###} kHz  ·  {2:0.##} ms  ·  幅度 {3:0.000}",
            (CenterHz - BandwidthHz / 2) / 1000, (CenterHz + BandwidthHz / 2) / 1000, DurationSeconds * 1000, Amplitude); } }
    }

    public sealed class MainReport
    {
        public uint Sequence, Count, Span;
        public int Bin, Minimum, Maximum, Flags;
        public ulong Power;
        public const double Fs = 165000000.0 / 144 / 32, BinHz = Fs / 8192;
        public double Frequency { get { return Bin * BinHz; } }
        static ulong Hex(string s, int width)
        {
            if (s.Length != width) throw new FormatException("字段长度错误");
            return ulong.Parse(s, NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }
        public static MainReport Parse(string line)
        {
            if (line.Length != 64 || !line.StartsWith("M1,") || !line.EndsWith("\r\n")) throw new FormatException("M1 格式错误");
            int checksum = 0; for (int i = 0; i < 60; i++) checksum ^= (byte)line[i];
            if (checksum != (int)Hex(line.Substring(60, 2), 2)) throw new FormatException("M1 校验失败");
            string[] f = line.Substring(0, 62).Split(','); if (f.Length != 10) throw new FormatException("M1 字段数错误");
            MainReport r = new MainReport();
            r.Sequence = (uint)Hex(f[1], 8); r.Count = (uint)Hex(f[2], 8); r.Bin = (int)Hex(f[3], 4);
            r.Power = Hex(f[4], 11); r.Minimum = unchecked((short)Hex(f[5], 4)); r.Maximum = unchecked((short)Hex(f[6], 4));
            r.Flags = (int)Hex(f[7], 2); r.Span = (uint)Hex(f[8], 8);
            if (r.Count > 8192 || r.Bin > 4096 || r.Power >= (1UL << 41)) throw new FormatException("M1 数值越界");
            return r;
        }
        public string Status
        {
            get {
                if ((Flags & 1) != 0 || Count != 8192) return "SHORT_OR_EMPTY_WINDOW";
                if ((Flags & 2) != 0 || Span != (Count - 1) * 4608) return "BAD_CADENCE";
                if ((Flags & 4) != 0) return "ADC_CLIPPED";
                if ((Flags & 8) != 0) return "FFT_OVERFLOW";
                if ((Flags & 32) != 0) return "CENTERING_CLIPPED";
                if ((Flags & 16) != 0) return "NO_STRONG_PEAK";
                if ((Flags & 128) != 0) return "RAW_BUFFER_CAPPED";
                if (Flags != 0) return "UNKNOWN_FLAGS";
                if (Bin < 6 || Bin > 114) return "PEAK_OUTSIDE_MAIN_RANGE";
                return "OK";
            }
        }
        public string StatusText
        {
            get {
                switch (Status) {
                    case "OK": return "有效";
                    case "SHORT_OR_EMPTY_WINDOW": return "采样不足 / 空窗口";
                    case "BAD_CADENCE": return "采样间隔不符合当前 main 配置";
                    case "ADC_CLIPPED": return "ADC 削顶，请降低输入幅度";
                    case "FFT_OVERFLOW": return "FFT 溢出";
                    case "CENTERING_CLIPPED": return "去直流后削顶";
                    case "NO_STRONG_PEAK": return "未检测到有效峰值";
                    case "RAW_BUFFER_CAPPED": return "波形缓存达到容量上限";
                    case "PEAK_OUTSIDE_MAIN_RANGE": return "峰值超出当前 main 搜索区间";
                    default: return "未知状态";
                }
            }
        }
    }

    // One parser for interleaved legacy binary waveform packets and 64-byte M1 records.
    public sealed class MainStreamParser
    {
        readonly List<byte> buffer = new List<byte>();
        static readonly byte[] magic = { 0, 0, 255, 255, 0, 255, 90, 0 };
        public Action<ScopeDataFrame> Raw;
        public Action<MainReport> Peak;
        public int Invalid { get; private set; }
        public int BufferedBytes { get { return buffer.Count; } }
        public void Reset() { buffer.Clear(); Invalid = 0; }
        bool Header(int offset) { for (int i = 0; i < 8; i++) if (buffer[offset + i] != magic[i]) return false; return true; }
        public void Feed(byte[] data, int count)
        {
            if (count < 0 || count > data.Length) throw new ArgumentOutOfRangeException("count");
            for (int i = 0; i < count; i++) buffer.Add(data[i]);
            int offset = 0;
            while (buffer.Count - offset >= 8) {
                int remaining = buffer.Count - offset;
                if (Header(offset)) {
                    if (remaining < 32) break;
                    byte[] h = buffer.GetRange(offset, 32).ToArray();
                    uint n = BitConverter.ToUInt32(h, 8); float dt = BitConverter.ToSingle(h, 16);
                    bool valid = h[24] == 0 && h[25] == 90 && h[28] == 255 && h[29] == 255 && h[30] == 0 && h[31] == 0;
                    if (!valid || n > 131072 || float.IsNaN(dt) || float.IsInfinity(dt) || dt <= 0 || dt > 1) { offset++; Invalid++; continue; }
                    int total = checked((int)n * 2 + 64); if (remaining < total) break;
                    for (int i = 0; i < 32; i++) {
                        byte expected = (i == 6 || i == 25) ? (byte)165 : h[i];
                        if (buffer[offset + total - 32 + i] != expected) valid = false;
                    }
                    if (!valid) { offset++; Invalid++; continue; }
                    ushort[] words = new ushort[n];
                    for (int i = 0; i < n; i++) words[i] = (ushort)(buffer[offset + 32 + 2*i] | buffer[offset + 33 + 2*i] << 8);
                    offset += total;
                    if (Raw != null) Raw(new ScopeDataFrame { DataLen = (int)n, Data = words, SamplingPeriod = dt, TempC = BitConverter.ToInt16(h, 26) / 128f });
                } else if (buffer[offset] == 77 && buffer[offset + 1] == 49 && buffer[offset + 2] == 44) {
                    if (remaining < 64) break;
                    MainReport r;
                    try { r = MainReport.Parse(Encoding.ASCII.GetString(buffer.GetRange(offset, 64).ToArray())); }
                    catch (FormatException) { offset++; Invalid++; continue; }
                    catch (OverflowException) { offset++; Invalid++; continue; }
                    offset += 64; if (Peak != null) Peak(r);
                } else offset++;
            }
            if (offset > 0) buffer.RemoveRange(0, offset);
        }
    }
}
