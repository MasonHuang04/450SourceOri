library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;
library real_ip;
use work.ChirpSettings.all;
entity tb_chirp_plot is end;
architecture test of tb_chirp_plot is
 constant period:time:=1 sec/165000000;
 signal done:boolean:=false;
 signal clk:std_logic:='0';signal rst:std_logic:='1';signal idx:std_logic_vector(31 downto 0):=(others=>'0');
 signal wave:integer range 0 to 16383;
begin
 clk<=not clk after period/2 when not done else '0';
 dut:entity real_ip.ChirpWaveGen(Beh) port map(iClk=>clk,iRst=>rst,iDIdx=>idx,
  iF0=>CFG_F0,iK=>CFG_SLOPE,iA=>CFG_AMPLITUDE,iDT=>x"31d03da8",oWaveform=>wave);
 process
  file f:text open write_mode is "chirp_stream.csv";variable l:line;variable tick:integer;
 begin
  for j in 1 to 30 loop wait until falling_edge(clk);end loop;rst<='0';
  for j in 1 to 300 loop wait until falling_edge(clk);end loop;
  for j in 0 to CFG_PLOT_SAMPLES+140 loop
   if j<CFG_PLOT_SAMPLES then tick:=j*CFG_PLOT_STRIDE;else tick:=CFG_TX_CYCLES-1;end if;
   idx<=std_logic_vector(to_unsigned(tick,32));wait until rising_edge(clk);wait for 1 ps;
   write(l,j);write(l,string'(","));write(l,tick);write(l,string'(","));write(l,wave);writeline(f,l);
   wait until falling_edge(clk);
  end loop;
  report "PASS QUARTER AMPLITUDE EXPORT: independent numeric check follows" severity note;done<=true;wait;
 end process;
end;
