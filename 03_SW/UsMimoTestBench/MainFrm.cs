using System;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.IO.Ports;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace UsMimoTestBench
{
    public partial class MainFrm : Form
    {
        readonly USSensor sensor = new USSensor();
        ComboBox ports; Button connect, refresh, apply, capture, defaults, demo, save;
        NumericUpDown center, bandwidth, duration, amplitude, target;
        CheckBox continuous; Label connection, parameterInfo, peakLabel, peakDetail, rawInfo, footer, temperatureLabel, distanceLabel;
        WaveformView waveform; DataGridView history; System.Windows.Forms.Timer timer;
        bool busy, failed, closing, opening, writing, hasFrame, isDemo;
        int generation; DateTime started, nextCapture; ScopeDataFrame latestFrame, pendingFrame;
        MainReport latestPeak; ChirpParameters pendingParameters; double pendingTarget; string logFolder, latestFrameSource="none";
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        public MainFrm()
        {
            InitializeComponent();
            sensor.RawReceived += f => Ui(() => ReceivedRaw(f));
            sensor.PeakReceived += r => Ui(() => ReceivedPeak(r));
            sensor.Failed += error => Ui(() => Fault("串口中断：" + error));
            timer = new System.Windows.Forms.Timer(components); timer.Interval = 100;
            timer.Tick += delegate {
                if (busy && DateTime.UtcNow-started > TimeSpan.FromSeconds(8)) Fault("8 秒内未收到完整波形和峰值。请检查 main 固件、COM 和 ADC，然后断开重连。");
                if (!busy && !opening && !writing && !failed && sensor.IsConnected && continuous.Checked && DateTime.UtcNow>=nextCapture) CaptureOnce();
            };
            timer.Start(); RefreshPorts(); SetDefaults(); UpdateControls();
        }
        void Ui(Action action)
        {
            if(closing||IsDisposed||!IsHandleCreated)return;
            try { BeginInvoke(new Action(() => { if(!closing&&!IsDisposed)action(); })); } catch(InvalidOperationException) { }
        }
        static Label LabelOf(string text) { return new Label { Text=text, AutoSize=false, Dock=DockStyle.Fill, TextAlign=ContentAlignment.MiddleLeft }; }
        static Button ButtonOf(string text, EventHandler action)
        {
            Button b=new Button { Text=text, AutoSize=true, Height=33, MinimumSize=new Size(80,32), Margin=new Padding(4) };b.Click+=action;return b;
        }
        NumericUpDown Number(decimal min, decimal max, int decimals, decimal step)
        {
            return new NumericUpDown { Minimum=min, Maximum=max, DecimalPlaces=decimals, Increment=step, Dock=DockStyle.Fill, ThousandsSeparator=true, TextAlign=HorizontalAlignment.Right, Margin=new Padding(3,7,3,7) };
        }
        void Field(TableLayoutPanel panel,int row,string name,Control input) { panel.Controls.Add(LabelOf(name),0,row);panel.Controls.Add(input,1,row); }
        void BuildLayout()
        {
            Text="multiFPGA · Square TX / Sine Reference / FFT";ClientSize=new Size(1220,790);MinimumSize=new Size(1020,720);
            StartPosition=FormStartPosition.CenterScreen;Font=new Font("Microsoft YaHei UI",9F);BackColor=Color.FromArgb(244,247,250);
            AutoScaleMode=AutoScaleMode.Dpi;
            TableLayoutPanel root=new TableLayoutPanel { Dock=DockStyle.Fill,ColumnCount=1,RowCount=3,Padding=new Padding(12) };
            root.RowStyles.Add(new RowStyle(SizeType.Absolute,62));root.RowStyles.Add(new RowStyle(SizeType.Percent,100));root.RowStyles.Add(new RowStyle(SizeType.Absolute,52));Controls.Add(root);
            FlowLayoutPanel connectionBar=new FlowLayoutPanel { Dock=DockStyle.Fill,WrapContents=false,Padding=new Padding(0,7,0,0) };
            connectionBar.Controls.Add(new Label { Text="主板 COM",AutoSize=true,Margin=new Padding(2,9,8,0) });
            ports=new ComboBox { Width=108,DropDownStyle=ComboBoxStyle.DropDownList,Margin=new Padding(2,6,5,0) };connectionBar.Controls.Add(ports);
            refresh=ButtonOf("刷新",delegate{RefreshPorts();});connect=ButtonOf("连接主板",ConnectClick);demo=ButtonOf("离线演示",delegate{LoadDemo();});
            connectionBar.Controls.Add(refresh);connectionBar.Controls.Add(connect);connectionBar.Controls.Add(demo);
            connection=new Label { Text="未连接 · 2 Mbaud / 8N1",AutoSize=true,Margin=new Padding(18,9,0,0) };connectionBar.Controls.Add(connection);root.Controls.Add(connectionBar,0,0);
            TableLayoutPanel content=new TableLayoutPanel { Dock=DockStyle.Fill,ColumnCount=2,RowCount=1 };
            content.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute,310));content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,100));root.Controls.Add(content,0,1);
            FlowLayoutPanel left=new FlowLayoutPanel { Dock=DockStyle.Fill,FlowDirection=FlowDirection.TopDown,WrapContents=false,AutoScroll=true,Padding=new Padding(0,0,8,0) };content.Controls.Add(left,0,0);
            GroupBox tx=new GroupBox { Text="TX · 方波 Chirp 参数",Width=292,Height=270,Padding=new Padding(10,23,10,8) };
            TableLayoutPanel fields=new TableLayoutPanel { Dock=DockStyle.Fill,ColumnCount=2,RowCount=6 };
            fields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,52));fields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,48));
            for(int i=0;i<4;i++)fields.RowStyles.Add(new RowStyle(SizeType.Absolute,40));fields.RowStyles.Add(new RowStyle(SizeType.Absolute,36));fields.RowStyles.Add(new RowStyle(SizeType.Percent,100));
            center=Number(.001m,1000m,3,1);bandwidth=Number(0,1000,3,1);duration=Number(.01m,100,2,1);amplitude=Number(0,1,3,.05m);
            Field(fields,0,"中心频率 (kHz)",center);Field(fields,1,"带宽 (kHz)",bandwidth);Field(fields,2,"时长 (ms)",duration);Field(fields,3,"幅度系数 (0–1)",amplitude);
            defaults=ButtonOf("恢复默认参数",delegate{SetDefaults();});fields.Controls.Add(defaults,0,4);fields.SetColumnSpan(defaults,2);
            Label txHint=LabelOf("方波 Chirp · 同源正弦参考 · 14 位");fields.Controls.Add(txHint,0,5);fields.SetColumnSpan(txHint,2);tx.Controls.Add(fields);left.Controls.Add(tx);
            foreach(NumericUpDown n in new[]{center,bandwidth,duration,amplitude})n.ValueChanged+=delegate{parameterInfo.Text="参数待发送；点击应用或采集。";};
            GroupBox rx=new GroupBox { Text="RX / 数字混频 / FFT",Width=292,Height=112,Padding=new Padding(12,24,8,6) };
            rx.Controls.Add(LabelOf(string.Format("原始RX：1.145833 MS/s，19 ms\n数字相乘 → CIC3 /32 → FFT\n672有效点 → 1024点，35.807 kS/s\n{0:g}–{1:g} Hz；低频精度受限",ChirpParameters.MainSearchMinHz,ChirpParameters.MainSearchMaxHz)));left.Controls.Add(rx);
            TableLayoutPanel reference=new TableLayoutPanel { Width=292,Height=62,ColumnCount=2,RowCount=1 };
            reference.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,57));reference.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,43));target=Number((decimal)ChirpParameters.MainSearchMinHz,(decimal)ChirpParameters.MainSearchMaxHz,3,1);target.Value=100;
            Field(reference,0,"拍频参考值 (Hz)\n仅用于计算误差",target);left.Controls.Add(reference);
            apply=ButtonOf("仅应用 TX 参数",ApplyClick);apply.Width=282;left.Controls.Add(apply);
            capture=ButtonOf("应用并采集一次",delegate{CaptureOnce();});capture.Width=282;capture.Height=38;capture.BackColor=Color.FromArgb(0,111,158);capture.ForeColor=Color.White;left.Controls.Add(capture);
            continuous=new CheckBox { Text="连续采集（收到完整结果后再开始）",AutoSize=false,Height=38,Margin=new Padding(6,8,0,4) };
            continuous.CheckedChanged+=delegate{nextCapture=DateTime.UtcNow;};left.Controls.Add(continuous);
            parameterInfo=new Label { Width=286,Height=54,Text="默认参数已载入。",ForeColor=Color.FromArgb(73,91,109),Padding=new Padding(4) };left.Controls.Add(parameterInfo);
            left.Layout+=delegate {
                int width=Math.Max(250,left.ClientSize.Width-left.Padding.Horizontal-SystemInformation.VerticalScrollBarWidth-2);
                foreach(Control child in left.Controls) { int desired=width-child.Margin.Horizontal;if(child.Width!=desired)child.Width=desired; }
            };
            TableLayoutPanel right=new TableLayoutPanel { Dock=DockStyle.Fill,ColumnCount=1,RowCount=4,Padding=new Padding(8,0,0,0) };
            right.RowStyles.Add(new RowStyle(SizeType.Absolute,180));right.RowStyles.Add(new RowStyle(SizeType.Absolute,42));right.RowStyles.Add(new RowStyle(SizeType.Percent,100));right.RowStyles.Add(new RowStyle(SizeType.Absolute,166));content.Controls.Add(right,1,0);
            Panel result=new Panel { Dock=DockStyle.Fill,BackColor=Color.White,Padding=new Padding(12) };
            peakLabel=new Label { Text="FPGA 峰值：—",Dock=DockStyle.Top,Height=44,Font=new Font(Font.FontFamily,23F,FontStyle.Bold),ForeColor=Color.FromArgb(0,103,143) };
            peakDetail=new Label { Text="等待主板回传 · 功率单位为 mixed-code²",Dock=DockStyle.Fill,Padding=new Padding(2,4,0,0) };
            FlowLayoutPanel measurement=new FlowLayoutPanel { Dock=DockStyle.Top,Height=32,WrapContents=false };
            temperatureLabel=new Label { Text="温度：—",AutoSize=true,Margin=new Padding(0,4,18,0),Font=new Font(Font.FontFamily,11F) };
            distanceLabel=new Label { Text="估算距离：—",AutoSize=true,Margin=new Padding(0,3,0,0),Font=new Font(Font.FontFamily,13F,FontStyle.Bold) };
            measurement.Controls.Add(temperatureLabel);measurement.Controls.Add(distanceLabel);
            result.Controls.Add(peakDetail);result.Controls.Add(measurement);result.Controls.Add(peakLabel);right.Controls.Add(result,0,0);
            FlowLayoutPanel waveBar=new FlowLayoutPanel { Dock=DockStyle.Fill,WrapContents=false };
            waveBar.Controls.Add(ButtonOf("完整波形",delegate{waveform.Fit();}));waveBar.Controls.Add(ButtonOf("前 10 ms",delegate{waveform.Detail();}));save=ButtonOf("导出波形 CSV",SaveClick);waveBar.Controls.Add(save);
            rawInfo=new Label { AutoSize=true,Margin=new Padding(8,12,0,0),Text="尚未采集" };waveBar.Controls.Add(rawInfo);right.Controls.Add(waveBar,0,1);
            waveform=new WaveformView { Dock=DockStyle.Fill,Font=Font };right.Controls.Add(waveform,0,2);
            history=new DataGridView { Dock=DockStyle.Fill,ReadOnly=true,AllowUserToAddRows=false,AllowUserToDeleteRows=false,RowHeadersVisible=false,BackgroundColor=Color.White,BorderStyle=BorderStyle.None,AutoSizeColumnsMode=DataGridViewAutoSizeColumnsMode.Fill,SelectionMode=DataGridViewSelectionMode.FullRowSelect };
            foreach(string name in new[]{"时间 / 来源","帧号","峰值 Hz","原频点 Hz","参考 Hz","误差 Hz","功率 code²","温度 °C","距离 mm","状态"})history.Columns.Add(name,name);
            history.Columns[0].FillWeight=140;history.Columns[9].FillWeight=170;right.Controls.Add(history,0,3);
            footer=LabelOf("请烧录新版 main 的 UsMimoTestBench.sof，再选择主板 COM 口。图中显示 RX 采集数据；当前固件只回传 FFT 峰值，不回传完整频谱。");footer.ForeColor=Color.FromArgb(65,84,103);root.Controls.Add(footer,0,2);
        }
        void SetDefaults() { center.Value=40;bandwidth.Value=4;duration.Value=20;amplitude.Value=.25m;parameterInfo.Text="默认：40 kHz / 4 kHz / 20 ms / 0.25。"; }
        ChirpParameters Parameters() { return new ChirpParameters((double)center.Value*1000,(double)bandwidth.Value*1000,(double)duration.Value,(double)amplitude.Value); }
        void RefreshPorts()
        {
            string selected=ports.Text;string[] names=SerialPort.GetPortNames();Array.Sort(names,StringComparer.OrdinalIgnoreCase);ports.Items.Clear();ports.Items.AddRange(names);
            if(ports.Items.Contains(selected))ports.SelectedItem=selected;else if(names.Length>0)ports.SelectedIndex=0;
        }
        void UpdateControls()
        {
            bool live=sensor.IsConnected, edit=!busy&&!opening&&!writing&&!failed;
            connect.Text=live||failed?"断开连接":"连接主板";connect.Enabled=!opening&&!writing;
            ports.Enabled=refresh.Enabled=!live&&!opening&&!failed;
            apply.Enabled=capture.Enabled=live&&edit;demo.Enabled=!live&&!opening&&!failed;
            defaults.Enabled=center.Enabled=bandwidth.Enabled=duration.Enabled=amplitude.Enabled=target.Enabled=edit;
            continuous.Enabled=live&&!opening&&!failed;save.Enabled=hasFrame&&!busy;
        }
        async void ConnectClick(object sender,EventArgs e)
        {
            if(sensor.IsConnected||failed){generation++;continuous.Checked=false;sensor.Close();failed=busy=false;connection.Text="未连接";footer.Text="连接已关闭。";UpdateControls();return;}
            if(ports.SelectedItem==null){footer.Text="未发现 COM 口，请连接主板 USB-C 后刷新。";return;}
            opening=true;UpdateControls();int token=++generation;
            try {
                string name=ports.Text;await Task.Run(()=>sensor.Open(name));await Task.Delay(500);
                if(closing||token!=generation){sensor.Close();return;}
                failed=false;isDemo=false;connection.Text="已连接 "+name+" · 2 Mbaud / 8N1";
                footer.Text="已连接。点击应用并采集一次；TX 参数通过串口发送，无需重新编译 FPGA。";
            } catch(Exception error){sensor.Close();footer.Text="连接失败："+error.Message;}
            finally{opening=false;if(!closing)UpdateControls();}
        }
        async void ApplyClick(object sender,EventArgs e)
        {
            if(busy||writing||opening)return;
            try {
                ChirpParameters p=Parameters();writing=true;UpdateControls();await Task.Run(()=>sensor.Send(p,false));if(closing)return;
                parameterInfo.Text="设置包已发送（固件无确认回复）。";footer.Text=p.Summary+"；RX/FFT 配置保持固定。";
            } catch(Exception error){footer.Text="未应用："+error.Message;}
            finally{writing=false;if(!closing)UpdateControls();}
        }
        async void CaptureOnce()
        {
            if(busy||writing||opening||failed||!sensor.IsConnected)return;
            ChirpParameters p;try{p=Parameters();}catch(Exception error){continuous.Checked=false;footer.Text=error.Message;return;}
            pendingParameters=p;pendingTarget=(double)target.Value;pendingFrame=new ScopeDataFrame();
            isDemo=false;busy=true;started=DateTime.UtcNow;peakLabel.Text="FPGA 峰值：等待回传";peakDetail.Text="先接收完整 RX 波形，再接收 FPGA 的测量报文。";temperatureLabel.Text="温度：等待";distanceLabel.Text="估算距离：等待";UpdateControls();
            try{await Task.Run(()=>sensor.Send(p,true));if(closing)return;parameterInfo.Text="设置包及触发命令已发送。";footer.Text=p.Summary+"；正在采集 / 回传…";}
            catch(Exception error){if(!closing)Fault("发送失败："+error.Message);}
        }
        void ReceivedRaw(ScopeDataFrame frame)
        {
            if(!busy)return;
            int expected=(int)(ChirpParameters.MainRxSeconds*165e6/144/4);
            if(Math.Abs(frame.DataLen-expected)>2||Math.Abs(frame.SamplingPeriod-576.0/165e6)>1e-10){Fault("收到的波形长度或采样率与当前 main 配置不符，请检查固件和串口设置。");return;}
            pendingFrame=latestFrame=frame;latestFrameSource=isDemo?"synthetic_demo":"UART";hasFrame=true;waveform.SetFrame(frame);
            rawInfo.Text=string.Format(Inv,"{0:N0} 点 · {1:0.###} ms",frame.DataLen,frame.DataLen*frame.SamplingPeriod*1000);
            footer.Text="RX 波形已收到，等待 FPGA 峰值…";
        }
        void ReceivedPeak(MainReport r)
        {
            if(!busy)return;
            if(pendingFrame.Data==null){Fault("收到峰值但缺少对应波形；请断开重连后重试。");return;}
            latestPeak=r;busy=false;
            bool valid=r.Status=="OK";
            peakLabel.Text=valid?string.Format(Inv,(isDemo?"演示峰值：":r.InterpolationValid?"FPGA 插值：":"FPGA 原频点：")+"{0:0.000} Hz",r.Frequency):"FPGA 峰值：结果无效";
            peakLabel.ForeColor=valid?(r.LowCycleWarning?Color.DarkOrange:Color.FromArgb(0,103,143)):Color.Firebrick;
            peakDetail.Text=string.Format(Inv,"{0}  ·  原频点 {1:0.000} Hz  ·  偏移 {2:+0.0000;-0.0000;0.0000} bin\n{3}  ·  功率 {4:0.000} mixed-code²  ·  有效点{5}  ·  参考 {6:0.###} Hz / 误差 {7:+0.000;-0.000;0.000} Hz{8}",
                r.InterpolationText,r.RawFrequency,r.OffsetBins,r.StatusText,r.Power/64.0,r.Count,pendingTarget,r.Frequency-pendingTarget,isDemo?"  ·  合成演示":"");
            temperatureLabel.Text=(isDemo?"演示温度：":"温度：")+r.TemperatureText;
            temperatureLabel.ForeColor=r.TemperatureValid?Color.FromArgb(0,103,143):Color.DarkOrange;
            distanceLabel.Text=(isDemo?"演示距离：":"估算距离：")+r.RangeText;
            distanceLabel.ForeColor=r.RangeValid?(r.LowCycleWarning?Color.DarkOrange:Color.FromArgb(0,103,143)):Color.DarkOrange;
            if(r.HasMeasurement&&r.TemperatureValid)peakDetail.Text+=string.Format(Inv,"\n声速 {0:0.000} m/s · FPGA 温度补偿距离 · 理想往返声程，未校准零点",r.SoundSpeed);
            string source=isDemo?"演示":"串口";
            history.Rows.Insert(0,DateTime.Now.ToString("HH:mm:ss")+" / "+source,r.Sequence,r.Frequency.ToString("F3",Inv),r.RawFrequency.ToString("F3",Inv),pendingTarget.ToString("0.###",Inv),(r.Frequency-pendingTarget).ToString("+0.000;-0.000;0.000",Inv),(r.Power/64.0).ToString("F3",Inv),r.TemperatureValid?r.TemperatureC.ToString("F2",Inv):"—",r.RangeValid?r.DistanceMm.ToString("F3",Inv):"—",r.StatusText);
            if(history.Rows.Count>100)history.Rows.RemoveAt(100);
            footer.Text=isDemo?"离线演示：合成40 kHz RX载波与约100 Hz拍频报文，非主板实测；未打开串口。":"本次采集完成。方波TX＋正弦参考；FPGA混频/低通/FFT/插值；模拟通路延迟尚需标定。19 ms短窗低频仅供参考。";
            try{WritePeakLog(source,r);}catch(Exception error){footer.Text+=" 日志保存失败："+error.Message;}
            nextCapture=DateTime.UtcNow.AddSeconds(1);UpdateControls();
        }
        void WritePeakLog(string source,MainReport r)
        {
            if(logFolder==null){logFolder=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"DataSessions",DateTime.Now.ToString("yyyyMMdd_HHmmss")+"_"+Guid.NewGuid().ToString("N").Substring(0,6));Directory.CreateDirectory(logFolder);}
            string file=Path.Combine(logFolder,"peaks.csv");bool exists=File.Exists(file);
            using(StreamWriter writer=new StreamWriter(file,true,Encoding.UTF8)) {
                if(!exists)writer.WriteLine("time,source,sequence,status,peak_hz,target_hz,error_hz,power_code_squared,bin,fft_count,flags,raw_count,raw_dt_s,tx_center_hz,tx_bandwidth_hz,tx_duration_s,tx_amplitude,raw_bin_hz,delta_q16,interpolation_status,interpolation_valid,fft_length,short_window_warning,temperature_c,temperature_status,frequency_millihz,distance_um,distance_mm,range_status,sound_speed_m_s");
                writer.WriteLine(string.Format(Inv,"{0},{1},{2},{3},{4:R},{5:R},{6:R},{7:R},{8},{9},{10},{11},{12:R},{13:R},{14:R},{15:R},{16:R},{17:R},{18},{19},{20},{21},{22}",DateTime.Now.ToString("o"),source,r.Sequence,r.Status,r.Frequency,pendingTarget,r.Frequency-pendingTarget,r.Power/64.0,r.Bin,r.Count,r.Flags,pendingFrame.DataLen,pendingFrame.SamplingPeriod,pendingParameters.CenterHz,pendingParameters.BandwidthHz,pendingParameters.DurationSeconds,pendingParameters.Amplitude,r.RawFrequency,r.DeltaQ16,r.HasInterpolation?r.InterpolationStatus:-1,r.InterpolationValid,r.FftLength,r.LowCycleWarning)+string.Format(Inv,",{0},{1},{2},{3},{4},{5},{6}",
                    r.TemperatureValid?r.TemperatureC.ToString("R",Inv):"",r.HasMeasurement?r.TemperatureStatus:-1,
                    r.HasMeasurement?r.ReportedFrequencyMilliHz.ToString(Inv):"",r.RangeValid?r.DistanceUm.ToString(Inv):"",
                    r.RangeValid?r.DistanceMm.ToString("R",Inv):"",r.HasMeasurement?r.RangeStatus:-1,
                    r.TemperatureValid?r.SoundSpeed.ToString("R",Inv):""));
            }
        }
        void Fault(string reason)
        {
            failed=true;busy=false;continuous.Checked=false;peakLabel.Text="采集未完成";temperatureLabel.Text="温度：—";distanceLabel.Text="估算距离：无效";peakDetail.Text="本次结果不能用于测量，请检查连接后重连。";footer.Text=reason;UpdateControls();
        }
        public void LoadDemo()
        {
            if(sensor.IsConnected||opening)return;
            isDemo=true;pendingParameters=Parameters();pendingTarget=100;pendingFrame=new ScopeDataFrame();busy=true;
            MainStreamParser parser=new MainStreamParser();parser.Raw=ReceivedRaw;parser.Peak=ReceivedPeak;
            byte[] data=SoftwareChecks.DemoStream();parser.Feed(data,data.Length);
        }
        async void SaveClick(object sender,EventArgs e)
        {
            if(!hasFrame)return;
            using(SaveFileDialog dialog=new SaveFileDialog { Filter="CSV 波形 (*.csv)|*.csv",FileName=(latestFrameSource=="synthetic_demo"?"demo_":"rx_")+DateTime.Now.ToString("yyyyMMdd_HHmmss")+".csv" }) {
                if(dialog.ShowDialog(this)!=DialogResult.OK)return;
                ScopeDataFrame frame=latestFrame;string source=latestFrameSource;
                try{await Task.Run(()=>ExportWaveform(dialog.FileName,frame,source));footer.Text="波形已保存："+dialog.FileName;}catch(Exception error){footer.Text="保存失败："+error.Message;}
            }
        }
        public static void ExportWaveform(string path,ScopeDataFrame frame,string source)
        {
            using(StreamWriter writer=new StreamWriter(path,false,Encoding.UTF8)) {
                writer.WriteLine("index,time_s,adc_unsigned,adc_centered,source");
                for(int i=0;i<frame.DataLen;i++)writer.WriteLine(string.Format(Inv,"{0},{1:R},{2},{3},{4}",i,i*(double)frame.SamplingPeriod,frame.Data[i],frame.Data[i]-32768,source));
            }
        }
        public void SavePreview(string path,bool detail)
        {
            if(detail)waveform.Detail();PerformLayout();
            using(Bitmap bitmap=new Bitmap(Width,Height)){DrawToBitmap(bitmap,new Rectangle(0,0,Width,Height));bitmap.Save(path,System.Drawing.Imaging.ImageFormat.Png);}
        }
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            closing=true;generation++;timer.Stop();sensor.Dispose();base.OnFormClosing(e);
        }
    }
}
