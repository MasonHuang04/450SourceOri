using System;
using System.IO;
using System.IO.Ports;
using System.Text;
using System.Globalization;
using System.Collections.Generic;
using System.Threading;

    public sealed class MainReport
    {
        public uint Sequence, Count, Span;
        public int Bin, Minimum, Maximum, Flags;
        public ulong Power;
        public bool HasInterpolation, HasFftLength; public int DeltaQ16, InterpolationStatus, FftLength = 8192;
        public bool HasMeasurement;
        public int TemperatureRawQ7, TemperatureStatus, RangeStatus;
        public uint ReportedFrequencyMilliHz, DistanceUm;
        public double TemperatureC { get { return TemperatureRawQ7 / 128.0; } }
        public bool TemperatureValid { get { return HasMeasurement && TemperatureStatus == 0; } }
        public double SoundSpeed { get { return 331.3 + .606 * TemperatureC; } }
        public double DistanceMm { get { return DistanceUm / 1000.0; } }
        public bool RangeValid { get { return HasMeasurement && RangeStatus == 0 && TemperatureValid && Status == "OK" && InterpolationValid; } }
        public string TemperatureText { get {
            if (!HasMeasurement) return "旧固件未提供温度有效状态";
            switch (TemperatureStatus) { case 0: return TemperatureC.ToString("F2", CultureInfo.InvariantCulture) + " °C";
                case 1: return "温度未读取 / 传感器无应答"; case 2: return "温度数据已过期"; default: return "温度数值超范围"; }
        } }
        public string RangeText { get {
            if (!HasMeasurement) return "旧固件未回传距离";
            if (Status != "OK") return "峰值无效：" + StatusText;
            switch (RangeStatus) { case 0: return RangeValid ? DistanceMm.ToString("F3", CultureInfo.InvariantCulture) + " mm" : "距离状态不一致";
                case 1: return "采集 / FFT 无效"; case 2: return TemperatureText; case 3: return "Chirp 参数不能用于测距";
                case 4: return "距离运算超范围"; default: return "插值无效，暂不估算距离"; }
        } }
        // BEGIN_MAIN_SEARCH_PROFILE
        public const double SearchMinHz = 25, SearchMaxHz = 2000;
        // END_MAIN_SEARCH_PROFILE
        public const double Fs = 165000000.0 / 144 / 32;
        public double BinHz { get { return Fs / FftLength; } }
        public double ObservationMs { get { return Count / Fs * 1000; } }
        public bool LowCycleWarning { get { return HasFftLength && Status == "OK" && Frequency * Count / Fs < 3; } }
        public double RawFrequency { get { return Bin * BinHz; } }
        public double OffsetBins { get { return DeltaQ16 / 65536.0; } }
        public bool InterpolationValid { get { return HasInterpolation && InterpolationStatus == 0 && Status == "OK"; } }
        // FPGA already computed the parabolic offset. PC only converts bin units to Hz.
        public double Frequency { get { return HasMeasurement ? ReportedFrequencyMilliHz / 1000.0 : InterpolationValid ? (Bin + OffsetBins) * BinHz : RawFrequency; } }
        public string InterpolationText { get {
            if (!HasInterpolation) return "旧固件：未提供插值";
            if (InterpolationValid) return "FPGA 三点对数插值";
            switch (InterpolationStatus) {
                case 1: return "插值停用：采集/FFT状态异常";
                case 2: return "插值停用：邻点不完整";
                case 3: return "插值停用：邻点功率为零";
                case 4: return "插值停用：非局部峰顶";
                case 5: return "插值停用：峰顶平坦";
                default: return "插值停用：结果状态异常";
            }
        } }
        static ulong Hex(string s, int width)
        {
            if (s.Length != width) throw new FormatException("字段长度错误");
            return ulong.Parse(s, NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }
        public static MainReport Parse(string line)
        {
            bool m4 = line.StartsWith("M4,"), m3 = line.StartsWith("M3,"), m2 = line.StartsWith("M2,"); int total = m4 ? 110 : m3 ? 81 : m2 ? 76 : 64, checkAt = total - 4;
            if (line.Length != total || (!m4 && !m3 && !m2 && !line.StartsWith("M1,")) || !line.EndsWith("\r\n")) throw new FormatException("Main 报告格式错误");
            int checksum = 0; for (int i = 0; i < checkAt; i++) checksum ^= (byte)line[i];
            if (checksum != (int)Hex(line.Substring(checkAt, 2), 2)) throw new FormatException("Main 报告校验失败");
            string[] f = line.Substring(0, total - 2).Split(','); if (f.Length != (m4 ? 18 : m3 ? 13 : m2 ? 12 : 10)) throw new FormatException("Main 报告字段数错误");
            MainReport r = new MainReport();
            r.Sequence = (uint)Hex(f[1], 8); r.Count = (uint)Hex(f[2], 8); r.Bin = (int)Hex(f[3], 4);
            r.Power = Hex(f[4], 11); r.Minimum = unchecked((short)Hex(f[5], 4)); r.Maximum = unchecked((short)Hex(f[6], 4));
            r.Flags = (int)Hex(f[7], 2); r.Span = (uint)Hex(f[8], 8);
            if (r.Count > 8192 || r.Bin > 4096 || r.Power >= (1UL << 41)) throw new FormatException("Main 报告数值越界");
            r.HasFftLength = m3 || m4;
            if (m3 || m4) { r.FftLength = (int)Hex(f[11],4); if (r.FftLength!=1024 && r.FftLength!=2048 && r.FftLength!=4096 && r.FftLength!=8192) throw new FormatException("FFT长度无效"); }
            if(r.Count>r.FftLength || r.Bin>r.FftLength/2)throw new FormatException("FFT数据越界");
            r.HasInterpolation = m2 || m3 || m4;
            if (r.HasInterpolation) {
                r.DeltaQ16 = unchecked((int)(uint)Hex(f[9], 8)); r.InterpolationStatus = (int)Hex(f[10], 2);
                if (r.DeltaQ16 < -32768 || r.DeltaQ16 > 32768 || r.InterpolationStatus > 5 ||
                    (r.InterpolationStatus != 0 && r.DeltaQ16 != 0)) throw new FormatException("插值字段越界");
            }
            if (m4) {
                r.HasMeasurement = true; r.TemperatureRawQ7 = unchecked((short)Hex(f[12], 4));
                r.TemperatureStatus = (int)Hex(f[13], 2); r.ReportedFrequencyMilliHz = (uint)Hex(f[14], 8);
                r.DistanceUm = (uint)Hex(f[15], 8); r.RangeStatus = (int)Hex(f[16], 2);
                if (r.TemperatureStatus > 3 || r.RangeStatus > 5 ||
                    (r.TemperatureStatus == 0 && (r.TemperatureRawQ7 < -7040 || r.TemperatureRawQ7 > 19200)) ||
                    (r.RangeStatus != 0 && r.DistanceUm != 0) ||
                    (r.RangeStatus == 0 && (!r.TemperatureValid || r.Flags != 0 || r.InterpolationStatus != 0)))
                    throw new FormatException("温度或距离字段状态无效");
                double expectedHz = r.InterpolationValid ? (r.Bin + r.OffsetBins) * r.BinHz : r.RawFrequency;
                if (r.Status == "OK" && Math.Abs(r.ReportedFrequencyMilliHz / 1000.0 - expectedHz) > .000501)
                    throw new FormatException("FPGA频率与峰格不一致");
            }
            return r;
        }
        public string Status
        {
            get {
                if ((Flags & 1) != 0 || Count < 64 || Count > FftLength || (!HasFftLength && Count != 8192)) return "SHORT_OR_EMPTY_WINDOW";
                if ((Flags & 2) != 0 || Span != (Count - 1) * 4608) return "BAD_CADENCE";
                if ((Flags & 4) != 0) return "ADC_CLIPPED";
                if ((Flags & 8) != 0) return "FFT_OVERFLOW";
                if ((Flags & 32) != 0) return "CENTERING_CLIPPED";
                if ((Flags & 16) != 0) return "NO_STRONG_PEAK";
                if ((Flags & 128) != 0) return "RAW_BUFFER_CAPPED";
                if (Flags != 0) return "UNKNOWN_FLAGS";
                if (Bin < Math.Ceiling(SearchMinHz / BinHz) || Bin > Math.Floor(SearchMaxHz / BinHz)) return "PEAK_OUTSIDE_MAIN_RANGE";
                return "OK";
            }
        }
        public string StatusText
        {
            get {
                switch (Status) {
                    case "OK": return LowCycleWarning ? "短窗低频，仅供参考" : "数据有效";
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


public sealed class MainStreamParser {
 readonly List<byte> b=new List<byte>();static readonly byte[] magic={0,0,255,255,0,255,90,0};
 public Action<ushort[],float> Raw;public Action<MainReport> Peak;public int Invalid;
 bool Header(){for(int i=0;i<8;i++)if(b[i]!=magic[i])return false;return true;}
 public void Feed(byte[] data,int n){
  for(int i=0;i<n;i++)b.Add(data[i]);
  while(b.Count>=8){
   if(Header()){
    if(b.Count<32)return;byte[] h=b.GetRange(0,32).ToArray();uint count=BitConverter.ToUInt32(h,8);float period=BitConverter.ToSingle(h,16);
    if(count>131072||float.IsNaN(period)||float.IsInfinity(period)||period<=0){b.RemoveAt(0);Invalid++;continue;}
    int total=checked((int)count*2+64);if(b.Count<total)return;
    bool ok=true;for(int i=0;i<32;i++){byte exp=(i==6||i==25)?(byte)165:h[i];if(b[total-32+i]!=exp)ok=false;}
    if(!ok){b.RemoveAt(0);Invalid++;continue;}
    ushort[] raw=new ushort[count];for(int i=0;i<count;i++)raw[i]=(ushort)(b[32+i*2]|b[33+i*2]<<8);
    b.RemoveRange(0,total);if(Raw!=null)Raw(raw,period);
   }else if(b[0]==77&&(b[1]==49||b[1]==50||b[1]==51||b[1]==52)&&b[2]==44){
    int length=b[1]==52?110:b[1]==51?81:b[1]==50?76:64;if(b.Count<length)return;
    try {MainReport r=MainReport.Parse(Encoding.ASCII.GetString(b.GetRange(0,length).ToArray()));b.RemoveRange(0,length);if(Peak!=null)Peak(r);}
    catch(FormatException){b.RemoveAt(0);Invalid++;}
   }else b.RemoveAt(0);
  }
 }
}
class Program {
 static byte[] HexFile(string p){List<byte> b=new List<byte>();foreach(string s in File.ReadAllLines(p))if(s.Trim().Length>0)b.Add(byte.Parse(s.Trim(),NumberStyles.HexNumber));return b.ToArray();}
 static int Main(string[] args){Console.OutputEncoding=Encoding.UTF8;try {
  if(args.Length>1&&args[0]=="--selftest-uart"){
   string line=File.ReadAllText(args[1]).Trim('\r','\n')+"\r\n";MainReport r=MainReport.Parse(line);
   if(r.Status!="OK"||r.Count!=672||r.Bin!=3||r.Power!=123456789||r.Minimum!=-256||r.Maximum!=256)throw new Exception("Physical UART record mismatch");
   Console.WriteLine("PASS MAIN MONITOR: real 2-Mbaud UART record and physical cadence metadata");return 0;
  }
  if(args.Length>1&&(args[0]=="--selftest"||args[0]=="--selftest-compressed")){
   bool compressed=args[0]=="--selftest-compressed";
   byte[] bytes=HexFile(args[1]);int raws=0,peaks=0;MainStreamParser p=new MainStreamParser();
   p.Raw=(raw,dt)=>{if(raw.Length<5440||raw.Length>5444||Math.Abs(dt-576.0/165e6)>1e-12)throw new Exception("Raw metadata");raws++;};
   p.Peak=r=>{if(r.Status!=(compressed?"BAD_CADENCE":"OK")||r.Count!=672||r.Flags!=0||r.Span!=(compressed?21472u:3091968u)||Math.Abs((r.Bin+(r.HasInterpolation?r.OffsetBins:0))*r.BinHz-100)>3)throw new Exception("FFT metadata");peaks++;};
   for(int i=0;i<bytes.Length;){int n=Math.Min((i%37)+1,bytes.Length-i);byte[] chunk=new byte[n];Array.Copy(bytes,i,chunk,0,n);p.Feed(chunk,n);i+=n;}
   if(raws!=1||peaks!=1||p.Invalid!=0)throw new Exception("Mixed stream counts");
   int tail=bytes.Length>=110&&bytes[bytes.Length-110]==77&&bytes[bytes.Length-109]==52?110:bytes[bytes.Length-81]==77&&bytes[bytes.Length-80]==51?81:bytes[bytes.Length-76]==77&&bytes[bytes.Length-75]==50?76:64;string line=Encoding.ASCII.GetString(bytes,bytes.Length-tail,tail);char[] bad=line.ToCharArray();bad[22]=bad[22]=='0'?'1':'0';bool rejected=false;
   try{MainReport.Parse(new string(bad));}catch(FormatException){rejected=true;}if(!rejected)throw new Exception("Bad checksum accepted");
   Console.WriteLine("PASS MAIN MONITOR: mixed raw/M1/M2/M3 stream, fragmented reads, checksum and frequency");return 0;
  }
  Console.WriteLine("Main：外部连续低频信号 -> RX -> CIC/32 -> Kaiser4 + 672 samples / 1024 FFT + 峰值\n请烧录 UsMimoTestBench.sof（main 新版），关闭其他串口程序。\n");
  string port;if(args.Length>0)port=args[0];else{Console.WriteLine("串口："+string.Join(", ",SerialPort.GetPortNames()));Console.Write("主板 COM 号：");port=Console.ReadLine().Trim();}
  double target=100;if(args.Length>1)target=double.Parse(args[1],CultureInfo.InvariantCulture);else{Console.Write("发生器频率 Hz（回车100，仅用于比较）：");string s=Console.ReadLine().Trim();if(s.Length>0)target=double.Parse(s,CultureInfo.InvariantCulture);}
  if(double.IsNaN(target)||double.IsInfinity(target)||target<=0)throw new Exception("Invalid target");
  string folder=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"Main_"+DateTime.Now.ToString("yyyyMMdd_HHmmss"));Directory.CreateDirectory(folder);
  using(SerialPort sp=new SerialPort(port,2000000,Parity.None,8,StopBits.One))using(StreamWriter log=new StreamWriter(Path.Combine(folder,"peaks.csv"),false,Encoding.UTF8)){
   sp.Handshake=Handshake.None;sp.DtrEnable=false;sp.RtsEnable=false;sp.ReadTimeout=3000;sp.Open();Thread.Sleep(500);sp.DiscardInBuffer();
   log.WriteLine("time,seq,status,count,bin,frequency_hz,target_hz,error_hz,power_code_squared,flags,raw_bin_hz,delta_q16,interpolation_status,fft_length,short_window_warning,temperature_c,temperature_status,distance_mm,range_status");
   MainStreamParser p=new MainStreamParser();bool done=false;int rawno=0;
   p.Raw=(raw,dt)=>{
    rawno++;string path=Path.Combine(folder,"raw_"+rawno.ToString("D4")+".csv");
    using(StreamWriter f=new StreamWriter(path)){f.WriteLine("index,time_s,unsigned_code,signed_code");for(int i=0;i<raw.Length;i++)f.WriteLine(string.Format(CultureInfo.InvariantCulture,"{0},{1:R},{2},{3}",i,i*(double)dt,raw[i],(int)raw[i]-32768));}
    Console.WriteLine("原始波形："+raw.Length+" 点，采样间隔 "+(dt*1e6).ToString("F4")+" us；"+path);
   };
   p.Peak=r=>{
    string msg=r.Status=="OK"?string.Format(CultureInfo.InvariantCulture,"峰值 {0:F3} Hz，误差 {1:+0.000;-0.000;0.000} Hz，功率 {2:F3} ADC code^2",r.Frequency,r.Frequency-target,r.Power/64.0):"结果无效/需检查："+r.Status;
    Console.WriteLine((r.HasMeasurement?"温度 "+r.TemperatureText+"；估算距离 "+r.RangeText+"；":"")+msg+"；原频点 "+r.RawFrequency.ToString("F3")+" Hz；"+r.InterpolationText+(r.LowCycleWarning?"；短窗低频，仅供参考":"")+"；FFT有效点数 "+r.Count+"；flags=0x"+r.Flags.ToString("X2"));
    log.WriteLine(string.Format(CultureInfo.InvariantCulture,"{0},{1},{2},{3},{4},{5:R},{6:R},{7:R},{8:R},{9},{10:R},{11},{12},{13},{14}",DateTime.Now.ToString("o"),r.Sequence,r.Status,r.Count,r.Bin,r.Frequency,target,r.Frequency-target,r.Power/64.0,r.Flags,r.RawFrequency,r.DeltaQ16,r.HasInterpolation?r.InterpolationStatus:-1,r.FftLength,r.LowCycleWarning)+string.Format(CultureInfo.InvariantCulture,",{0},{1},{2},{3}",r.TemperatureValid?r.TemperatureC.ToString("R",CultureInfo.InvariantCulture):"",r.HasMeasurement?r.TemperatureStatus:-1,r.RangeValid?r.DistanceMm.ToString("R",CultureInfo.InvariantCulture):"",r.HasMeasurement?r.RangeStatus:-1));log.Flush();done=true;
   };
   byte[] trigger={0,90,0,90,165,255,165,255};byte[] buffer=new byte[4096];
   Console.WriteLine("默认搜索{0:g}–{1:g} Hz；有效采样35.807 kS/s，672有效点/1024 FFT，观察约18.77 ms，低频精度受限。\n保持外部正弦波连续输出；本程序只发送触发，不覆盖已编译参数。\n",MainReport.SearchMinHz,MainReport.SearchMaxHz);
   while(true){done=false;sp.Write(trigger,0,trigger.Length);Console.WriteLine("已触发，等待采集及波形回传（通常约1秒）。");
    while(!done){try{int n=sp.Read(buffer,0,buffer.Length);p.Feed(buffer,n);}catch(TimeoutException){Console.WriteLine("仍未收到完整结果：核对main固件、COM及ADC连接。按Ctrl+C退出。");}}
    Console.Write("回车再测；输入新的目标Hz再回车可更新比较值；q退出：");string s=Console.ReadLine().Trim();if(s=="q")break;if(s.Length>0)target=double.Parse(s,CultureInfo.InvariantCulture);
   }
  }return 0;
 }catch(Exception e){Console.WriteLine("错误："+e.Message);if(args.Length==0)Console.ReadLine();return 1;}}
}
