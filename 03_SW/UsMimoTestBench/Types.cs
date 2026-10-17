using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UsMimoTestBench
{

    public struct USSensorSettingStruct
    {
        public bool AutoTriggerEn;
        public ushort AutoTriggerPeriod;
        public bool TxSQWaveEn;
        public ushort TxDownSampleRate;
        public byte TxDataResolution;
        public float TxCenterFreq;
        public float TxBandWidth;
        public float TxTimeLength;
        public float TxDigitalAmplitude;
        public byte TxMuxSel;
        public ushort RxDownSampleRate;
        public byte RxDataResolution;
        public float RxStartDelay;
        public float RxTimeLength;
        public byte RxMuxSel;

        public static bool operator ==(USSensorSettingStruct c1, USSensorSettingStruct c2)
        {
            if (c1.AutoTriggerEn != c2.AutoTriggerEn) return false;
            if (c1.AutoTriggerPeriod != c2.AutoTriggerPeriod) return false;
            if (c1.TxSQWaveEn != c2.TxSQWaveEn) return false;
            if (c1.TxDownSampleRate != c2.TxDownSampleRate) return false;
            if (c1.TxDataResolution != c2.TxDataResolution) return false;
            if (c1.TxCenterFreq != c2.TxCenterFreq) return false;
            if (c1.TxBandWidth != c2.TxBandWidth) return false;
            if (c1.TxTimeLength != c2.TxTimeLength) return false;
            if (c1.TxDigitalAmplitude != c2.TxDigitalAmplitude) return false;
            if (c1.TxMuxSel != c2.TxMuxSel) return false;
            if (c1.RxStartDelay != c2.RxStartDelay) return false;
            if (c1.RxTimeLength != c2.RxTimeLength) return false;
            if (c1.RxDownSampleRate != c2.RxDownSampleRate) return false;
            if (c1.RxDataResolution != c2.RxDataResolution) return false;
            if (c1.RxMuxSel != c2.RxMuxSel) return false;

            return true;
        }

        public static bool operator !=(USSensorSettingStruct c1, USSensorSettingStruct c2)
        {
            return !(c1 == c2);
        }

        public byte[] ToComBuffer()
        {

            byte[] Buffer = new byte[64];
            byte[] TmpArr;

            Buffer[0] = 0x00;
            Buffer[1] = 0xA5;
            Buffer[2] = 0x00;
            Buffer[3] = 0xA5;
            Buffer[60] = 0x5A;
            Buffer[61] = 0xFF;
            Buffer[62] = 0x5A;
            Buffer[63] = 0xFF;

            int ConfStart = 4;

            Buffer[ConfStart + 0] = (byte)(AutoTriggerEn ? 1 : 0);

            Buffer[ConfStart + 2] = (byte)(AutoTriggerPeriod & 0xFF);
            Buffer[ConfStart + 3] = (byte)((AutoTriggerPeriod >> 8) & 0xFF);

            Buffer[ConfStart + 4] = (byte)(TxSQWaveEn ? 1 : 0);
            Buffer[ConfStart + 5] = (byte)(TxDownSampleRate & 0xFF);
            Buffer[ConfStart + 6] = (byte)((TxDownSampleRate >> 8) & 0xFF);
            Buffer[ConfStart + 7] = TxDataResolution;

            TmpArr = BitConverter.GetBytes(TxCenterFreq);
            Buffer[ConfStart + 8] = TmpArr[0];
            Buffer[ConfStart + 9] = TmpArr[1];
            Buffer[ConfStart + 10] = TmpArr[2];
            Buffer[ConfStart + 11] = TmpArr[3];

            TmpArr = BitConverter.GetBytes(TxBandWidth);
            Buffer[ConfStart + 12] = TmpArr[0];
            Buffer[ConfStart + 13] = TmpArr[1];
            Buffer[ConfStart + 14] = TmpArr[2];
            Buffer[ConfStart + 15] = TmpArr[3];

            TmpArr = BitConverter.GetBytes(TxTimeLength);
            Buffer[ConfStart + 16] = TmpArr[0];
            Buffer[ConfStart + 17] = TmpArr[1];
            Buffer[ConfStart + 18] = TmpArr[2];
            Buffer[ConfStart + 19] = TmpArr[3];

            TmpArr = BitConverter.GetBytes(TxDigitalAmplitude);
            Buffer[ConfStart + 20] = TmpArr[0];
            Buffer[ConfStart + 21] = TmpArr[1];
            Buffer[ConfStart + 22] = TmpArr[2];
            Buffer[ConfStart + 23] = TmpArr[3];

            Buffer[ConfStart + 24] = TxMuxSel;

            TmpArr = BitConverter.GetBytes(RxTimeLength);
            Buffer[ConfStart + 36] = TmpArr[0];
            Buffer[ConfStart + 37] = TmpArr[1];
            Buffer[ConfStart + 38] = TmpArr[2];
            Buffer[ConfStart + 39] = TmpArr[3];

            TmpArr = BitConverter.GetBytes(RxStartDelay);
            Buffer[ConfStart + 40] = TmpArr[0];
            Buffer[ConfStart + 41] = TmpArr[1];
            Buffer[ConfStart + 42] = TmpArr[2];
            Buffer[ConfStart + 43] = TmpArr[3];

            Buffer[ConfStart + 44] = (byte)(RxDownSampleRate & 0xFF);
            Buffer[ConfStart + 45] = (byte)((RxDownSampleRate >> 8) & 0xFF);
            Buffer[ConfStart + 46] = RxDataResolution;
            Buffer[ConfStart + 47] = RxMuxSel;

            return Buffer;
        }

    }

    public struct ScopeDataFrame
    {
        public int DataLen;
        public float SamplingPeriod;
        public float TempC;
        public ushort[] Data;

        public string GetDataStr()
        {
            string DataStr = "Temp = " + TempC.ToString("F3") + "°C\n" + "N\tt\tValue\n";
            //add data
            for (int i = 0; i < DataLen; i++)
            {
                DataStr += i.ToString() + "\t" + (i * SamplingPeriod).ToString() + "\t" + Data[i].ToString() + "\n";
            }
            return DataStr;
        }

        public bool SaveTextData(string FileName)
        {
            try
            {
                System.IO.StreamWriter Writer = new System.IO.StreamWriter(FileName, false, System.Text.Encoding.Default);
                Writer.Write(GetDataStr());
                Writer.Close();
            }
            catch
            {
                return false;
            }
            return true;
        }

    }
}
