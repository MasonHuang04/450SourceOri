using System;
using System.IO.Ports;
using System.Threading;

namespace UsMimoTestBench
{
    public sealed class USSensor : IDisposable
    {
        readonly object gate = new object();
        SerialPort port; Thread reader; volatile bool running;
        long transferred;
        public event Action<ScopeDataFrame> RawReceived;
        public event Action<MainReport> PeakReceived;
        public event Action<string> Failed;
        public const int BAUD_RATE = 2000000;
        public bool IsConnected { get { lock(gate) return port != null && port.IsOpen && running; } }
        public long BytesTransferred { get { return Interlocked.Read(ref transferred); } }
        public int InvalidPackets { get { return parser == null ? 0 : parser.Invalid; } }
        MainStreamParser parser;
        public void Open(string name)
        {
            Close();
            SerialPort candidate = new SerialPort(name, BAUD_RATE, Parity.None, 8, StopBits.One);
            candidate.Handshake = Handshake.None; candidate.DtrEnable = false; candidate.RtsEnable = false;
            candidate.ReadBufferSize = 1048576; candidate.WriteTimeout = 1500; candidate.ReadTimeout = 200;
            try { candidate.Open(); candidate.DiscardInBuffer(); }
            catch { candidate.Dispose(); throw; }
            parser = new MainStreamParser();
            parser.Raw = f => { if (RawReceived != null) RawReceived(f); };
            parser.Peak = p => { if (PeakReceived != null) PeakReceived(p); };
            transferred = 0; lock(gate) { port = candidate; running = true; }
            reader = new Thread(ReadLoop); reader.IsBackground = true; reader.Name = "Main UART reader"; reader.Start();
        }
        void ReadLoop()
        {
            byte[] data = new byte[8192];
            while (running) {
                try {
                    int n = port.Read(data, 0, data.Length);
                    Interlocked.Add(ref transferred, n); parser.Feed(data, n);
                } catch (TimeoutException) { }
                catch (Exception e) { if (running) { running = false; if (Failed != null) Failed(e.Message); } break; }
            }
        }
        public void Send(ChirpParameters parameters, bool trigger)
        {
            byte[] command = parameters.Command(trigger);
            lock(gate) {
                if (port == null || !port.IsOpen || !running) throw new InvalidOperationException("请先连接主板串口。");
                // Single ordered write: complete settings packet precedes the trigger command.
                port.Write(command, 0, command.Length);
            }
        }
        public void Close()
        {
            running = false;
            SerialPort old; lock(gate) { old = port; }
            if (old != null) { try { old.Close(); } catch { } }
            if (reader != null && reader != Thread.CurrentThread) reader.Join(1200);
            lock(gate) { if (old != null) old.Dispose(); port = null; }
            reader = null;
        }
        public void Dispose() { Close(); }
    }
}
