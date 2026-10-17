library ieee;use ieee.std_logic_1164.all;
package MainSettings is
 constant MF_RX_TC:std_logic_vector(31 downto 0):=x"3e800000"; --250ms
 constant MF_RX_DOWNSAMPLE:natural:=3; --raw packet only; FFT uses full-rate tap
 constant MF_VALID_SAMPLES:positive:=8192;
 constant MF_DELTA_W:positive:=6;
 constant MF_MIN_BIN:natural:=6;
 constant MF_MAX_BIN:natural:=114;
end package;
