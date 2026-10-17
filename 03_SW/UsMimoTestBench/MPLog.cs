using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace UsMimoTestBench
{
    public partial class MPLog : UserControl
    {
        public enum LogTypeEnum
        {
            Info,
            Notice,
            Warning,
            Success,
            Failure
        };

        public delegate void LogAddDlgType(LogTypeEnum LogType, string Content);

        public MPLog()
        {
            InitializeComponent();
        }

        public void Add(LogTypeEnum LogType, string Content)
        {
            LogAddDlgType Dlg = new LogAddDlgType(LocalAdd);
            try
            {
                Invoke(Dlg, LogType, Content);
            }
            catch
            { ; }
        }


        private void LocalAdd(LogTypeEnum LogType, string Content)
        {
            DateTime t = DateTime.Now;


            int SelStart = MainRtb.TextLength;

            MainRtb.AppendText(t.Hour.ToString("D2") + ":" + t.Minute.ToString("D2") + "'" + t.Second.ToString("D2") + "'" + t.Millisecond.ToString("D3") + " :" + Content + "\r\n");

            int SelLen = MainRtb.TextLength - SelStart;

            MainRtb.Select(SelStart, SelLen);

            switch (LogType)
            {
                case LogTypeEnum.Info:
                    MainRtb.SelectionColor = Color.DimGray;
                    break;
                case LogTypeEnum.Notice:
                    MainRtb.SelectionColor = Color.Blue;
                    break;
                case LogTypeEnum.Warning:
                    MainRtb.SelectionColor = Color.DarkGoldenrod;
                    break;
                case LogTypeEnum.Success:
                    MainRtb.SelectionColor = Color.DarkGreen;
                    break;
                case LogTypeEnum.Failure:
                    MainRtb.SelectionColor = Color.DarkRed;
                    break;
            }

            MainRtb.SelectionStart = MainRtb.TextLength;

            if (AutoRollCkb.Checked) RollToEnd();

            Application.DoEvents();
        }

        public void Clear()
        {
            MainRtb.Text = "";
        }

        public void RollToEnd()
        {
            MainRtb.SelectionStart = MainRtb.Text.Length;
            MainRtb.ScrollToCaret();
        }

        public bool IsAutoRoll
        {
            get
            {
                return AutoRollCkb.Checked;
            }
            set
            {
                AutoRollCkb.Checked = value;
            }
        }

        private void RollToEndBtn_Click(object sender, EventArgs e)
        {
            RollToEnd();
        }

        private void ClearBtn_Click(object sender, EventArgs e)
        {
            Clear();
        }



    }
}
