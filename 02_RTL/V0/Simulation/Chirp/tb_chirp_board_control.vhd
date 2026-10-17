library ieee;
use ieee.std_logic_1164.all;
use std.env.all;
entity tb_chirp_board_control is end;
architecture test of tb_chirp_board_control is
 signal done:boolean:=false;
 signal clk:std_logic:='0';signal locked:std_logic:='0';signal fake_busy,inhibit,busy:std_logic:='0';
 signal reset,start,pd,ready:std_logic;signal pulse_count:integer:=0;
begin
 clk<=not clk after 5 ns when not done else '0';busy<=fake_busy or inhibit;
 dut:entity work.ScopeBurstControl(rtl) generic map(RESET_CYCLES=>4,DAC_ENABLE_CYCLES=>8,BOOT_CYCLES=>16,PERIOD_CYCLES=>100)
  port map(clk,locked,busy,reset,start,pd,ready);
 process(clk)
  variable hold:integer:=0;variable cycle,last_start:integer:=0;variable previous_start:std_logic:='0';
 begin
  if rising_edge(clk) then
   cycle:=cycle+1;
   assert not(reset='1' and pd='0') report "DAC enabled before core reset release" severity failure;
   if ready='0' then last_start:=0;end if;
   if start='1' then
    assert previous_start='0' and busy='0' and reset='0' and pd='0' and ready='1' report "Invalid auto-trigger" severity failure;
    if last_start/=0 then assert (cycle-last_start) mod 100=0 report "Incorrect repeat period" severity failure;end if;
    last_start:=cycle;pulse_count<=pulse_count+1;hold:=20;
   end if;
   if hold>0 then fake_busy<='1';hold:=hold-1;else fake_busy<='0';end if;
   previous_start:=start;
  end if;
 end process;
 process begin
  wait for 100 ns;assert reset='1' and pd='1' and ready='0' and pulse_count=0 severity failure;
  wait until falling_edge(clk);locked<='1';
  wait until pulse_count=4;wait until falling_edge(clk);inhibit<='1';
  for i in 1 to 250 loop wait until falling_edge(clk);end loop;
  assert pulse_count=4 report "Trigger issued while busy" severity failure;
  inhibit<='0';wait until pulse_count=6;wait until falling_edge(clk);locked<='0';
  for i in 1 to 5 loop wait until falling_edge(clk);end loop;
  assert reset='1' and pd='1' and ready='0' report "PLL lock loss not handled" severity failure;
  locked<='1';wait until pulse_count=7;
  report "PASS SCOPE BURST CONTROL: startup, periodic trigger, busy suppression, lock loss/restart" severity note;done<=true;wait;
 end process;
 process begin wait for 20 us;assert done report "Control test timeout" severity failure;wait;end process;
end;
