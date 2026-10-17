统一入口：只打开UsMimoTestBench.qpf；Project -> Revisions -> ChirpTxScope40k20ms -> Set Current，然后编译。

当前目录入口已统一：Simulation/Chirp、Simulation/FFT；模块位于SourceCode根目录。先阅读Simulation/README.md。

主板 Chirp 发射：烧录和示波器测试
================================

这是可综合、可生成 .sof 的独立板级工程，不是 testbench。
文件：02_RTL/V0/UsMimoTestBench.qpf
烧录：02_RTL/V0/output_chirp_scope_40k20ms/ChirpTxScope40k20ms.sof
芯片：Cyclone V 5CEFA7F23I7，51个板级引脚沿用原工程。

烧录后自动发射：
  38 kHz -> 42 kHz 线性 Chirp
  每次约20 ms，每200 ms一次（5次/秒）
  数字幅度为满量程25%；实际P4电压由板上模拟电路决定
  TX模拟滤波选择为旁路，DAC保持原165MHz更新时钟
  上电/PLL锁定后约100ms开始，不需要上位机或UART触发
  本次只运行TX，ADC/RX保持停用，不包含FFT/电脑回传

接线
1. 只接主板：主板USB-C J1供电，打开主板S1。
2. USB-Blaster接电脑，另一端经主板专用转接线接P2 JTAG。
   主板USB-C连接的是电源和CH343G串口，不能替代JTAG下载器。
3. 主板P4 (TX_OUT BNC) 接示波器CH1。使用BNC线，或探头接信号、地接BNC外壳。
   示波器先用1 MΩ输入、DC耦合；不用前端板或换能器。

Quartus烧录
1. 在Quartus选择 Tools -> Programmer（可以直接打开，不必先开原工程）。
2. Hardware Setup 选择USB-Blaster，Mode选JTAG。
3. 点Auto Detect；在检测出的5CEFA7 FPGA那一行点Change File。
4. 选择本目录output_chirp_scope_40k20ms/ChirpTxScope40k20ms.sof。
5. 勾选该行Program/Configure，点Start，等待100% (Successful)。
6. 稍等约0.1秒就会自动输出，不用点上位机Trigger。

示波器怎么看
1. 先用自动量程找到信号，再设约5ms/div，观察约20ms长的波包。
2. 使用CH1上升沿触发，触发电平放在有效波形幅度内。
   如果触发总落在波包中间，可将触发Holdoff设为约50ms（示波器支持时）。
3. 设20ms/div，可观察相邻波包起点约相隔200ms。
4. 在一个波包内部放大到约10us/div：
   起始附近周期约26.3us（38kHz）；末尾附近约23.8us（42kHz）。
   应看到正弦波逐渐变密，波包间回到静态电平。
5. 判断扫频需要比较同一20ms波包的开头和结尾，不能只看一屏的平均Frequency读数。

如果没有波形
- Programmer看不到USB-Blaster：检查下载器驱动、USB和主板供电。
- Auto Detect看不到FPGA：检查P2 JTAG转接线和主板电源；单独插USB-C不能烧录。
- 烧录成功但P4没有输出：确认选择的是ChirpTxScope40k20ms.sof、接的是主板P4、
  示波器处于1MΩ/合适量程，并至少等待0.2秒。不要选原UsMimoTestBench.sof。

.sof是临时SRAM配置：断电后会丢失这次测试配置，需要重新下载；本次没有改配置Flash。
需要重新编译时，用File -> Open Project打开UsMimoTestBench.qpf，再Start Compilation。
在Project -> Revisions选择ChirpTxScope40k20ms并点Set Current；不要误选原系统UsMimoTestBench Revision。

实现与验证说明
- 新增顶层SourceCode/ChirpTxScope40k20ms.vhd，自动控制器ScopeBurstControl.vhd。
- 原UsMimoTestBench.vhd、TxController、ChirpWaveGen、MainPLL及original备份都未改。
- 复用真实原TX运算核；新顶层增加一级DAC数据输出寄存器，固定延迟一个系统时钟。
- DAC时钟反相转发，在数据更新间隔的中间沿采样；SDC检查DAC904 setup=1ns、hold=1.5ns，
  两侧各预留0.25ns板级相对走线偏差假设。实际板上走线延迟未实测。
- QSF对Chirp内部复位寄存器做扇出复制，保持recovery/removal时序检查，不通过假路径隐藏问题。
- 自动启动、间隔、忙状态抑制及失锁重启已做控制仿真；25%幅度的真实Intel IP数值已核对。
- 编译/时序和最终SOF校验值见output_chirp_scope_40k20ms/build_checks.json。
- 这里提供可用于实板测试的文件，示波器实测仍由实际连接的板子完成。

资料依据
DAC904时序表：https://www.ti.com/lit/ds/symlink/dac904.pdf 第5页。
Quartus烧录步骤：https://www.intel.com/content/www/us/en/docs/programmable/683548/19-1/step-11-programming-the-board.html
