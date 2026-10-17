library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Synthesizable auto-trigger sequencer. Actual defaults are in system clocks.
-- Wait for PLL lock, release TX reset, enable DAC after data can settle, then
-- emit one-cycle triggers every 200 ms. Never issue a trigger while TX is busy.
entity ScopeBurstControl is
 generic(RESET_CYCLES:positive:=16500;DAC_ENABLE_CYCLES:positive:=33000;
         BOOT_CYCLES:positive:=16500000;PERIOD_CYCLES:positive:=33000000);
 port(clk,pll_locked,tx_busy:in std_logic;
      tx_reset,tx_start,dac_power_down,ready:out std_logic);
end;
architecture rtl of ScopeBurstControl is
 signal lock_sync:std_logic_vector(1 downto 0):=(others=>'0');
 signal boot_count:natural range 0 to BOOT_CYCLES:=0;
 signal repeat_count:natural range 0 to PERIOD_CYCLES-1:=0;
 signal start_reg:std_logic:='0';
 attribute altera_attribute:string;
 attribute altera_attribute of lock_sync:signal is "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
begin
 assert RESET_CYCLES<DAC_ENABLE_CYCLES and DAC_ENABLE_CYCLES<BOOT_CYCLES
  report "Reset, DAC enable and first trigger must be ordered" severity failure;
 tx_reset<='1' when lock_sync(1)='0' or boot_count<RESET_CYCLES else '0';
 dac_power_down<='1' when lock_sync(1)='0' or boot_count<DAC_ENABLE_CYCLES else '0';
 ready<='1' when lock_sync(1)='1' and boot_count=BOOT_CYCLES else '0';
 tx_start<=start_reg;
 process(clk) begin
  if rising_edge(clk) then
   lock_sync<=lock_sync(0)&pll_locked;start_reg<='0';
   if lock_sync(1)='0' then boot_count<=0;repeat_count<=0;
   elsif boot_count<BOOT_CYCLES then boot_count<=boot_count+1;repeat_count<=0;
   else
    if repeat_count=0 and tx_busy='0' then start_reg<='1';end if;
    if repeat_count=PERIOD_CYCLES-1 then repeat_count<=0;
    else repeat_count<=repeat_count+1;end if;
   end if;
  end if;
 end process;
end;
