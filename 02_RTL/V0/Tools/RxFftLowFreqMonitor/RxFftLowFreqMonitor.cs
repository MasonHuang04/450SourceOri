using System;
using System.IO;
using System.IO.Ports;
using System.Globalization;
using System.Text;

public sealed class FftReport {
 public uint Sequence,Count,Span;public int Bin,Minimum,Maximum,Flags;public ulong Power;
 public const double Fs=165000000.0/144.0/128.0, BinHz=Fs/2048.0;
 public double Frequency {get{return Bin*BinHz;}}
 static ulong Hex(string s,int width){if(s.Length!=width)throw new FormatException("Field width");return ulong.Parse(s,NumberStyles.AllowHexSpecifier,CultureInfo.InvariantCulture);}
 public static FftReport Parse(string line){
  line=line.TrimEnd('\r','\n');if(line.Length!=62||!line.StartsWith("L1,"))throw new FormatException("Record header/length");
  int sum=0;for(int i=0;i<60;i++)sum^=(byte)line[i];if(sum!=(int)Hex(line.Substring(60),2))throw new FormatException("Checksum");
  string[] f=line.Split(',');if(f.Length!=10)throw new FormatException("Field count");
  FftReport r=new FftReport();r.Sequence=(uint)Hex(f[1],8);r.Count=(uint)Hex(f[2],8);r.Bin=(int)Hex(f[3],4);r.Power=Hex(f[4],11);
  r.Minimum=unchecked((short)Hex(f[5],4));r.Maximum=unchecked((short)Hex(f[6],4));r.Flags=(int)Hex(f[7],2);r.Span=(uint)Hex(f[8],8);
  if(r.Bin>1024||r.Power>=((ulong)1<<41))throw new FormatException("FFT numeric range");
  return r;
 }
 public string Status { get {return GetStatus(6288384);}}
 public string GetStatus(uint expectedSpan) {
   if((Flags&1)!=0)return "ADC_TIMEOUT";
   if(Count!=2048)return "BAD_SAMPLE_COUNT";
   if((Flags&2)!=0||Span!=expectedSpan)return "BAD_ADC_CADENCE";
   if((Flags&4)!=0)return "ADC_CLIPPED";
   if((Flags&8)!=0)return "FFT_OVERFLOW";
   if((Flags&32)!=0)return "DC_CENTERING_CLIPPED";
   if((Flags&16)!=0)return "NO_STRONG_PEAK";
   if(Flags!=0)return "UNKNOWN_FLAGS";
   return "OK";
 }
 public string Display(double target){
  if(Count==0)return string.Format(CultureInfo.InvariantCulture,"frame={0}  {1}  n=0",Sequence,Status);
  if(Status!="OK")return string.Format(CultureInfo.InvariantCulture,"frame={0}  {1}  n={2}  LPF_ADC=[{3},{4}]  flags=0x{5:X2}",Sequence,Status,Count,Minimum,Maximum,Flags);
  double error=Frequency-target;
  return string.Format(CultureInfo.InvariantCulture,"frame={0}  peak={1:F2} Hz  bin={2}  error={3:+0.00;-0.00;0.00} Hz  {4}  power={5:F2} code^2  LPF_ADC=[{6},{7}]",
   Sequence,Frequency,Bin,error,Math.Abs(error)<=3 ? "PASS_WITHIN_3HZ":"CHECK_FREQ",Power/64.0,Minimum,Maximum);
 }
}
class Program {
 static int Main(string[] argv){
  Console.OutputEncoding=Encoding.UTF8;
  try {
   if(argv.Length>=2&&(argv[0]=="--selftest"||argv[0]=="--selftest-compressed")){
    bool compressed=argv[0]=="--selftest-compressed";
    string[] lines=File.ReadAllLines(argv[1]);
    if(lines.Length!=(compressed?11:1))throw new Exception("Unexpected test record count");
    for(int i=0;i<lines.Length;i++){
     FftReport r=FftReport.Parse(lines[i]);string status=r.GetStatus(compressed?262016u:6288384u);
     string expected=(compressed&&i==10)?"ADC_TIMEOUT":(compressed&&i==9)?"ADC_CLIPPED":"OK";
     if(status!=expected)throw new Exception("Status: "+status+" expected "+expected);
     if(!compressed&&Math.Abs(r.Frequency-100)>3)throw new Exception("Frequency error");
     Console.WriteLine("case="+i+" status="+status+" bin="+r.Bin+" frequency="+r.Frequency);
    }
    char[] bad=lines[0].ToCharArray();bad[22]=bad[22]=='0'?'1':'0';bool caught=false;
    try{FftReport.Parse(new string(bad));}catch(FormatException){caught=true;}if(!caught)throw new Exception("Bad checksum accepted");
    caught=false;try{FftReport.Parse(lines[0].Substring(1));}catch(FormatException){caught=true;}if(!caught)throw new Exception("Truncated record accepted");
    caught=false;try{FftReport.Parse("F"+lines[0].Substring(1));}catch(FormatException){caught=true;}if(!caught)throw new Exception("Old firmware accepted");
    Console.WriteLine("PASS MONITOR: UART record parsing and error handling");return 0;
   }
   Console.WriteLine("实验 2：外部正弦波 -> 主板 RX -> Kaiser4 / FFT / 峰值\n需要烧录 RxFftLowFreq50to100Hz.sof；请关闭原上位机和其他串口程序。\n");
   string port;
   if(argv.Length>0)port=argv[0];
   else {
    Console.WriteLine("当前串口："+string.Join(", ",SerialPort.GetPortNames()));
    Console.Write("输入主板串口，例如 COM5：");port=Console.ReadLine().Trim();
   }
   double target=100;
   if(argv.Length>1)target=double.Parse(argv[1],CultureInfo.InvariantCulture);
   else {Console.Write("发生器频率 Hz（回车默认 100）：");string s=Console.ReadLine().Trim();if(s.Length>0)target=double.Parse(s,CultureInfo.InvariantCulture);}
   if(double.IsNaN(target)||double.IsInfinity(target)||target<50||target>100)throw new Exception("本固件仅测试50–100 Hz范围。");
   string logPath=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"FFT_"+DateTime.Now.ToString("yyyyMMdd_HHmmss")+".csv");
   using(SerialPort sp=new SerialPort(port,2000000,Parity.None,8,StopBits.One))
   using(StreamWriter log=new StreamWriter(logPath,false,Encoding.UTF8)){
    sp.Handshake=Handshake.None;sp.DtrEnable=false;sp.RtsEnable=false;sp.ReadTimeout=2000;sp.NewLine="\n";sp.Open();
    log.WriteLine("time,sequence,status,count,bin,frequency_hz,target_hz,error_hz,power_code_squared,adc_min,adc_max,span_ticks,flags");
    Console.WriteLine("已打开 "+port+"，2 Mbaud / 8N1。\n50–100 Hz低频模式：CIC滤波/128，2048点，约228.78ms，频格4.371Hz。\nPASS_WITHIN_3HZ表示本次相对你输入的目标频率误差不超过3Hz。\n更改发生器频率后请重启查看器并输入新目标；目标只用于比较，不会修改测量值。\n结果保存："+logPath+"\n按 Ctrl+C 退出。\n");
    int timeouts=0;
    while(true){
     string line;try{line=sp.ReadLine();timeouts=0;}catch(TimeoutException){if(++timeouts%3==1)Console.WriteLine("等待数据：核对实验2固件、USB串口和主板供电。");continue;}
     FftReport r;try{r=FftReport.Parse(line);}catch(FormatException){Console.WriteLine("丢弃数据：请确认烧录50–100Hz新版固件，旧版报文不兼容。");continue;}
     Console.WriteLine(r.Display(target));
     log.WriteLine(string.Format(CultureInfo.InvariantCulture,"{0},{1},{2},{3},{4},{5:F8},{6:F3},{7:F8},{8:F6},{9},{10},{11},{12}",DateTime.Now.ToString("o"),r.Sequence,r.Status,r.Count,r.Bin,r.Frequency,target,r.Frequency-target,r.Power/64.0,r.Minimum,r.Maximum,r.Span,r.Flags));log.Flush();
    }
   }
  }catch(Exception e){Console.WriteLine("错误："+e.Message);if(argv.Length==0){Console.WriteLine("按回车关闭。");Console.ReadLine();}return 1;}
 }
}
