-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 20.1 (Release Build #720)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2020 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from FPFCos_0002
-- VHDL created on Mon Mar 10 16:41:47 2025


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity FPFCos_0002 is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end FPFCos_0002;

architecture normal of FPFCos_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid6_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid7_fpCosPiTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal cstAllZWE_uid8_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_x_uid9_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_x_uid10_fpCosPiTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_x_uid11_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_x_uid11_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid12_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid12_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid13_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid13_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid14_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid15_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid16_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid17_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid18_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid19_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid19_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_fpx_uid22_uid28_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_fpx_uid22_uid28_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid29_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid30_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_fpx_uid32_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_fpx_uid32_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cwFo2_uid39_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal biasM1_uid40_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal xBranch0_uid41_fpCosPiTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal xBranch0_uid41_fpCosPiTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal xBranch0_uid41_fpCosPiTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal xBranch0_uid41_fpCosPiTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal xBranch_uid42_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXTableAddrExt_uid43_fpCosPiTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expXTableAddrExt_uid43_fpCosPiTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expXTableAddrExt_uid43_fpCosPiTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expXTableAddrExt_uid43_fpCosPiTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expXTableAddr_uid44_fpCosPiTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal expXTableAddr_uid44_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal invXBranch_uid45_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXTableAddrPost_uid46_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expXTableAddrPost_uid46_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal os_uid49_fpCosPiTest_q : STD_LOGIC_VECTOR (79 downto 0);
    signal oFracX_uid52_fpCosPiTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal multFracBits_uid54_fpCosPiTest_in : STD_LOGIC_VECTOR (77 downto 0);
    signal multFracBits_uid54_fpCosPiTest_b : STD_LOGIC_VECTOR (77 downto 0);
    signal multFracBitsTopLow_uid55_fpCosPiTest_in : STD_LOGIC_VECTOR (76 downto 0);
    signal multFracBitsTopLow_uid55_fpCosPiTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal multFracBitsTop_uid56_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal intBit_uid57_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal fracCompOut_uid60_fpCosPiTest_in : STD_LOGIC_VECTOR (76 downto 0);
    signal fracCompOut_uid60_fpCosPiTest_b : STD_LOGIC_VECTOR (52 downto 0);
    signal ZerosGB_uid63_fpCosPiTest_q : STD_LOGIC_VECTOR (29 downto 0);
    signal fracXRExt_uid64_fpCosPiTest_q : STD_LOGIC_VECTOR (52 downto 0);
    signal finalFrac_uid65_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal finalFrac_uid65_fpCosPiTest_q : STD_LOGIC_VECTOR (52 downto 0);
    signal RRangeRed_uid67_fpCosPiTest_q : STD_LOGIC_VECTOR (61 downto 0);
    signal cstBiasMwShiftM2_uid68_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZwShiftP1_uid69_fpCosPiTest_q : STD_LOGIC_VECTOR (13 downto 0);
    signal expXRR_uid70_fpCosPiTest_in : STD_LOGIC_VECTOR (60 downto 0);
    signal expXRR_uid70_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracXRR_uid71_fpCosPiTest_in : STD_LOGIC_VECTOR (52 downto 0);
    signal fracXRR_uid71_fpCosPiTest_b : STD_LOGIC_VECTOR (52 downto 0);
    signal oFracXRR_uid73_fpCosPiTest_q : STD_LOGIC_VECTOR (53 downto 0);
    signal fxpXShiftValExt_uid74_fpCosPiTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal fxpXShiftValExt_uid74_fpCosPiTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal fxpXShiftValExt_uid74_fpCosPiTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal fxpXShiftValExt_uid74_fpCosPiTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fxpXShiftVal_uid75_fpCosPiTest_in : STD_LOGIC_VECTOR (3 downto 0);
    signal fxpXShiftVal_uid75_fpCosPiTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal extendedFracX_uid76_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal cstBias_uid78_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstNaNwF_uid84_fpCosPiTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal signXRR_uid87_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal cosXIsOne_uid88_fpCosPiTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal cosXIsOne_uid88_fpCosPiTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal cosXIsOne_uid88_fpCosPiTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal cosXIsOne_uid88_fpCosPiTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal cosXIsOneXRR_uid89_fpCosPiTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal cosXIsOneXRR_uid89_fpCosPiTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal cosXIsOneXRR_uid89_fpCosPiTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal cosXIsOneXRR_uid89_fpCosPiTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal intXParity_uid90_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal y_uid91_fpCosPiTest_in : STD_LOGIC_VECTOR (66 downto 0);
    signal y_uid91_fpCosPiTest_b : STD_LOGIC_VECTOR (65 downto 0);
    signal paddingY_uid92_fpCosPiTest_q : STD_LOGIC_VECTOR (65 downto 0);
    signal updatedY_uid93_fpCosPiTest_q : STD_LOGIC_VECTOR (66 downto 0);
    signal yIsZero_uid92_fpCosPiTest_a : STD_LOGIC_VECTOR (66 downto 0);
    signal yIsZero_uid92_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal yIsZero_uid92_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstZmwFRRPwSM1_uid95_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal half_uid97_fpCosPiTest_q : STD_LOGIC_VECTOR (65 downto 0);
    signal updatedY_uid99_fpCosPiTest_q : STD_LOGIC_VECTOR (131 downto 0);
    signal yIsHalf_uid98_fpCosPiTest_a : STD_LOGIC_VECTOR (131 downto 0);
    signal yIsHalf_uid98_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal yIsHalf_uid98_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal aPostPad_uid103_fpCosPiTest_q : STD_LOGIC_VECTOR (66 downto 0);
    signal oneMinusY_uid104_fpCosPiTest_a : STD_LOGIC_VECTOR (67 downto 0);
    signal oneMinusY_uid104_fpCosPiTest_b : STD_LOGIC_VECTOR (67 downto 0);
    signal oneMinusY_uid104_fpCosPiTest_o : STD_LOGIC_VECTOR (67 downto 0);
    signal oneMinusY_uid104_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal cmpYToOneMinusY_uid106_fpCosPiTest_a : STD_LOGIC_VECTOR (69 downto 0);
    signal cmpYToOneMinusY_uid106_fpCosPiTest_b : STD_LOGIC_VECTOR (69 downto 0);
    signal cmpYToOneMinusY_uid106_fpCosPiTest_o : STD_LOGIC_VECTOR (69 downto 0);
    signal cmpYToOneMinusY_uid106_fpCosPiTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal invCmpYToOMY_uid107_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oMyBottom_uid108_fpCosPiTest_in : STD_LOGIC_VECTOR (64 downto 0);
    signal oMyBottom_uid108_fpCosPiTest_b : STD_LOGIC_VECTOR (64 downto 0);
    signal yBottom_uid109_fpCosPiTest_in : STD_LOGIC_VECTOR (64 downto 0);
    signal yBottom_uid109_fpCosPiTest_b : STD_LOGIC_VECTOR (64 downto 0);
    signal z_uid110_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal z_uid110_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal p_uid114_fpCosPiTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal expP_uid116_fpCosPiTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expP_uid116_fpCosPiTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expP_uid116_fpCosPiTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expP_uid116_fpCosPiTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal yAddr_uid118_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal zPPolyEval_uid119_fpCosPiTest_in : STD_LOGIC_VECTOR (56 downto 0);
    signal zPPolyEval_uid119_fpCosPiTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal fxpSinRes_uid121_fpCosPiTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal fxpSinRes_uid121_fpCosPiTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal normBit_uid123_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highRes_uid124_fpCosPiTest_in : STD_LOGIC_VECTOR (50 downto 0);
    signal highRes_uid124_fpCosPiTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal lowRes_uid125_fpCosPiTest_in : STD_LOGIC_VECTOR (49 downto 0);
    signal lowRes_uid125_fpCosPiTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRCompPreRnd_uid126_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRCompPreRnd_uid126_fpCosPiTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expRCompFracRCompPreRnd_uid127_fpCosPiTest_q : STD_LOGIC_VECTOR (32 downto 0);
    signal rndOp_uid132_fpCosPiTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal expRCompFracRComp_uid133_fpCosPiTest_a : STD_LOGIC_VECTOR (34 downto 0);
    signal expRCompFracRComp_uid133_fpCosPiTest_b : STD_LOGIC_VECTOR (34 downto 0);
    signal expRCompFracRComp_uid133_fpCosPiTest_o : STD_LOGIC_VECTOR (34 downto 0);
    signal expRCompFracRComp_uid133_fpCosPiTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal fracRComp_uid134_fpCosPiTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRComp_uid134_fpCosPiTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expRComp_uid135_fpCosPiTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expRComp_uid135_fpCosPiTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expRCosIsNeg_uid137_fpCosPiTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal expRCosIsNeg_uid137_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal invCosXIsOne_uid138_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invCosXIsOneXRR_uid139_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal yHalfCosNotONe_uid140_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cosUnderflow_uid141_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroCos_uid142_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid143_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid143_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZOrCosOne_uid144_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZOrCosOne_uid144_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPostExcSel_uid145_fpCosPiTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid147_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid147_fpCosPiTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal excConc_uid148_fpCosPiTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal expSelBits_uid149_fpCosPiTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal expSelector_uid150_fpCosPiTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid152_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid152_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invYIsZero_uid153_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cosXOne_uid154_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRCond2_uid156_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invIntParity_uid158_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRCond1_uid159_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRBase_uid160_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRBase_uid160_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xorSignRRXSignBase_uid161_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcXI_uid162_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcXN_uid163_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid164_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid164_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cosx_uid165_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal expFracX_uid167_px_uid21_fpCosPiTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal R_uid168_px_uid21_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid170_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vCount_uid172_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid173_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vStagei_uid175_zCount_uid58_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid175_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid176_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid178_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid181_zCount_uid58_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid181_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid184_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid187_zCount_uid58_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid187_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zs_uid188_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid190_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid193_zCount_uid58_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid193_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zs_uid194_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid196_zCount_uid58_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid196_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid199_zCount_uid58_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid199_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid201_zCount_uid58_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid202_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid203_zCount_uid58_fpCosPiTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal zs_uid205_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (63 downto 0);
    signal rVStage_uid206_lzcZ_uid112_fpCosPiTest_b : STD_LOGIC_VECTOR (63 downto 0);
    signal vCount_uid207_lzcZ_uid112_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid207_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid208_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (62 downto 0);
    signal vStage_uid209_lzcZ_uid112_fpCosPiTest_in : STD_LOGIC_VECTOR (0 downto 0);
    signal vStage_uid209_lzcZ_uid112_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal cStage_uid210_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (63 downto 0);
    signal vStagei_uid212_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid212_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (63 downto 0);
    signal vCount_uid215_lzcZ_uid112_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid215_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid218_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid218_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vCount_uid221_lzcZ_uid112_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid221_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid224_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid224_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid227_lzcZ_uid112_fpCosPiTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid227_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid230_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid230_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal vCount_uid233_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid236_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid236_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid239_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid242_lzcZ_uid112_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid242_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid244_lzcZ_uid112_fpCosPiTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid245_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid246_lzcZ_uid112_fpCosPiTest_q : STD_LOGIC_VECTOR (6 downto 0);
    signal yT1_uid260_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal lowRangeB_uid262_invPolyEval_in : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeB_uid262_invPolyEval_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highBBits_uid263_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal s1sumAHighB_uid264_invPolyEval_a : STD_LOGIC_VECTOR (21 downto 0);
    signal s1sumAHighB_uid264_invPolyEval_b : STD_LOGIC_VECTOR (21 downto 0);
    signal s1sumAHighB_uid264_invPolyEval_o : STD_LOGIC_VECTOR (21 downto 0);
    signal s1sumAHighB_uid264_invPolyEval_q : STD_LOGIC_VECTOR (21 downto 0);
    signal s1_uid265_invPolyEval_q : STD_LOGIC_VECTOR (22 downto 0);
    signal lowRangeB_uid268_invPolyEval_in : STD_LOGIC_VECTOR (1 downto 0);
    signal lowRangeB_uid268_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal highBBits_uid269_invPolyEval_b : STD_LOGIC_VECTOR (21 downto 0);
    signal s2sumAHighB_uid270_invPolyEval_a : STD_LOGIC_VECTOR (30 downto 0);
    signal s2sumAHighB_uid270_invPolyEval_b : STD_LOGIC_VECTOR (30 downto 0);
    signal s2sumAHighB_uid270_invPolyEval_o : STD_LOGIC_VECTOR (30 downto 0);
    signal s2sumAHighB_uid270_invPolyEval_q : STD_LOGIC_VECTOR (30 downto 0);
    signal s2_uid271_invPolyEval_q : STD_LOGIC_VECTOR (32 downto 0);
    signal osig_uid274_pT1_uid261_invPolyEval_b : STD_LOGIC_VECTOR (13 downto 0);
    signal osig_uid277_pT2_uid267_invPolyEval_b : STD_LOGIC_VECTOR (23 downto 0);
    signal rrTable_uid47_fpCosPiTest_lutmem_reset0 : std_logic;
    signal rrTable_uid47_fpCosPiTest_lutmem_ia : STD_LOGIC_VECTOR (39 downto 0);
    signal rrTable_uid47_fpCosPiTest_lutmem_aa : STD_LOGIC_VECTOR (7 downto 0);
    signal rrTable_uid47_fpCosPiTest_lutmem_ab : STD_LOGIC_VECTOR (7 downto 0);
    signal rrTable_uid47_fpCosPiTest_lutmem_ir : STD_LOGIC_VECTOR (39 downto 0);
    signal rrTable_uid47_fpCosPiTest_lutmem_r : STD_LOGIC_VECTOR (39 downto 0);
    signal rrTable_uid48_fpCosPiTest_lutmem_reset0 : std_logic;
    signal rrTable_uid48_fpCosPiTest_lutmem_ia : STD_LOGIC_VECTOR (39 downto 0);
    signal rrTable_uid48_fpCosPiTest_lutmem_aa : STD_LOGIC_VECTOR (7 downto 0);
    signal rrTable_uid48_fpCosPiTest_lutmem_ab : STD_LOGIC_VECTOR (7 downto 0);
    signal rrTable_uid48_fpCosPiTest_lutmem_ir : STD_LOGIC_VECTOR (39 downto 0);
    signal rrTable_uid48_fpCosPiTest_lutmem_r : STD_LOGIC_VECTOR (39 downto 0);
    signal prod_uid53_fpCosPiTest_align_9_q : STD_LOGIC_VECTOR (52 downto 0);
    signal prod_uid53_fpCosPiTest_align_9_qint : STD_LOGIC_VECTOR (52 downto 0);
    signal prod_uid53_fpCosPiTest_align_11_q : STD_LOGIC_VECTOR (77 downto 0);
    signal prod_uid53_fpCosPiTest_align_11_qint : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (61 downto 0);
    signal leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (61 downto 0);
    signal leftShiftStage0Idx1_uid299_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (45 downto 0);
    signal leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (45 downto 0);
    signal leftShiftStage0Idx2_uid302_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage0Idx3Pad48_uid303_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (47 downto 0);
    signal leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage0Idx3_uid305_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (73 downto 0);
    signal leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (73 downto 0);
    signal leftShiftStage1Idx1_uid310_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (69 downto 0);
    signal leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (69 downto 0);
    signal leftShiftStage1Idx2_uid313_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage1Idx3Pad12_uid314_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (11 downto 0);
    signal leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (65 downto 0);
    signal leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (65 downto 0);
    signal leftShiftStage1Idx3_uid316_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (76 downto 0);
    signal leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (76 downto 0);
    signal leftShiftStage2Idx1_uid321_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (75 downto 0);
    signal leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (75 downto 0);
    signal leftShiftStage2Idx2_uid324_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage2Idx3Pad3_uid325_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_in : STD_LOGIC_VECTOR (74 downto 0);
    signal leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_b : STD_LOGIC_VECTOR (74 downto 0);
    signal leftShiftStage2Idx3_uid327_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q : STD_LOGIC_VECTOR (77 downto 0);
    signal expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_i : STD_LOGIC_VECTOR (8 downto 0);
    signal expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_q : STD_LOGIC_VECTOR (7 downto 0);
    signal leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (63 downto 0);
    signal leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (63 downto 0);
    signal leftShiftStage0Idx1_uid336_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (59 downto 0);
    signal leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (59 downto 0);
    signal leftShiftStage0Idx2_uid339_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (55 downto 0);
    signal leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (55 downto 0);
    signal leftShiftStage0Idx3_uid342_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (66 downto 0);
    signal leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (66 downto 0);
    signal leftShiftStage1Idx1_uid347_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (65 downto 0);
    signal leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (65 downto 0);
    signal leftShiftStage1Idx2_uid350_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_in : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_b : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1Idx3_uid353_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q : STD_LOGIC_VECTOR (67 downto 0);
    signal leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage0Idx1_uid361_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage0Idx2_uid364_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (56 downto 0);
    signal leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (56 downto 0);
    signal leftShiftStage1Idx1_uid370_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (48 downto 0);
    signal leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (48 downto 0);
    signal leftShiftStage1Idx2_uid373_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1Idx3Pad24_uid374_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (40 downto 0);
    signal leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (40 downto 0);
    signal leftShiftStage1Idx3_uid376_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (62 downto 0);
    signal leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (62 downto 0);
    signal leftShiftStage2Idx1_uid381_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (60 downto 0);
    signal leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (60 downto 0);
    signal leftShiftStage2Idx2_uid384_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage2Idx3Pad6_uid385_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (58 downto 0);
    signal leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (58 downto 0);
    signal leftShiftStage2Idx3_uid387_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_in : STD_LOGIC_VECTOR (63 downto 0);
    signal leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_b : STD_LOGIC_VECTOR (63 downto 0);
    signal leftShiftStage3Idx1_uid392_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal memoryC0_uid248_sinXTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid248_sinXTables_lutmem_ia : STD_LOGIC_VECTOR (29 downto 0);
    signal memoryC0_uid248_sinXTables_lutmem_aa : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC0_uid248_sinXTables_lutmem_ab : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC0_uid248_sinXTables_lutmem_ir : STD_LOGIC_VECTOR (29 downto 0);
    signal memoryC0_uid248_sinXTables_lutmem_r : STD_LOGIC_VECTOR (29 downto 0);
    signal memoryC1_uid251_sinXTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid251_sinXTables_lutmem_ia : STD_LOGIC_VECTOR (20 downto 0);
    signal memoryC1_uid251_sinXTables_lutmem_aa : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC1_uid251_sinXTables_lutmem_ab : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC1_uid251_sinXTables_lutmem_ir : STD_LOGIC_VECTOR (20 downto 0);
    signal memoryC1_uid251_sinXTables_lutmem_r : STD_LOGIC_VECTOR (20 downto 0);
    signal memoryC2_uid254_sinXTables_lutmem_reset0 : std_logic;
    signal memoryC2_uid254_sinXTables_lutmem_ia : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC2_uid254_sinXTables_lutmem_aa : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC2_uid254_sinXTables_lutmem_ab : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC2_uid254_sinXTables_lutmem_ir : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC2_uid254_sinXTables_lutmem_r : STD_LOGIC_VECTOR (12 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_UpperBits_for_b_q : STD_LOGIC_VECTOR (26 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_a : STD_LOGIC_VECTOR (73 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_b : STD_LOGIC_VECTOR (73 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_o : STD_LOGIC_VECTOR (73 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_c : STD_LOGIC_VECTOR (0 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q : STD_LOGIC_VECTOR (72 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_a : STD_LOGIC_VECTOR (33 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_b : STD_LOGIC_VECTOR (33 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_o : STD_LOGIC_VECTOR (33 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_cin : STD_LOGIC_VECTOR (0 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_q : STD_LOGIC_VECTOR (31 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitJoin_for_q_q : STD_LOGIC_VECTOR (104 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_b_q : STD_LOGIC_VECTOR (72 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_c_q : STD_LOGIC_VECTOR (31 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_BitJoin_for_c_q : STD_LOGIC_VECTOR (31 downto 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_reset : std_logic;
    type mul2xSinRes_uid122_fpCosPiTest_cma_a0type is array(NATURAL range <>) of UNSIGNED(25 downto 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_a0 : mul2xSinRes_uid122_fpCosPiTest_cma_a0type(0 to 0);
    attribute preserve : boolean;
    attribute preserve of mul2xSinRes_uid122_fpCosPiTest_cma_a0 : signal is true;
    signal mul2xSinRes_uid122_fpCosPiTest_cma_c0 : mul2xSinRes_uid122_fpCosPiTest_cma_a0type(0 to 0);
    attribute preserve of mul2xSinRes_uid122_fpCosPiTest_cma_c0 : signal is true;
    type mul2xSinRes_uid122_fpCosPiTest_cma_ptype is array(NATURAL range <>) of UNSIGNED(51 downto 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_p : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_u : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_w : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_x : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_y : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_s : mul2xSinRes_uid122_fpCosPiTest_cma_ptype(0 to 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_qq : STD_LOGIC_VECTOR (51 downto 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_q : STD_LOGIC_VECTOR (51 downto 0);
    signal mul2xSinRes_uid122_fpCosPiTest_cma_ena0 : std_logic;
    signal mul2xSinRes_uid122_fpCosPiTest_cma_ena1 : std_logic;
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_reset : std_logic;
    type prodXY_uid273_pT1_uid261_invPolyEval_cma_a0type is array(NATURAL range <>) of UNSIGNED(12 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_a0 : prodXY_uid273_pT1_uid261_invPolyEval_cma_a0type(0 to 0);
    attribute preserve of prodXY_uid273_pT1_uid261_invPolyEval_cma_a0 : signal is true;
    type prodXY_uid273_pT1_uid261_invPolyEval_cma_c0type is array(NATURAL range <>) of SIGNED(12 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_c0 : prodXY_uid273_pT1_uid261_invPolyEval_cma_c0type(0 to 0);
    attribute preserve of prodXY_uid273_pT1_uid261_invPolyEval_cma_c0 : signal is true;
    type prodXY_uid273_pT1_uid261_invPolyEval_cma_ltype is array(NATURAL range <>) of SIGNED(13 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_l : prodXY_uid273_pT1_uid261_invPolyEval_cma_ltype(0 to 0);
    type prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype is array(NATURAL range <>) of SIGNED(26 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_p : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_u : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_w : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_x : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_y : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_s : prodXY_uid273_pT1_uid261_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_qq : STD_LOGIC_VECTOR (25 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_q : STD_LOGIC_VECTOR (25 downto 0);
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_ena0 : std_logic;
    signal prodXY_uid273_pT1_uid261_invPolyEval_cma_ena1 : std_logic;
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_reset : std_logic;
    type prodXY_uid276_pT2_uid267_invPolyEval_cma_a0type is array(NATURAL range <>) of UNSIGNED(17 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_a0 : prodXY_uid276_pT2_uid267_invPolyEval_cma_a0type(0 to 0);
    attribute preserve of prodXY_uid276_pT2_uid267_invPolyEval_cma_a0 : signal is true;
    type prodXY_uid276_pT2_uid267_invPolyEval_cma_c0type is array(NATURAL range <>) of SIGNED(22 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_c0 : prodXY_uid276_pT2_uid267_invPolyEval_cma_c0type(0 to 0);
    attribute preserve of prodXY_uid276_pT2_uid267_invPolyEval_cma_c0 : signal is true;
    type prodXY_uid276_pT2_uid267_invPolyEval_cma_ltype is array(NATURAL range <>) of SIGNED(18 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_l : prodXY_uid276_pT2_uid267_invPolyEval_cma_ltype(0 to 0);
    type prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype is array(NATURAL range <>) of SIGNED(41 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_p : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_u : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_w : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_x : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_y : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_s : prodXY_uid276_pT2_uid267_invPolyEval_cma_ptype(0 to 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_qq : STD_LOGIC_VECTOR (40 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_q : STD_LOGIC_VECTOR (40 downto 0);
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_ena0 : std_logic;
    signal prodXY_uid276_pT2_uid267_invPolyEval_cma_ena1 : std_logic;
    signal prod_uid53_fpCosPiTest_im0_cma_reset : std_logic;
    signal prod_uid53_fpCosPiTest_im0_cma_a0 : mul2xSinRes_uid122_fpCosPiTest_cma_a0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im0_cma_a0 : signal is true;
    type prod_uid53_fpCosPiTest_im0_cma_c0type is array(NATURAL range <>) of UNSIGNED(23 downto 0);
    signal prod_uid53_fpCosPiTest_im0_cma_c0 : prod_uid53_fpCosPiTest_im0_cma_c0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im0_cma_c0 : signal is true;
    type prod_uid53_fpCosPiTest_im0_cma_ptype is array(NATURAL range <>) of UNSIGNED(49 downto 0);
    signal prod_uid53_fpCosPiTest_im0_cma_p : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_u : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_w : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_x : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_y : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_s : prod_uid53_fpCosPiTest_im0_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im0_cma_qq : STD_LOGIC_VECTOR (49 downto 0);
    signal prod_uid53_fpCosPiTest_im0_cma_q : STD_LOGIC_VECTOR (49 downto 0);
    signal prod_uid53_fpCosPiTest_im0_cma_ena0 : std_logic;
    signal prod_uid53_fpCosPiTest_im0_cma_ena1 : std_logic;
    signal prod_uid53_fpCosPiTest_im3_cma_reset : std_logic;
    type prod_uid53_fpCosPiTest_im3_cma_a0type is array(NATURAL range <>) of UNSIGNED(26 downto 0);
    signal prod_uid53_fpCosPiTest_im3_cma_a0 : prod_uid53_fpCosPiTest_im3_cma_a0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im3_cma_a0 : signal is true;
    signal prod_uid53_fpCosPiTest_im3_cma_c0 : prod_uid53_fpCosPiTest_im0_cma_c0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im3_cma_c0 : signal is true;
    type prod_uid53_fpCosPiTest_im3_cma_ptype is array(NATURAL range <>) of UNSIGNED(50 downto 0);
    signal prod_uid53_fpCosPiTest_im3_cma_p : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_u : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_w : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_x : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_y : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_s : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im3_cma_qq : STD_LOGIC_VECTOR (50 downto 0);
    signal prod_uid53_fpCosPiTest_im3_cma_q : STD_LOGIC_VECTOR (50 downto 0);
    signal prod_uid53_fpCosPiTest_im3_cma_ena0 : std_logic;
    signal prod_uid53_fpCosPiTest_im3_cma_ena1 : std_logic;
    signal prod_uid53_fpCosPiTest_im6_cma_reset : std_logic;
    signal prod_uid53_fpCosPiTest_im6_cma_a0 : prod_uid53_fpCosPiTest_im3_cma_a0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im6_cma_a0 : signal is true;
    signal prod_uid53_fpCosPiTest_im6_cma_c0 : prod_uid53_fpCosPiTest_im0_cma_c0type(0 to 0);
    attribute preserve of prod_uid53_fpCosPiTest_im6_cma_c0 : signal is true;
    signal prod_uid53_fpCosPiTest_im6_cma_p : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_u : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_w : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_x : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_y : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_s : prod_uid53_fpCosPiTest_im3_cma_ptype(0 to 0);
    signal prod_uid53_fpCosPiTest_im6_cma_qq : STD_LOGIC_VECTOR (50 downto 0);
    signal prod_uid53_fpCosPiTest_im6_cma_q : STD_LOGIC_VECTOR (50 downto 0);
    signal prod_uid53_fpCosPiTest_im6_cma_ena0 : std_logic;
    signal prod_uid53_fpCosPiTest_im6_cma_ena1 : std_logic;
    signal prod_uid53_fpCosPiTest_bs1_merged_bit_select_b : STD_LOGIC_VECTOR (25 downto 0);
    signal prod_uid53_fpCosPiTest_bs1_merged_bit_select_c : STD_LOGIC_VECTOR (26 downto 0);
    signal prod_uid53_fpCosPiTest_bs1_merged_bit_select_d : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal exp_fpx_uid26_fpCosPiTest_merged_bit_select_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_fpx_uid26_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_fpx_uid26_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (22 downto 0);
    signal rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (31 downto 0);
    signal rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (31 downto 0);
    signal rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e : STD_LOGIC_VECTOR (0 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_b : STD_LOGIC_VECTOR (21 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c : STD_LOGIC_VECTOR (30 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_b : STD_LOGIC_VECTOR (72 downto 0);
    signal prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c : STD_LOGIC_VECTOR (4 downto 0);
    signal redist0_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist1_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist2_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist3_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist4_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (15 downto 0);
    signal redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (15 downto 0);
    signal redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist11_leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist17_prod_uid53_fpCosPiTest_im6_cma_q_1_q : STD_LOGIC_VECTOR (50 downto 0);
    signal redist18_prod_uid53_fpCosPiTest_im3_cma_q_1_q : STD_LOGIC_VECTOR (50 downto 0);
    signal redist19_prod_uid53_fpCosPiTest_im0_cma_q_1_q : STD_LOGIC_VECTOR (49 downto 0);
    signal redist20_prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q_1_q : STD_LOGIC_VECTOR (72 downto 0);
    signal redist21_memoryC0_uid248_sinXTables_lutmem_r_1_q : STD_LOGIC_VECTOR (29 downto 0);
    signal redist22_osig_uid277_pT2_uid267_invPolyEval_b_1_q : STD_LOGIC_VECTOR (23 downto 0);
    signal redist23_lowRangeB_uid262_invPolyEval_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist24_r_uid246_lzcZ_uid112_fpCosPiTest_q_5_q : STD_LOGIC_VECTOR (6 downto 0);
    signal redist25_vCount_uid233_lzcZ_uid112_fpCosPiTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist26_vCount_uid227_lzcZ_uid112_fpCosPiTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist27_vCount_uid221_lzcZ_uid112_fpCosPiTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist28_vCount_uid215_lzcZ_uid112_fpCosPiTest_q_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_vStage_uid209_lzcZ_uid112_fpCosPiTest_b_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_vCount_uid207_lzcZ_uid112_fpCosPiTest_q_5_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (63 downto 0);
    signal redist32_vCount_uid190_zCount_uid58_fpCosPiTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_vCount_uid184_zCount_uid58_fpCosPiTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_vCount_uid178_zCount_uid58_fpCosPiTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_vCount_uid172_zCount_uid58_fpCosPiTest_q_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_signR_uid164_fpCosPiTest_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist37_excRNaN_uid143_fpCosPiTest_q_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist38_excRNaN_uid143_fpCosPiTest_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist39_expRCosIsNeg_uid137_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist40_expRComp_uid135_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist41_fracRComp_uid134_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist42_normBit_uid123_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist43_fxpSinRes_uid121_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (25 downto 0);
    signal redist44_zPPolyEval_uid119_fpCosPiTest_b_3_q : STD_LOGIC_VECTOR (17 downto 0);
    signal redist45_yAddr_uid118_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist46_yAddr_uid118_fpCosPiTest_b_5_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist47_p_uid114_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (25 downto 0);
    signal redist48_z_uid110_fpCosPiTest_q_1_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist49_z_uid110_fpCosPiTest_q_2_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist50_z_uid110_fpCosPiTest_q_6_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist51_yBottom_uid109_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist52_oMyBottom_uid108_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist53_yIsHalf_uid98_fpCosPiTest_q_14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist54_y_uid91_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (65 downto 0);
    signal redist55_y_uid91_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (65 downto 0);
    signal redist56_intXParity_uid90_fpCosPiTest_b_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist59_cosXIsOne_uid88_fpCosPiTest_n_18_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist60_cosXIsOne_uid88_fpCosPiTest_n_31_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist61_signXRR_uid87_fpCosPiTest_b_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist63_fracXRR_uid71_fpCosPiTest_b_2_q : STD_LOGIC_VECTOR (52 downto 0);
    signal redist64_expXRR_uid70_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist65_intBit_uid57_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist67_expXTableAddr_uid44_fpCosPiTest_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist68_xBranch_uid42_fpCosPiTest_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist69_xBranch_uid42_fpCosPiTest_q_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist70_excR_x_uid19_fpCosPiTest_q_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist71_fracXIsZero_uid13_fpCosPiTest_q_19_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist72_expXIsMax_uid12_fpCosPiTest_q_19_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist73_excZ_x_uid11_fpCosPiTest_q_19_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_reset0 : std_logic;
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_aa : STD_LOGIC_VECTOR (3 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ab : STD_LOGIC_VECTOR (3 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i : UNSIGNED (3 downto 0);
    attribute preserve of redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i : signal is true;
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq : std_logic;
    attribute preserve of redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq : signal is true;
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_last_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_b : STD_LOGIC_VECTOR (4 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge : boolean;
    attribute dont_merge of redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q : signal is true;
    signal redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_reset0 : std_logic;
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i : signal is true;
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge of redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q : signal is true;
    signal redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist44_zPPolyEval_uid119_fpCosPiTest_b_3_inputreg_q : STD_LOGIC_VECTOR (17 downto 0);
    signal redist50_z_uid110_fpCosPiTest_q_6_inputreg_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist50_z_uid110_fpCosPiTest_q_6_outputreg_q : STD_LOGIC_VECTOR (64 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q : STD_LOGIC_VECTOR (77 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_reset0 : std_logic;
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ia : STD_LOGIC_VECTOR (77 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_aa : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ab : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_iq : STD_LOGIC_VECTOR (77 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_q : STD_LOGIC_VECTOR (77 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i : UNSIGNED (0 downto 0);
    attribute preserve of redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i : signal is true;
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge of redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q : signal is true;
    signal redist66_multFracBits_uid54_fpCosPiTest_b_4_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_notEnable(LOGICAL,544)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_nor(LOGICAL,545)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_nor_q <= not (redist66_multFracBits_uid54_fpCosPiTest_b_4_notEnable_q or redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q);

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg(REG,543)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg_q <= STD_LOGIC_VECTOR(VCC_q);
        END IF;
    END PROCESS;

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena(REG,546)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist66_multFracBits_uid54_fpCosPiTest_b_4_nor_q = "1") THEN
                redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q <= STD_LOGIC_VECTOR(redist66_multFracBits_uid54_fpCosPiTest_b_4_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_enaAnd(LOGICAL,547)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_enaAnd_q <= redist66_multFracBits_uid54_fpCosPiTest_b_4_sticky_ena_q and VCC_q;

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt(COUNTER,541)
    -- low=0, high=1, step=1, init=0
    redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i <= TO_UNSIGNED(0, 1);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i <= redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_i, 1)));

    -- expFracX_uid167_px_uid21_fpCosPiTest(BITSELECT,166)@0
    expFracX_uid167_px_uid21_fpCosPiTest_b <= a(30 downto 0);

    -- R_uid168_px_uid21_fpCosPiTest(BITJOIN,167)@0
    R_uid168_px_uid21_fpCosPiTest_q <= GND_q & expFracX_uid167_px_uid21_fpCosPiTest_b;

    -- exp_fpx_uid26_fpCosPiTest_merged_bit_select(BITSELECT,426)@0
    exp_fpx_uid26_fpCosPiTest_merged_bit_select_in <= R_uid168_px_uid21_fpCosPiTest_q(30 downto 0);
    exp_fpx_uid26_fpCosPiTest_merged_bit_select_b <= exp_fpx_uid26_fpCosPiTest_merged_bit_select_in(30 downto 23);
    exp_fpx_uid26_fpCosPiTest_merged_bit_select_c <= exp_fpx_uid26_fpCosPiTest_merged_bit_select_in(22 downto 0);

    -- redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3(DELAY,455)
    redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3 : dspba_delay
    GENERIC MAP ( width => 23, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => exp_fpx_uid26_fpCosPiTest_merged_bit_select_c, xout => redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3_q, clk => clk, aclr => areset );

    -- oFracX_uid52_fpCosPiTest(BITJOIN,51)@3
    oFracX_uid52_fpCosPiTest_q <= VCC_q & redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3_q;

    -- cstAllZWE_uid8_fpCosPiTest(CONSTANT,7)
    cstAllZWE_uid8_fpCosPiTest_q <= "00000000";

    -- excZ_fpx_uid22_uid28_fpCosPiTest(LOGICAL,27)@0 + 1
    excZ_fpx_uid22_uid28_fpCosPiTest_qi <= "1" WHEN exp_fpx_uid26_fpCosPiTest_merged_bit_select_b = cstAllZWE_uid8_fpCosPiTest_q ELSE "0";
    excZ_fpx_uid22_uid28_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_fpx_uid22_uid28_fpCosPiTest_qi, xout => excZ_fpx_uid22_uid28_fpCosPiTest_q, clk => clk, aclr => areset );

    -- cstZeroWF_uid7_fpCosPiTest(CONSTANT,6)
    cstZeroWF_uid7_fpCosPiTest_q <= "00000000000000000000000";

    -- fracXIsZero_uid30_fpCosPiTest(LOGICAL,29)@0
    fracXIsZero_uid30_fpCosPiTest_q <= "1" WHEN cstZeroWF_uid7_fpCosPiTest_q = exp_fpx_uid26_fpCosPiTest_merged_bit_select_c ELSE "0";

    -- cstAllOWE_uid6_fpCosPiTest(CONSTANT,5)
    cstAllOWE_uid6_fpCosPiTest_q <= "11111111";

    -- expXIsMax_uid29_fpCosPiTest(LOGICAL,28)@0
    expXIsMax_uid29_fpCosPiTest_q <= "1" WHEN exp_fpx_uid26_fpCosPiTest_merged_bit_select_b = cstAllOWE_uid6_fpCosPiTest_q ELSE "0";

    -- excI_fpx_uid32_fpCosPiTest(LOGICAL,31)@0 + 1
    excI_fpx_uid32_fpCosPiTest_qi <= expXIsMax_uid29_fpCosPiTest_q and fracXIsZero_uid30_fpCosPiTest_q;
    excI_fpx_uid32_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_fpx_uid32_fpCosPiTest_qi, xout => excI_fpx_uid32_fpCosPiTest_q, clk => clk, aclr => areset );

    -- cwFo2_uid39_fpCosPiTest(CONSTANT,38)
    cwFo2_uid39_fpCosPiTest_q <= "01110011";

    -- xBranch0_uid41_fpCosPiTest(COMPARE,40)@0 + 1
    xBranch0_uid41_fpCosPiTest_a <= STD_LOGIC_VECTOR("00" & cwFo2_uid39_fpCosPiTest_q);
    xBranch0_uid41_fpCosPiTest_b <= STD_LOGIC_VECTOR("00" & exp_fpx_uid26_fpCosPiTest_merged_bit_select_b);
    xBranch0_uid41_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            xBranch0_uid41_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            xBranch0_uid41_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(xBranch0_uid41_fpCosPiTest_a) - UNSIGNED(xBranch0_uid41_fpCosPiTest_b));
        END IF;
    END PROCESS;
    xBranch0_uid41_fpCosPiTest_n(0) <= not (xBranch0_uid41_fpCosPiTest_o(9));

    -- xBranch_uid42_fpCosPiTest(LOGICAL,41)@1
    xBranch_uid42_fpCosPiTest_q <= xBranch0_uid41_fpCosPiTest_n or excI_fpx_uid32_fpCosPiTest_q or excZ_fpx_uid22_uid28_fpCosPiTest_q;

    -- invXBranch_uid45_fpCosPiTest(LOGICAL,44)@1
    invXBranch_uid45_fpCosPiTest_q <= not (xBranch_uid42_fpCosPiTest_q);

    -- expXTableAddrExt_uid43_fpCosPiTest(SUB,42)@0
    expXTableAddrExt_uid43_fpCosPiTest_a <= STD_LOGIC_VECTOR("0" & exp_fpx_uid26_fpCosPiTest_merged_bit_select_b);
    expXTableAddrExt_uid43_fpCosPiTest_b <= STD_LOGIC_VECTOR("0" & cwFo2_uid39_fpCosPiTest_q);
    expXTableAddrExt_uid43_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expXTableAddrExt_uid43_fpCosPiTest_a) - UNSIGNED(expXTableAddrExt_uid43_fpCosPiTest_b));
    expXTableAddrExt_uid43_fpCosPiTest_q <= expXTableAddrExt_uid43_fpCosPiTest_o(8 downto 0);

    -- expXTableAddr_uid44_fpCosPiTest(BITSELECT,43)@0
    expXTableAddr_uid44_fpCosPiTest_in <= expXTableAddrExt_uid43_fpCosPiTest_q(7 downto 0);
    expXTableAddr_uid44_fpCosPiTest_b <= expXTableAddr_uid44_fpCosPiTest_in(7 downto 0);

    -- redist67_expXTableAddr_uid44_fpCosPiTest_b_1(DELAY,507)
    redist67_expXTableAddr_uid44_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXTableAddr_uid44_fpCosPiTest_b, xout => redist67_expXTableAddr_uid44_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- expXTableAddrPost_uid46_fpCosPiTest(LOGICAL,45)@1
    expXTableAddrPost_uid46_fpCosPiTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((7 downto 1 => invXBranch_uid45_fpCosPiTest_q(0)) & invXBranch_uid45_fpCosPiTest_q));
    expXTableAddrPost_uid46_fpCosPiTest_q <= redist67_expXTableAddr_uid44_fpCosPiTest_b_1_q and expXTableAddrPost_uid46_fpCosPiTest_b;

    -- rrTable_uid48_fpCosPiTest_lutmem(DUALMEM,279)@1 + 2
    -- in j@20000000
    rrTable_uid48_fpCosPiTest_lutmem_aa <= expXTableAddrPost_uid46_fpCosPiTest_q;
    rrTable_uid48_fpCosPiTest_lutmem_reset0 <= areset;
    rrTable_uid48_fpCosPiTest_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 40,
        widthad_a => 8,
        numwords_a => 141,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPFCos_0002_rrTable_uid48_fpCosPiTest_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => rrTable_uid48_fpCosPiTest_lutmem_reset0,
        clock0 => clk,
        address_a => rrTable_uid48_fpCosPiTest_lutmem_aa,
        q_a => rrTable_uid48_fpCosPiTest_lutmem_ir
    );
    rrTable_uid48_fpCosPiTest_lutmem_r <= rrTable_uid48_fpCosPiTest_lutmem_ir(39 downto 0);

    -- rrTable_uid47_fpCosPiTest_lutmem(DUALMEM,278)@1 + 2
    -- in j@20000000
    rrTable_uid47_fpCosPiTest_lutmem_aa <= expXTableAddrPost_uid46_fpCosPiTest_q;
    rrTable_uid47_fpCosPiTest_lutmem_reset0 <= areset;
    rrTable_uid47_fpCosPiTest_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 40,
        widthad_a => 8,
        numwords_a => 141,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPFCos_0002_rrTable_uid47_fpCosPiTest_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => rrTable_uid47_fpCosPiTest_lutmem_reset0,
        clock0 => clk,
        address_a => rrTable_uid47_fpCosPiTest_lutmem_aa,
        q_a => rrTable_uid47_fpCosPiTest_lutmem_ir
    );
    rrTable_uid47_fpCosPiTest_lutmem_r <= rrTable_uid47_fpCosPiTest_lutmem_ir(39 downto 0);

    -- os_uid49_fpCosPiTest(BITJOIN,48)@3
    os_uid49_fpCosPiTest_q <= rrTable_uid48_fpCosPiTest_lutmem_r & rrTable_uid47_fpCosPiTest_lutmem_r;

    -- prod_uid53_fpCosPiTest_bs1_merged_bit_select(BITSELECT,424)@3
    prod_uid53_fpCosPiTest_bs1_merged_bit_select_b <= os_uid49_fpCosPiTest_q(79 downto 54);
    prod_uid53_fpCosPiTest_bs1_merged_bit_select_c <= os_uid49_fpCosPiTest_q(53 downto 27);
    prod_uid53_fpCosPiTest_bs1_merged_bit_select_d <= os_uid49_fpCosPiTest_q(26 downto 0);

    -- prod_uid53_fpCosPiTest_im3_cma(CHAINMULTADD,422)@3 + 2
    prod_uid53_fpCosPiTest_im3_cma_reset <= areset;
    prod_uid53_fpCosPiTest_im3_cma_ena0 <= '1';
    prod_uid53_fpCosPiTest_im3_cma_ena1 <= prod_uid53_fpCosPiTest_im3_cma_ena0;
    prod_uid53_fpCosPiTest_im3_cma_p(0) <= prod_uid53_fpCosPiTest_im3_cma_a0(0) * prod_uid53_fpCosPiTest_im3_cma_c0(0);
    prod_uid53_fpCosPiTest_im3_cma_u(0) <= RESIZE(prod_uid53_fpCosPiTest_im3_cma_p(0),51);
    prod_uid53_fpCosPiTest_im3_cma_w(0) <= prod_uid53_fpCosPiTest_im3_cma_u(0);
    prod_uid53_fpCosPiTest_im3_cma_x(0) <= prod_uid53_fpCosPiTest_im3_cma_w(0);
    prod_uid53_fpCosPiTest_im3_cma_y(0) <= prod_uid53_fpCosPiTest_im3_cma_x(0);
    prod_uid53_fpCosPiTest_im3_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im3_cma_a0 <= (others => (others => '0'));
            prod_uid53_fpCosPiTest_im3_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im3_cma_ena0 = '1') THEN
                prod_uid53_fpCosPiTest_im3_cma_a0(0) <= RESIZE(UNSIGNED(prod_uid53_fpCosPiTest_bs1_merged_bit_select_c),27);
                prod_uid53_fpCosPiTest_im3_cma_c0(0) <= RESIZE(UNSIGNED(oFracX_uid52_fpCosPiTest_q),24);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im3_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im3_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im3_cma_ena1 = '1') THEN
                prod_uid53_fpCosPiTest_im3_cma_s(0) <= prod_uid53_fpCosPiTest_im3_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im3_cma_delay : dspba_delay
    GENERIC MAP ( width => 51, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im3_cma_s(0)(50 downto 0)), xout => prod_uid53_fpCosPiTest_im3_cma_qq, clk => clk, aclr => areset );
    prod_uid53_fpCosPiTest_im3_cma_q <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im3_cma_qq(50 downto 0));

    -- redist18_prod_uid53_fpCosPiTest_im3_cma_q_1(DELAY,458)
    redist18_prod_uid53_fpCosPiTest_im3_cma_q_1 : dspba_delay
    GENERIC MAP ( width => 51, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_im3_cma_q, xout => redist18_prod_uid53_fpCosPiTest_im3_cma_q_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_align_11(BITSHIFT,291)@6
    prod_uid53_fpCosPiTest_align_11_qint <= redist18_prod_uid53_fpCosPiTest_im3_cma_q_1_q & "000000000000000000000000000";
    prod_uid53_fpCosPiTest_align_11_q <= prod_uid53_fpCosPiTest_align_11_qint(77 downto 0);

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select(BITSELECT,439)@6
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_b <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_align_11_q(72 downto 0));
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_align_11_q(77 downto 73));

    -- prod_uid53_fpCosPiTest_im0_cma(CHAINMULTADD,421)@3 + 2
    prod_uid53_fpCosPiTest_im0_cma_reset <= areset;
    prod_uid53_fpCosPiTest_im0_cma_ena0 <= '1';
    prod_uid53_fpCosPiTest_im0_cma_ena1 <= prod_uid53_fpCosPiTest_im0_cma_ena0;
    prod_uid53_fpCosPiTest_im0_cma_p(0) <= prod_uid53_fpCosPiTest_im0_cma_a0(0) * prod_uid53_fpCosPiTest_im0_cma_c0(0);
    prod_uid53_fpCosPiTest_im0_cma_u(0) <= RESIZE(prod_uid53_fpCosPiTest_im0_cma_p(0),50);
    prod_uid53_fpCosPiTest_im0_cma_w(0) <= prod_uid53_fpCosPiTest_im0_cma_u(0);
    prod_uid53_fpCosPiTest_im0_cma_x(0) <= prod_uid53_fpCosPiTest_im0_cma_w(0);
    prod_uid53_fpCosPiTest_im0_cma_y(0) <= prod_uid53_fpCosPiTest_im0_cma_x(0);
    prod_uid53_fpCosPiTest_im0_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im0_cma_a0 <= (others => (others => '0'));
            prod_uid53_fpCosPiTest_im0_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im0_cma_ena0 = '1') THEN
                prod_uid53_fpCosPiTest_im0_cma_a0(0) <= RESIZE(UNSIGNED(prod_uid53_fpCosPiTest_bs1_merged_bit_select_b),26);
                prod_uid53_fpCosPiTest_im0_cma_c0(0) <= RESIZE(UNSIGNED(oFracX_uid52_fpCosPiTest_q),24);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im0_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im0_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im0_cma_ena1 = '1') THEN
                prod_uid53_fpCosPiTest_im0_cma_s(0) <= prod_uid53_fpCosPiTest_im0_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im0_cma_delay : dspba_delay
    GENERIC MAP ( width => 50, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im0_cma_s(0)(49 downto 0)), xout => prod_uid53_fpCosPiTest_im0_cma_qq, clk => clk, aclr => areset );
    prod_uid53_fpCosPiTest_im0_cma_q <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im0_cma_qq(49 downto 0));

    -- redist19_prod_uid53_fpCosPiTest_im0_cma_q_1(DELAY,459)
    redist19_prod_uid53_fpCosPiTest_im0_cma_q_1 : dspba_delay
    GENERIC MAP ( width => 50, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_im0_cma_q, xout => redist19_prod_uid53_fpCosPiTest_im0_cma_q_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_align_9(BITSHIFT,289)@6
    prod_uid53_fpCosPiTest_align_9_qint <= redist19_prod_uid53_fpCosPiTest_im0_cma_q_1_q & "000";
    prod_uid53_fpCosPiTest_align_9_q <= prod_uid53_fpCosPiTest_align_9_qint(52 downto 0);

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select(BITSELECT,438)@6
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_b <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_align_9_q(21 downto 0));
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_align_9_q(52 downto 22));

    -- prod_uid53_fpCosPiTest_im6_cma(CHAINMULTADD,423)@3 + 2
    prod_uid53_fpCosPiTest_im6_cma_reset <= areset;
    prod_uid53_fpCosPiTest_im6_cma_ena0 <= '1';
    prod_uid53_fpCosPiTest_im6_cma_ena1 <= prod_uid53_fpCosPiTest_im6_cma_ena0;
    prod_uid53_fpCosPiTest_im6_cma_p(0) <= prod_uid53_fpCosPiTest_im6_cma_a0(0) * prod_uid53_fpCosPiTest_im6_cma_c0(0);
    prod_uid53_fpCosPiTest_im6_cma_u(0) <= RESIZE(prod_uid53_fpCosPiTest_im6_cma_p(0),51);
    prod_uid53_fpCosPiTest_im6_cma_w(0) <= prod_uid53_fpCosPiTest_im6_cma_u(0);
    prod_uid53_fpCosPiTest_im6_cma_x(0) <= prod_uid53_fpCosPiTest_im6_cma_w(0);
    prod_uid53_fpCosPiTest_im6_cma_y(0) <= prod_uid53_fpCosPiTest_im6_cma_x(0);
    prod_uid53_fpCosPiTest_im6_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im6_cma_a0 <= (others => (others => '0'));
            prod_uid53_fpCosPiTest_im6_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im6_cma_ena0 = '1') THEN
                prod_uid53_fpCosPiTest_im6_cma_a0(0) <= RESIZE(UNSIGNED(prod_uid53_fpCosPiTest_bs1_merged_bit_select_d),27);
                prod_uid53_fpCosPiTest_im6_cma_c0(0) <= RESIZE(UNSIGNED(oFracX_uid52_fpCosPiTest_q),24);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im6_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_im6_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prod_uid53_fpCosPiTest_im6_cma_ena1 = '1') THEN
                prod_uid53_fpCosPiTest_im6_cma_s(0) <= prod_uid53_fpCosPiTest_im6_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_im6_cma_delay : dspba_delay
    GENERIC MAP ( width => 51, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im6_cma_s(0)(50 downto 0)), xout => prod_uid53_fpCosPiTest_im6_cma_qq, clk => clk, aclr => areset );
    prod_uid53_fpCosPiTest_im6_cma_q <= STD_LOGIC_VECTOR(prod_uid53_fpCosPiTest_im6_cma_qq(50 downto 0));

    -- redist17_prod_uid53_fpCosPiTest_im6_cma_q_1(DELAY,457)
    redist17_prod_uid53_fpCosPiTest_im6_cma_q_1 : dspba_delay
    GENERIC MAP ( width => 51, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_im6_cma_q, xout => redist17_prod_uid53_fpCosPiTest_im6_cma_q_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_b(BITJOIN,409)@6
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_b_q <= prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_b & redist17_prod_uid53_fpCosPiTest_im6_cma_q_1_q;

    -- prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2(ADD,404)@6 + 1
    prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_a <= STD_LOGIC_VECTOR("0" & prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_b_q);
    prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_b <= STD_LOGIC_VECTOR("0" & prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_b);
    prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_o <= STD_LOGIC_VECTOR(UNSIGNED(prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_a) + UNSIGNED(prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_b));
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_c(0) <= prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_o(73);
    prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q <= prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_o(72 downto 0);

    -- prod_uid53_fpCosPiTest_result_add_0_0_UpperBits_for_b(CONSTANT,401)
    prod_uid53_fpCosPiTest_result_add_0_0_UpperBits_for_b_q <= "000000000000000000000000000";

    -- redist0_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c_1(DELAY,440)
    redist0_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 5, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c, xout => redist0_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_BitJoin_for_c(BITJOIN,417)@7
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_BitJoin_for_c_q <= prod_uid53_fpCosPiTest_result_add_0_0_UpperBits_for_b_q & redist0_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_tessel0_0_merged_bit_select_c_1_q;

    -- redist1_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c_1(DELAY,441)
    redist1_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c, xout => redist1_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_c(BITJOIN,412)@7
    prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_c_q <= GND_q & redist1_prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_tessel0_1_merged_bit_select_c_1_q;

    -- prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2(ADD,405)@7 + 1
    prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_cin <= prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_c;
    prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_a <= STD_LOGIC_VECTOR("0" & prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_a_BitJoin_for_c_q) & '1';
    prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_b <= STD_LOGIC_VECTOR("0" & prod_uid53_fpCosPiTest_result_add_0_0_BitSelect_for_b_BitJoin_for_c_q) & prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_cin(0);
    prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_o <= STD_LOGIC_VECTOR(UNSIGNED(prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_a) + UNSIGNED(prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_b));
        END IF;
    END PROCESS;
    prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_q <= prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_o(32 downto 1);

    -- redist20_prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q_1(DELAY,460)
    redist20_prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q_1 : dspba_delay
    GENERIC MAP ( width => 73, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q, xout => redist20_prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q_1_q, clk => clk, aclr => areset );

    -- prod_uid53_fpCosPiTest_result_add_0_0_BitJoin_for_q(BITJOIN,406)@8
    prod_uid53_fpCosPiTest_result_add_0_0_BitJoin_for_q_q <= prod_uid53_fpCosPiTest_result_add_0_0_p2_of_2_q & redist20_prod_uid53_fpCosPiTest_result_add_0_0_p1_of_2_q_1_q;

    -- multFracBits_uid54_fpCosPiTest(BITSELECT,53)@8
    multFracBits_uid54_fpCosPiTest_in <= prod_uid53_fpCosPiTest_result_add_0_0_BitJoin_for_q_q(77 downto 0);
    multFracBits_uid54_fpCosPiTest_b <= multFracBits_uid54_fpCosPiTest_in(77 downto 0);

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr(REG,542)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr_q <= "1";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr_q <= STD_LOGIC_VECTOR(redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_mem(DUALMEM,540)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ia <= STD_LOGIC_VECTOR(multFracBits_uid54_fpCosPiTest_b);
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_aa <= redist66_multFracBits_uid54_fpCosPiTest_b_4_wraddr_q;
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ab <= redist66_multFracBits_uid54_fpCosPiTest_b_4_rdcnt_q;
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_reset0 <= areset;
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 78,
        widthad_a => 1,
        numwords_a => 2,
        width_b => 78,
        widthad_b => 1,
        numwords_b => 2,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist66_multFracBits_uid54_fpCosPiTest_b_4_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_reset0,
        clock1 => clk,
        address_a => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_aa,
        data_a => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_ab,
        q_b => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_iq
    );
    redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_q <= redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_iq(77 downto 0);

    -- redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg(DELAY,539)
    redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg : dspba_delay
    GENERIC MAP ( width => 78, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist66_multFracBits_uid54_fpCosPiTest_b_4_mem_q, xout => redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q, clk => clk, aclr => areset );

    -- intBit_uid57_fpCosPiTest(BITSELECT,56)@12
    intBit_uid57_fpCosPiTest_b <= STD_LOGIC_VECTOR(redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q(77 downto 77));

    -- redist65_intBit_uid57_fpCosPiTest_b_1(DELAY,505)
    redist65_intBit_uid57_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => intBit_uid57_fpCosPiTest_b, xout => redist65_intBit_uid57_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_notEnable(LOGICAL,521)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_nor(LOGICAL,522)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_nor_q <= not (redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_notEnable_q or redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q);

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_last(CONSTANT,518)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_last_q <= "01000";

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp(LOGICAL,519)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_b <= STD_LOGIC_VECTOR("0" & redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_q);
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_q <= "1" WHEN redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_last_q = redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_b ELSE "0";

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg(REG,520)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg_q <= STD_LOGIC_VECTOR(redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmp_q);
        END IF;
    END PROCESS;

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena(REG,523)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_nor_q = "1") THEN
                redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q <= STD_LOGIC_VECTOR(redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_enaAnd(LOGICAL,524)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_enaAnd_q <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_sticky_ena_q and VCC_q;

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt(COUNTER,516)
    -- low=0, high=9, step=1, init=0
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i <= TO_UNSIGNED(0, 4);
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i = TO_UNSIGNED(8, 4)) THEN
                redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq <= '1';
            ELSE
                redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq <= '0';
            END IF;
            IF (redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_eq = '1') THEN
                redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i + 7;
            ELSE
                redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_i, 4)));

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr(REG,517)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr_q <= "1001";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr_q <= STD_LOGIC_VECTOR(redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem(DUALMEM,515)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ia <= STD_LOGIC_VECTOR(exp_fpx_uid26_fpCosPiTest_merged_bit_select_b);
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_aa <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_wraddr_q;
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ab <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_rdcnt_q;
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_reset0 <= areset;
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 4,
        numwords_a => 10,
        width_b => 8,
        widthad_b => 4,
        numwords_b => 10,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_reset0,
        clock1 => clk,
        address_a => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_aa,
        data_a => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_ab,
        q_b => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_iq
    );
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_q <= redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_iq(7 downto 0);

    -- redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_outputreg(DELAY,514)
    redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_mem_q, xout => redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_outputreg_q, clk => clk, aclr => areset );

    -- redist68_xBranch_uid42_fpCosPiTest_q_11(DELAY,508)
    redist68_xBranch_uid42_fpCosPiTest_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => xBranch_uid42_fpCosPiTest_q, xout => redist68_xBranch_uid42_fpCosPiTest_q_11_q, clk => clk, aclr => areset );

    -- zs_uid170_zCount_uid58_fpCosPiTest(CONSTANT,169)
    zs_uid170_zCount_uid58_fpCosPiTest_q <= "00000000000000000000000000000000";

    -- multFracBitsTopLow_uid55_fpCosPiTest(BITSELECT,54)@8
    multFracBitsTopLow_uid55_fpCosPiTest_in <= multFracBits_uid54_fpCosPiTest_b(76 downto 0);
    multFracBitsTopLow_uid55_fpCosPiTest_b <= multFracBitsTopLow_uid55_fpCosPiTest_in(76 downto 46);

    -- multFracBitsTop_uid56_fpCosPiTest(BITJOIN,55)@8
    multFracBitsTop_uid56_fpCosPiTest_q <= GND_q & multFracBitsTopLow_uid55_fpCosPiTest_b;

    -- vCount_uid172_zCount_uid58_fpCosPiTest(LOGICAL,171)@8
    vCount_uid172_zCount_uid58_fpCosPiTest_q <= "1" WHEN multFracBitsTop_uid56_fpCosPiTest_q = zs_uid170_zCount_uid58_fpCosPiTest_q ELSE "0";

    -- redist35_vCount_uid172_zCount_uid58_fpCosPiTest_q_4(DELAY,475)
    redist35_vCount_uid172_zCount_uid58_fpCosPiTest_q_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid172_zCount_uid58_fpCosPiTest_q, xout => redist35_vCount_uid172_zCount_uid58_fpCosPiTest_q_4_q, clk => clk, aclr => areset );

    -- zs_uid176_zCount_uid58_fpCosPiTest(CONSTANT,175)
    zs_uid176_zCount_uid58_fpCosPiTest_q <= "0000000000000000";

    -- mO_uid173_zCount_uid58_fpCosPiTest(CONSTANT,172)
    mO_uid173_zCount_uid58_fpCosPiTest_q <= "11111111111111111111111111111111";

    -- vStagei_uid175_zCount_uid58_fpCosPiTest(MUX,174)@8 + 1
    vStagei_uid175_zCount_uid58_fpCosPiTest_s <= vCount_uid172_zCount_uid58_fpCosPiTest_q;
    vStagei_uid175_zCount_uid58_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid175_zCount_uid58_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid175_zCount_uid58_fpCosPiTest_s) IS
                WHEN "0" => vStagei_uid175_zCount_uid58_fpCosPiTest_q <= multFracBitsTop_uid56_fpCosPiTest_q;
                WHEN "1" => vStagei_uid175_zCount_uid58_fpCosPiTest_q <= mO_uid173_zCount_uid58_fpCosPiTest_q;
                WHEN OTHERS => vStagei_uid175_zCount_uid58_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select(BITSELECT,427)@9
    rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_b <= vStagei_uid175_zCount_uid58_fpCosPiTest_q(31 downto 16);
    rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_c <= vStagei_uid175_zCount_uid58_fpCosPiTest_q(15 downto 0);

    -- vCount_uid178_zCount_uid58_fpCosPiTest(LOGICAL,177)@9
    vCount_uid178_zCount_uid58_fpCosPiTest_q <= "1" WHEN rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_b = zs_uid176_zCount_uid58_fpCosPiTest_q ELSE "0";

    -- redist34_vCount_uid178_zCount_uid58_fpCosPiTest_q_3(DELAY,474)
    redist34_vCount_uid178_zCount_uid58_fpCosPiTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid178_zCount_uid58_fpCosPiTest_q, xout => redist34_vCount_uid178_zCount_uid58_fpCosPiTest_q_3_q, clk => clk, aclr => areset );

    -- vStagei_uid181_zCount_uid58_fpCosPiTest(MUX,180)@9 + 1
    vStagei_uid181_zCount_uid58_fpCosPiTest_s <= vCount_uid178_zCount_uid58_fpCosPiTest_q;
    vStagei_uid181_zCount_uid58_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid181_zCount_uid58_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid181_zCount_uid58_fpCosPiTest_s) IS
                WHEN "0" => vStagei_uid181_zCount_uid58_fpCosPiTest_q <= rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_b;
                WHEN "1" => vStagei_uid181_zCount_uid58_fpCosPiTest_q <= rVStage_uid177_zCount_uid58_fpCosPiTest_merged_bit_select_c;
                WHEN OTHERS => vStagei_uid181_zCount_uid58_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select(BITSELECT,428)@10
    rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_b <= vStagei_uid181_zCount_uid58_fpCosPiTest_q(15 downto 8);
    rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_c <= vStagei_uid181_zCount_uid58_fpCosPiTest_q(7 downto 0);

    -- vCount_uid184_zCount_uid58_fpCosPiTest(LOGICAL,183)@10
    vCount_uid184_zCount_uid58_fpCosPiTest_q <= "1" WHEN rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_b = cstAllZWE_uid8_fpCosPiTest_q ELSE "0";

    -- redist33_vCount_uid184_zCount_uid58_fpCosPiTest_q_2(DELAY,473)
    redist33_vCount_uid184_zCount_uid58_fpCosPiTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid184_zCount_uid58_fpCosPiTest_q, xout => redist33_vCount_uid184_zCount_uid58_fpCosPiTest_q_2_q, clk => clk, aclr => areset );

    -- zs_uid188_zCount_uid58_fpCosPiTest(CONSTANT,187)
    zs_uid188_zCount_uid58_fpCosPiTest_q <= "0000";

    -- vStagei_uid187_zCount_uid58_fpCosPiTest(MUX,186)@10 + 1
    vStagei_uid187_zCount_uid58_fpCosPiTest_s <= vCount_uid184_zCount_uid58_fpCosPiTest_q;
    vStagei_uid187_zCount_uid58_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid187_zCount_uid58_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid187_zCount_uid58_fpCosPiTest_s) IS
                WHEN "0" => vStagei_uid187_zCount_uid58_fpCosPiTest_q <= rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_b;
                WHEN "1" => vStagei_uid187_zCount_uid58_fpCosPiTest_q <= rVStage_uid183_zCount_uid58_fpCosPiTest_merged_bit_select_c;
                WHEN OTHERS => vStagei_uid187_zCount_uid58_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select(BITSELECT,429)@11
    rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_b <= vStagei_uid187_zCount_uid58_fpCosPiTest_q(7 downto 4);
    rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_c <= vStagei_uid187_zCount_uid58_fpCosPiTest_q(3 downto 0);

    -- vCount_uid190_zCount_uid58_fpCosPiTest(LOGICAL,189)@11
    vCount_uid190_zCount_uid58_fpCosPiTest_q <= "1" WHEN rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_b = zs_uid188_zCount_uid58_fpCosPiTest_q ELSE "0";

    -- redist32_vCount_uid190_zCount_uid58_fpCosPiTest_q_1(DELAY,472)
    redist32_vCount_uid190_zCount_uid58_fpCosPiTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid190_zCount_uid58_fpCosPiTest_q, xout => redist32_vCount_uid190_zCount_uid58_fpCosPiTest_q_1_q, clk => clk, aclr => areset );

    -- zs_uid194_zCount_uid58_fpCosPiTest(CONSTANT,193)
    zs_uid194_zCount_uid58_fpCosPiTest_q <= "00";

    -- vStagei_uid193_zCount_uid58_fpCosPiTest(MUX,192)@11
    vStagei_uid193_zCount_uid58_fpCosPiTest_s <= vCount_uid190_zCount_uid58_fpCosPiTest_q;
    vStagei_uid193_zCount_uid58_fpCosPiTest_combproc: PROCESS (vStagei_uid193_zCount_uid58_fpCosPiTest_s, rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_b, rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid193_zCount_uid58_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid193_zCount_uid58_fpCosPiTest_q <= rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid193_zCount_uid58_fpCosPiTest_q <= rVStage_uid189_zCount_uid58_fpCosPiTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid193_zCount_uid58_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select(BITSELECT,430)@11
    rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b <= vStagei_uid193_zCount_uid58_fpCosPiTest_q(3 downto 2);
    rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c <= vStagei_uid193_zCount_uid58_fpCosPiTest_q(1 downto 0);

    -- vCount_uid196_zCount_uid58_fpCosPiTest(LOGICAL,195)@11 + 1
    vCount_uid196_zCount_uid58_fpCosPiTest_qi <= "1" WHEN rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b = zs_uid194_zCount_uid58_fpCosPiTest_q ELSE "0";
    vCount_uid196_zCount_uid58_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid196_zCount_uid58_fpCosPiTest_qi, xout => vCount_uid196_zCount_uid58_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1(DELAY,453)
    redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c, xout => redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1(DELAY,452)
    redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b, xout => redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid199_zCount_uid58_fpCosPiTest(MUX,198)@12
    vStagei_uid199_zCount_uid58_fpCosPiTest_s <= vCount_uid196_zCount_uid58_fpCosPiTest_q;
    vStagei_uid199_zCount_uid58_fpCosPiTest_combproc: PROCESS (vStagei_uid199_zCount_uid58_fpCosPiTest_s, redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1_q, redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid199_zCount_uid58_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid199_zCount_uid58_fpCosPiTest_q <= redist12_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid199_zCount_uid58_fpCosPiTest_q <= redist13_rVStage_uid195_zCount_uid58_fpCosPiTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid199_zCount_uid58_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid201_zCount_uid58_fpCosPiTest(BITSELECT,200)@12
    rVStage_uid201_zCount_uid58_fpCosPiTest_b <= vStagei_uid199_zCount_uid58_fpCosPiTest_q(1 downto 1);

    -- vCount_uid202_zCount_uid58_fpCosPiTest(LOGICAL,201)@12
    vCount_uid202_zCount_uid58_fpCosPiTest_q <= "1" WHEN rVStage_uid201_zCount_uid58_fpCosPiTest_b = GND_q ELSE "0";

    -- r_uid203_zCount_uid58_fpCosPiTest(BITJOIN,202)@12
    r_uid203_zCount_uid58_fpCosPiTest_q <= redist35_vCount_uid172_zCount_uid58_fpCosPiTest_q_4_q & redist34_vCount_uid178_zCount_uid58_fpCosPiTest_q_3_q & redist33_vCount_uid184_zCount_uid58_fpCosPiTest_q_2_q & redist32_vCount_uid190_zCount_uid58_fpCosPiTest_q_1_q & vCount_uid196_zCount_uid58_fpCosPiTest_q & vCount_uid202_zCount_uid58_fpCosPiTest_q;

    -- biasM1_uid40_fpCosPiTest(CONSTANT,39)
    biasM1_uid40_fpCosPiTest_q <= "01111110";

    -- expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged(SUB,330)@12 + 1
    expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_a <= STD_LOGIC_VECTOR("0" & biasM1_uid40_fpCosPiTest_q);
    expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_b <= STD_LOGIC_VECTOR("000" & r_uid203_zCount_uid58_fpCosPiTest_q);
    expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_i <= "0" & redist14_exp_fpx_uid26_fpCosPiTest_merged_bit_select_b_12_outputreg_q;
    expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist68_xBranch_uid42_fpCosPiTest_q_11_q = "1") THEN
                expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_o <= expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_i;
            ELSE
                expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_o <= STD_LOGIC_VECTOR(UNSIGNED(expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_a) - UNSIGNED(expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_b));
            END IF;
        END IF;
    END PROCESS;
    expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_q <= expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_o(7 downto 0);

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_notEnable(LOGICAL,532)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_nor(LOGICAL,533)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_nor_q <= not (redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_notEnable_q or redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q);

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_last(CONSTANT,529)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_last_q <= "0110";

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp(LOGICAL,530)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_b <= STD_LOGIC_VECTOR("0" & redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_q);
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_q <= "1" WHEN redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_last_q = redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_b ELSE "0";

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg(REG,531)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg_q <= STD_LOGIC_VECTOR(redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmp_q);
        END IF;
    END PROCESS;

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena(REG,534)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_nor_q = "1") THEN
                redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q <= STD_LOGIC_VECTOR(redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_enaAnd(LOGICAL,535)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_enaAnd_q <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_sticky_ena_q and VCC_q;

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt(COUNTER,527)
    -- low=0, high=7, step=1, init=0
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i <= TO_UNSIGNED(0, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_i, 3)));

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr(REG,528)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr_q <= "111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr_q <= STD_LOGIC_VECTOR(redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem(DUALMEM,526)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ia <= STD_LOGIC_VECTOR(redist15_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_3_q);
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_aa <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_wraddr_q;
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ab <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_rdcnt_q;
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_reset0 <= areset;
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 23,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_reset0,
        clock1 => clk,
        address_a => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_aa,
        data_a => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_ab,
        q_b => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_iq
    );
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_q <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_iq(22 downto 0);

    -- redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_outputreg(DELAY,525)
    redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_mem_q, xout => redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_outputreg_q, clk => clk, aclr => areset );

    -- ZerosGB_uid63_fpCosPiTest(CONSTANT,62)
    ZerosGB_uid63_fpCosPiTest_q <= "000000000000000000000000000000";

    -- fracXRExt_uid64_fpCosPiTest(BITJOIN,63)@13
    fracXRExt_uid64_fpCosPiTest_q <= redist16_exp_fpx_uid26_fpCosPiTest_merged_bit_select_c_13_outputreg_q & ZerosGB_uid63_fpCosPiTest_q;

    -- leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest(BITSELECT,325)@13
    leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_in <= leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q(74 downto 0);
    leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_b <= leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_in(74 downto 0);

    -- leftShiftStage2Idx3Pad3_uid325_normMult_uid59_fpCosPiTest(CONSTANT,324)
    leftShiftStage2Idx3Pad3_uid325_normMult_uid59_fpCosPiTest_q <= "000";

    -- leftShiftStage2Idx3_uid327_normMult_uid59_fpCosPiTest(BITJOIN,326)@13
    leftShiftStage2Idx3_uid327_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx3Rng3_uid326_normMult_uid59_fpCosPiTest_b & leftShiftStage2Idx3Pad3_uid325_normMult_uid59_fpCosPiTest_q;

    -- leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest(BITSELECT,322)@13
    leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_in <= leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q(75 downto 0);
    leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_b <= leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_in(75 downto 0);

    -- leftShiftStage2Idx2_uid324_normMult_uid59_fpCosPiTest(BITJOIN,323)@13
    leftShiftStage2Idx2_uid324_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx2Rng2_uid323_normMult_uid59_fpCosPiTest_b & zs_uid194_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest(BITSELECT,319)@13
    leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_in <= leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q(76 downto 0);
    leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_b <= leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_in(76 downto 0);

    -- leftShiftStage2Idx1_uid321_normMult_uid59_fpCosPiTest(BITJOIN,320)@13
    leftShiftStage2Idx1_uid321_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx1Rng1_uid320_normMult_uid59_fpCosPiTest_b & GND_q;

    -- leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest(BITSELECT,314)@12
    leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_in <= leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q(65 downto 0);
    leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_b <= leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_in(65 downto 0);

    -- leftShiftStage1Idx3Pad12_uid314_normMult_uid59_fpCosPiTest(CONSTANT,313)
    leftShiftStage1Idx3Pad12_uid314_normMult_uid59_fpCosPiTest_q <= "000000000000";

    -- leftShiftStage1Idx3_uid316_normMult_uid59_fpCosPiTest(BITJOIN,315)@12
    leftShiftStage1Idx3_uid316_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx3Rng12_uid315_normMult_uid59_fpCosPiTest_b & leftShiftStage1Idx3Pad12_uid314_normMult_uid59_fpCosPiTest_q;

    -- leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest(BITSELECT,311)@12
    leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_in <= leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q(69 downto 0);
    leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_b <= leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_in(69 downto 0);

    -- leftShiftStage1Idx2_uid313_normMult_uid59_fpCosPiTest(BITJOIN,312)@12
    leftShiftStage1Idx2_uid313_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx2Rng8_uid312_normMult_uid59_fpCosPiTest_b & cstAllZWE_uid8_fpCosPiTest_q;

    -- leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest(BITSELECT,308)@12
    leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_in <= leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q(73 downto 0);
    leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_b <= leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_in(73 downto 0);

    -- leftShiftStage1Idx1_uid310_normMult_uid59_fpCosPiTest(BITJOIN,309)@12
    leftShiftStage1Idx1_uid310_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx1Rng4_uid309_normMult_uid59_fpCosPiTest_b & zs_uid188_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest(BITSELECT,303)@12
    leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_in <= redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q(29 downto 0);
    leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_b <= leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_in(29 downto 0);

    -- leftShiftStage0Idx3Pad48_uid303_normMult_uid59_fpCosPiTest(CONSTANT,302)
    leftShiftStage0Idx3Pad48_uid303_normMult_uid59_fpCosPiTest_q <= "000000000000000000000000000000000000000000000000";

    -- leftShiftStage0Idx3_uid305_normMult_uid59_fpCosPiTest(BITJOIN,304)@12
    leftShiftStage0Idx3_uid305_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx3Rng48_uid304_normMult_uid59_fpCosPiTest_b & leftShiftStage0Idx3Pad48_uid303_normMult_uid59_fpCosPiTest_q;

    -- leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest(BITSELECT,300)@12
    leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_in <= redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q(45 downto 0);
    leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_b <= leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_in(45 downto 0);

    -- leftShiftStage0Idx2_uid302_normMult_uid59_fpCosPiTest(BITJOIN,301)@12
    leftShiftStage0Idx2_uid302_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx2Rng32_uid301_normMult_uid59_fpCosPiTest_b & zs_uid170_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest(BITSELECT,297)@12
    leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_in <= redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q(61 downto 0);
    leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_b <= leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_in(61 downto 0);

    -- leftShiftStage0Idx1_uid299_normMult_uid59_fpCosPiTest(BITJOIN,298)@12
    leftShiftStage0Idx1_uid299_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx1Rng16_uid298_normMult_uid59_fpCosPiTest_b & zs_uid176_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage0_uid307_normMult_uid59_fpCosPiTest(MUX,306)@12
    leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_s <= leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_b;
    leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_combproc: PROCESS (leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_s, redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q, leftShiftStage0Idx1_uid299_normMult_uid59_fpCosPiTest_q, leftShiftStage0Idx2_uid302_normMult_uid59_fpCosPiTest_q, leftShiftStage0Idx3_uid305_normMult_uid59_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q <= redist66_multFracBits_uid54_fpCosPiTest_b_4_outputreg_q;
            WHEN "01" => leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx1_uid299_normMult_uid59_fpCosPiTest_q;
            WHEN "10" => leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx2_uid302_normMult_uid59_fpCosPiTest_q;
            WHEN "11" => leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q <= leftShiftStage0Idx3_uid305_normMult_uid59_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select(BITSELECT,431)@12
    leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_b <= r_uid203_zCount_uid58_fpCosPiTest_q(5 downto 4);
    leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_c <= r_uid203_zCount_uid58_fpCosPiTest_q(3 downto 2);
    leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d <= r_uid203_zCount_uid58_fpCosPiTest_q(1 downto 0);

    -- leftShiftStage1_uid318_normMult_uid59_fpCosPiTest(MUX,317)@12 + 1
    leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_s <= leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_c;
    leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_s) IS
                WHEN "00" => leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= leftShiftStage0_uid307_normMult_uid59_fpCosPiTest_q;
                WHEN "01" => leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx1_uid310_normMult_uid59_fpCosPiTest_q;
                WHEN "10" => leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx2_uid313_normMult_uid59_fpCosPiTest_q;
                WHEN "11" => leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= leftShiftStage1Idx3_uid316_normMult_uid59_fpCosPiTest_q;
                WHEN OTHERS => leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist11_leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d_1(DELAY,451)
    redist11_leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d, xout => redist11_leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d_1_q, clk => clk, aclr => areset );

    -- leftShiftStage2_uid329_normMult_uid59_fpCosPiTest(MUX,328)@13
    leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_s <= redist11_leftShiftStageSel5Dto4_uid306_normMult_uid59_fpCosPiTest_merged_bit_select_d_1_q;
    leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_combproc: PROCESS (leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_s, leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q, leftShiftStage2Idx1_uid321_normMult_uid59_fpCosPiTest_q, leftShiftStage2Idx2_uid324_normMult_uid59_fpCosPiTest_q, leftShiftStage2Idx3_uid327_normMult_uid59_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q <= leftShiftStage1_uid318_normMult_uid59_fpCosPiTest_q;
            WHEN "01" => leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx1_uid321_normMult_uid59_fpCosPiTest_q;
            WHEN "10" => leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx2_uid324_normMult_uid59_fpCosPiTest_q;
            WHEN "11" => leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q <= leftShiftStage2Idx3_uid327_normMult_uid59_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracCompOut_uid60_fpCosPiTest(BITSELECT,59)@13
    fracCompOut_uid60_fpCosPiTest_in <= leftShiftStage2_uid329_normMult_uid59_fpCosPiTest_q(76 downto 0);
    fracCompOut_uid60_fpCosPiTest_b <= fracCompOut_uid60_fpCosPiTest_in(76 downto 24);

    -- redist69_xBranch_uid42_fpCosPiTest_q_12(DELAY,509)
    redist69_xBranch_uid42_fpCosPiTest_q_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist68_xBranch_uid42_fpCosPiTest_q_11_q, xout => redist69_xBranch_uid42_fpCosPiTest_q_12_q, clk => clk, aclr => areset );

    -- finalFrac_uid65_fpCosPiTest(MUX,64)@13
    finalFrac_uid65_fpCosPiTest_s <= redist69_xBranch_uid42_fpCosPiTest_q_12_q;
    finalFrac_uid65_fpCosPiTest_combproc: PROCESS (finalFrac_uid65_fpCosPiTest_s, fracCompOut_uid60_fpCosPiTest_b, fracXRExt_uid64_fpCosPiTest_q)
    BEGIN
        CASE (finalFrac_uid65_fpCosPiTest_s) IS
            WHEN "0" => finalFrac_uid65_fpCosPiTest_q <= fracCompOut_uid60_fpCosPiTest_b;
            WHEN "1" => finalFrac_uid65_fpCosPiTest_q <= fracXRExt_uid64_fpCosPiTest_q;
            WHEN OTHERS => finalFrac_uid65_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- RRangeRed_uid67_fpCosPiTest(BITJOIN,66)@13
    RRangeRed_uid67_fpCosPiTest_q <= redist65_intBit_uid57_fpCosPiTest_b_1_q & expCompOutExt_uid61_fpCosPiTest_finalExp_uid66_fpCosPiTest_merged_q & finalFrac_uid65_fpCosPiTest_q;

    -- expXRR_uid70_fpCosPiTest(BITSELECT,69)@13
    expXRR_uid70_fpCosPiTest_in <= RRangeRed_uid67_fpCosPiTest_q(60 downto 0);
    expXRR_uid70_fpCosPiTest_b <= expXRR_uid70_fpCosPiTest_in(60 downto 53);

    -- redist64_expXRR_uid70_fpCosPiTest_b_1(DELAY,504)
    redist64_expXRR_uid70_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXRR_uid70_fpCosPiTest_b, xout => redist64_expXRR_uid70_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- cstBiasMwShiftM2_uid68_fpCosPiTest(CONSTANT,67)
    cstBiasMwShiftM2_uid68_fpCosPiTest_q <= "01110000";

    -- cosXIsOneXRR_uid89_fpCosPiTest(COMPARE,88)@14 + 1
    cosXIsOneXRR_uid89_fpCosPiTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & cstBiasMwShiftM2_uid68_fpCosPiTest_q));
    cosXIsOneXRR_uid89_fpCosPiTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 8 => redist64_expXRR_uid70_fpCosPiTest_b_1_q(7)) & redist64_expXRR_uid70_fpCosPiTest_b_1_q));
    cosXIsOneXRR_uid89_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            cosXIsOneXRR_uid89_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            cosXIsOneXRR_uid89_fpCosPiTest_o <= STD_LOGIC_VECTOR(SIGNED(cosXIsOneXRR_uid89_fpCosPiTest_a) - SIGNED(cosXIsOneXRR_uid89_fpCosPiTest_b));
        END IF;
    END PROCESS;
    cosXIsOneXRR_uid89_fpCosPiTest_n(0) <= not (cosXIsOneXRR_uid89_fpCosPiTest_o(10));

    -- redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4(DELAY,497)
    redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => cosXIsOneXRR_uid89_fpCosPiTest_n, xout => redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4_q, clk => clk, aclr => areset );

    -- exp_x_uid9_fpCosPiTest(BITSELECT,8)@0
    exp_x_uid9_fpCosPiTest_b <= a(30 downto 23);

    -- cosXIsOne_uid88_fpCosPiTest(COMPARE,87)@0 + 1
    cosXIsOne_uid88_fpCosPiTest_a <= STD_LOGIC_VECTOR("00" & cwFo2_uid39_fpCosPiTest_q);
    cosXIsOne_uid88_fpCosPiTest_b <= STD_LOGIC_VECTOR("00" & exp_x_uid9_fpCosPiTest_b);
    cosXIsOne_uid88_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            cosXIsOne_uid88_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            cosXIsOne_uid88_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(cosXIsOne_uid88_fpCosPiTest_a) - UNSIGNED(cosXIsOne_uid88_fpCosPiTest_b));
        END IF;
    END PROCESS;
    cosXIsOne_uid88_fpCosPiTest_n(0) <= not (cosXIsOne_uid88_fpCosPiTest_o(9));

    -- redist59_cosXIsOne_uid88_fpCosPiTest_n_18(DELAY,499)
    redist59_cosXIsOne_uid88_fpCosPiTest_n_18 : dspba_delay
    GENERIC MAP ( width => 1, depth => 17, reset_kind => "ASYNC" )
    PORT MAP ( xin => cosXIsOne_uid88_fpCosPiTest_n, xout => redist59_cosXIsOne_uid88_fpCosPiTest_n_18_q, clk => clk, aclr => areset );

    -- cosXOne_uid154_fpCosPiTest(LOGICAL,153)@18
    cosXOne_uid154_fpCosPiTest_q <= not (redist59_cosXIsOne_uid88_fpCosPiTest_n_18_q or redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4_q);

    -- leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest(BITSELECT,351)@15
    leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_in <= leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q(64 downto 0);
    leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_b <= leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_in(64 downto 0);

    -- leftShiftStage1Idx3_uid353_fxpX_uid77_fpCosPiTest(BITJOIN,352)@15
    leftShiftStage1Idx3_uid353_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx3Rng3_uid352_fxpX_uid77_fpCosPiTest_b & leftShiftStage2Idx3Pad3_uid325_normMult_uid59_fpCosPiTest_q;

    -- leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest(BITSELECT,348)@15
    leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_in <= leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q(65 downto 0);
    leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_b <= leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_in(65 downto 0);

    -- leftShiftStage1Idx2_uid350_fxpX_uid77_fpCosPiTest(BITJOIN,349)@15
    leftShiftStage1Idx2_uid350_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx2Rng2_uid349_fxpX_uid77_fpCosPiTest_b & zs_uid194_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest(BITSELECT,345)@15
    leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_in <= leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q(66 downto 0);
    leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_b <= leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_in(66 downto 0);

    -- leftShiftStage1Idx1_uid347_fxpX_uid77_fpCosPiTest(BITJOIN,346)@15
    leftShiftStage1Idx1_uid347_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx1Rng1_uid346_fxpX_uid77_fpCosPiTest_b & GND_q;

    -- leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest(BITSELECT,340)@15
    leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_in <= extendedFracX_uid76_fpCosPiTest_q(55 downto 0);
    leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_b <= leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_in(55 downto 0);

    -- leftShiftStage0Idx3_uid342_fxpX_uid77_fpCosPiTest(BITJOIN,341)@15
    leftShiftStage0Idx3_uid342_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx3Rng12_uid341_fxpX_uid77_fpCosPiTest_b & leftShiftStage1Idx3Pad12_uid314_normMult_uid59_fpCosPiTest_q;

    -- leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest(BITSELECT,337)@15
    leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_in <= extendedFracX_uid76_fpCosPiTest_q(59 downto 0);
    leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_b <= leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_in(59 downto 0);

    -- leftShiftStage0Idx2_uid339_fxpX_uid77_fpCosPiTest(BITJOIN,338)@15
    leftShiftStage0Idx2_uid339_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx2Rng8_uid338_fxpX_uid77_fpCosPiTest_b & cstAllZWE_uid8_fpCosPiTest_q;

    -- leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest(BITSELECT,334)@15
    leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_in <= extendedFracX_uid76_fpCosPiTest_q(63 downto 0);
    leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_b <= leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_in(63 downto 0);

    -- leftShiftStage0Idx1_uid336_fxpX_uid77_fpCosPiTest(BITJOIN,335)@15
    leftShiftStage0Idx1_uid336_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx1Rng4_uid335_fxpX_uid77_fpCosPiTest_b & zs_uid188_zCount_uid58_fpCosPiTest_q;

    -- cstZwShiftP1_uid69_fpCosPiTest(CONSTANT,68)
    cstZwShiftP1_uid69_fpCosPiTest_q <= "00000000000000";

    -- fracXRR_uid71_fpCosPiTest(BITSELECT,70)@13
    fracXRR_uid71_fpCosPiTest_in <= RRangeRed_uid67_fpCosPiTest_q(52 downto 0);
    fracXRR_uid71_fpCosPiTest_b <= fracXRR_uid71_fpCosPiTest_in(52 downto 0);

    -- redist63_fracXRR_uid71_fpCosPiTest_b_2(DELAY,503)
    redist63_fracXRR_uid71_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 53, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXRR_uid71_fpCosPiTest_b, xout => redist63_fracXRR_uid71_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- oFracXRR_uid73_fpCosPiTest(BITJOIN,72)@15
    oFracXRR_uid73_fpCosPiTest_q <= VCC_q & redist63_fracXRR_uid71_fpCosPiTest_b_2_q;

    -- extendedFracX_uid76_fpCosPiTest(BITJOIN,75)@15
    extendedFracX_uid76_fpCosPiTest_q <= cstZwShiftP1_uid69_fpCosPiTest_q & oFracXRR_uid73_fpCosPiTest_q;

    -- leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest(MUX,343)@15
    leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_s <= leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_b;
    leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_combproc: PROCESS (leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_s, extendedFracX_uid76_fpCosPiTest_q, leftShiftStage0Idx1_uid336_fxpX_uid77_fpCosPiTest_q, leftShiftStage0Idx2_uid339_fxpX_uid77_fpCosPiTest_q, leftShiftStage0Idx3_uid342_fxpX_uid77_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q <= extendedFracX_uid76_fpCosPiTest_q;
            WHEN "01" => leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx1_uid336_fxpX_uid77_fpCosPiTest_q;
            WHEN "10" => leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx2_uid339_fxpX_uid77_fpCosPiTest_q;
            WHEN "11" => leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0Idx3_uid342_fxpX_uid77_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fxpXShiftValExt_uid74_fpCosPiTest(SUB,73)@14
    fxpXShiftValExt_uid74_fpCosPiTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 8 => redist64_expXRR_uid70_fpCosPiTest_b_1_q(7)) & redist64_expXRR_uid70_fpCosPiTest_b_1_q));
    fxpXShiftValExt_uid74_fpCosPiTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & cstBiasMwShiftM2_uid68_fpCosPiTest_q));
    fxpXShiftValExt_uid74_fpCosPiTest_o <= STD_LOGIC_VECTOR(SIGNED(fxpXShiftValExt_uid74_fpCosPiTest_a) - SIGNED(fxpXShiftValExt_uid74_fpCosPiTest_b));
    fxpXShiftValExt_uid74_fpCosPiTest_q <= fxpXShiftValExt_uid74_fpCosPiTest_o(9 downto 0);

    -- fxpXShiftVal_uid75_fpCosPiTest(BITSELECT,74)@14
    fxpXShiftVal_uid75_fpCosPiTest_in <= fxpXShiftValExt_uid74_fpCosPiTest_q(3 downto 0);
    fxpXShiftVal_uid75_fpCosPiTest_b <= fxpXShiftVal_uid75_fpCosPiTest_in(3 downto 0);

    -- redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1(DELAY,502)
    redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 4, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fxpXShiftVal_uid75_fpCosPiTest_b, xout => redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select(BITSELECT,425)@15
    leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_b <= redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1_q(3 downto 2);
    leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_c <= redist62_fxpXShiftVal_uid75_fpCosPiTest_b_1_q(1 downto 0);

    -- leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest(MUX,354)@15
    leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_s <= leftShiftStageSel3Dto2_uid343_fxpX_uid77_fpCosPiTest_merged_bit_select_c;
    leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_combproc: PROCESS (leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_s, leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q, leftShiftStage1Idx1_uid347_fxpX_uid77_fpCosPiTest_q, leftShiftStage1Idx2_uid350_fxpX_uid77_fpCosPiTest_q, leftShiftStage1Idx3_uid353_fxpX_uid77_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q <= leftShiftStage0_uid344_fxpX_uid77_fpCosPiTest_q;
            WHEN "01" => leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx1_uid347_fxpX_uid77_fpCosPiTest_q;
            WHEN "10" => leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx2_uid350_fxpX_uid77_fpCosPiTest_q;
            WHEN "11" => leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q <= leftShiftStage1Idx3_uid353_fxpX_uid77_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- y_uid91_fpCosPiTest(BITSELECT,90)@15
    y_uid91_fpCosPiTest_in <= leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q(66 downto 0);
    y_uid91_fpCosPiTest_b <= y_uid91_fpCosPiTest_in(66 downto 1);

    -- redist54_y_uid91_fpCosPiTest_b_1(DELAY,494)
    redist54_y_uid91_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 66, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => y_uid91_fpCosPiTest_b, xout => redist54_y_uid91_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- redist55_y_uid91_fpCosPiTest_b_2(DELAY,495)
    redist55_y_uid91_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 66, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist54_y_uid91_fpCosPiTest_b_1_q, xout => redist55_y_uid91_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- paddingY_uid92_fpCosPiTest(CONSTANT,91)
    paddingY_uid92_fpCosPiTest_q <= "000000000000000000000000000000000000000000000000000000000000000000";

    -- aPostPad_uid103_fpCosPiTest(BITJOIN,102)@16
    aPostPad_uid103_fpCosPiTest_q <= VCC_q & paddingY_uid92_fpCosPiTest_q;

    -- oneMinusY_uid104_fpCosPiTest(SUB,103)@16 + 1
    oneMinusY_uid104_fpCosPiTest_a <= STD_LOGIC_VECTOR("0" & aPostPad_uid103_fpCosPiTest_q);
    oneMinusY_uid104_fpCosPiTest_b <= STD_LOGIC_VECTOR("00" & redist54_y_uid91_fpCosPiTest_b_1_q);
    oneMinusY_uid104_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            oneMinusY_uid104_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            oneMinusY_uid104_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(oneMinusY_uid104_fpCosPiTest_a) - UNSIGNED(oneMinusY_uid104_fpCosPiTest_b));
        END IF;
    END PROCESS;
    oneMinusY_uid104_fpCosPiTest_q <= oneMinusY_uid104_fpCosPiTest_o(67 downto 0);

    -- cmpYToOneMinusY_uid106_fpCosPiTest(COMPARE,105)@17 + 1
    cmpYToOneMinusY_uid106_fpCosPiTest_a <= STD_LOGIC_VECTOR("00" & oneMinusY_uid104_fpCosPiTest_q);
    cmpYToOneMinusY_uid106_fpCosPiTest_b <= STD_LOGIC_VECTOR("0000" & redist55_y_uid91_fpCosPiTest_b_2_q);
    cmpYToOneMinusY_uid106_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            cmpYToOneMinusY_uid106_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            cmpYToOneMinusY_uid106_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(cmpYToOneMinusY_uid106_fpCosPiTest_a) - UNSIGNED(cmpYToOneMinusY_uid106_fpCosPiTest_b));
        END IF;
    END PROCESS;
    cmpYToOneMinusY_uid106_fpCosPiTest_c(0) <= cmpYToOneMinusY_uid106_fpCosPiTest_o(69);

    -- invCmpYToOMY_uid107_fpCosPiTest(LOGICAL,106)@18
    invCmpYToOMY_uid107_fpCosPiTest_q <= not (cmpYToOneMinusY_uid106_fpCosPiTest_c);

    -- intXParity_uid90_fpCosPiTest(BITSELECT,89)@15
    intXParity_uid90_fpCosPiTest_b <= STD_LOGIC_VECTOR(leftShiftStage1_uid355_fxpX_uid77_fpCosPiTest_q(67 downto 67));

    -- redist56_intXParity_uid90_fpCosPiTest_b_3(DELAY,496)
    redist56_intXParity_uid90_fpCosPiTest_b_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => intXParity_uid90_fpCosPiTest_b, xout => redist56_intXParity_uid90_fpCosPiTest_b_3_q, clk => clk, aclr => areset );

    -- updatedY_uid93_fpCosPiTest(BITJOIN,92)@17
    updatedY_uid93_fpCosPiTest_q <= GND_q & paddingY_uid92_fpCosPiTest_q;

    -- yIsZero_uid92_fpCosPiTest(LOGICAL,93)@17 + 1
    yIsZero_uid92_fpCosPiTest_a <= STD_LOGIC_VECTOR("0" & redist55_y_uid91_fpCosPiTest_b_2_q);
    yIsZero_uid92_fpCosPiTest_qi <= "1" WHEN yIsZero_uid92_fpCosPiTest_a = updatedY_uid93_fpCosPiTest_q ELSE "0";
    yIsZero_uid92_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => yIsZero_uid92_fpCosPiTest_qi, xout => yIsZero_uid92_fpCosPiTest_q, clk => clk, aclr => areset );

    -- invYIsZero_uid153_fpCosPiTest(LOGICAL,152)@18
    invYIsZero_uid153_fpCosPiTest_q <= not (yIsZero_uid92_fpCosPiTest_q);

    -- signRCond2_uid156_fpCosPiTest(LOGICAL,155)@18
    signRCond2_uid156_fpCosPiTest_q <= invYIsZero_uid153_fpCosPiTest_q and redist56_intXParity_uid90_fpCosPiTest_b_3_q and invCmpYToOMY_uid107_fpCosPiTest_q and cosXOne_uid154_fpCosPiTest_q;

    -- invIntParity_uid158_fpCosPiTest(LOGICAL,157)@18
    invIntParity_uid158_fpCosPiTest_q <= not (redist56_intXParity_uid90_fpCosPiTest_b_3_q);

    -- signRCond1_uid159_fpCosPiTest(LOGICAL,158)@18
    signRCond1_uid159_fpCosPiTest_q <= invYIsZero_uid153_fpCosPiTest_q and invIntParity_uid158_fpCosPiTest_q and cmpYToOneMinusY_uid106_fpCosPiTest_c and cosXOne_uid154_fpCosPiTest_q;

    -- signRBase_uid160_fpCosPiTest(LOGICAL,159)@18 + 1
    signRBase_uid160_fpCosPiTest_qi <= signRCond1_uid159_fpCosPiTest_q or signRCond2_uid156_fpCosPiTest_q;
    signRBase_uid160_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRBase_uid160_fpCosPiTest_qi, xout => signRBase_uid160_fpCosPiTest_q, clk => clk, aclr => areset );

    -- signXRR_uid87_fpCosPiTest(BITSELECT,86)@13
    signXRR_uid87_fpCosPiTest_b <= STD_LOGIC_VECTOR(RRangeRed_uid67_fpCosPiTest_q(61 downto 61));

    -- redist61_signXRR_uid87_fpCosPiTest_b_6(DELAY,501)
    redist61_signXRR_uid87_fpCosPiTest_b_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => signXRR_uid87_fpCosPiTest_b, xout => redist61_signXRR_uid87_fpCosPiTest_b_6_q, clk => clk, aclr => areset );

    -- xorSignRRXSignBase_uid161_fpCosPiTest(LOGICAL,160)@19
    xorSignRRXSignBase_uid161_fpCosPiTest_q <= redist61_signXRR_uid87_fpCosPiTest_b_6_q xor signRBase_uid160_fpCosPiTest_q;

    -- frac_x_uid10_fpCosPiTest(BITSELECT,9)@0
    frac_x_uid10_fpCosPiTest_b <= a(22 downto 0);

    -- fracXIsZero_uid13_fpCosPiTest(LOGICAL,12)@0 + 1
    fracXIsZero_uid13_fpCosPiTest_qi <= "1" WHEN cstZeroWF_uid7_fpCosPiTest_q = frac_x_uid10_fpCosPiTest_b ELSE "0";
    fracXIsZero_uid13_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid13_fpCosPiTest_qi, xout => fracXIsZero_uid13_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist71_fracXIsZero_uid13_fpCosPiTest_q_19(DELAY,511)
    redist71_fracXIsZero_uid13_fpCosPiTest_q_19 : dspba_delay
    GENERIC MAP ( width => 1, depth => 18, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid13_fpCosPiTest_q, xout => redist71_fracXIsZero_uid13_fpCosPiTest_q_19_q, clk => clk, aclr => areset );

    -- expXIsMax_uid12_fpCosPiTest(LOGICAL,11)@0 + 1
    expXIsMax_uid12_fpCosPiTest_qi <= "1" WHEN exp_x_uid9_fpCosPiTest_b = cstAllOWE_uid6_fpCosPiTest_q ELSE "0";
    expXIsMax_uid12_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid12_fpCosPiTest_qi, xout => expXIsMax_uid12_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist72_expXIsMax_uid12_fpCosPiTest_q_19(DELAY,512)
    redist72_expXIsMax_uid12_fpCosPiTest_q_19 : dspba_delay
    GENERIC MAP ( width => 1, depth => 18, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid12_fpCosPiTest_q, xout => redist72_expXIsMax_uid12_fpCosPiTest_q_19_q, clk => clk, aclr => areset );

    -- excI_x_uid15_fpCosPiTest(LOGICAL,14)@19
    excI_x_uid15_fpCosPiTest_q <= redist72_expXIsMax_uid12_fpCosPiTest_q_19_q and redist71_fracXIsZero_uid13_fpCosPiTest_q_19_q;

    -- invExcXI_uid162_fpCosPiTest(LOGICAL,161)@19
    invExcXI_uid162_fpCosPiTest_q <= not (excI_x_uid15_fpCosPiTest_q);

    -- fracXIsNotZero_uid14_fpCosPiTest(LOGICAL,13)@19
    fracXIsNotZero_uid14_fpCosPiTest_q <= not (redist71_fracXIsZero_uid13_fpCosPiTest_q_19_q);

    -- excN_x_uid16_fpCosPiTest(LOGICAL,15)@19
    excN_x_uid16_fpCosPiTest_q <= redist72_expXIsMax_uid12_fpCosPiTest_q_19_q and fracXIsNotZero_uid14_fpCosPiTest_q;

    -- invExcXN_uid163_fpCosPiTest(LOGICAL,162)@19
    invExcXN_uid163_fpCosPiTest_q <= not (excN_x_uid16_fpCosPiTest_q);

    -- signR_uid164_fpCosPiTest(LOGICAL,163)@19 + 1
    signR_uid164_fpCosPiTest_qi <= invExcXN_uid163_fpCosPiTest_q and invExcXI_uid162_fpCosPiTest_q and xorSignRRXSignBase_uid161_fpCosPiTest_q;
    signR_uid164_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid164_fpCosPiTest_qi, xout => signR_uid164_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist36_signR_uid164_fpCosPiTest_q_13(DELAY,476)
    redist36_signR_uid164_fpCosPiTest_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 12, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid164_fpCosPiTest_q, xout => redist36_signR_uid164_fpCosPiTest_q_13_q, clk => clk, aclr => areset );

    -- cstBias_uid78_fpCosPiTest(CONSTANT,77)
    cstBias_uid78_fpCosPiTest_q <= "01111111";

    -- oMyBottom_uid108_fpCosPiTest(BITSELECT,107)@17
    oMyBottom_uid108_fpCosPiTest_in <= oneMinusY_uid104_fpCosPiTest_q(64 downto 0);
    oMyBottom_uid108_fpCosPiTest_b <= oMyBottom_uid108_fpCosPiTest_in(64 downto 0);

    -- redist52_oMyBottom_uid108_fpCosPiTest_b_1(DELAY,492)
    redist52_oMyBottom_uid108_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oMyBottom_uid108_fpCosPiTest_b, xout => redist52_oMyBottom_uid108_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- yBottom_uid109_fpCosPiTest(BITSELECT,108)@17
    yBottom_uid109_fpCosPiTest_in <= redist55_y_uid91_fpCosPiTest_b_2_q(64 downto 0);
    yBottom_uid109_fpCosPiTest_b <= yBottom_uid109_fpCosPiTest_in(64 downto 0);

    -- redist51_yBottom_uid109_fpCosPiTest_b_1(DELAY,491)
    redist51_yBottom_uid109_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => yBottom_uid109_fpCosPiTest_b, xout => redist51_yBottom_uid109_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- z_uid110_fpCosPiTest(MUX,109)@18
    z_uid110_fpCosPiTest_s <= invCmpYToOMY_uid107_fpCosPiTest_q;
    z_uid110_fpCosPiTest_combproc: PROCESS (z_uid110_fpCosPiTest_s, redist51_yBottom_uid109_fpCosPiTest_b_1_q, redist52_oMyBottom_uid108_fpCosPiTest_b_1_q)
    BEGIN
        CASE (z_uid110_fpCosPiTest_s) IS
            WHEN "0" => z_uid110_fpCosPiTest_q <= redist51_yBottom_uid109_fpCosPiTest_b_1_q;
            WHEN "1" => z_uid110_fpCosPiTest_q <= redist52_oMyBottom_uid108_fpCosPiTest_b_1_q;
            WHEN OTHERS => z_uid110_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- yAddr_uid118_fpCosPiTest(BITSELECT,117)@18
    yAddr_uid118_fpCosPiTest_b <= z_uid110_fpCosPiTest_q(64 downto 57);

    -- memoryC2_uid254_sinXTables_lutmem(DUALMEM,397)@18 + 2
    -- in j@20000000
    memoryC2_uid254_sinXTables_lutmem_aa <= yAddr_uid118_fpCosPiTest_b;
    memoryC2_uid254_sinXTables_lutmem_reset0 <= areset;
    memoryC2_uid254_sinXTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 13,
        widthad_a => 8,
        numwords_a => 256,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPFCos_0002_memoryC2_uid254_sinXTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC2_uid254_sinXTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC2_uid254_sinXTables_lutmem_aa,
        q_a => memoryC2_uid254_sinXTables_lutmem_ir
    );
    memoryC2_uid254_sinXTables_lutmem_r <= memoryC2_uid254_sinXTables_lutmem_ir(12 downto 0);

    -- redist48_z_uid110_fpCosPiTest_q_1(DELAY,488)
    redist48_z_uid110_fpCosPiTest_q_1 : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => z_uid110_fpCosPiTest_q, xout => redist48_z_uid110_fpCosPiTest_q_1_q, clk => clk, aclr => areset );

    -- redist49_z_uid110_fpCosPiTest_q_2(DELAY,489)
    redist49_z_uid110_fpCosPiTest_q_2 : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist48_z_uid110_fpCosPiTest_q_1_q, xout => redist49_z_uid110_fpCosPiTest_q_2_q, clk => clk, aclr => areset );

    -- zPPolyEval_uid119_fpCosPiTest(BITSELECT,118)@20
    zPPolyEval_uid119_fpCosPiTest_in <= redist49_z_uid110_fpCosPiTest_q_2_q(56 downto 0);
    zPPolyEval_uid119_fpCosPiTest_b <= zPPolyEval_uid119_fpCosPiTest_in(56 downto 39);

    -- yT1_uid260_invPolyEval(BITSELECT,259)@20
    yT1_uid260_invPolyEval_b <= zPPolyEval_uid119_fpCosPiTest_b(17 downto 5);

    -- prodXY_uid273_pT1_uid261_invPolyEval_cma(CHAINMULTADD,419)@20 + 2
    prodXY_uid273_pT1_uid261_invPolyEval_cma_reset <= areset;
    prodXY_uid273_pT1_uid261_invPolyEval_cma_ena0 <= '1';
    prodXY_uid273_pT1_uid261_invPolyEval_cma_ena1 <= prodXY_uid273_pT1_uid261_invPolyEval_cma_ena0;
    prodXY_uid273_pT1_uid261_invPolyEval_cma_l(0) <= SIGNED(RESIZE(prodXY_uid273_pT1_uid261_invPolyEval_cma_a0(0),14));
    prodXY_uid273_pT1_uid261_invPolyEval_cma_p(0) <= prodXY_uid273_pT1_uid261_invPolyEval_cma_l(0) * prodXY_uid273_pT1_uid261_invPolyEval_cma_c0(0);
    prodXY_uid273_pT1_uid261_invPolyEval_cma_u(0) <= RESIZE(prodXY_uid273_pT1_uid261_invPolyEval_cma_p(0),27);
    prodXY_uid273_pT1_uid261_invPolyEval_cma_w(0) <= prodXY_uid273_pT1_uid261_invPolyEval_cma_u(0);
    prodXY_uid273_pT1_uid261_invPolyEval_cma_x(0) <= prodXY_uid273_pT1_uid261_invPolyEval_cma_w(0);
    prodXY_uid273_pT1_uid261_invPolyEval_cma_y(0) <= prodXY_uid273_pT1_uid261_invPolyEval_cma_x(0);
    prodXY_uid273_pT1_uid261_invPolyEval_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid273_pT1_uid261_invPolyEval_cma_a0 <= (others => (others => '0'));
            prodXY_uid273_pT1_uid261_invPolyEval_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prodXY_uid273_pT1_uid261_invPolyEval_cma_ena0 = '1') THEN
                prodXY_uid273_pT1_uid261_invPolyEval_cma_a0(0) <= RESIZE(UNSIGNED(yT1_uid260_invPolyEval_b),13);
                prodXY_uid273_pT1_uid261_invPolyEval_cma_c0(0) <= RESIZE(SIGNED(memoryC2_uid254_sinXTables_lutmem_r),13);
            END IF;
        END IF;
    END PROCESS;
    prodXY_uid273_pT1_uid261_invPolyEval_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid273_pT1_uid261_invPolyEval_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prodXY_uid273_pT1_uid261_invPolyEval_cma_ena1 = '1') THEN
                prodXY_uid273_pT1_uid261_invPolyEval_cma_s(0) <= prodXY_uid273_pT1_uid261_invPolyEval_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    prodXY_uid273_pT1_uid261_invPolyEval_cma_delay : dspba_delay
    GENERIC MAP ( width => 26, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prodXY_uid273_pT1_uid261_invPolyEval_cma_s(0)(25 downto 0)), xout => prodXY_uid273_pT1_uid261_invPolyEval_cma_qq, clk => clk, aclr => areset );
    prodXY_uid273_pT1_uid261_invPolyEval_cma_q <= STD_LOGIC_VECTOR(prodXY_uid273_pT1_uid261_invPolyEval_cma_qq(25 downto 0));

    -- osig_uid274_pT1_uid261_invPolyEval(BITSELECT,273)@22
    osig_uid274_pT1_uid261_invPolyEval_b <= STD_LOGIC_VECTOR(prodXY_uid273_pT1_uid261_invPolyEval_cma_q(25 downto 12));

    -- highBBits_uid263_invPolyEval(BITSELECT,262)@22
    highBBits_uid263_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid274_pT1_uid261_invPolyEval_b(13 downto 1));

    -- redist45_yAddr_uid118_fpCosPiTest_b_2(DELAY,485)
    redist45_yAddr_uid118_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid118_fpCosPiTest_b, xout => redist45_yAddr_uid118_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- memoryC1_uid251_sinXTables_lutmem(DUALMEM,396)@20 + 2
    -- in j@20000000
    memoryC1_uid251_sinXTables_lutmem_aa <= redist45_yAddr_uid118_fpCosPiTest_b_2_q;
    memoryC1_uid251_sinXTables_lutmem_reset0 <= areset;
    memoryC1_uid251_sinXTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 21,
        widthad_a => 8,
        numwords_a => 256,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPFCos_0002_memoryC1_uid251_sinXTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid251_sinXTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid251_sinXTables_lutmem_aa,
        q_a => memoryC1_uid251_sinXTables_lutmem_ir
    );
    memoryC1_uid251_sinXTables_lutmem_r <= memoryC1_uid251_sinXTables_lutmem_ir(20 downto 0);

    -- s1sumAHighB_uid264_invPolyEval(ADD,263)@22 + 1
    s1sumAHighB_uid264_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 21 => memoryC1_uid251_sinXTables_lutmem_r(20)) & memoryC1_uid251_sinXTables_lutmem_r));
    s1sumAHighB_uid264_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 13 => highBBits_uid263_invPolyEval_b(12)) & highBBits_uid263_invPolyEval_b));
    s1sumAHighB_uid264_invPolyEval_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            s1sumAHighB_uid264_invPolyEval_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            s1sumAHighB_uid264_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(s1sumAHighB_uid264_invPolyEval_a) + SIGNED(s1sumAHighB_uid264_invPolyEval_b));
        END IF;
    END PROCESS;
    s1sumAHighB_uid264_invPolyEval_q <= s1sumAHighB_uid264_invPolyEval_o(21 downto 0);

    -- lowRangeB_uid262_invPolyEval(BITSELECT,261)@22
    lowRangeB_uid262_invPolyEval_in <= osig_uid274_pT1_uid261_invPolyEval_b(0 downto 0);
    lowRangeB_uid262_invPolyEval_b <= lowRangeB_uid262_invPolyEval_in(0 downto 0);

    -- redist23_lowRangeB_uid262_invPolyEval_b_1(DELAY,463)
    redist23_lowRangeB_uid262_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid262_invPolyEval_b, xout => redist23_lowRangeB_uid262_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- s1_uid265_invPolyEval(BITJOIN,264)@23
    s1_uid265_invPolyEval_q <= s1sumAHighB_uid264_invPolyEval_q & redist23_lowRangeB_uid262_invPolyEval_b_1_q;

    -- redist44_zPPolyEval_uid119_fpCosPiTest_b_3_inputreg(DELAY,536)
    redist44_zPPolyEval_uid119_fpCosPiTest_b_3_inputreg : dspba_delay
    GENERIC MAP ( width => 18, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => zPPolyEval_uid119_fpCosPiTest_b, xout => redist44_zPPolyEval_uid119_fpCosPiTest_b_3_inputreg_q, clk => clk, aclr => areset );

    -- redist44_zPPolyEval_uid119_fpCosPiTest_b_3(DELAY,484)
    redist44_zPPolyEval_uid119_fpCosPiTest_b_3 : dspba_delay
    GENERIC MAP ( width => 18, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist44_zPPolyEval_uid119_fpCosPiTest_b_3_inputreg_q, xout => redist44_zPPolyEval_uid119_fpCosPiTest_b_3_q, clk => clk, aclr => areset );

    -- prodXY_uid276_pT2_uid267_invPolyEval_cma(CHAINMULTADD,420)@23 + 2
    prodXY_uid276_pT2_uid267_invPolyEval_cma_reset <= areset;
    prodXY_uid276_pT2_uid267_invPolyEval_cma_ena0 <= '1';
    prodXY_uid276_pT2_uid267_invPolyEval_cma_ena1 <= prodXY_uid276_pT2_uid267_invPolyEval_cma_ena0;
    prodXY_uid276_pT2_uid267_invPolyEval_cma_l(0) <= SIGNED(RESIZE(prodXY_uid276_pT2_uid267_invPolyEval_cma_a0(0),19));
    prodXY_uid276_pT2_uid267_invPolyEval_cma_p(0) <= prodXY_uid276_pT2_uid267_invPolyEval_cma_l(0) * prodXY_uid276_pT2_uid267_invPolyEval_cma_c0(0);
    prodXY_uid276_pT2_uid267_invPolyEval_cma_u(0) <= RESIZE(prodXY_uid276_pT2_uid267_invPolyEval_cma_p(0),42);
    prodXY_uid276_pT2_uid267_invPolyEval_cma_w(0) <= prodXY_uid276_pT2_uid267_invPolyEval_cma_u(0);
    prodXY_uid276_pT2_uid267_invPolyEval_cma_x(0) <= prodXY_uid276_pT2_uid267_invPolyEval_cma_w(0);
    prodXY_uid276_pT2_uid267_invPolyEval_cma_y(0) <= prodXY_uid276_pT2_uid267_invPolyEval_cma_x(0);
    prodXY_uid276_pT2_uid267_invPolyEval_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid276_pT2_uid267_invPolyEval_cma_a0 <= (others => (others => '0'));
            prodXY_uid276_pT2_uid267_invPolyEval_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prodXY_uid276_pT2_uid267_invPolyEval_cma_ena0 = '1') THEN
                prodXY_uid276_pT2_uid267_invPolyEval_cma_a0(0) <= RESIZE(UNSIGNED(redist44_zPPolyEval_uid119_fpCosPiTest_b_3_q),18);
                prodXY_uid276_pT2_uid267_invPolyEval_cma_c0(0) <= RESIZE(SIGNED(s1_uid265_invPolyEval_q),23);
            END IF;
        END IF;
    END PROCESS;
    prodXY_uid276_pT2_uid267_invPolyEval_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid276_pT2_uid267_invPolyEval_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (prodXY_uid276_pT2_uid267_invPolyEval_cma_ena1 = '1') THEN
                prodXY_uid276_pT2_uid267_invPolyEval_cma_s(0) <= prodXY_uid276_pT2_uid267_invPolyEval_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    prodXY_uid276_pT2_uid267_invPolyEval_cma_delay : dspba_delay
    GENERIC MAP ( width => 41, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prodXY_uid276_pT2_uid267_invPolyEval_cma_s(0)(40 downto 0)), xout => prodXY_uid276_pT2_uid267_invPolyEval_cma_qq, clk => clk, aclr => areset );
    prodXY_uid276_pT2_uid267_invPolyEval_cma_q <= STD_LOGIC_VECTOR(prodXY_uid276_pT2_uid267_invPolyEval_cma_qq(40 downto 0));

    -- osig_uid277_pT2_uid267_invPolyEval(BITSELECT,276)@25
    osig_uid277_pT2_uid267_invPolyEval_b <= STD_LOGIC_VECTOR(prodXY_uid276_pT2_uid267_invPolyEval_cma_q(40 downto 17));

    -- redist22_osig_uid277_pT2_uid267_invPolyEval_b_1(DELAY,462)
    redist22_osig_uid277_pT2_uid267_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 24, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid277_pT2_uid267_invPolyEval_b, xout => redist22_osig_uid277_pT2_uid267_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- highBBits_uid269_invPolyEval(BITSELECT,268)@26
    highBBits_uid269_invPolyEval_b <= STD_LOGIC_VECTOR(redist22_osig_uid277_pT2_uid267_invPolyEval_b_1_q(23 downto 2));

    -- redist46_yAddr_uid118_fpCosPiTest_b_5(DELAY,486)
    redist46_yAddr_uid118_fpCosPiTest_b_5 : dspba_delay
    GENERIC MAP ( width => 8, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist45_yAddr_uid118_fpCosPiTest_b_2_q, xout => redist46_yAddr_uid118_fpCosPiTest_b_5_q, clk => clk, aclr => areset );

    -- memoryC0_uid248_sinXTables_lutmem(DUALMEM,395)@23 + 2
    -- in j@20000000
    memoryC0_uid248_sinXTables_lutmem_aa <= redist46_yAddr_uid118_fpCosPiTest_b_5_q;
    memoryC0_uid248_sinXTables_lutmem_reset0 <= areset;
    memoryC0_uid248_sinXTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 30,
        widthad_a => 8,
        numwords_a => 256,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "FPFCos_0002_memoryC0_uid248_sinXTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid248_sinXTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid248_sinXTables_lutmem_aa,
        q_a => memoryC0_uid248_sinXTables_lutmem_ir
    );
    memoryC0_uid248_sinXTables_lutmem_r <= memoryC0_uid248_sinXTables_lutmem_ir(29 downto 0);

    -- redist21_memoryC0_uid248_sinXTables_lutmem_r_1(DELAY,461)
    redist21_memoryC0_uid248_sinXTables_lutmem_r_1 : dspba_delay
    GENERIC MAP ( width => 30, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => memoryC0_uid248_sinXTables_lutmem_r, xout => redist21_memoryC0_uid248_sinXTables_lutmem_r_1_q, clk => clk, aclr => areset );

    -- s2sumAHighB_uid270_invPolyEval(ADD,269)@26
    s2sumAHighB_uid270_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 30 => redist21_memoryC0_uid248_sinXTables_lutmem_r_1_q(29)) & redist21_memoryC0_uid248_sinXTables_lutmem_r_1_q));
    s2sumAHighB_uid270_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((30 downto 22 => highBBits_uid269_invPolyEval_b(21)) & highBBits_uid269_invPolyEval_b));
    s2sumAHighB_uid270_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(s2sumAHighB_uid270_invPolyEval_a) + SIGNED(s2sumAHighB_uid270_invPolyEval_b));
    s2sumAHighB_uid270_invPolyEval_q <= s2sumAHighB_uid270_invPolyEval_o(30 downto 0);

    -- lowRangeB_uid268_invPolyEval(BITSELECT,267)@26
    lowRangeB_uid268_invPolyEval_in <= redist22_osig_uid277_pT2_uid267_invPolyEval_b_1_q(1 downto 0);
    lowRangeB_uid268_invPolyEval_b <= lowRangeB_uid268_invPolyEval_in(1 downto 0);

    -- s2_uid271_invPolyEval(BITJOIN,270)@26
    s2_uid271_invPolyEval_q <= s2sumAHighB_uid270_invPolyEval_q & lowRangeB_uid268_invPolyEval_b;

    -- fxpSinRes_uid121_fpCosPiTest(BITSELECT,120)@26
    fxpSinRes_uid121_fpCosPiTest_in <= s2_uid271_invPolyEval_q(30 downto 0);
    fxpSinRes_uid121_fpCosPiTest_b <= fxpSinRes_uid121_fpCosPiTest_in(30 downto 5);

    -- redist43_fxpSinRes_uid121_fpCosPiTest_b_1(DELAY,483)
    redist43_fxpSinRes_uid121_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 26, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fxpSinRes_uid121_fpCosPiTest_b, xout => redist43_fxpSinRes_uid121_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest(BITSELECT,390)@25
    leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q(63 downto 0);
    leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_in(63 downto 0);

    -- leftShiftStage3Idx1_uid392_alignedZ_uid113_fpCosPiTest(BITJOIN,391)@25
    leftShiftStage3Idx1_uid392_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage3Idx1Rng1_uid391_alignedZ_uid113_fpCosPiTest_b & GND_q;

    -- leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest(BITSELECT,385)@25
    leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q(58 downto 0);
    leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_in(58 downto 0);

    -- leftShiftStage2Idx3Pad6_uid385_alignedZ_uid113_fpCosPiTest(CONSTANT,384)
    leftShiftStage2Idx3Pad6_uid385_alignedZ_uid113_fpCosPiTest_q <= "000000";

    -- leftShiftStage2Idx3_uid387_alignedZ_uid113_fpCosPiTest(BITJOIN,386)@25
    leftShiftStage2Idx3_uid387_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx3Rng6_uid386_alignedZ_uid113_fpCosPiTest_b & leftShiftStage2Idx3Pad6_uid385_alignedZ_uid113_fpCosPiTest_q;

    -- leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest(BITSELECT,382)@25
    leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q(60 downto 0);
    leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_in(60 downto 0);

    -- leftShiftStage2Idx2_uid384_alignedZ_uid113_fpCosPiTest(BITJOIN,383)@25
    leftShiftStage2Idx2_uid384_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx2Rng4_uid383_alignedZ_uid113_fpCosPiTest_b & zs_uid188_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest(BITSELECT,379)@25
    leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q(62 downto 0);
    leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_in(62 downto 0);

    -- leftShiftStage2Idx1_uid381_alignedZ_uid113_fpCosPiTest(BITJOIN,380)@25
    leftShiftStage2Idx1_uid381_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx1Rng2_uid380_alignedZ_uid113_fpCosPiTest_b & zs_uid194_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest(BITSELECT,374)@25
    leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q(40 downto 0);
    leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_in(40 downto 0);

    -- leftShiftStage1Idx3Pad24_uid374_alignedZ_uid113_fpCosPiTest(CONSTANT,373)
    leftShiftStage1Idx3Pad24_uid374_alignedZ_uid113_fpCosPiTest_q <= "000000000000000000000000";

    -- leftShiftStage1Idx3_uid376_alignedZ_uid113_fpCosPiTest(BITJOIN,375)@25
    leftShiftStage1Idx3_uid376_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx3Rng24_uid375_alignedZ_uid113_fpCosPiTest_b & leftShiftStage1Idx3Pad24_uid374_alignedZ_uid113_fpCosPiTest_q;

    -- leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest(BITSELECT,371)@25
    leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q(48 downto 0);
    leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_in(48 downto 0);

    -- leftShiftStage1Idx2_uid373_alignedZ_uid113_fpCosPiTest(BITJOIN,372)@25
    leftShiftStage1Idx2_uid373_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx2Rng16_uid372_alignedZ_uid113_fpCosPiTest_b & zs_uid176_zCount_uid58_fpCosPiTest_q;

    -- leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest(BITSELECT,368)@25
    leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_in <= leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q(56 downto 0);
    leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_in(56 downto 0);

    -- leftShiftStage1Idx1_uid370_alignedZ_uid113_fpCosPiTest(BITJOIN,369)@25
    leftShiftStage1Idx1_uid370_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx1Rng8_uid369_alignedZ_uid113_fpCosPiTest_b & cstAllZWE_uid8_fpCosPiTest_q;

    -- cstZmwFRRPwSM1_uid95_fpCosPiTest(CONSTANT,94)
    cstZmwFRRPwSM1_uid95_fpCosPiTest_q <= "00000000000000000000000000000000000000000000000000000000000000000";

    -- vStage_uid209_lzcZ_uid112_fpCosPiTest(BITSELECT,208)@20
    vStage_uid209_lzcZ_uid112_fpCosPiTest_in <= redist49_z_uid110_fpCosPiTest_q_2_q(0 downto 0);
    vStage_uid209_lzcZ_uid112_fpCosPiTest_b <= vStage_uid209_lzcZ_uid112_fpCosPiTest_in(0 downto 0);

    -- redist29_vStage_uid209_lzcZ_uid112_fpCosPiTest_b_4(DELAY,469)
    redist29_vStage_uid209_lzcZ_uid112_fpCosPiTest_b_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => vStage_uid209_lzcZ_uid112_fpCosPiTest_b, xout => redist29_vStage_uid209_lzcZ_uid112_fpCosPiTest_b_4_q, clk => clk, aclr => areset );

    -- zs_uid205_lzcZ_uid112_fpCosPiTest(CONSTANT,204)
    zs_uid205_lzcZ_uid112_fpCosPiTest_q <= "0000000000000000000000000000000000000000000000000000000000000000";

    -- leftShiftStage0Idx2_uid364_alignedZ_uid113_fpCosPiTest(BITJOIN,363)@24
    leftShiftStage0Idx2_uid364_alignedZ_uid113_fpCosPiTest_q <= redist29_vStage_uid209_lzcZ_uid112_fpCosPiTest_b_4_q & zs_uid205_lzcZ_uid112_fpCosPiTest_q;

    -- leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest(BITSELECT,359)@24
    leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_in <= redist50_z_uid110_fpCosPiTest_q_6_outputreg_q(32 downto 0);
    leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_b <= leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_in(32 downto 0);

    -- leftShiftStage0Idx1_uid361_alignedZ_uid113_fpCosPiTest(BITJOIN,360)@24
    leftShiftStage0Idx1_uid361_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage0Idx1Rng32_uid360_alignedZ_uid113_fpCosPiTest_b & zs_uid170_zCount_uid58_fpCosPiTest_q;

    -- redist50_z_uid110_fpCosPiTest_q_6_inputreg(DELAY,537)
    redist50_z_uid110_fpCosPiTest_q_6_inputreg : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist49_z_uid110_fpCosPiTest_q_2_q, xout => redist50_z_uid110_fpCosPiTest_q_6_inputreg_q, clk => clk, aclr => areset );

    -- redist50_z_uid110_fpCosPiTest_q_6(DELAY,490)
    redist50_z_uid110_fpCosPiTest_q_6 : dspba_delay
    GENERIC MAP ( width => 65, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist50_z_uid110_fpCosPiTest_q_6_inputreg_q, xout => redist50_z_uid110_fpCosPiTest_q_6_q, clk => clk, aclr => areset );

    -- redist50_z_uid110_fpCosPiTest_q_6_outputreg(DELAY,538)
    redist50_z_uid110_fpCosPiTest_q_6_outputreg : dspba_delay
    GENERIC MAP ( width => 65, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist50_z_uid110_fpCosPiTest_q_6_q, xout => redist50_z_uid110_fpCosPiTest_q_6_outputreg_q, clk => clk, aclr => areset );

    -- rVStage_uid206_lzcZ_uid112_fpCosPiTest(BITSELECT,205)@19
    rVStage_uid206_lzcZ_uid112_fpCosPiTest_b <= redist48_z_uid110_fpCosPiTest_q_1_q(64 downto 1);

    -- vCount_uid207_lzcZ_uid112_fpCosPiTest(LOGICAL,206)@19 + 1
    vCount_uid207_lzcZ_uid112_fpCosPiTest_qi <= "1" WHEN rVStage_uid206_lzcZ_uid112_fpCosPiTest_b = zs_uid205_lzcZ_uid112_fpCosPiTest_q ELSE "0";
    vCount_uid207_lzcZ_uid112_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid207_lzcZ_uid112_fpCosPiTest_qi, xout => vCount_uid207_lzcZ_uid112_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist30_vCount_uid207_lzcZ_uid112_fpCosPiTest_q_5(DELAY,470)
    redist30_vCount_uid207_lzcZ_uid112_fpCosPiTest_q_5 : dspba_delay
    GENERIC MAP ( width => 1, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid207_lzcZ_uid112_fpCosPiTest_q, xout => redist30_vCount_uid207_lzcZ_uid112_fpCosPiTest_q_5_q, clk => clk, aclr => areset );

    -- mO_uid208_lzcZ_uid112_fpCosPiTest(CONSTANT,207)
    mO_uid208_lzcZ_uid112_fpCosPiTest_q <= "111111111111111111111111111111111111111111111111111111111111111";

    -- cStage_uid210_lzcZ_uid112_fpCosPiTest(BITJOIN,209)@20
    cStage_uid210_lzcZ_uid112_fpCosPiTest_q <= vStage_uid209_lzcZ_uid112_fpCosPiTest_b & mO_uid208_lzcZ_uid112_fpCosPiTest_q;

    -- redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1(DELAY,471)
    redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 64, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid206_lzcZ_uid112_fpCosPiTest_b, xout => redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid212_lzcZ_uid112_fpCosPiTest(MUX,211)@20
    vStagei_uid212_lzcZ_uid112_fpCosPiTest_s <= vCount_uid207_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid212_lzcZ_uid112_fpCosPiTest_combproc: PROCESS (vStagei_uid212_lzcZ_uid112_fpCosPiTest_s, redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1_q, cStage_uid210_lzcZ_uid112_fpCosPiTest_q)
    BEGIN
        CASE (vStagei_uid212_lzcZ_uid112_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid212_lzcZ_uid112_fpCosPiTest_q <= redist31_rVStage_uid206_lzcZ_uid112_fpCosPiTest_b_1_q;
            WHEN "1" => vStagei_uid212_lzcZ_uid112_fpCosPiTest_q <= cStage_uid210_lzcZ_uid112_fpCosPiTest_q;
            WHEN OTHERS => vStagei_uid212_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select(BITSELECT,432)@20
    rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b <= vStagei_uid212_lzcZ_uid112_fpCosPiTest_q(63 downto 32);
    rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c <= vStagei_uid212_lzcZ_uid112_fpCosPiTest_q(31 downto 0);

    -- vCount_uid215_lzcZ_uid112_fpCosPiTest(LOGICAL,214)@20 + 1
    vCount_uid215_lzcZ_uid112_fpCosPiTest_qi <= "1" WHEN rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b = zs_uid170_zCount_uid58_fpCosPiTest_q ELSE "0";
    vCount_uid215_lzcZ_uid112_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid215_lzcZ_uid112_fpCosPiTest_qi, xout => vCount_uid215_lzcZ_uid112_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist28_vCount_uid215_lzcZ_uid112_fpCosPiTest_q_4(DELAY,468)
    redist28_vCount_uid215_lzcZ_uid112_fpCosPiTest_q_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid215_lzcZ_uid112_fpCosPiTest_q, xout => redist28_vCount_uid215_lzcZ_uid112_fpCosPiTest_q_4_q, clk => clk, aclr => areset );

    -- redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1(DELAY,450)
    redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c, xout => redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1(DELAY,449)
    redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b, xout => redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid218_lzcZ_uid112_fpCosPiTest(MUX,217)@21
    vStagei_uid218_lzcZ_uid112_fpCosPiTest_s <= vCount_uid215_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid218_lzcZ_uid112_fpCosPiTest_combproc: PROCESS (vStagei_uid218_lzcZ_uid112_fpCosPiTest_s, redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid218_lzcZ_uid112_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid218_lzcZ_uid112_fpCosPiTest_q <= redist9_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid218_lzcZ_uid112_fpCosPiTest_q <= redist10_rVStage_uid214_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid218_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select(BITSELECT,433)@21
    rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b <= vStagei_uid218_lzcZ_uid112_fpCosPiTest_q(31 downto 16);
    rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c <= vStagei_uid218_lzcZ_uid112_fpCosPiTest_q(15 downto 0);

    -- vCount_uid221_lzcZ_uid112_fpCosPiTest(LOGICAL,220)@21 + 1
    vCount_uid221_lzcZ_uid112_fpCosPiTest_qi <= "1" WHEN rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b = zs_uid176_zCount_uid58_fpCosPiTest_q ELSE "0";
    vCount_uid221_lzcZ_uid112_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid221_lzcZ_uid112_fpCosPiTest_qi, xout => vCount_uid221_lzcZ_uid112_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist27_vCount_uid221_lzcZ_uid112_fpCosPiTest_q_3(DELAY,467)
    redist27_vCount_uid221_lzcZ_uid112_fpCosPiTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid221_lzcZ_uid112_fpCosPiTest_q, xout => redist27_vCount_uid221_lzcZ_uid112_fpCosPiTest_q_3_q, clk => clk, aclr => areset );

    -- redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1(DELAY,448)
    redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 16, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c, xout => redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1(DELAY,447)
    redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 16, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b, xout => redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid224_lzcZ_uid112_fpCosPiTest(MUX,223)@22
    vStagei_uid224_lzcZ_uid112_fpCosPiTest_s <= vCount_uid221_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid224_lzcZ_uid112_fpCosPiTest_combproc: PROCESS (vStagei_uid224_lzcZ_uid112_fpCosPiTest_s, redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid224_lzcZ_uid112_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid224_lzcZ_uid112_fpCosPiTest_q <= redist7_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid224_lzcZ_uid112_fpCosPiTest_q <= redist8_rVStage_uid220_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid224_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select(BITSELECT,434)@22
    rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b <= vStagei_uid224_lzcZ_uid112_fpCosPiTest_q(15 downto 8);
    rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c <= vStagei_uid224_lzcZ_uid112_fpCosPiTest_q(7 downto 0);

    -- vCount_uid227_lzcZ_uid112_fpCosPiTest(LOGICAL,226)@22 + 1
    vCount_uid227_lzcZ_uid112_fpCosPiTest_qi <= "1" WHEN rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b = cstAllZWE_uid8_fpCosPiTest_q ELSE "0";
    vCount_uid227_lzcZ_uid112_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid227_lzcZ_uid112_fpCosPiTest_qi, xout => vCount_uid227_lzcZ_uid112_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist26_vCount_uid227_lzcZ_uid112_fpCosPiTest_q_2(DELAY,466)
    redist26_vCount_uid227_lzcZ_uid112_fpCosPiTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid227_lzcZ_uid112_fpCosPiTest_q, xout => redist26_vCount_uid227_lzcZ_uid112_fpCosPiTest_q_2_q, clk => clk, aclr => areset );

    -- redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1(DELAY,446)
    redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c, xout => redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1(DELAY,445)
    redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b, xout => redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid230_lzcZ_uid112_fpCosPiTest(MUX,229)@23
    vStagei_uid230_lzcZ_uid112_fpCosPiTest_s <= vCount_uid227_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid230_lzcZ_uid112_fpCosPiTest_combproc: PROCESS (vStagei_uid230_lzcZ_uid112_fpCosPiTest_s, redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q, redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid230_lzcZ_uid112_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid230_lzcZ_uid112_fpCosPiTest_q <= redist5_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid230_lzcZ_uid112_fpCosPiTest_q <= redist6_rVStage_uid226_lzcZ_uid112_fpCosPiTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid230_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select(BITSELECT,435)@23
    rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_b <= vStagei_uid230_lzcZ_uid112_fpCosPiTest_q(7 downto 4);
    rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_c <= vStagei_uid230_lzcZ_uid112_fpCosPiTest_q(3 downto 0);

    -- vCount_uid233_lzcZ_uid112_fpCosPiTest(LOGICAL,232)@23
    vCount_uid233_lzcZ_uid112_fpCosPiTest_q <= "1" WHEN rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_b = zs_uid188_zCount_uid58_fpCosPiTest_q ELSE "0";

    -- redist25_vCount_uid233_lzcZ_uid112_fpCosPiTest_q_1(DELAY,465)
    redist25_vCount_uid233_lzcZ_uid112_fpCosPiTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid233_lzcZ_uid112_fpCosPiTest_q, xout => redist25_vCount_uid233_lzcZ_uid112_fpCosPiTest_q_1_q, clk => clk, aclr => areset );

    -- vStagei_uid236_lzcZ_uid112_fpCosPiTest(MUX,235)@23 + 1
    vStagei_uid236_lzcZ_uid112_fpCosPiTest_s <= vCount_uid233_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid236_lzcZ_uid112_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid236_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid236_lzcZ_uid112_fpCosPiTest_s) IS
                WHEN "0" => vStagei_uid236_lzcZ_uid112_fpCosPiTest_q <= rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_b;
                WHEN "1" => vStagei_uid236_lzcZ_uid112_fpCosPiTest_q <= rVStage_uid232_lzcZ_uid112_fpCosPiTest_merged_bit_select_c;
                WHEN OTHERS => vStagei_uid236_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select(BITSELECT,436)@24
    rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_b <= vStagei_uid236_lzcZ_uid112_fpCosPiTest_q(3 downto 2);
    rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_c <= vStagei_uid236_lzcZ_uid112_fpCosPiTest_q(1 downto 0);

    -- vCount_uid239_lzcZ_uid112_fpCosPiTest(LOGICAL,238)@24
    vCount_uid239_lzcZ_uid112_fpCosPiTest_q <= "1" WHEN rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_b = zs_uid194_zCount_uid58_fpCosPiTest_q ELSE "0";

    -- vStagei_uid242_lzcZ_uid112_fpCosPiTest(MUX,241)@24
    vStagei_uid242_lzcZ_uid112_fpCosPiTest_s <= vCount_uid239_lzcZ_uid112_fpCosPiTest_q;
    vStagei_uid242_lzcZ_uid112_fpCosPiTest_combproc: PROCESS (vStagei_uid242_lzcZ_uid112_fpCosPiTest_s, rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_b, rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid242_lzcZ_uid112_fpCosPiTest_s) IS
            WHEN "0" => vStagei_uid242_lzcZ_uid112_fpCosPiTest_q <= rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid242_lzcZ_uid112_fpCosPiTest_q <= rVStage_uid238_lzcZ_uid112_fpCosPiTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid242_lzcZ_uid112_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid244_lzcZ_uid112_fpCosPiTest(BITSELECT,243)@24
    rVStage_uid244_lzcZ_uid112_fpCosPiTest_b <= vStagei_uid242_lzcZ_uid112_fpCosPiTest_q(1 downto 1);

    -- vCount_uid245_lzcZ_uid112_fpCosPiTest(LOGICAL,244)@24
    vCount_uid245_lzcZ_uid112_fpCosPiTest_q <= "1" WHEN rVStage_uid244_lzcZ_uid112_fpCosPiTest_b = GND_q ELSE "0";

    -- r_uid246_lzcZ_uid112_fpCosPiTest(BITJOIN,245)@24
    r_uid246_lzcZ_uid112_fpCosPiTest_q <= redist30_vCount_uid207_lzcZ_uid112_fpCosPiTest_q_5_q & redist28_vCount_uid215_lzcZ_uid112_fpCosPiTest_q_4_q & redist27_vCount_uid221_lzcZ_uid112_fpCosPiTest_q_3_q & redist26_vCount_uid227_lzcZ_uid112_fpCosPiTest_q_2_q & redist25_vCount_uid233_lzcZ_uid112_fpCosPiTest_q_1_q & vCount_uid239_lzcZ_uid112_fpCosPiTest_q & vCount_uid245_lzcZ_uid112_fpCosPiTest_q;

    -- leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select(BITSELECT,437)@24
    leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_b <= r_uid246_lzcZ_uid112_fpCosPiTest_q(6 downto 5);
    leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c <= r_uid246_lzcZ_uid112_fpCosPiTest_q(4 downto 3);
    leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d <= r_uid246_lzcZ_uid112_fpCosPiTest_q(2 downto 1);
    leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e <= r_uid246_lzcZ_uid112_fpCosPiTest_q(0 downto 0);

    -- leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest(MUX,366)@24 + 1
    leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_s <= leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_b;
    leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_s) IS
                WHEN "00" => leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= redist50_z_uid110_fpCosPiTest_q_6_outputreg_q;
                WHEN "01" => leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage0Idx1_uid361_alignedZ_uid113_fpCosPiTest_q;
                WHEN "10" => leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage0Idx2_uid364_alignedZ_uid113_fpCosPiTest_q;
                WHEN "11" => leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= cstZmwFRRPwSM1_uid95_fpCosPiTest_q;
                WHEN OTHERS => leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist2_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c_1(DELAY,442)
    redist2_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c, xout => redist2_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest(MUX,377)@25
    leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_s <= redist2_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_c_1_q;
    leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_combproc: PROCESS (leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_s, leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q, leftShiftStage1Idx1_uid370_alignedZ_uid113_fpCosPiTest_q, leftShiftStage1Idx2_uid373_alignedZ_uid113_fpCosPiTest_q, leftShiftStage1Idx3_uid376_alignedZ_uid113_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage0_uid367_alignedZ_uid113_fpCosPiTest_q;
            WHEN "01" => leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx1_uid370_alignedZ_uid113_fpCosPiTest_q;
            WHEN "10" => leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx2_uid373_alignedZ_uid113_fpCosPiTest_q;
            WHEN "11" => leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1Idx3_uid376_alignedZ_uid113_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist3_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d_1(DELAY,443)
    redist3_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d, xout => redist3_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d_1_q, clk => clk, aclr => areset );

    -- leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest(MUX,388)@25
    leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_s <= redist3_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_d_1_q;
    leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_combproc: PROCESS (leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_s, leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q, leftShiftStage2Idx1_uid381_alignedZ_uid113_fpCosPiTest_q, leftShiftStage2Idx2_uid384_alignedZ_uid113_fpCosPiTest_q, leftShiftStage2Idx3_uid387_alignedZ_uid113_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_s) IS
            WHEN "00" => leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage1_uid378_alignedZ_uid113_fpCosPiTest_q;
            WHEN "01" => leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx1_uid381_alignedZ_uid113_fpCosPiTest_q;
            WHEN "10" => leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx2_uid384_alignedZ_uid113_fpCosPiTest_q;
            WHEN "11" => leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2Idx3_uid387_alignedZ_uid113_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist4_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e_1(DELAY,444)
    redist4_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e, xout => redist4_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e_1_q, clk => clk, aclr => areset );

    -- leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest(MUX,393)@25
    leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_s <= redist4_leftShiftStageSel6Dto5_uid366_alignedZ_uid113_fpCosPiTest_merged_bit_select_e_1_q;
    leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_combproc: PROCESS (leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_s, leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q, leftShiftStage3Idx1_uid392_alignedZ_uid113_fpCosPiTest_q)
    BEGIN
        CASE (leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_s) IS
            WHEN "0" => leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage2_uid389_alignedZ_uid113_fpCosPiTest_q;
            WHEN "1" => leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_q <= leftShiftStage3Idx1_uid392_alignedZ_uid113_fpCosPiTest_q;
            WHEN OTHERS => leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- p_uid114_fpCosPiTest(BITSELECT,113)@25
    p_uid114_fpCosPiTest_b <= leftShiftStage3_uid394_alignedZ_uid113_fpCosPiTest_q(64 downto 39);

    -- redist47_p_uid114_fpCosPiTest_b_2(DELAY,487)
    redist47_p_uid114_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 26, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => p_uid114_fpCosPiTest_b, xout => redist47_p_uid114_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- mul2xSinRes_uid122_fpCosPiTest_cma(CHAINMULTADD,418)@27 + 2
    mul2xSinRes_uid122_fpCosPiTest_cma_reset <= areset;
    mul2xSinRes_uid122_fpCosPiTest_cma_ena0 <= '1';
    mul2xSinRes_uid122_fpCosPiTest_cma_ena1 <= mul2xSinRes_uid122_fpCosPiTest_cma_ena0;
    mul2xSinRes_uid122_fpCosPiTest_cma_p(0) <= mul2xSinRes_uid122_fpCosPiTest_cma_a0(0) * mul2xSinRes_uid122_fpCosPiTest_cma_c0(0);
    mul2xSinRes_uid122_fpCosPiTest_cma_u(0) <= RESIZE(mul2xSinRes_uid122_fpCosPiTest_cma_p(0),52);
    mul2xSinRes_uid122_fpCosPiTest_cma_w(0) <= mul2xSinRes_uid122_fpCosPiTest_cma_u(0);
    mul2xSinRes_uid122_fpCosPiTest_cma_x(0) <= mul2xSinRes_uid122_fpCosPiTest_cma_w(0);
    mul2xSinRes_uid122_fpCosPiTest_cma_y(0) <= mul2xSinRes_uid122_fpCosPiTest_cma_x(0);
    mul2xSinRes_uid122_fpCosPiTest_cma_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            mul2xSinRes_uid122_fpCosPiTest_cma_a0 <= (others => (others => '0'));
            mul2xSinRes_uid122_fpCosPiTest_cma_c0 <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (mul2xSinRes_uid122_fpCosPiTest_cma_ena0 = '1') THEN
                mul2xSinRes_uid122_fpCosPiTest_cma_a0(0) <= RESIZE(UNSIGNED(redist47_p_uid114_fpCosPiTest_b_2_q),26);
                mul2xSinRes_uid122_fpCosPiTest_cma_c0(0) <= RESIZE(UNSIGNED(redist43_fxpSinRes_uid121_fpCosPiTest_b_1_q),26);
            END IF;
        END IF;
    END PROCESS;
    mul2xSinRes_uid122_fpCosPiTest_cma_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            mul2xSinRes_uid122_fpCosPiTest_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (mul2xSinRes_uid122_fpCosPiTest_cma_ena1 = '1') THEN
                mul2xSinRes_uid122_fpCosPiTest_cma_s(0) <= mul2xSinRes_uid122_fpCosPiTest_cma_y(0);
            END IF;
        END IF;
    END PROCESS;
    mul2xSinRes_uid122_fpCosPiTest_cma_delay : dspba_delay
    GENERIC MAP ( width => 52, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(mul2xSinRes_uid122_fpCosPiTest_cma_s(0)(51 downto 0)), xout => mul2xSinRes_uid122_fpCosPiTest_cma_qq, clk => clk, aclr => areset );
    mul2xSinRes_uid122_fpCosPiTest_cma_q <= STD_LOGIC_VECTOR(mul2xSinRes_uid122_fpCosPiTest_cma_qq(51 downto 0));

    -- normBit_uid123_fpCosPiTest(BITSELECT,122)@29
    normBit_uid123_fpCosPiTest_b <= STD_LOGIC_VECTOR(mul2xSinRes_uid122_fpCosPiTest_cma_q(51 downto 51));

    -- redist42_normBit_uid123_fpCosPiTest_b_1(DELAY,482)
    redist42_normBit_uid123_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => normBit_uid123_fpCosPiTest_b, xout => redist42_normBit_uid123_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- rndOp_uid132_fpCosPiTest(BITJOIN,131)@30
    rndOp_uid132_fpCosPiTest_q <= redist42_normBit_uid123_fpCosPiTest_b_1_q & cstZeroWF_uid7_fpCosPiTest_q & VCC_q;

    -- redist24_r_uid246_lzcZ_uid112_fpCosPiTest_q_5(DELAY,464)
    redist24_r_uid246_lzcZ_uid112_fpCosPiTest_q_5 : dspba_delay
    GENERIC MAP ( width => 7, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => r_uid246_lzcZ_uid112_fpCosPiTest_q, xout => redist24_r_uid246_lzcZ_uid112_fpCosPiTest_q_5_q, clk => clk, aclr => areset );

    -- expP_uid116_fpCosPiTest(SUB,115)@29 + 1
    expP_uid116_fpCosPiTest_a <= STD_LOGIC_VECTOR("0" & biasM1_uid40_fpCosPiTest_q);
    expP_uid116_fpCosPiTest_b <= STD_LOGIC_VECTOR("00" & redist24_r_uid246_lzcZ_uid112_fpCosPiTest_q_5_q);
    expP_uid116_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expP_uid116_fpCosPiTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expP_uid116_fpCosPiTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expP_uid116_fpCosPiTest_a) - UNSIGNED(expP_uid116_fpCosPiTest_b));
        END IF;
    END PROCESS;
    expP_uid116_fpCosPiTest_q <= expP_uid116_fpCosPiTest_o(8 downto 0);

    -- highRes_uid124_fpCosPiTest(BITSELECT,123)@29
    highRes_uid124_fpCosPiTest_in <= mul2xSinRes_uid122_fpCosPiTest_cma_q(50 downto 0);
    highRes_uid124_fpCosPiTest_b <= highRes_uid124_fpCosPiTest_in(50 downto 27);

    -- lowRes_uid125_fpCosPiTest(BITSELECT,124)@29
    lowRes_uid125_fpCosPiTest_in <= mul2xSinRes_uid122_fpCosPiTest_cma_q(49 downto 0);
    lowRes_uid125_fpCosPiTest_b <= lowRes_uid125_fpCosPiTest_in(49 downto 26);

    -- fracRCompPreRnd_uid126_fpCosPiTest(MUX,125)@29 + 1
    fracRCompPreRnd_uid126_fpCosPiTest_s <= normBit_uid123_fpCosPiTest_b;
    fracRCompPreRnd_uid126_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRCompPreRnd_uid126_fpCosPiTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRCompPreRnd_uid126_fpCosPiTest_s) IS
                WHEN "0" => fracRCompPreRnd_uid126_fpCosPiTest_q <= lowRes_uid125_fpCosPiTest_b;
                WHEN "1" => fracRCompPreRnd_uid126_fpCosPiTest_q <= highRes_uid124_fpCosPiTest_b;
                WHEN OTHERS => fracRCompPreRnd_uid126_fpCosPiTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- expRCompFracRCompPreRnd_uid127_fpCosPiTest(BITJOIN,126)@30
    expRCompFracRCompPreRnd_uid127_fpCosPiTest_q <= expP_uid116_fpCosPiTest_q & fracRCompPreRnd_uid126_fpCosPiTest_q;

    -- expRCompFracRComp_uid133_fpCosPiTest(ADD,132)@30
    expRCompFracRComp_uid133_fpCosPiTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 33 => expRCompFracRCompPreRnd_uid127_fpCosPiTest_q(32)) & expRCompFracRCompPreRnd_uid127_fpCosPiTest_q));
    expRCompFracRComp_uid133_fpCosPiTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0000000000" & rndOp_uid132_fpCosPiTest_q));
    expRCompFracRComp_uid133_fpCosPiTest_o <= STD_LOGIC_VECTOR(SIGNED(expRCompFracRComp_uid133_fpCosPiTest_a) + SIGNED(expRCompFracRComp_uid133_fpCosPiTest_b));
    expRCompFracRComp_uid133_fpCosPiTest_q <= expRCompFracRComp_uid133_fpCosPiTest_o(33 downto 0);

    -- expRComp_uid135_fpCosPiTest(BITSELECT,134)@30
    expRComp_uid135_fpCosPiTest_in <= expRCompFracRComp_uid133_fpCosPiTest_q(31 downto 0);
    expRComp_uid135_fpCosPiTest_b <= expRComp_uid135_fpCosPiTest_in(31 downto 24);

    -- redist40_expRComp_uid135_fpCosPiTest_b_2(DELAY,480)
    redist40_expRComp_uid135_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRComp_uid135_fpCosPiTest_b, xout => redist40_expRComp_uid135_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- redist60_cosXIsOne_uid88_fpCosPiTest_n_31(DELAY,500)
    redist60_cosXIsOne_uid88_fpCosPiTest_n_31 : dspba_delay
    GENERIC MAP ( width => 1, depth => 13, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist59_cosXIsOne_uid88_fpCosPiTest_n_18_q, xout => redist60_cosXIsOne_uid88_fpCosPiTest_n_31_q, clk => clk, aclr => areset );

    -- redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17(DELAY,498)
    redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17 : dspba_delay
    GENERIC MAP ( width => 1, depth => 13, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist57_cosXIsOneXRR_uid89_fpCosPiTest_n_4_q, xout => redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17_q, clk => clk, aclr => areset );

    -- invCosXIsOneXRR_uid139_fpCosPiTest(LOGICAL,138)@31
    invCosXIsOneXRR_uid139_fpCosPiTest_q <= not (redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17_q);

    -- invCosXIsOne_uid138_fpCosPiTest(LOGICAL,137)@31
    invCosXIsOne_uid138_fpCosPiTest_q <= not (redist60_cosXIsOne_uid88_fpCosPiTest_n_31_q);

    -- half_uid97_fpCosPiTest(BITJOIN,96)@17
    half_uid97_fpCosPiTest_q <= VCC_q & cstZmwFRRPwSM1_uid95_fpCosPiTest_q;

    -- updatedY_uid99_fpCosPiTest(BITJOIN,98)@17
    updatedY_uid99_fpCosPiTest_q <= half_uid97_fpCosPiTest_q & paddingY_uid92_fpCosPiTest_q;

    -- yIsHalf_uid98_fpCosPiTest(LOGICAL,99)@17 + 1
    yIsHalf_uid98_fpCosPiTest_a <= STD_LOGIC_VECTOR("000000000000000000000000000000000000000000000000000000000000000000" & redist55_y_uid91_fpCosPiTest_b_2_q);
    yIsHalf_uid98_fpCosPiTest_qi <= "1" WHEN yIsHalf_uid98_fpCosPiTest_a = updatedY_uid99_fpCosPiTest_q ELSE "0";
    yIsHalf_uid98_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => yIsHalf_uid98_fpCosPiTest_qi, xout => yIsHalf_uid98_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist53_yIsHalf_uid98_fpCosPiTest_q_14(DELAY,493)
    redist53_yIsHalf_uid98_fpCosPiTest_q_14 : dspba_delay
    GENERIC MAP ( width => 1, depth => 13, reset_kind => "ASYNC" )
    PORT MAP ( xin => yIsHalf_uid98_fpCosPiTest_q, xout => redist53_yIsHalf_uid98_fpCosPiTest_q_14_q, clk => clk, aclr => areset );

    -- yHalfCosNotONe_uid140_fpCosPiTest(LOGICAL,139)@31
    yHalfCosNotONe_uid140_fpCosPiTest_q <= redist53_yIsHalf_uid98_fpCosPiTest_q_14_q and invCosXIsOne_uid138_fpCosPiTest_q and invCosXIsOneXRR_uid139_fpCosPiTest_q;

    -- expRCosIsNeg_uid137_fpCosPiTest(BITSELECT,136)@30
    expRCosIsNeg_uid137_fpCosPiTest_in <= STD_LOGIC_VECTOR(expRCompFracRComp_uid133_fpCosPiTest_q(32 downto 0));
    expRCosIsNeg_uid137_fpCosPiTest_b <= STD_LOGIC_VECTOR(expRCosIsNeg_uid137_fpCosPiTest_in(32 downto 32));

    -- redist39_expRCosIsNeg_uid137_fpCosPiTest_b_1(DELAY,479)
    redist39_expRCosIsNeg_uid137_fpCosPiTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRCosIsNeg_uid137_fpCosPiTest_b, xout => redist39_expRCosIsNeg_uid137_fpCosPiTest_b_1_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid17_fpCosPiTest(LOGICAL,16)@19
    invExpXIsMax_uid17_fpCosPiTest_q <= not (redist72_expXIsMax_uid12_fpCosPiTest_q_19_q);

    -- excZ_x_uid11_fpCosPiTest(LOGICAL,10)@0 + 1
    excZ_x_uid11_fpCosPiTest_qi <= "1" WHEN exp_x_uid9_fpCosPiTest_b = cstAllZWE_uid8_fpCosPiTest_q ELSE "0";
    excZ_x_uid11_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid11_fpCosPiTest_qi, xout => excZ_x_uid11_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist73_excZ_x_uid11_fpCosPiTest_q_19(DELAY,513)
    redist73_excZ_x_uid11_fpCosPiTest_q_19 : dspba_delay
    GENERIC MAP ( width => 1, depth => 18, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid11_fpCosPiTest_q, xout => redist73_excZ_x_uid11_fpCosPiTest_q_19_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid18_fpCosPiTest(LOGICAL,17)@19
    InvExpXIsZero_uid18_fpCosPiTest_q <= not (redist73_excZ_x_uid11_fpCosPiTest_q_19_q);

    -- excR_x_uid19_fpCosPiTest(LOGICAL,18)@19 + 1
    excR_x_uid19_fpCosPiTest_qi <= InvExpXIsZero_uid18_fpCosPiTest_q and invExpXIsMax_uid17_fpCosPiTest_q;
    excR_x_uid19_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_x_uid19_fpCosPiTest_qi, xout => excR_x_uid19_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist70_excR_x_uid19_fpCosPiTest_q_12(DELAY,510)
    redist70_excR_x_uid19_fpCosPiTest_q_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_x_uid19_fpCosPiTest_q, xout => redist70_excR_x_uid19_fpCosPiTest_q_12_q, clk => clk, aclr => areset );

    -- cosUnderflow_uid141_fpCosPiTest(LOGICAL,140)@31
    cosUnderflow_uid141_fpCosPiTest_q <= redist70_excR_x_uid19_fpCosPiTest_q_12_q and redist39_expRCosIsNeg_uid137_fpCosPiTest_b_1_q and invCosXIsOne_uid138_fpCosPiTest_q and invCosXIsOneXRR_uid139_fpCosPiTest_q;

    -- excRZeroCos_uid142_fpCosPiTest(LOGICAL,141)@31
    excRZeroCos_uid142_fpCosPiTest_q <= cosUnderflow_uid141_fpCosPiTest_q or yHalfCosNotONe_uid140_fpCosPiTest_q;

    -- excRNaN_uid143_fpCosPiTest(LOGICAL,142)@19 + 1
    excRNaN_uid143_fpCosPiTest_qi <= excN_x_uid16_fpCosPiTest_q or excI_x_uid15_fpCosPiTest_q;
    excRNaN_uid143_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaN_uid143_fpCosPiTest_qi, xout => excRNaN_uid143_fpCosPiTest_q, clk => clk, aclr => areset );

    -- redist37_excRNaN_uid143_fpCosPiTest_q_12(DELAY,477)
    redist37_excRNaN_uid143_fpCosPiTest_q_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaN_uid143_fpCosPiTest_q, xout => redist37_excRNaN_uid143_fpCosPiTest_q_12_q, clk => clk, aclr => areset );

    -- excConc_uid148_fpCosPiTest(BITJOIN,147)@31
    excConc_uid148_fpCosPiTest_q <= redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17_q & excRZeroCos_uid142_fpCosPiTest_q & redist37_excRNaN_uid143_fpCosPiTest_q_12_q;

    -- expSelBits_uid149_fpCosPiTest(BITJOIN,148)@31
    expSelBits_uid149_fpCosPiTest_q <= redist60_cosXIsOne_uid88_fpCosPiTest_n_31_q & excConc_uid148_fpCosPiTest_q;

    -- expSelector_uid150_fpCosPiTest(LOOKUP,149)@31 + 1
    expSelector_uid150_fpCosPiTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expSelector_uid150_fpCosPiTest_q <= "00";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (expSelBits_uid149_fpCosPiTest_q) IS
                WHEN "0000" => expSelector_uid150_fpCosPiTest_q <= "00";
                WHEN "0001" => expSelector_uid150_fpCosPiTest_q <= "11";
                WHEN "0010" => expSelector_uid150_fpCosPiTest_q <= "10";
                WHEN "0011" => expSelector_uid150_fpCosPiTest_q <= "00";
                WHEN "0100" => expSelector_uid150_fpCosPiTest_q <= "01";
                WHEN "0101" => expSelector_uid150_fpCosPiTest_q <= "11";
                WHEN "0110" => expSelector_uid150_fpCosPiTest_q <= "10";
                WHEN "0111" => expSelector_uid150_fpCosPiTest_q <= "00";
                WHEN "1000" => expSelector_uid150_fpCosPiTest_q <= "01";
                WHEN "1001" => expSelector_uid150_fpCosPiTest_q <= "11";
                WHEN "1010" => expSelector_uid150_fpCosPiTest_q <= "10";
                WHEN "1011" => expSelector_uid150_fpCosPiTest_q <= "00";
                WHEN "1100" => expSelector_uid150_fpCosPiTest_q <= "01";
                WHEN "1101" => expSelector_uid150_fpCosPiTest_q <= "11";
                WHEN "1110" => expSelector_uid150_fpCosPiTest_q <= "10";
                WHEN "1111" => expSelector_uid150_fpCosPiTest_q <= "00";
                WHEN OTHERS => -- unreachable
                               expSelector_uid150_fpCosPiTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- expRPostExc_uid152_fpCosPiTest(MUX,151)@32
    expRPostExc_uid152_fpCosPiTest_s <= expSelector_uid150_fpCosPiTest_q;
    expRPostExc_uid152_fpCosPiTest_combproc: PROCESS (expRPostExc_uid152_fpCosPiTest_s, redist40_expRComp_uid135_fpCosPiTest_b_2_q, cstBias_uid78_fpCosPiTest_q, cstAllZWE_uid8_fpCosPiTest_q, cstAllOWE_uid6_fpCosPiTest_q)
    BEGIN
        CASE (expRPostExc_uid152_fpCosPiTest_s) IS
            WHEN "00" => expRPostExc_uid152_fpCosPiTest_q <= redist40_expRComp_uid135_fpCosPiTest_b_2_q;
            WHEN "01" => expRPostExc_uid152_fpCosPiTest_q <= cstBias_uid78_fpCosPiTest_q;
            WHEN "10" => expRPostExc_uid152_fpCosPiTest_q <= cstAllZWE_uid8_fpCosPiTest_q;
            WHEN "11" => expRPostExc_uid152_fpCosPiTest_q <= cstAllOWE_uid6_fpCosPiTest_q;
            WHEN OTHERS => expRPostExc_uid152_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- cstNaNwF_uid84_fpCosPiTest(CONSTANT,83)
    cstNaNwF_uid84_fpCosPiTest_q <= "00000000000000000000001";

    -- fracRComp_uid134_fpCosPiTest(BITSELECT,133)@30
    fracRComp_uid134_fpCosPiTest_in <= expRCompFracRComp_uid133_fpCosPiTest_q(23 downto 0);
    fracRComp_uid134_fpCosPiTest_b <= fracRComp_uid134_fpCosPiTest_in(23 downto 1);

    -- redist41_fracRComp_uid134_fpCosPiTest_b_2(DELAY,481)
    redist41_fracRComp_uid134_fpCosPiTest_b_2 : dspba_delay
    GENERIC MAP ( width => 23, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRComp_uid134_fpCosPiTest_b, xout => redist41_fracRComp_uid134_fpCosPiTest_b_2_q, clk => clk, aclr => areset );

    -- redist38_excRNaN_uid143_fpCosPiTest_q_13(DELAY,478)
    redist38_excRNaN_uid143_fpCosPiTest_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist37_excRNaN_uid143_fpCosPiTest_q_12_q, xout => redist38_excRNaN_uid143_fpCosPiTest_q_13_q, clk => clk, aclr => areset );

    -- excZOrCosOne_uid144_fpCosPiTest(LOGICAL,143)@31 + 1
    excZOrCosOne_uid144_fpCosPiTest_qi <= excRZeroCos_uid142_fpCosPiTest_q or redist60_cosXIsOne_uid88_fpCosPiTest_n_31_q or redist58_cosXIsOneXRR_uid89_fpCosPiTest_n_17_q;
    excZOrCosOne_uid144_fpCosPiTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZOrCosOne_uid144_fpCosPiTest_qi, xout => excZOrCosOne_uid144_fpCosPiTest_q, clk => clk, aclr => areset );

    -- fracRPostExcSel_uid145_fpCosPiTest(BITJOIN,144)@32
    fracRPostExcSel_uid145_fpCosPiTest_q <= redist38_excRNaN_uid143_fpCosPiTest_q_13_q & excZOrCosOne_uid144_fpCosPiTest_q;

    -- fracRPostExc_uid147_fpCosPiTest(MUX,146)@32
    fracRPostExc_uid147_fpCosPiTest_s <= fracRPostExcSel_uid145_fpCosPiTest_q;
    fracRPostExc_uid147_fpCosPiTest_combproc: PROCESS (fracRPostExc_uid147_fpCosPiTest_s, redist41_fracRComp_uid134_fpCosPiTest_b_2_q, cstZeroWF_uid7_fpCosPiTest_q, cstNaNwF_uid84_fpCosPiTest_q)
    BEGIN
        CASE (fracRPostExc_uid147_fpCosPiTest_s) IS
            WHEN "00" => fracRPostExc_uid147_fpCosPiTest_q <= redist41_fracRComp_uid134_fpCosPiTest_b_2_q;
            WHEN "01" => fracRPostExc_uid147_fpCosPiTest_q <= cstZeroWF_uid7_fpCosPiTest_q;
            WHEN "10" => fracRPostExc_uid147_fpCosPiTest_q <= cstNaNwF_uid84_fpCosPiTest_q;
            WHEN "11" => fracRPostExc_uid147_fpCosPiTest_q <= cstNaNwF_uid84_fpCosPiTest_q;
            WHEN OTHERS => fracRPostExc_uid147_fpCosPiTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- cosx_uid165_fpCosPiTest(BITJOIN,164)@32
    cosx_uid165_fpCosPiTest_q <= redist36_signR_uid164_fpCosPiTest_q_13_q & expRPostExc_uid152_fpCosPiTest_q & fracRPostExc_uid147_fpCosPiTest_q;

    -- xOut(GPOUT,4)@32
    q <= cosx_uid165_fpCosPiTest_q;

END normal;
