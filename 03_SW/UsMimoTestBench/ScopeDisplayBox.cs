using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

namespace UsMimoTestBench
{
    public partial class ScopeDisplayBox : UserControl
    {
        public ScopeDisplayBox()
        {
            InitializeComponent();


            //avoid blinking
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            this.SetStyle(ControlStyles.UserPaint, true);

            this.Paint += ScopeDisplayBox_Paint;

            this.MouseDown += MouseDownHandler;
            this.MouseUp += MouseUpHandler;
            this.MouseMove += MouseMoveHandler;
            this.MouseWheel += MouseWheelHandler;

            this.KeyDown += ScopeDisplayBox_KeyDown;
            this.KeyUp += ScopeDisplayBox_KeyUp;
            this.LostFocus += ScopeDisplayBox_LostFocus;
        }

        void ScopeDisplayBox_LostFocus(object sender, EventArgs e)
        {
            IsShiftPressed = false;
            IsUnderMove = false;
        }

        bool IsShiftPressed = false;

        void ScopeDisplayBox_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyValue == 16) IsShiftPressed = false;
        }

        void ScopeDisplayBox_KeyDown(object sender, KeyEventArgs e)
        {
            char c = (char)e.KeyValue;

            if (c == 16) IsShiftPressed = true;
            else if (c == 67)
            {
                //char c, copy bitmap
                Clipboard.SetImage(this.Bmp);
            }
            else if (c == 68)
            {
                //char d, copy data to clipboard
                                
                Clipboard.SetText(DataFrame.GetDataStr());
            }
        }


        public float HorizontalZoom = 1f;
        public float HorizontalOffset = 0f; //in multiple of screen

        private void MouseWheelHandler(object sender, MouseEventArgs e)
        {
            float ZoomRatio = ((e.Delta > 0 ? 0.1f : -0.1f) + 1);

            if (IsShiftPressed)
            {
                float p1 = (VerticalOffset * DrawRegionHeight + MidY - e.Y + DrawRegionStartY) / (VerticalScale * DrawRegionHeight);
                VerticalScale *= ZoomRatio;
                float p2 = (VerticalOffset * DrawRegionHeight + MidY - e.Y + DrawRegionStartY) / (VerticalScale * DrawRegionHeight);
                VerticalOffset -= (p2 - p1) * VerticalScale;
                //System.Diagnostics.Debug.Print(p1.ToString());
            }
            else
            {
                float p1 = GetDataIdxFromX(e.X);
                HorizontalZoom *= ZoomRatio;
                if (HorizontalZoom < 1f) HorizontalZoom = 1f;
                else
                {
                    RatioWidth = (float)DrawRegionWidth / (float)DataFrame.DataLen * HorizontalZoom;
                    float p2 = GetDataIdxFromX(e.X);
                    HorizontalOffset = HorizontalOffset + (p2 - p1) / DataFrame.DataLen;

                }
            }

            this.Invalidate();
        }

        private bool IsUnderMove = false;
        private Point MoveStartPoint;


        public bool IsLocked = false;

        int CurDataIndex = int.MinValue;

        private void MouseDownHandler(object sender, MouseEventArgs e)
        {
            if (e.Button == System.Windows.Forms.MouseButtons.Left)
            {
                IsUnderMove = true;
                MoveStartPoint = e.Location;

            }
            else if (e.Button == System.Windows.Forms.MouseButtons.Right)
            {
                if (CurDataIndex != int.MinValue) IsLocked = !IsLocked;
            }
            else if (e.Button == System.Windows.Forms.MouseButtons.Middle)
            {
                //shift pressed, reset vertical, otherwise horizontal
                if (IsShiftPressed)
                {
                    VerticalScale = 1.0f / 65536.0f;
                    VerticalOffset = 0.5f;
                }
                else
                {
                    HorizontalZoom = 1f;
                    HorizontalOffset = 0f;
                }

                this.Invalidate();
            }
        }

        private void MouseUpHandler(object sender, MouseEventArgs e)
        {
            if (e.Button == System.Windows.Forms.MouseButtons.Left) IsUnderMove = false;
        }

        private void MouseMoveHandler(object sender, MouseEventArgs e)
        {
            if (DataFrame.Data == null) return;
            bool PaintReq = false;
            if (!IsLocked)
            {
                CurDataIndex = (int)Math.Round((e.X - DrawRegionStartX) / RatioWidth - HorizontalOffset * DataFrame.DataLen);
                PaintReq = true;
            }

            if (IsUnderMove)
            {
                var pt = e.Location;
                if (IsShiftPressed)
                {
                    VerticalOffset += (float)(pt.Y - MoveStartPoint.Y) / DrawRegionHeight;
                }
                else
                {
                    HorizontalOffset += (float)(pt.X - MoveStartPoint.X) / RatioWidth / DataFrame.DataLen;
                }
                MoveStartPoint = pt;
                PaintReq = true;
            }
            if (PaintReq) this.Invalidate();
        }

        private int GetDataIdxFromX(int x)
        {
            int n = (int)((x - BorderWidth) / RatioWidth - HorizontalOffset * (float)m_DataFrame.DataLen);
            //if (n < 0 || n >= m_DataFrame.DataLen) return -1;
            return n;
        }



        public Bitmap Bmp = null;
        private ScopeDataFrame m_DataFrame;

        public ScopeDataFrame DataFrame
        {
            set
            {
                m_DataFrame = value;
                this.Invalidate();
            }
            get
            {
                return m_DataFrame;
            }
        }

        private float RatioWidth = 0;
        int BorderWidth = 50;

        int DrawRegionStartX;
        int DrawRegionEndX;
        int DrawRegionWidth;

        int DrawRegionStartY;
        int DrawRegionEndY;
        int DrawRegionHeight;


        int MidY;

        float VerticalScale = 1f / 65536f;
        float VerticalOffset = 0.5f;


        Point[] PolygonPoints = new Point[3];

        public Pen WaveformPen = new Pen(Color.FromArgb(255, 255, 100), 2);

        private unsafe void Shader()
        {
            try
            {

                if ((DataFrame.Data == null) || (this.Width == 0) || (this.Height == 0)) return;

                //decide size

                DrawRegionStartX = BorderWidth;
                DrawRegionEndX = Width - BorderWidth;
                DrawRegionWidth = Width - BorderWidth * 2;

                DrawRegionStartY = BorderWidth;
                DrawRegionEndY = Height - BorderWidth;
                DrawRegionHeight = Height - BorderWidth * 2;

                RatioWidth = (float)DrawRegionWidth / (float)DataFrame.DataLen * HorizontalZoom;

                MidY = DrawRegionHeight / 2;

                int FullSize = Width * Height;

                Bmp = new System.Drawing.Bitmap(Width, Height);
                Graphics g = Graphics.FromImage(Bmp);

                g.Clear(Color.Black);

                Pen PenAuxline = new Pen(Color.FromArgb(50, 50, 50), 2);
                Pen PenOutline = new Pen(Color.FromArgb(230, 230, 230), 2);
                Pen PenTimeMark = new Pen(Color.Orange, 2);
                Pen PenMarkers = new Pen(Color.FromArgb(200, 200, 200), 1);
                int ChNameFontSize = 20;

                string Str;
                SizeF StrSize;
                Color StrColor;

                //draw AuxLine
                float AuxLineXDis = DrawRegionWidth / 8f;
                float AuxLineYDis = DrawRegionHeight / 8f;

                for (int i = 1; i < 8; i++)
                {
                    g.DrawLine(PenAuxline, DrawRegionStartX + AuxLineXDis * i, DrawRegionStartY, DrawRegionStartX + AuxLineXDis * i, DrawRegionEndY);
                    g.DrawLine(PenAuxline, DrawRegionStartX, DrawRegionStartY + AuxLineYDis * i, DrawRegionEndX, DrawRegionStartY + AuxLineYDis * i);
                }

                for (int i = 1; i < 32; i++)
                {
                    g.DrawLine(PenAuxline, Width / 2 - 5, DrawRegionStartY + (float)DrawRegionHeight / 32f * i, Width / 2 + 5, DrawRegionStartY + (float)DrawRegionHeight / 32f * i);
                    g.DrawLine(PenAuxline, DrawRegionStartX + (float)DrawRegionWidth / 32f * i, Height / 2 - 5, DrawRegionStartX + (float)DrawRegionWidth / 32f * i, Height / 2 + 5);
                }



                if (m_DataFrame.Data != null)
                {
                    float LastChannelNameX = 10;

                    //draw channel name

                    Str = "Ch 1";

                    StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize));
                    StrColor = WaveformPen.Color;

                    g.FillRectangle(new SolidBrush(StrColor), new Rectangle(new Point((int)LastChannelNameX, (int)(BorderWidth / 2 - StrSize.Height / 2)), StrSize.ToSize()));
                    g.DrawString(Str, new Font("Consolas", ChNameFontSize, FontStyle.Bold), new SolidBrush(Color.Black), new PointF(LastChannelNameX, BorderWidth / 2 - StrSize.Height / 2));

                    LastChannelNameX += 10 + StrSize.Width;

                    Str = (0.125f / VerticalScale).ToString("F2") + "/";
                    StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize - 5));
                    StrColor = Color.White;

                    g.DrawString(Str, new Font("Consolas", ChNameFontSize - 5, FontStyle.Regular), new SolidBrush(StrColor), new PointF(LastChannelNameX, BorderWidth / 2 - StrSize.Height / 2));

                    LastChannelNameX += 30 + StrSize.Width;



                    //draw data

                    int pX_L1 = 0;
                    int pY_L1 = 0;

                    for (int j = 0; j < m_DataFrame.DataLen; j++)
                    {
                        int pX = (int)((j + HorizontalOffset * m_DataFrame.DataLen) * RatioWidth);
                        int pY = (int)(MidY - (m_DataFrame.Data[j] * VerticalScale * DrawRegionHeight - VerticalOffset * DrawRegionHeight));


                        if (pX < 0) pX = 0;
                        else if (pX > DrawRegionWidth) pX = DrawRegionWidth;
                        else
                        {

                            if (HorizontalZoom > 10f && pY >= 0 && pY < DrawRegionHeight) g.DrawEllipse(WaveformPen, DrawRegionStartX + pX - 2, DrawRegionStartY + pY - 2, 5, 5);
                            if (j != 0)
                            {
                                //limit line region
                                if (pY < 0) pY = 0;
                                if (pY > DrawRegionHeight) pY = DrawRegionHeight;

                                g.DrawLine(WaveformPen, DrawRegionStartX + pX_L1, DrawRegionStartY + pY_L1, DrawRegionStartX + pX, DrawRegionStartY + pY);

                            }
                        }

                        pX_L1 = pX;
                        pY_L1 = pY;

                    }

                    //draw 0 mark

                    int ZeroY = (int)(VerticalOffset * DrawRegionHeight);

                    if (ZeroY >= 0 && ZeroY < DrawRegionHeight)
                    {
                        ZeroY += DrawRegionStartY;

                        PolygonPoints[0].X = DrawRegionStartX - 10;
                        PolygonPoints[0].Y = ZeroY - 10;
                        PolygonPoints[1].X = DrawRegionStartX;
                        PolygonPoints[1].Y = ZeroY;
                        PolygonPoints[2].X = DrawRegionStartX - 10;
                        PolygonPoints[2].Y = ZeroY + 10;

                        g.FillPolygon(new SolidBrush(WaveformPen.Color), PolygonPoints);

                        g.DrawLine(new Pen(WaveformPen.Color, 2), DrawRegionStartX - 10, ZeroY, DrawRegionStartX - 20, ZeroY);
                        g.DrawLine(new Pen(WaveformPen.Color, 2), DrawRegionStartX - 20, ZeroY, DrawRegionStartX - 20, ZeroY + 20);
                        g.DrawLine(new Pen(WaveformPen.Color, 2), DrawRegionStartX - 30, ZeroY + 20, DrawRegionStartX - 10, ZeroY + 20);
                        g.DrawLine(new Pen(WaveformPen.Color, 2), DrawRegionStartX - 26, ZeroY + 25, DrawRegionStartX - 14, ZeroY + 25);
                        g.DrawLine(new Pen(WaveformPen.Color, 2), DrawRegionStartX - 22, ZeroY + 30, DrawRegionStartX - 18, ZeroY + 30);

                        Str = "1";
                        StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize - 5));
                        StrColor = WaveformPen.Color;

                        g.DrawString(Str, new Font("Consolas", ChNameFontSize - 5, FontStyle.Regular), new SolidBrush(StrColor), new PointF(5, ZeroY - StrSize.Height / 2));

                    }
                }

                //draw time position

                PolygonPoints[0] = new Point(Width / 2 - 10, DrawRegionStartY);
                PolygonPoints[1] = new Point(Width / 2 + 10, DrawRegionStartY);
                PolygonPoints[2] = new Point(Width / 2, DrawRegionStartY + 10);
                g.DrawPolygon(PenTimeMark, PolygonPoints);

                int CenterX = (int)((DataFrame.DataLen / 2 + HorizontalOffset * DataFrame.DataLen) * RatioWidth);

                if (CenterX > 0 && CenterX < DrawRegionWidth)
                {
                    PolygonPoints[0] = new Point(CenterX + BorderWidth - 10, DrawRegionStartY);
                    PolygonPoints[1] = new Point(CenterX + BorderWidth + 10, DrawRegionStartY);
                    PolygonPoints[2] = new Point(CenterX + BorderWidth, DrawRegionStartY + 10);
                }
                g.FillPolygon(new SolidBrush(PenTimeMark.Color), PolygonPoints);


                float SmpPerGrid = DrawRegionWidth / 8f / RatioWidth;
                float SmpShift = DrawRegionWidth / 2f / RatioWidth - HorizontalOffset * DataFrame.DataLen - DataFrame.DataLen / 2f;

                Str = SmpShift.ToString("F2") + "Sa    " + SmpPerGrid.ToString("F2") + "Sa/";
                StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize));
                Color StringColor = Color.Gainsboro;

                g.DrawString(Str, new Font("Consolas", ChNameFontSize, FontStyle.Bold), new SolidBrush(StringColor), new PointF(Width - StrSize.Width - 50, BorderWidth / 2 - StrSize.Height / 2));

                //draw temperature

                Str = "Temp = " + DataFrame.TempC.ToString("F3") + "°C";
                StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize));
                StringColor = Color.Gainsboro;

                g.DrawString(Str, new Font("Consolas", ChNameFontSize, FontStyle.Bold), new SolidBrush(StringColor), new PointF(Width / 2 - StrSize.Width / 2, BorderWidth / 2 - StrSize.Height / 2));


                //draw markers

                if (CurDataIndex >= 0 && CurDataIndex < DataFrame.DataLen)
                {
                    int CursorX = (int)((CurDataIndex + HorizontalOffset * DataFrame.DataLen) * RatioWidth) + DrawRegionStartX;
                    g.DrawLine(new Pen(Color.Gray, 2), CursorX, DrawRegionStartY, CursorX, DrawRegionEndY);


                    int StrPos = 10;


                    Str = "1: " + DataFrame.Data[CurDataIndex].ToString();
                    StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize - 5));
                    StrColor = WaveformPen.Color;

                    g.DrawString(Str, new Font("Consolas", ChNameFontSize - 5, FontStyle.Regular), new SolidBrush(StrColor), new PointF(StrPos, DrawRegionEndY + StrSize.Height / 2));

                    StrPos += 250;


                    Str = "Sample #" + CurDataIndex.ToString() + " in [0, " + (DataFrame.DataLen - 1).ToString() + "]";
                    StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize - 5));
                    StrColor = Color.Goldenrod;

                    g.DrawString(Str, new Font("Consolas", ChNameFontSize - 5, FontStyle.Regular), new SolidBrush(StrColor), new PointF(Width - StrSize.Width - 20, DrawRegionEndY + StrSize.Height / 2));
                    
                    Str = "t = " + (CurDataIndex * DataFrame.SamplingPeriod * 1000).ToString("F3") + "ms in [0, " + ((DataFrame.DataLen - 1) * DataFrame.SamplingPeriod * 1000).ToString("F3") + "]ms";
                    StrSize = g.MeasureString(Str, new Font("Consolas", ChNameFontSize - 5));
                    StrColor = Color.Goldenrod;

                    g.DrawString(Str, new Font("Consolas", ChNameFontSize - 5, FontStyle.Regular), new SolidBrush(StrColor), new PointF(Width / 2 - StrSize.Width / 2, DrawRegionEndY + StrSize.Height / 2));

                }
                //draw region outline

                g.DrawLine(PenOutline, 0, DrawRegionStartY, Width, DrawRegionStartY);
                g.DrawLine(PenOutline, 0, DrawRegionEndY, Width, DrawRegionEndY);
                g.DrawLine(PenOutline, DrawRegionStartX, DrawRegionStartY, DrawRegionStartX, DrawRegionEndY);
                g.DrawLine(PenOutline, DrawRegionEndX, DrawRegionStartY, DrawRegionEndX, DrawRegionEndY);

            }
            catch
            {
            }


        }


        public static unsafe Bitmap ConvertRGBByteArrayToRGBBitmap(byte* Red, byte* Green, byte* Blue, int Width, int Height, Bitmap OldBitmap = null)
        {
            if (Width <= 0 || Height <= 0) throw new System.ArgumentOutOfRangeException();
            int s = Width * Height;

            Bitmap ReturnBmp;
            BitmapData BmpData;
            if ((OldBitmap != null) && (OldBitmap.Width == Width) && (OldBitmap.Height == Height))
                ReturnBmp = OldBitmap;
            else
                ReturnBmp = new Bitmap(Width, Height, PixelFormat.Format24bppRgb);
            //if size changed, new a bitmap

            BmpData = ReturnBmp.LockBits(new Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, PixelFormat.Format24bppRgb);
            //stride must be set to width, otherwise the stride will be automatically set to n times of 4
            //BmpData.Stride = (int)Width * 3;

            byte* ByteArray = (byte*)BmpData.Scan0;

            int i = 0;
            for (int y = 0; y < Height; y++)
            {
                int RowBase = BmpData.Stride * y;
                for (int x = 0; x < Width; x++)
                {
                    int Idx = RowBase + x * 3;
                    ByteArray[Idx] = Blue[i];
                    ByteArray[Idx + 1] = Green[i];
                    ByteArray[Idx + 2] = Red[i];
                    i++;
                }
            }

            ReturnBmp.UnlockBits(BmpData);

            return ReturnBmp;
        }


        public bool InPaint = false;
        public bool PaintEnable = true;

        public int DisplayCounter = 0;

        private void ScopeDisplayBox_Paint(object sender, PaintEventArgs e)
        {
            if (PaintEnable)
            {
                Shader();

                InPaint = true;
                if (Bmp == null) { InPaint = false; return; }
                Graphics graphics = e.Graphics;
                graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
                graphics.SmoothingMode = SmoothingMode.HighSpeed;
                graphics.DrawImageUnscaled(Bmp, 0, 0);
                InPaint = false;

                DisplayCounter++;
            }
        }

        private void ScopeDisplayBox_Resize(object sender, EventArgs e)
        {
            this.Invalidate();
        }
    }
}
