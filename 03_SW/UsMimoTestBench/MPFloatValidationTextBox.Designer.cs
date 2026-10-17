namespace UsMimoTestBench
{
    partial class MPFloatValidationTextBox
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.Tbx = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // Tbx
            // 
            this.Tbx.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Tbx.Location = new System.Drawing.Point(0, 0);
            this.Tbx.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Tbx.Name = "Tbx";
            this.Tbx.Size = new System.Drawing.Size(55, 23);
            this.Tbx.TabIndex = 0;
            this.Tbx.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.Tbx.Click += new System.EventHandler(this.Tbx_Click);
            this.Tbx.TextChanged += new System.EventHandler(this.Tbx_TextChanged);
            this.Tbx.DoubleClick += new System.EventHandler(this.Tbx_DoubleClick);
            this.Tbx.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Tbx_KeyPress);
            this.Tbx.Leave += new System.EventHandler(this.Tbx_Leave);
            // 
            // MPFloatValidationTextBox
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.Controls.Add(this.Tbx);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "MPFloatValidationTextBox";
            this.Size = new System.Drawing.Size(55, 23);
            this.SizeChanged += new System.EventHandler(this.MPFloatValidationTextBox_SizeChanged);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox Tbx;
    }
}
