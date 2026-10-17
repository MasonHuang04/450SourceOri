using System;
using System.IO;
using System.IO.Ports;
using System.Text;
using System.Globalization;
using System.Collections.Generic;
using System.Threading;

public sealed class MainReport {
 public uint Sequence,Count,Span;public int Bin,Minimum,Maximum,Flags;public ulong Power;
 public const double Fs=165000000.0/144.0/32.0, BinHz=Fs/8192.0;
 public double Frequency {get{return Bin*BinHz;}}
 static ulong Hex(string s,int n){if(s.Length!=n)throw new FormatException("Field width");return ulong.Parse(s,NumberStyles.HexNumber,CultureInfo.InvariantCulture);}
 public static MainReport Parse(string line){
  if(line.Length!=64||!line.StartsWith("M1,")||!line.EndsWith("\r\n"))throw new FormatException("M1 format");
  int ck=0;for(int i=0;i<60;i++)ck^=(byte)line[i];if(ck!=(int)Hex(line.Substring(60,2),2))throw new FormatException("M1 checksum");
  string[] a=line.Substring(0,62).Split(',');if(a.Length!=10)throw new FormatException("M1 fields");
  MainReport r=new MainReport();r.Sequence=(uint)Hex(a[1],8);r.Count=(uint)Hex(a[2],8);r.Bin=(int)Hex(a[3],4);r.Power=Hex(a[4],11);
  r.Minimum=unchecked((short)Hex(a[5],4));r.Maximum=unchecked((short)Hex(a[6],4));r.Flags=(int)Hex(a[7],2);r.Span=(uint)Hex(a[8],8);
  if(r.Count>8192||r.Bin>4096||r.Power>=((ulong)1<<41))throw new FormatException("M1 range");return r;
 }
 public string Status {get{
  if((Flags&1)!=0)return "SHORT_OR_EMPTY_WINDOW";
  if(Count<2||(Flags&2)!=0||Span!=(Count-1)*4608)return "BAD_CADENCE";
  if((Flags&4)!=0)return "ADC_CLIPPED";if((Flags&8)!=0)return "FFT_OVERFLOW";
  if((Flags&32)!=0)return "CENTERING_CLIPPED";if((Flags&16)!=0)return "NO_STRONG_PEAK";
  if((Flags&128)!=0)return "RAW_BUFFER_CAPPED";return Flags==0 ? "OK" : "UNKNOWN_FLAGS";
 }}
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
   }else if(b[0]==77&&b[1]==49&&b[2]==44){
    if(b.Count<64)return;
    try {MainReport r=MainReport.Parse(Encoding.ASCII.GetString(b.GetRange(0,64).ToArray()));b.RemoveRange(0,64);if(Peak!=null)Peak(r);}
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
   if(r.Status!="OK"||r.Count!=8192||r.Bin!=23||r.Power!=123456789||r.Minimum!=-256||r.Maximum!=256)throw new Exception("Physical UART record mismatch");
   Console.WriteLine("PASS MAIN MONITOR: real 2-Mbaud UART record and physical cadence metadata");return 0;
  }
  if(args.Length>1&&(args[0]=="--selftest"||args[0]=="--selftest-compressed")){
   bool compressed=args[0]=="--selftest-compressed";
   byte[] bytes=HexFile(args[1]);int raws=0,peaks=0;MainStreamParser p=new MainStreamParser();
   p.Raw=(raw,dt)=>{if(raw.Length<71000||raw.Length>72000||Math.Abs(dt-576.0/165e6)>1e-12)throw new Exception("Raw metadata");raws++;};
   p.Peak=r=>{if(r.Status!=(compressed?"BAD_CADENCE":"OK")||r.Count!=8192||r.Flags!=0||r.Span!=(compressed?262112u:37744128u)||Math.Abs(r.Frequency-100)>3)throw new Exception("FFT metadata");peaks++;};
   for(int i=0;i<bytes.Length;){int n=Math.Min((i%37)+1,bytes.Length-i);byte[] chunk=new byte[n];Array.Copy(bytes,i,chunk,0,n);p.Feed(chunk,n);i+=n;}
   if(raws!=1||peaks!=1||p.Invalid!=0)throw new Exception("Mixed stream counts");
   string line=Encoding.ASCII.GetString(bytes,bytes.Length-64,64);char[] bad=line.ToCharArray();bad[22]=bad[22]=='0'?'1':'0';bool rejected=false;
   try{MainReport.Parse(new string(bad));}catch(FormatException){rejected=true;}if(!rejected)throw new Exception("Bad checksum accepted");
   Console.WriteLine("PASS MAIN MONITOR: mixed raw/M1 stream, fragmented reads, checksum and frequency");return 0;
  }
  Console.WriteLine("Main：外部连续低频信号 -> RX -> CIC/32 -> Kaiser4 + 8192 FFT + 峰值\n请烧录 UsMimoTestBench.sof（main 新版），关闭其他串口程序。\n");
  string port;if(args.Length>0)port=args[0];else{Console.WriteLine("串口："+string.Join(", ",SerialPort.GetPortNames()));Console.Write("主板 COM 号：");port=Console.ReadLine().Trim();}
  double target=100;if(args.Length>1)target=double.Parse(args[1],CultureInfo.InvariantCulture);else{Console.Write("发生器频率 Hz（回车100，仅用于比较）：");string s=Console.ReadLine().Trim();if(s.Length>0)target=double.Parse(s,CultureInfo.InvariantCulture);}
  if(double.IsNaN(target)||double.IsInfinity(target)||target<=0)throw new Exception("Invalid target");
  string folder=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"Main_"+DateTime.Now.ToString("yyyyMMdd_HHmmss"));Directory.CreateDirectory(folder);
  using(SerialPort sp=new SerialPort(port,2000000,Parity.None,8,StopBits.One))using(StreamWriter log=new StreamWriter(Path.Combine(folder,"peaks.csv"),false,Encoding.UTF8)){
   sp.Handshake=Handshake.None;sp.DtrEnable=false;sp.RtsEnable=false;sp.ReadTimeout=3000;sp.Open();Thread.Sleep(500);sp.DiscardInBuffer();
   log.WriteLine("time,seq,status,count,bin,frequency_hz,target_hz,error_hz,power_code_squared,flags");
   MainStreamParser p=new MainStreamParser();bool done=false;int rawno=0;
   p.Raw=(raw,dt)=>{
    rawno++;string path=Path.Combine(folder,"raw_"+rawno.ToString("D4")+".csv");
    using(StreamWriter f=new StreamWriter(path)){f.WriteLine("index,time_s,unsigned_code,signed_code");for(int i=0;i<raw.Length;i++)f.WriteLine(string.Format(CultureInfo.InvariantCulture,"{0},{1:R},{2},{3}",i,i*(double)dt,raw[i],(int)raw[i]-32768));}
    Console.WriteLine("原始波形："+raw.Length+" 点，采样间隔 "+(dt*1e6).ToString("F4")+" us；"+path);
   };
   p.Peak=r=>{
    string msg=r.Status=="OK"?string.Format(CultureInfo.InvariantCulture,"峰值 {0:F3} Hz，误差 {1:+0.000;-0.000;0.000} Hz，功率 {2:F3} ADC code^2",r.Frequency,r.Frequency-target,r.Power/64.0):"结果无效/需检查："+r.Status;
    Console.WriteLine(msg+"；FFT有效点数 "+r.Count+"；flags=0x"+r.Flags.ToString("X2"));
    log.WriteLine(string.Format(CultureInfo.InvariantCulture,"{0},{1},{2},{3},{4},{5:R},{6:R},{7:R},{8:R},{9}",DateTime.Now.ToString("o"),r.Sequence,r.Status,r.Count,r.Bin,r.Frequency,target,r.Frequency-target,r.Power/64.0,r.Flags));log.Flush();done=true;
   };
   byte[] trigger={0,90,0,90,165,255,165,255};byte[] buffer=new byte[4096];
   Console.WriteLine("默认搜索25–500 Hz；有效采样35.807 kS/s，8192点，观察约229 ms。\n保持外部正弦波连续输出；本程序只发送触发，不覆盖已编译参数。\n");
   while(true){done=false;sp.Write(trigger,0,trigger.Length);Console.WriteLine("已触发，等待采集及波形回传（通常约1秒）。");
    while(!done){try{int n=sp.Read(buffer,0,buffer.Length);p.Feed(buffer,n);}catch(TimeoutException){Console.WriteLine("仍未收到完整结果：核对main固件、COM及ADC连接。按Ctrl+C退出。");}}
    Console.Write("回车再测；输入新的目标Hz再回车可更新比较值；q退出：");string s=Console.ReadLine().Trim();if(s=="q")break;if(s.Length>0)target=double.Parse(s,CultureInfo.InvariantCulture);
   }
  }return 0;
 }catch(Exception e){Console.WriteLine("错误："+e.Message);if(args.Length==0)Console.ReadLine();return 1;}}
}
