namespace UsMimoTestBench
{
    partial class MPLog
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
            this.AutoRollCkb = new System.Windows.Forms.CheckBox();
            this.ClearBtn = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.RollToEndBtn = new System.Windows.Forms.Button();
            this.MainRtb = new System.Windows.Forms.RichTextBox();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // AutoRollCkb
            // 
            this.AutoRollCkb.AutoSize = true;
            this.AutoRollCkb.Checked = true;
            this.AutoRollCkb.CheckState = System.Windows.Forms.CheckState.Checked;
            this.AutoRollCkb.Location = new System.Drawing.Point(3, 7);
            this.AutoRollCkb.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.AutoRollCkb.Name = "AutoRollCkb";
            this.AutoRollCkb.Size = new System.Drawing.Size(80, 21);
            this.AutoRollCkb.TabIndex = 1;
            this.AutoRollCkb.Text = "Auto Roll";
            this.AutoRollCkb.UseVisualStyleBackColor = true;
            // 
            // ClearBtn
            // 
            this.ClearBtn.Dock = System.Windows.Forms.DockStyle.Right;
            this.ClearBtn.Location = new System.Drawing.Point(344, 0);
            this.ClearBtn.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.ClearBtn.Name = "ClearBtn";
            this.ClearBtn.Size = new System.Drawing.Size(58, 36);
            this.ClearBtn.TabIndex = 2;
            this.ClearBtn.Text = "Clear";
            this.ClearBtn.UseVisualStyleBackColor = true;
            this.ClearBtn.Click += new System.EventHandler(this.ClearBtn_Click);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.RollToEndBtn);
            this.panel1.Controls.Add(this.ClearBtn);
            this.panel1.Controls.Add(this.AutoRollCkb);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panel1.Location = new System.Drawing.Point(0, 314);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(402, 36);
            this.panel1.TabIndex = 3;
            // 
            // RollToEndBtn
            // 
            this.RollToEndBtn.Dock = System.Windows.Forms.DockStyle.Right;
            this.RollToEndBtn.Location = new System.Drawing.Point(250, 0);
            this.RollToEndBtn.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.RollToEndBtn.Name = "RollToEndBtn";
            this.RollToEndBtn.Size = new System.Drawing.Size(94, 36);
            this.RollToEndBtn.TabIndex = 3;
            this.RollToEndBtn.Text = "Roll To End";
            this.RollToEndBtn.UseVisualStyleBackColor = true;
            this.RollToEndBtn.Click += new System.EventHandler(this.RollToEndBtn_Click);
            // 
            // MainRtb
            // 
            this.MainRtb.Dock = System.Windows.Forms.DockStyle.Fill;
            this.MainRtb.Location = new System.Drawing.Point(0, 0);
            this.MainRtb.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.MainRtb.Name = "MainRtb";
            this.MainRtb.ReadOnly = true;
            this.MainRtb.Size = new System.Drawing.Size(402, 314);
            this.MainRtb.TabIndex = 4;
            this.MainRtb.Text = "";
            // 
            // MPLog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.MainRtb);
            this.Controls.Add(this.panel1);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "MPLog";
            this.Size = new System.Drawing.Size(402, 350);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.CheckBox AutoRollCkb;
        private System.Windows.Forms.Button ClearBtn;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button RollToEndBtn;
        private System.Windows.Forms.RichTextBox MainRtb;
    }
}
