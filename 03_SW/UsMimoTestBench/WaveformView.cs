using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.Windows.Forms;

namespace UsMimoTestBench
{
    public sealed class WaveformView : Control
    {
        ScopeDataFrame frame; int first, visible = 1, hover = -1, dragX, dragFirst; bool dragging;
        public WaveformView()
        {
            DoubleBuffered = true; BackColor = Color.White; ForeColor = Color.FromArgb(36, 54, 71);
            SetStyle(ControlStyles.ResizeRedraw, true); TabStop = true;
        }
        public void SetFrame(ScopeDataFrame value) { frame = value; Fit(); }
        public void Fit() { first = 0; visible = Math.Max(1, frame.DataLen); hover = -1; Invalidate(); }
        public void Detail()
        {
            if (frame.DataLen < 2) return;
            visible = Math.Min(frame.DataLen, Math.Max(32, (int)(.01 / frame.SamplingPeriod)));
            first = 0; Invalidate();
        }
        Rectangle Plot { get { return new Rectangle(76, 28, Math.Max(10, Width-98), Math.Max(10, Height-85)); } }
        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e); Graphics g = e.Graphics; Rectangle box = Plot;
            using (Pen grid = new Pen(Color.FromArgb(229, 235, 241)))
            using (Brush text = new SolidBrush(ForeColor))
            using (Pen line = new Pen(Color.FromArgb(0, 119, 173), 1.25f)) {
                g.DrawString("RX 采集波形 · ADC 码值（减去 32768）", Font, text, 8, 5);
                for (int i = 0; i <= 5; i++) { float x = box.Left + box.Width*i/5f; g.DrawLine(grid, x, box.Top, x, box.Bottom); }
                for (int i = 0; i <= 4; i++) { float y = box.Top + box.Height*i/4f; g.DrawLine(grid, box.Left, y, box.Right, y); }
                if (frame.Data == null || frame.DataLen < 2) {
                    g.DrawString("连接主板后点击「应用并采集一次」，或查看离线演示。", Font, text, box.Left+12, box.Top+30); return;
                }
                int count = Math.Min(visible, frame.DataLen-first), last = first+count-1;
                int lo = 32767, hi = -32768;
                for (int i = first; i <= last; i++) { int v = frame.Data[i]-32768; lo = Math.Min(lo,v); hi = Math.Max(hi,v); }
                double pad = Math.Max(50,(hi-lo)*.08), min = lo-pad, max = hi+pad;
                Func<int,float> yAt = v => (float)(box.Bottom-(v-min)/(max-min)*box.Height);
                for (int i = 0; i <= 4; i++) {
                    string label = (max-(max-min)*i/4).ToString("0",CultureInfo.InvariantCulture);
                    SizeF sz = g.MeasureString(label,Font); g.DrawString(label,Font,text,box.Left-sz.Width-7,box.Top+box.Height*i/4f-sz.Height/2);
                }
                for (int i = 0; i <= 5; i++) {
                    string label = ((first+(count-1)*i/5.0)*frame.SamplingPeriod*1000).ToString("0.###",CultureInfo.InvariantCulture);
                    SizeF sz = g.MeasureString(label,Font); g.DrawString(label,Font,text,box.Left+box.Width*i/5f-sz.Width/2,box.Bottom+7);
                }
                g.DrawString("时间 (ms) · 滚轮缩放 / 拖动平移", Font, text, box.Left, Height-25);
                // Min/max buckets preserve narrow peaks when many samples map to one pixel.
                if (count > box.Width*2) {
                    for (int x = 0; x < box.Width; x++) {
                        int a=first+(int)((long)x*count/box.Width), b=first+(int)((long)(x+1)*count/box.Width);
                        int low=32767,high=-32768;
                        for(int j=a;j<b;j++){int v=frame.Data[j]-32768;low=Math.Min(low,v);high=Math.Max(high,v);}
                        if(a<b)g.DrawLine(line,box.Left+x,yAt(low),box.Left+x,yAt(high));
                    }
                } else {
                    PointF[] pts = new PointF[count];
                    for(int i=0;i<count;i++)pts[i]=new PointF(box.Left+(float)i/(count-1)*box.Width,yAt(frame.Data[first+i]-32768));
                    g.SmoothingMode=SmoothingMode.AntiAlias;g.DrawLines(line,pts);
                }
                if (hover>=first && hover<=last) {
                    float x=box.Left+(float)(hover-first)/(count-1)*box.Width;
                    using(Pen cursor=new Pen(Color.FromArgb(126,141,156))){cursor.DashStyle=DashStyle.Dash;g.DrawLine(cursor,x,box.Top,x,box.Bottom);}
                    string s=string.Format(CultureInfo.InvariantCulture,"t={0:0.000} ms   code={1}",hover*frame.SamplingPeriod*1000,frame.Data[hover]-32768);
                    SizeF sz=g.MeasureString(s,Font);g.DrawString(s,Font,text,Math.Max(box.Left,box.Right-sz.Width),5);
                }
            }
        }
        protected override void OnMouseWheel(MouseEventArgs e)
        {
            if(frame.DataLen<2)return;
            double fraction=Math.Max(0,Math.Min(1,(e.X-Plot.Left)/(double)Plot.Width));
            int anchor=first+(int)(fraction*(visible-1));
            visible=Math.Max(Math.Min(32,frame.DataLen),Math.Min(frame.DataLen,(int)(visible*(e.Delta>0?.65:1.54))));
            first=Math.Max(0,Math.Min(frame.DataLen-visible,anchor-(int)(fraction*(visible-1))));Invalidate();
        }
        protected override void OnMouseDown(MouseEventArgs e) { base.OnMouseDown(e);Focus();if(e.Button==MouseButtons.Left){dragging=true;dragX=e.X;dragFirst=first;Capture=true;} }
        protected override void OnMouseUp(MouseEventArgs e) { base.OnMouseUp(e);dragging=false;Capture=false; }
        protected override void OnMouseLeave(EventArgs e) { base.OnMouseLeave(e);hover=-1;Invalidate(); }
        protected override void OnMouseMove(MouseEventArgs e)
        {
            if(frame.DataLen<2)return;
            if(dragging)first=Math.Max(0,Math.Min(frame.DataLen-visible,dragFirst-(int)((e.X-dragX)*(double)visible/Plot.Width)));
            hover=first+(int)(Math.Max(0,Math.Min(1,(e.X-Plot.Left)/(double)Plot.Width))*(visible-1));Invalidate();
        }
    }
}
