using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace UsMimoTestBench
{
    static class Program
    {
        [STAThread]
        static int Main(string[] args)
        {
            try {
                Application.EnableVisualStyles();Application.SetCompatibleTextRenderingDefault(false);
                if(args.Length==3&&args[0]=="--selftest") { SoftwareChecks.Run(args[1],args[2]);return 0; }
                if(args.Length>=2&&args[0]=="--preview") {
                    using(MainFrm form=new MainFrm()) {
                        form.StartPosition=FormStartPosition.Manual;form.Location=new Point(-30000,-30000);form.ShowInTaskbar=false;
                        if(args.Length>2&&args[2]=="compact")form.ClientSize=new Size(1020,720);
                        form.Show();Application.DoEvents();form.LoadDemo();Application.DoEvents();
                        form.SavePreview(args[1],args.Length>2&&args[2]=="detail");form.Close();
                    }return 0;
                }
                Application.Run(new MainFrm());return 0;
            } catch(Exception error) {
                if(args.Length>0){File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"last_test_error.txt"),error.ToString());return 1;}
                MessageBox.Show(error.Message,"UsMimoTestBench",MessageBoxButtons.OK,MessageBoxIcon.Error);return 1;
            }
        }
    }
}
