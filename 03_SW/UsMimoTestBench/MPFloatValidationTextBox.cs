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
    public partial class MPFloatValidationTextBox : UserControl
    {
        public MPFloatValidationTextBox()
        {
            InitializeComponent();
        }

        private float m_Value;

        /// <summary>
        /// property of represented value. note that set the value will not call callback function!
        /// </summary>
        public float Value
        {
            get
            {
                return m_Value;
            }
            set
            {
                m_Value = value;

                if (InvokeRequired)
                {
                    this.Invoke(new Action(() =>
                    {
                        Tbx.Text = value.ToString();
                    }));
                }
                else
                {
                    Tbx.Text = value.ToString();
                }
            }
        }

        public bool IsReadOnly
        {
            get { return Tbx.ReadOnly; }
            set { Tbx.ReadOnly = value; }
        }

        /// <summary>
        /// enable of max value check, default is false
        /// </summary>
        private bool m_MaxCheck = false;
        public bool MaxCheck { get { return m_MaxCheck; } set { m_MaxCheck = value; } }
        /// <summary>
        /// valid state if a number equals to max value when max check is enabled, default is true
        /// </summary>
        private bool m_MaxEqualValid = true;
        public bool MaxEqualValid { get { return m_MaxEqualValid; } set { m_MaxEqualValid = value; } }
        /// <summary>
        /// max value
        /// </summary>
        private float m_MaxValue = 0;
        public float MaxValue { get { return m_MaxValue; } set { m_MaxValue = value; } }

        /// <summary>
        /// enable of min value check, default is false
        /// </summary>
        private bool m_MinCheck = false;
        public bool MinCheck { get { return m_MinCheck; } set { m_MinCheck = value; } }
        /// <summary>
        /// valid state of a number equals to min value when min check is enabled, default is true
        /// </summary>
        private bool m_MinEqualValid = true;
        public bool MinEqualValid { get { return m_MinEqualValid; } set { m_MinEqualValid = value; } }
        /// <summary>
        /// min value
        /// </summary>
        private float m_MinValue = 0;
        public float MinValue { get { return m_MinValue; } set { m_MinValue = value; } }

        private void Tbx_TextChanged(object sender, EventArgs e)
        {
            if (!Tbx.Focused) return;
            float Val;
            try
            {
                Val = float.Parse(Tbx.Text);
                if ((MaxCheck && ((Val > MaxValue) || ((!MaxEqualValid) && (Val == MaxValue)))) || (MinCheck && ((Val < MinValue) || ((!MinEqualValid) && (Val == MinValue))))) throw new System.ArgumentOutOfRangeException();
                Tbx.BackColor = Color.PaleGreen;
            }
            catch
            {
                Tbx.BackColor = Color.Pink;
            }
        }

        /// <summary>
        /// event of valid value entered and user left the text box. use Value to get the value instead of EventArgs
        /// </summary>
        public event EventHandler ValueChanged;

        private void Tbx_Leave(object sender, EventArgs e)
        {
            if (IsReadOnly) return;
            if (Tbx.BackColor == Color.PaleGreen)
            {
                m_Value = float.Parse(Tbx.Text);
                if (ValueChanged != null) ValueChanged(this, null);
            }
            else if (Tbx.BackColor == Color.Pink) //restore value if user entered invalid value
            {
                Tbx.Text = m_Value.ToString();
            }
            Tbx.BackColor = Color.White;
        }

        private void Tbx_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13) //force to loose focus
            {
                this.Visible = false;
                this.Visible = true;
            }
        }

        private void MPFloatValidationTextBox_SizeChanged(object sender, EventArgs e)
        {
            this.Height = Tbx.Height;
        }

        public event EventHandler Click;
        private void Tbx_Click(object sender, EventArgs e)
        {
            if (Click != null) Click(this, null);
        }

        public event EventHandler DoubleClick;
        private void Tbx_DoubleClick(object sender, EventArgs e)
        {
            if (DoubleClick != null) DoubleClick(this, null);
        }
    }
}
