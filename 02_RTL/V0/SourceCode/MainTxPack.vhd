
library IEEE;
use IEEE.Std_Logic_1164.ALL;
use IEEE.Std_Logic_Arith.ALL;
use IEEE.Std_Logic_Unsigned.ALL;
use Work.SysLib.ALL;

entity MainTxPack is
	port(
		iClk : in std_logic;
		iRst : in std_logic;
		
		iStart : in std_logic := '0';
		oBusy : out std_logic := '0';
		
		--data input
		iSamplingPeriod : in std_logic_vector(31 downto 0) := (others => '0');
		iDataCnt : in integer range 0 to 16777215 := 0;
		iNewData : in std_logic := '0';
		iValue : in std_logic_vector(15 downto 0) := x"0000";
		
		iTempData : in std_logic_vector(15 downto 0) := x"0000";
		
		--to uart controller
		iTxBusy : in std_logic := '0';
		oTxDataValid : out std_logic := '0';
		oTxData : out std_logic_vector(7 downto 0)
		
	);
end entity MainTxPack;

architecture Beh of MainTxPack is

	component MainWaveFifo
		PORT
		(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	signal cFIFOClr : std_logic := '1';
	
	signal cFIFOFull : std_logic := '0';
	signal cFIFOWReq : std_logic := '0';
	signal cFIFOData : std_logic_vector(15 downto 0) := x"0000";
	signal cFIFOEmpty : std_logic := '1';
	signal cFIFORReq : std_logic := '0';
	signal cMetaByte,cTailByte,cBodyByte:std_logic_vector(7 downto 0):=(others=>'0');
	signal cFIFOQ : std_logic_vector(7 downto 0) := x"00";
	
	signal cWriteEn : std_logic := '0';
		
	
begin

	--block filling FIFO if it is full
	cFIFOWReq <= '1' when (cFIFOFull = '0') and (iNewData = '1') and (cWriteEn = '1') else '0';
	cFIFOData <= iValue;

	f1 : MainWaveFifo port map ( aclr => cFIFOClr, 
		--input
		wrclk => iClk, wrfull => cFIFOFull, wrreq => cFIFOWReq, data => cFIFOData, 
		--output
		rdclk => iClk, rdempty => cFIFOEmpty, rdreq => cFIFORReq, q => cFIFOQ);
	

	process(iClk, iRst)
		variable vStart_L1 : std_logic := '0';
		variable vCnt : integer range 0 to 255 := 0;
		variable vState : integer range 0 to 15 := 0;
		variable vDataCnt : std_logic_vector(31 downto 0) := (others => '0');
		variable vSamplingPeriod : std_logic_vector(31 downto 0) := (others => '0');
		variable vTxDataValid : std_logic := '0';
		variable vFIFORReq : std_logic := '0';
		variable vTempData : std_logic_vector(15 downto 0) := (others => '0');
	begin
	
		if iClk'event and iClk = '1' then
            cBodyByte<=cFIFOQ;
            case vCnt is
							when 0 => cMetaByte <= x"00";
							when 1 => cMetaByte <= x"00";
							when 2 => cMetaByte <= x"FF";
							when 3 => cMetaByte <= x"FF";
							when 4 => cMetaByte <= x"00";
							when 5 => cMetaByte <= x"FF";
							when 6 => cMetaByte<=x"5A";
							when 7 => cMetaByte <= x"00";
							
							when 8 => cMetaByte <= vDataCnt(7 downto 0);
							when 9 => cMetaByte <= vDataCnt(15 downto 8);
							when 10 => cMetaByte <= vDataCnt(23 downto 16);
							when 11 => cMetaByte <= vDataCnt(31 downto 24);
							when 12 => cMetaByte <= x"00";
							when 13 => cMetaByte <= x"FF";
							when 14 => cMetaByte <= x"FF";
							when 15 => cMetaByte <= x"00";
							
							when 16 => cMetaByte <= vSamplingPeriod(7 downto 0);
							when 17 => cMetaByte <= vSamplingPeriod(15 downto 8);
							when 18 => cMetaByte <= vSamplingPeriod(23 downto 16);
							when 19 => cMetaByte <= vSamplingPeriod(31 downto 24);
							when 20 => cMetaByte <= x"00";
							when 21 => cMetaByte <= x"FF";
							when 22 => cMetaByte <= x"FF";
							when 23 => cMetaByte <= x"00";
							
							when 24 => cMetaByte <= x"00";
							when 25 => cMetaByte<=x"5A";
							when 26 => cMetaByte <= vTempData(7 downto 0);
							when 27 => cMetaByte <= vTempData(15 downto 8);
							when 28 => cMetaByte <= x"FF";
							when 29 => cMetaByte <= x"FF";
							when 30 => cMetaByte <= x"00";
							when others => cMetaByte <= x"00";
						end case;
case vCnt is
							when 0 => cTailByte <= x"00";
							when 1 => cTailByte <= x"00";
							when 2 => cTailByte <= x"FF";
							when 3 => cTailByte <= x"FF";
							when 4 => cTailByte <= x"00";
							when 5 => cTailByte <= x"FF";
							when 6 => cTailByte<=x"A5";
							when 7 => cTailByte <= x"00";
							
							when 8 => cTailByte <= vDataCnt(7 downto 0);
							when 9 => cTailByte <= vDataCnt(15 downto 8);
							when 10 => cTailByte <= vDataCnt(23 downto 16);
							when 11 => cTailByte <= vDataCnt(31 downto 24);
							when 12 => cTailByte <= x"00";
							when 13 => cTailByte <= x"FF";
							when 14 => cTailByte <= x"FF";
							when 15 => cTailByte <= x"00";
							
							when 16 => cTailByte <= vSamplingPeriod(7 downto 0);
							when 17 => cTailByte <= vSamplingPeriod(15 downto 8);
							when 18 => cTailByte <= vSamplingPeriod(23 downto 16);
							when 19 => cTailByte <= vSamplingPeriod(31 downto 24);
							when 20 => cTailByte <= x"00";
							when 21 => cTailByte <= x"FF";
							when 22 => cTailByte <= x"FF";
							when 23 => cTailByte <= x"00";
							
							when 24 => cTailByte <= x"00";
							when 25 => cTailByte<=x"A5";
							when 26 => cTailByte <= vTempData(7 downto 0);
							when 27 => cTailByte <= vTempData(15 downto 8);
							when 28 => cTailByte <= x"FF";
							when 29 => cTailByte <= x"FF";
							when 30 => cTailByte <= x"00";
							when others => cTailByte <= x"00";
						end case;
		
			vTxDataValid := '0';
			vFIFORReq := '0';
			
			if iRst = '1' then
				cFIFOClr <= '1';
				cFIFORReq <= '0';
				cWriteEn <= '0';
				vCnt := 0;
				vState := 0;
				oBusy <= '0';
			else
			
				if vState = 0 then
					--release clr, fill FIFO and wait for start
					cFIFOClr <= '0';
					cWriteEn <= '1';
					oBusy <= '0';
					
					if iStart = '1' and vStart_L1 = '0' then
						--rising edge of start, stop fill FIFO, start to send
						vDataCnt := conv_std_logic_vector(iDataCnt, 32);
						vSamplingPeriod := iSamplingPeriod;
						vTempData := iTempData;
						cWriteEn <= '0';
						vCnt := 0;
						oBusy <= '1';
						vState := 1;
					end if;
					
				elsif vState = 1 then
					--wait Tx idle, and send byte
					if iTxBusy = '0' then
					
						--send 32 byte pack head
						vTxDataValid := '1';
						
						oTxData <= cMetaByte;
						
						vState := 2;
					end if;
						
				elsif vState = 2 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--check head send finish
						if vCnt = 31 then
							--finish head
							vCnt := 0;
							vState := 3;
						else
							--send next byte
							vCnt := vCnt + 1;
							vState := 1;
						end if;
					end if;
					
				elsif vState = 3 then
					--check FIFO empty and read
					if cFIFOEmpty = '0' then
						--read one byte
						vFIFORReq := '1';
						vState := 4;
					else
						--FIFO empty, body send end
                        cFIFOClr<='1'; --reclaim the complete main frame before the next capture
						vState := 7;
					end if;
					
				elsif vState = 4 then
					--dummy for FIFO latency
					vState := 9;
					
				elsif vState = 9 then
                    vState := 10; --banked frame buffer read pipeline
                elsif vState=10 then vState:=11;
                elsif vState=11 then vState:=12;
                elsif vState=12 then vState:=13;
                elsif vState=13 then vState:=14;
                elsif vState=14 then vState:=5;
                elsif vState = 5 then
					--wait Tx idle and send byte
					if iTxBusy = '0' then
						vTxDataValid := '1';
						oTxData <= cBodyByte;
						vState := 6;
					end if;
					
				elsif vState = 6 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--goto next byte
						vState := 3;
					end if;
					
				elsif vState = 7 then
					--send pack tail
					if iTxBusy = '0' then
					
						--send 32 byte pack tail
						vTxDataValid := '1';
						
						oTxData <= cTailByte;
						
						vState := 8;
					end if;
						
				elsif vState = 8 then
					--wait Tx enter busy
					if iTxBusy = '1' then
						--check tail send finish
						if vCnt = 31 then
							--finish tail
							vCnt := 0;
							vState := 0;
						else
							--send next byte
							vCnt := vCnt + 1;
							vState := 7;
						end if;
					end if;
						
				end if;--end of state machine
			
			end if;--end of rst
			
			cFIFORReq <= vFIFORReq;
			oTxDataValid <= vTxDataValid;
			
			vStart_L1 := iStart;
		end if; --end of clk
	
	end process;
	
end architecture Beh;
