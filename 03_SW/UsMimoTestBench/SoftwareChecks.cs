using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace UsMimoTestBench
{
    public static class SoftwareChecks
    {
        static void Check(bool condition,string name) { if(!condition)throw new Exception("CHECK FAILED: "+name); }
        static byte[] Join(params byte[][] parts) { List<byte> bytes=new List<byte>();foreach(byte[] p in parts)bytes.AddRange(p);return bytes.ToArray(); }
        static byte[] Record(int bin=23,ulong power=277994098,int flags=0,uint count=8192,uint span=37744128)
        {
            string s=string.Format(CultureInfo.InvariantCulture,"M1,{0:X8},{1:X8},{2:X4},{3:X11},{4:X4},{5:X4},{6:X2},{7:X8},",1,count,bin,power,unchecked((ushort)-7000),7000,flags,span);
            Check(s.Length==60,"fixture M1 length");int c=0;foreach(char ch in s)c^=(byte)ch;
            return Encoding.ASCII.GetBytes(s+c.ToString("X2")+"\r\n");
        }
        static byte[] Wave(ushort[] data)
        {
            byte[] h={0,0,255,255,0,255,90,0,0,0,0,0,0,255,255,0,0,0,0,0,0,255,255,0,0,90,128,12,255,255,0,0};
            Array.Copy(BitConverter.GetBytes(data.Length),0,h,8,4);Array.Copy(BitConverter.GetBytes((float)(576.0/165e6)),0,h,16,4);
            byte[] bytes=new byte[2*data.Length+64];Array.Copy(h,bytes,32);
            for(int i=0;i<data.Length;i++){bytes[32+2*i]=(byte)data[i];bytes[33+2*i]=(byte)(data[i]>>8);}
            h[6]=h[25]=165;Array.Copy(h,0,bytes,bytes.Length-32,32);return bytes;
        }
        public static byte[] DemoStream()
        {
            ushort[] data=new ushort[71614];double dt=576.0/165e6;
            for(int i=0;i<data.Length;i++)data[i]=(ushort)(32768+Math.Round(7000*Math.Sin(2*Math.PI*100*i*dt)));
            return Join(Wave(data),Record());
        }
        static byte[] ReadHex(string path) { return File.ReadAllText(path).Split((char[])null,StringSplitOptions.RemoveEmptyEntries).Select(x=>byte.Parse(x,NumberStyles.HexNumber,CultureInfo.InvariantCulture)).ToArray(); }
        static void SaveHex(string path,byte[] data) { File.WriteAllLines(path,data.Select(x=>x.ToString("x2")).ToArray()); }
        static void Fragment(MainStreamParser parser,byte[] bytes)
        {
            for(int i=0;i<bytes.Length;){int n=Math.Min(i<100?1:1+(i%701),bytes.Length-i);byte[] part=new byte[n];Array.Copy(bytes,i,part,0,n);parser.Feed(part,n);i+=n;}
        }
        public static void Run(string project,string output)
        {
            Directory.CreateDirectory(output);List<string> passed=new List<string>();
            byte[] packet=ChirpParameters.Defaults.Command(true);
            byte[] golden=new byte[64];golden[1]=golden[3]=165;golden[60]=golden[62]=90;golden[61]=golden[63]=255;
            golden[11]=14;
            byte[] fc={0,64,28,71},bw={0,0,122,69},tc={10,215,163,60},amp={0,0,128,62},delay={111,18,131,58};
            Array.Copy(fc,0,golden,12,4);Array.Copy(bw,0,golden,16,4);Array.Copy(tc,0,golden,20,4);Array.Copy(amp,0,golden,24,4);
            Array.Copy(amp,0,golden,40,4);Array.Copy(delay,0,golden,44,4);golden[48]=3;golden[50]=16;golden[51]=4;
            Check(packet.Take(64).SequenceEqual(golden),"independent default settings golden bytes");
            Check(packet.Skip(64).SequenceEqual(new byte[]{0,90,0,90,165,255,165,255}),"trigger after full settings");
            byte[] custom=new ChirpParameters(200000,20000,80,.5).Command(true);
            Check(Math.Abs(BitConverter.ToSingle(custom,12)-200000)<.1 && BitConverter.ToSingle(custom,16)==20000 && BitConverter.ToSingle(custom,20)==.08f && BitConverter.ToSingle(custom,24)==.5f,"custom TX packet");
            Check(custom.Take(12).SequenceEqual(packet.Take(12))&&custom.Skip(28).SequenceEqual(packet.Skip(28)),"RX, auto-trigger and reserved bytes unchanged");
            SaveHex(Path.Combine(output,"default_command.hex"),packet);SaveHex(Path.Combine(output,"custom_command.hex"),custom);
            Check(new ChirpParameters(40000,0,100,0).Command(false).Length==64,"CW and zero amplitude accepted");
            double[][] invalid={new[]{double.NaN,4.0,20,.25},new[]{0.0,4,20,.25},new[]{40.0,80,20,.25},new[]{40000.0,4000,101,.25},new[]{40000.0,4000,0,.25},new[]{40000.0,4000,20,1.01},new[]{1000000.0,1,20,.25}};
            foreach(double[] a in invalid){bool rejected=false;try{new ChirpParameters(a[0],a[1],a[2],a[3]);}catch(ArgumentException){rejected=true;}Check(rejected,"invalid parameter rejected");}
            passed.Add("PASS settings: independent golden bytes, custom TX, RX profile unchanged, limits, complete settings before trigger");

            byte[] real=ReadHex(Path.Combine(project,"02_RTL/V0/Simulation/FFT/results/main/system/stream.hex"));
            MainStreamParser parser=new MainStreamParser();int raws=0,peaks=0;
            parser.Raw=f=>{raws++;Check(f.DataLen==71614,"real complete raw frame length");for(int i=0;i<f.DataLen;i++)Check(f.Data[i]==(ushort)(real[32+2*i]|real[33+2*i]<<8),"real raw sample equality");Check(Math.Abs(f.SamplingPeriod-576.0/165e6)<1e-12,"real raw dt");};
            parser.Peak=r=>{peaks++;Check(r.Status=="BAD_CADENCE"&&r.Count==8192&&r.Flags==0&&r.Span==262112&&r.Bin==23,"compressed-clock RTL fixture correctly flagged");};
            Fragment(parser,real);Check(raws==1&&peaks==1&&parser.Invalid==0,"mixed archived RTL stream counts");
            string physical=File.ReadAllText(Path.Combine(project,"02_RTL/V0/Simulation/FFT/results/main/io/uart.txt")).Trim('\r','\n')+"\r\n";
            MainReport actual=MainReport.Parse(physical);Check(actual.Status=="OK"&&actual.Bin==23&&actual.Power==123456789&&actual.Minimum==-256,"real 2Mbaud RTL fixture");
            passed.Add("PASS receive: full archived RTL stream (71,614 exact samples), fragmented reads, real UART record, compressed-clock fixture flagged");

            ushort[] edge=Enumerable.Range(0,131072).Select(i=>(ushort)((i*7919)&65535)).ToArray();edge[0]=0;edge[1]=65535;edge[2]=32768;
            byte[] max=Wave(edge);parser=new MainStreamParser();raws=peaks=0;
            parser.Raw=f=>{raws++;Check(f.Data.SequenceEqual(edge),"maximum waveform data");};parser.Peak=r=>{peaks++;Check(r.Status=="OK","valid peak");};
            byte[] noisy=Join(new byte[]{99,13,77,1,6},max,Record(),max,Record());Fragment(parser,noisy);
            Check(raws==2&&peaks==2&&parser.BufferedBytes==0,"two consecutive max frames and resynchronization");
            byte[] bad=Record();bad[22]=(byte)'9';parser.Feed(bad,bad.Length);parser.Feed(Record(),64);Check(peaks==3&&parser.Invalid>0,"bad M1 checksum rejected and next frame recovered");
            byte[] badTail=(byte[])max.Clone();badTail[badTail.Length-2]^=1;parser=new MainStreamParser();raws=0;parser.Raw=f=>raws++;Fragment(parser,badTail);Check(raws==0&&parser.Invalid>0,"corrupt raw trailer rejected");
            parser.Reset();parser.Feed(max,100);Check(parser.BufferedBytes==100,"partial raw retained");parser.Reset();Check(parser.BufferedBytes==0,"disconnect/reset drops partial packet");
            byte[] tooLarge=(byte[])max.Clone();Array.Copy(BitConverter.GetBytes(131073),0,tooLarge,8,4);parser.Feed(tooLarge,32);Check(parser.Invalid>0&&parser.BufferedBytes<32,"oversized length bounded");
            foreach(int flag in new[]{1,2,4,8,16,32,128,64})Check(MainReport.Parse(Encoding.ASCII.GetString(Record(flags:flag))).Status!="OK","flag handled "+flag);
            Check(MainReport.Parse(Encoding.ASCII.GetString(Record(bin:115))).Status!="OK","out of search bin rejected");
            passed.Add("PASS robustness: 131,072-word capacity, two frames, noise, corrupt checksum/trailer, partial reset, oversized header, flags and range");
            ScopeDataFrame exportFrame=new ScopeDataFrame {Data=new ushort[]{0,32768,65535},DataLen=3,SamplingPeriod=.001f};
            string csv=Path.Combine(output,"export_check.csv");MainFrm.ExportWaveform(csv,exportFrame,"synthetic_test");
            string[] rows=File.ReadAllLines(csv);Check(rows.Length==4&&rows[1].Contains(",-32768,")&&rows[2].Contains(",0,")&&rows[3].Contains(",32767,"),"offset binary export");
            passed.Add("PASS waveform CSV: signed centering and explicit synthetic/live source");
            File.WriteAllLines(Path.Combine(output,"checks.txt"),passed,Encoding.UTF8);
        }
    }
}
