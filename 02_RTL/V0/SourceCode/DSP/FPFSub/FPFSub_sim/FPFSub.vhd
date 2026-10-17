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

-- VHDL created from FPFSub
-- VHDL created on Mon Mar 10 16:37:51 2025


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

entity FPFSub is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end FPFSub;

architecture normal of FPFSub is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracX_uid6_fpSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expFracY_uid7_fpSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal xGTEy_uid8_fpSubTest_a : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpSubTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpSubTest_o : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal sigY_uid9_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigY_uid10_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracY_uid11_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expY_uid12_fpSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal ypn_uid13_fpSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal aSig_uid17_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal aSig_uid17_fpSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal bSig_uid18_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal bSig_uid18_fpSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal cstAllOWE_uid19_fpSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid20_fpSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal cstAllZWE_uid21_fpSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_aSig_uid22_fpSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_aSig_uid22_fpSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_aSig_uid23_fpSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_aSig_uid23_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_aSig_uid17_uid24_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_aSig_uid17_uid24_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid25_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid25_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid26_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid26_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid27_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_aSig_uid28_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_aSig_uid28_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_aSig_uid29_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_aSig_uid29_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid30_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid31_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_aSig_uid32_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_aSig_uid32_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal exp_bSig_uid36_fpSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_bSig_uid36_fpSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_bSig_uid37_fpSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_bSig_uid37_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_bSig_uid18_uid38_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_bSig_uid18_uid38_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid39_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid39_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid40_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid40_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid41_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_bSig_uid42_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_bSig_uid42_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_bSig_uid43_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_bSig_uid43_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid44_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid45_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_bSig_uid46_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_bSig_uid46_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigA_uid51_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sigB_uid52_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal effSub_uid53_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracBz_uid57_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracBz_uid57_fpSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal oFracB_uid60_fpSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expAmExpB_uid61_fpSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid61_fpSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid61_fpSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid61_fpSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal oFracA_uid65_fpSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal oFracAE_uid66_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBR_uid68_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid69_fpSubTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid69_fpSubTest_qi : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREX_uid69_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREXC2_uid70_fpSubTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid70_fpSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid70_fpSubTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid70_fpSubTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal oFracBREXC2_uid71_fpSubTest_in : STD_LOGIC_VECTOR (26 downto 0);
    signal oFracBREXC2_uid71_fpSubTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal fracAddResult_uid73_fpSubTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid73_fpSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid73_fpSubTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResult_uid73_fpSubTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal fracAddResultNoSignExt_uid74_fpSubTest_in : STD_LOGIC_VECTOR (26 downto 0);
    signal fracAddResultNoSignExt_uid74_fpSubTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal cAmA_uid77_fpSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal aMinusA_uid78_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal aMinusA_uid78_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expInc_uid79_fpSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid79_fpSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid79_fpSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid79_fpSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expPostNorm_uid80_fpSubTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid80_fpSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid80_fpSubTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNorm_uid80_fpSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fracPostNormRndRange_uid81_fpSubTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal fracPostNormRndRange_uid81_fpSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracR_uid82_fpSubTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal wEP2AllOwE_uid83_fpSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal rndExp_uid84_fpSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rOvf_uid85_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal rOvf_uid85_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rUdf_uid86_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExc_uid87_fpSubTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExc_uid87_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExc_uid88_fpSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expRPreExc_uid88_fpSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal regInputs_uid89_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroVInC_uid90_fpSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal excRZero_uid91_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rInfOvf_uid92_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfVInC_uid93_fpSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRInf_uid94_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN2_uid95_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excAIBISub_uid96_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid97_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid98_fpSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid99_fpSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal invAMinusA_uid100_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRReg_uid101_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigBBInf_uid102_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigAAInf_uid103_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInf_uid104_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excAZBZSigASigB_uid105_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excBZARSigA_uid106_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRZero_uid107_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInfRZRReg_uid108_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRInfRZRReg_uid108_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaN_uid109_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid110_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid110_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneFracRPostExc2_uid111_fpSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExc_uid114_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid114_fpSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPostExc_uid118_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid118_fpSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal R_uid119_fpSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid121_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid122_lzCountVal_uid75_fpSubTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid123_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid124_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal vStage_uid125_lzCountVal_uid75_fpSubTest_in : STD_LOGIC_VECTOR (10 downto 0);
    signal vStage_uid125_lzCountVal_uid75_fpSubTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal cStage_uid126_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid128_lzCountVal_uid75_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid128_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid131_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid134_lzCountVal_uid75_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid134_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zs_uid135_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid137_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid140_lzCountVal_uid75_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid140_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zs_uid141_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid143_lzCountVal_uid75_fpSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid143_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid146_lzCountVal_uid75_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid146_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid148_lzCountVal_uid75_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid149_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid150_lzCountVal_uid75_fpSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal xMSB_uid152_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal seMsb_to8_uid156_in : STD_LOGIC_VECTOR (7 downto 0);
    signal seMsb_to8_uid156_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rightShiftStage0Idx1Rng8_uid157_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (18 downto 0);
    signal rightShiftStage0Idx1_uid158_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to16_uid159_in : STD_LOGIC_VECTOR (15 downto 0);
    signal seMsb_to16_uid159_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rightShiftStage0Idx2Rng16_uid160_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal rightShiftStage0Idx2_uid161_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to24_uid162_in : STD_LOGIC_VECTOR (23 downto 0);
    signal seMsb_to24_uid162_b : STD_LOGIC_VECTOR (23 downto 0);
    signal rightShiftStage0Idx3Rng24_uid163_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal rightShiftStage0Idx3_uid164_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to2_uid167_in : STD_LOGIC_VECTOR (1 downto 0);
    signal seMsb_to2_uid167_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1Idx1Rng2_uid168_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1Idx1_uid169_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to4_uid170_in : STD_LOGIC_VECTOR (3 downto 0);
    signal seMsb_to4_uid170_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rightShiftStage1Idx2Rng4_uid171_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal rightShiftStage1Idx2_uid172_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal seMsb_to6_uid173_in : STD_LOGIC_VECTOR (5 downto 0);
    signal seMsb_to6_uid173_b : STD_LOGIC_VECTOR (5 downto 0);
    signal rightShiftStage1Idx3Rng6_uid174_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (20 downto 0);
    signal rightShiftStage1Idx3_uid175_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage2Idx1Rng1_uid178_alignmentShifter_uid72_fpSubTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal rightShiftStage2Idx1_uid179_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal shiftOutConstant_to27_uid182_in : STD_LOGIC_VECTOR (26 downto 0);
    signal shiftOutConstant_to27_uid182_b : STD_LOGIC_VECTOR (26 downto 0);
    signal r_uid184_alignmentShifter_uid72_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid184_alignmentShifter_uid72_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (18 downto 0);
    signal leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (18 downto 0);
    signal leftShiftStage0Idx1_uid190_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx2_uid193_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0Idx3Pad24_uid194_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStage0Idx3_uid196_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1_uid201_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx2_uid204_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1Idx3Pad6_uid205_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (20 downto 0);
    signal leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (20 downto 0);
    signal leftShiftStage1Idx3_uid207_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage2Idx1_uid212_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_in : STD_LOGIC_VECTOR (4 downto 0);
    signal rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d : STD_LOGIC_VECTOR (0 downto 0);
    signal rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d : STD_LOGIC_VECTOR (0 downto 0);
    signal redist0_leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist3_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b_2_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist4_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c_2_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist5_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist6_shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_vCount_uid137_lzCountVal_uid75_fpSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist9_vCount_uid131_lzCountVal_uid75_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist10_vStage_uid125_lzCountVal_uid75_fpSubTest_b_3_q : STD_LOGIC_VECTOR (10 downto 0);
    signal redist11_vCount_uid123_lzCountVal_uid75_fpSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_regInputs_uid89_fpSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist13_expRPreExc_uid88_fpSubTest_b_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist14_fracRPreExc_uid87_fpSubTest_b_2_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist17_oFracBREXC2_uid71_fpSubTest_b_1_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist18_effSub_uid53_fpSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist19_effSub_uid53_fpSubTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist20_sigB_uid52_fpSubTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist21_sigB_uid52_fpSubTest_b_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist22_sigA_uid51_fpSubTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist23_sigA_uid51_fpSubTest_b_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist24_InvExpXIsZero_uid45_fpSubTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist25_excN_bSig_uid43_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist26_excI_bSig_uid42_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist27_fracXIsZero_uid40_fpSubTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist28_expXIsMax_uid39_fpSubTest_q_9_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_frac_bSig_uid37_fpSubTest_b_1_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist31_excN_aSig_uid29_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist32_excI_aSig_uid28_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_fracXIsZero_uid26_fpSubTest_q_4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist37_xIn_a_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist38_xIn_b_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_reset0 : std_logic;
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i : UNSIGNED (1 downto 0);
    attribute preserve : boolean;
    attribute preserve of redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i : signal is true;
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq : std_logic;
    attribute preserve of redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq : signal is true;
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_mem_last_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge : boolean;
    attribute dont_merge of redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q : signal is true;
    signal redist35_frac_aSig_uid23_fpSubTest_b_5_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_reset0 : std_logic;
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i : signal is true;
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq : std_logic;
    attribute preserve of redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq : signal is true;
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute dont_merge of redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q : signal is true;
    signal redist36_exp_aSig_uid22_fpSubTest_b_8_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- cAmA_uid77_fpSubTest(CONSTANT,76)
    cAmA_uid77_fpSubTest_q <= "11011";

    -- zs_uid121_lzCountVal_uid75_fpSubTest(CONSTANT,120)
    zs_uid121_lzCountVal_uid75_fpSubTest_q <= "0000000000000000";

    -- redist38_xIn_b_1(DELAY,258)
    redist38_xIn_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => b, xout => redist38_xIn_b_1_q, clk => clk, aclr => areset );

    -- sigY_uid9_fpSubTest(BITSELECT,8)@1
    sigY_uid9_fpSubTest_b <= STD_LOGIC_VECTOR(redist38_xIn_b_1_q(31 downto 31));

    -- invSigY_uid10_fpSubTest(LOGICAL,9)@1
    invSigY_uid10_fpSubTest_q <= not (sigY_uid9_fpSubTest_b);

    -- expY_uid12_fpSubTest(BITSELECT,11)@1
    expY_uid12_fpSubTest_b <= redist38_xIn_b_1_q(30 downto 23);

    -- fracY_uid11_fpSubTest(BITSELECT,10)@1
    fracY_uid11_fpSubTest_b <= redist38_xIn_b_1_q(22 downto 0);

    -- ypn_uid13_fpSubTest(BITJOIN,12)@1
    ypn_uid13_fpSubTest_q <= invSigY_uid10_fpSubTest_q & expY_uid12_fpSubTest_b & fracY_uid11_fpSubTest_b;

    -- redist37_xIn_a_1(DELAY,257)
    redist37_xIn_a_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => a, xout => redist37_xIn_a_1_q, clk => clk, aclr => areset );

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- expFracY_uid7_fpSubTest(BITSELECT,6)@0
    expFracY_uid7_fpSubTest_b <= b(30 downto 0);

    -- expFracX_uid6_fpSubTest(BITSELECT,5)@0
    expFracX_uid6_fpSubTest_b <= a(30 downto 0);

    -- xGTEy_uid8_fpSubTest(COMPARE,7)@0 + 1
    xGTEy_uid8_fpSubTest_a <= STD_LOGIC_VECTOR("00" & expFracX_uid6_fpSubTest_b);
    xGTEy_uid8_fpSubTest_b <= STD_LOGIC_VECTOR("00" & expFracY_uid7_fpSubTest_b);
    xGTEy_uid8_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            xGTEy_uid8_fpSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            xGTEy_uid8_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(xGTEy_uid8_fpSubTest_a) - UNSIGNED(xGTEy_uid8_fpSubTest_b));
        END IF;
    END PROCESS;
    xGTEy_uid8_fpSubTest_n(0) <= not (xGTEy_uid8_fpSubTest_o(32));

    -- bSig_uid18_fpSubTest(MUX,17)@1
    bSig_uid18_fpSubTest_s <= xGTEy_uid8_fpSubTest_n;
    bSig_uid18_fpSubTest_combproc: PROCESS (bSig_uid18_fpSubTest_s, redist37_xIn_a_1_q, ypn_uid13_fpSubTest_q)
    BEGIN
        CASE (bSig_uid18_fpSubTest_s) IS
            WHEN "0" => bSig_uid18_fpSubTest_q <= redist37_xIn_a_1_q;
            WHEN "1" => bSig_uid18_fpSubTest_q <= ypn_uid13_fpSubTest_q;
            WHEN OTHERS => bSig_uid18_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigB_uid52_fpSubTest(BITSELECT,51)@1
    sigB_uid52_fpSubTest_b <= STD_LOGIC_VECTOR(bSig_uid18_fpSubTest_q(31 downto 31));

    -- redist20_sigB_uid52_fpSubTest_b_1(DELAY,240)
    redist20_sigB_uid52_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigB_uid52_fpSubTest_b, xout => redist20_sigB_uid52_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- aSig_uid17_fpSubTest(MUX,16)@1
    aSig_uid17_fpSubTest_s <= xGTEy_uid8_fpSubTest_n;
    aSig_uid17_fpSubTest_combproc: PROCESS (aSig_uid17_fpSubTest_s, ypn_uid13_fpSubTest_q, redist37_xIn_a_1_q)
    BEGIN
        CASE (aSig_uid17_fpSubTest_s) IS
            WHEN "0" => aSig_uid17_fpSubTest_q <= ypn_uid13_fpSubTest_q;
            WHEN "1" => aSig_uid17_fpSubTest_q <= redist37_xIn_a_1_q;
            WHEN OTHERS => aSig_uid17_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigA_uid51_fpSubTest(BITSELECT,50)@1
    sigA_uid51_fpSubTest_b <= STD_LOGIC_VECTOR(aSig_uid17_fpSubTest_q(31 downto 31));

    -- redist22_sigA_uid51_fpSubTest_b_1(DELAY,242)
    redist22_sigA_uid51_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigA_uid51_fpSubTest_b, xout => redist22_sigA_uid51_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- effSub_uid53_fpSubTest(LOGICAL,52)@2
    effSub_uid53_fpSubTest_q <= redist22_sigA_uid51_fpSubTest_b_1_q xor redist20_sigB_uid52_fpSubTest_b_1_q;

    -- redist18_effSub_uid53_fpSubTest_q_1(DELAY,238)
    redist18_effSub_uid53_fpSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => effSub_uid53_fpSubTest_q, xout => redist18_effSub_uid53_fpSubTest_q_1_q, clk => clk, aclr => areset );

    -- cstAllZWE_uid21_fpSubTest(CONSTANT,20)
    cstAllZWE_uid21_fpSubTest_q <= "00000000";

    -- exp_bSig_uid36_fpSubTest(BITSELECT,35)@1
    exp_bSig_uid36_fpSubTest_in <= bSig_uid18_fpSubTest_q(30 downto 0);
    exp_bSig_uid36_fpSubTest_b <= exp_bSig_uid36_fpSubTest_in(30 downto 23);

    -- excZ_bSig_uid18_uid38_fpSubTest(LOGICAL,37)@1 + 1
    excZ_bSig_uid18_uid38_fpSubTest_qi <= "1" WHEN exp_bSig_uid36_fpSubTest_b = cstAllZWE_uid21_fpSubTest_q ELSE "0";
    excZ_bSig_uid18_uid38_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_bSig_uid18_uid38_fpSubTest_qi, xout => excZ_bSig_uid18_uid38_fpSubTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid45_fpSubTest(LOGICAL,44)@2
    InvExpXIsZero_uid45_fpSubTest_q <= not (excZ_bSig_uid18_uid38_fpSubTest_q);

    -- cstZeroWF_uid20_fpSubTest(CONSTANT,19)
    cstZeroWF_uid20_fpSubTest_q <= "00000000000000000000000";

    -- frac_bSig_uid37_fpSubTest(BITSELECT,36)@1
    frac_bSig_uid37_fpSubTest_in <= bSig_uid18_fpSubTest_q(22 downto 0);
    frac_bSig_uid37_fpSubTest_b <= frac_bSig_uid37_fpSubTest_in(22 downto 0);

    -- redist30_frac_bSig_uid37_fpSubTest_b_1(DELAY,250)
    redist30_frac_bSig_uid37_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => frac_bSig_uid37_fpSubTest_b, xout => redist30_frac_bSig_uid37_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- fracBz_uid57_fpSubTest(MUX,56)@2
    fracBz_uid57_fpSubTest_s <= excZ_bSig_uid18_uid38_fpSubTest_q;
    fracBz_uid57_fpSubTest_combproc: PROCESS (fracBz_uid57_fpSubTest_s, redist30_frac_bSig_uid37_fpSubTest_b_1_q, cstZeroWF_uid20_fpSubTest_q)
    BEGIN
        CASE (fracBz_uid57_fpSubTest_s) IS
            WHEN "0" => fracBz_uid57_fpSubTest_q <= redist30_frac_bSig_uid37_fpSubTest_b_1_q;
            WHEN "1" => fracBz_uid57_fpSubTest_q <= cstZeroWF_uid20_fpSubTest_q;
            WHEN OTHERS => fracBz_uid57_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oFracB_uid60_fpSubTest(BITJOIN,59)@2
    oFracB_uid60_fpSubTest_q <= InvExpXIsZero_uid45_fpSubTest_q & fracBz_uid57_fpSubTest_q;

    -- oFracBR_uid68_fpSubTest(BITJOIN,67)@2
    oFracBR_uid68_fpSubTest_q <= GND_q & oFracB_uid60_fpSubTest_q & GND_q & GND_q;

    -- oFracBREX_uid69_fpSubTest(LOGICAL,68)@2 + 1
    oFracBREX_uid69_fpSubTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((26 downto 1 => effSub_uid53_fpSubTest_q(0)) & effSub_uid53_fpSubTest_q));
    oFracBREX_uid69_fpSubTest_qi <= oFracBR_uid68_fpSubTest_q xor oFracBREX_uid69_fpSubTest_b;
    oFracBREX_uid69_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oFracBREX_uid69_fpSubTest_qi, xout => oFracBREX_uid69_fpSubTest_q, clk => clk, aclr => areset );

    -- oFracBREXC2_uid70_fpSubTest(ADD,69)@3
    oFracBREXC2_uid70_fpSubTest_a <= STD_LOGIC_VECTOR("0" & oFracBREX_uid69_fpSubTest_q);
    oFracBREXC2_uid70_fpSubTest_b <= STD_LOGIC_VECTOR("000000000000000000000000000" & redist18_effSub_uid53_fpSubTest_q_1_q);
    oFracBREXC2_uid70_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(oFracBREXC2_uid70_fpSubTest_a) + UNSIGNED(oFracBREXC2_uid70_fpSubTest_b));
    oFracBREXC2_uid70_fpSubTest_q <= oFracBREXC2_uid70_fpSubTest_o(27 downto 0);

    -- oFracBREXC2_uid71_fpSubTest(BITSELECT,70)@3
    oFracBREXC2_uid71_fpSubTest_in <= STD_LOGIC_VECTOR(oFracBREXC2_uid70_fpSubTest_q(26 downto 0));
    oFracBREXC2_uid71_fpSubTest_b <= STD_LOGIC_VECTOR(oFracBREXC2_uid71_fpSubTest_in(26 downto 0));

    -- redist17_oFracBREXC2_uid71_fpSubTest_b_1(DELAY,237)
    redist17_oFracBREXC2_uid71_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oFracBREXC2_uid71_fpSubTest_b, xout => redist17_oFracBREXC2_uid71_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- xMSB_uid152_alignmentShifter_uid72_fpSubTest(BITSELECT,151)@4
    xMSB_uid152_alignmentShifter_uid72_fpSubTest_b <= STD_LOGIC_VECTOR(redist17_oFracBREXC2_uid71_fpSubTest_b_1_q(26 downto 26));

    -- redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1(DELAY,227)
    redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b, xout => redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- shiftOutConstant_to27_uid182(BITSELECT,181)@5
    shiftOutConstant_to27_uid182_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((26 downto 1 => redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1_q(0)) & redist7_xMSB_uid152_alignmentShifter_uid72_fpSubTest_b_1_q));
    shiftOutConstant_to27_uid182_b <= STD_LOGIC_VECTOR(shiftOutConstant_to27_uid182_in(26 downto 0));

    -- rightShiftStage2Idx1Rng1_uid178_alignmentShifter_uid72_fpSubTest(BITSELECT,177)@4
    rightShiftStage2Idx1Rng1_uid178_alignmentShifter_uid72_fpSubTest_b <= rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q(26 downto 1);

    -- rightShiftStage2Idx1_uid179_alignmentShifter_uid72_fpSubTest(BITJOIN,178)@4
    rightShiftStage2Idx1_uid179_alignmentShifter_uid72_fpSubTest_q <= xMSB_uid152_alignmentShifter_uid72_fpSubTest_b & rightShiftStage2Idx1Rng1_uid178_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to6_uid173(BITSELECT,172)@4
    seMsb_to6_uid173_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((5 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to6_uid173_b <= STD_LOGIC_VECTOR(seMsb_to6_uid173_in(5 downto 0));

    -- rightShiftStage1Idx3Rng6_uid174_alignmentShifter_uid72_fpSubTest(BITSELECT,173)@4
    rightShiftStage1Idx3Rng6_uid174_alignmentShifter_uid72_fpSubTest_b <= rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q(26 downto 6);

    -- rightShiftStage1Idx3_uid175_alignmentShifter_uid72_fpSubTest(BITJOIN,174)@4
    rightShiftStage1Idx3_uid175_alignmentShifter_uid72_fpSubTest_q <= seMsb_to6_uid173_b & rightShiftStage1Idx3Rng6_uid174_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to4_uid170(BITSELECT,169)@4
    seMsb_to4_uid170_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((3 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to4_uid170_b <= STD_LOGIC_VECTOR(seMsb_to4_uid170_in(3 downto 0));

    -- rightShiftStage1Idx2Rng4_uid171_alignmentShifter_uid72_fpSubTest(BITSELECT,170)@4
    rightShiftStage1Idx2Rng4_uid171_alignmentShifter_uid72_fpSubTest_b <= rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q(26 downto 4);

    -- rightShiftStage1Idx2_uid172_alignmentShifter_uid72_fpSubTest(BITJOIN,171)@4
    rightShiftStage1Idx2_uid172_alignmentShifter_uid72_fpSubTest_q <= seMsb_to4_uid170_b & rightShiftStage1Idx2Rng4_uid171_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to2_uid167(BITSELECT,166)@4
    seMsb_to2_uid167_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((1 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to2_uid167_b <= STD_LOGIC_VECTOR(seMsb_to2_uid167_in(1 downto 0));

    -- rightShiftStage1Idx1Rng2_uid168_alignmentShifter_uid72_fpSubTest(BITSELECT,167)@4
    rightShiftStage1Idx1Rng2_uid168_alignmentShifter_uid72_fpSubTest_b <= rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q(26 downto 2);

    -- rightShiftStage1Idx1_uid169_alignmentShifter_uid72_fpSubTest(BITJOIN,168)@4
    rightShiftStage1Idx1_uid169_alignmentShifter_uid72_fpSubTest_q <= seMsb_to2_uid167_b & rightShiftStage1Idx1Rng2_uid168_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to24_uid162(BITSELECT,161)@4
    seMsb_to24_uid162_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((23 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to24_uid162_b <= STD_LOGIC_VECTOR(seMsb_to24_uid162_in(23 downto 0));

    -- rightShiftStage0Idx3Rng24_uid163_alignmentShifter_uid72_fpSubTest(BITSELECT,162)@4
    rightShiftStage0Idx3Rng24_uid163_alignmentShifter_uid72_fpSubTest_b <= redist17_oFracBREXC2_uid71_fpSubTest_b_1_q(26 downto 24);

    -- rightShiftStage0Idx3_uid164_alignmentShifter_uid72_fpSubTest(BITJOIN,163)@4
    rightShiftStage0Idx3_uid164_alignmentShifter_uid72_fpSubTest_q <= seMsb_to24_uid162_b & rightShiftStage0Idx3Rng24_uid163_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to16_uid159(BITSELECT,158)@4
    seMsb_to16_uid159_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((15 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to16_uid159_b <= STD_LOGIC_VECTOR(seMsb_to16_uid159_in(15 downto 0));

    -- rightShiftStage0Idx2Rng16_uid160_alignmentShifter_uid72_fpSubTest(BITSELECT,159)@4
    rightShiftStage0Idx2Rng16_uid160_alignmentShifter_uid72_fpSubTest_b <= redist17_oFracBREXC2_uid71_fpSubTest_b_1_q(26 downto 16);

    -- rightShiftStage0Idx2_uid161_alignmentShifter_uid72_fpSubTest(BITJOIN,160)@4
    rightShiftStage0Idx2_uid161_alignmentShifter_uid72_fpSubTest_q <= seMsb_to16_uid159_b & rightShiftStage0Idx2Rng16_uid160_alignmentShifter_uid72_fpSubTest_b;

    -- seMsb_to8_uid156(BITSELECT,155)@4
    seMsb_to8_uid156_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((7 downto 1 => xMSB_uid152_alignmentShifter_uid72_fpSubTest_b(0)) & xMSB_uid152_alignmentShifter_uid72_fpSubTest_b));
    seMsb_to8_uid156_b <= STD_LOGIC_VECTOR(seMsb_to8_uid156_in(7 downto 0));

    -- rightShiftStage0Idx1Rng8_uid157_alignmentShifter_uid72_fpSubTest(BITSELECT,156)@4
    rightShiftStage0Idx1Rng8_uid157_alignmentShifter_uid72_fpSubTest_b <= redist17_oFracBREXC2_uid71_fpSubTest_b_1_q(26 downto 8);

    -- rightShiftStage0Idx1_uid158_alignmentShifter_uid72_fpSubTest(BITJOIN,157)@4
    rightShiftStage0Idx1_uid158_alignmentShifter_uid72_fpSubTest_q <= seMsb_to8_uid156_b & rightShiftStage0Idx1Rng8_uid157_alignmentShifter_uid72_fpSubTest_b;

    -- exp_aSig_uid22_fpSubTest(BITSELECT,21)@1
    exp_aSig_uid22_fpSubTest_in <= aSig_uid17_fpSubTest_q(30 downto 0);
    exp_aSig_uid22_fpSubTest_b <= exp_aSig_uid22_fpSubTest_in(30 downto 23);

    -- expAmExpB_uid61_fpSubTest(SUB,60)@1 + 1
    expAmExpB_uid61_fpSubTest_a <= STD_LOGIC_VECTOR("0" & exp_aSig_uid22_fpSubTest_b);
    expAmExpB_uid61_fpSubTest_b <= STD_LOGIC_VECTOR("0" & exp_bSig_uid36_fpSubTest_b);
    expAmExpB_uid61_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expAmExpB_uid61_fpSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expAmExpB_uid61_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expAmExpB_uid61_fpSubTest_a) - UNSIGNED(expAmExpB_uid61_fpSubTest_b));
        END IF;
    END PROCESS;
    expAmExpB_uid61_fpSubTest_q <= expAmExpB_uid61_fpSubTest_o(8 downto 0);

    -- rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select(BITSELECT,215)@2
    rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_in <= expAmExpB_uid61_fpSubTest_q(4 downto 0);
    rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b <= rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_in(4 downto 3);
    rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c <= rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_in(2 downto 1);
    rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d <= rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_in(0 downto 0);

    -- redist3_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b_2(DELAY,223)
    redist3_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b_2 : dspba_delay
    GENERIC MAP ( width => 2, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b, xout => redist3_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b_2_q, clk => clk, aclr => areset );

    -- rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest(MUX,165)@4
    rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_s <= redist3_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_b_2_q;
    rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_combproc: PROCESS (rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_s, redist17_oFracBREXC2_uid71_fpSubTest_b_1_q, rightShiftStage0Idx1_uid158_alignmentShifter_uid72_fpSubTest_q, rightShiftStage0Idx2_uid161_alignmentShifter_uid72_fpSubTest_q, rightShiftStage0Idx3_uid164_alignmentShifter_uid72_fpSubTest_q)
    BEGIN
        CASE (rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_s) IS
            WHEN "00" => rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q <= redist17_oFracBREXC2_uid71_fpSubTest_b_1_q;
            WHEN "01" => rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage0Idx1_uid158_alignmentShifter_uid72_fpSubTest_q;
            WHEN "10" => rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage0Idx2_uid161_alignmentShifter_uid72_fpSubTest_q;
            WHEN "11" => rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage0Idx3_uid164_alignmentShifter_uid72_fpSubTest_q;
            WHEN OTHERS => rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist4_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c_2(DELAY,224)
    redist4_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c_2 : dspba_delay
    GENERIC MAP ( width => 2, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c, xout => redist4_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c_2_q, clk => clk, aclr => areset );

    -- rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest(MUX,176)@4
    rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_s <= redist4_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_c_2_q;
    rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_combproc: PROCESS (rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_s, rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q, rightShiftStage1Idx1_uid169_alignmentShifter_uid72_fpSubTest_q, rightShiftStage1Idx2_uid172_alignmentShifter_uid72_fpSubTest_q, rightShiftStage1Idx3_uid175_alignmentShifter_uid72_fpSubTest_q)
    BEGIN
        CASE (rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_s) IS
            WHEN "00" => rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage0_uid166_alignmentShifter_uid72_fpSubTest_q;
            WHEN "01" => rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage1Idx1_uid169_alignmentShifter_uid72_fpSubTest_q;
            WHEN "10" => rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage1Idx2_uid172_alignmentShifter_uid72_fpSubTest_q;
            WHEN "11" => rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage1Idx3_uid175_alignmentShifter_uid72_fpSubTest_q;
            WHEN OTHERS => rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist5_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d_2(DELAY,225)
    redist5_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d, xout => redist5_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d_2_q, clk => clk, aclr => areset );

    -- rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest(MUX,180)@4 + 1
    rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_s <= redist5_rightShiftStageSel4Dto3_uid165_alignmentShifter_uid72_fpSubTest_merged_bit_select_d_2_q;
    rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_s) IS
                WHEN "0" => rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage1_uid177_alignmentShifter_uid72_fpSubTest_q;
                WHEN "1" => rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage2Idx1_uid179_alignmentShifter_uid72_fpSubTest_q;
                WHEN OTHERS => rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- shiftedOut_uid155_alignmentShifter_uid72_fpSubTest(COMPARE,154)@2 + 1
    shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_a <= STD_LOGIC_VECTOR("00" & expAmExpB_uid61_fpSubTest_q);
    shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_b <= STD_LOGIC_VECTOR("000000" & cAmA_uid77_fpSubTest_q);
    shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_a) - UNSIGNED(shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_b));
        END IF;
    END PROCESS;
    shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n(0) <= not (shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_o(10));

    -- redist6_shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n_3(DELAY,226)
    redist6_shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n, xout => redist6_shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n_3_q, clk => clk, aclr => areset );

    -- r_uid184_alignmentShifter_uid72_fpSubTest(MUX,183)@5 + 1
    r_uid184_alignmentShifter_uid72_fpSubTest_s <= redist6_shiftedOut_uid155_alignmentShifter_uid72_fpSubTest_n_3_q;
    r_uid184_alignmentShifter_uid72_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            r_uid184_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (r_uid184_alignmentShifter_uid72_fpSubTest_s) IS
                WHEN "0" => r_uid184_alignmentShifter_uid72_fpSubTest_q <= rightShiftStage2_uid181_alignmentShifter_uid72_fpSubTest_q;
                WHEN "1" => r_uid184_alignmentShifter_uid72_fpSubTest_q <= shiftOutConstant_to27_uid182_b;
                WHEN OTHERS => r_uid184_alignmentShifter_uid72_fpSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_notEnable(LOGICAL,266)
    redist35_frac_aSig_uid23_fpSubTest_b_5_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_nor(LOGICAL,267)
    redist35_frac_aSig_uid23_fpSubTest_b_5_nor_q <= not (redist35_frac_aSig_uid23_fpSubTest_b_5_notEnable_q or redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q);

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_mem_last(CONSTANT,263)
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_last_q <= "01";

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_cmp(LOGICAL,264)
    redist35_frac_aSig_uid23_fpSubTest_b_5_cmp_q <= "1" WHEN redist35_frac_aSig_uid23_fpSubTest_b_5_mem_last_q = redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_q ELSE "0";

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg(REG,265)
    redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid23_fpSubTest_b_5_cmp_q);
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena(REG,268)
    redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist35_frac_aSig_uid23_fpSubTest_b_5_nor_q = "1") THEN
                redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid23_fpSubTest_b_5_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_enaAnd(LOGICAL,269)
    redist35_frac_aSig_uid23_fpSubTest_b_5_enaAnd_q <= redist35_frac_aSig_uid23_fpSubTest_b_5_sticky_ena_q and VCC_q;

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt(COUNTER,261)
    -- low=0, high=2, step=1, init=0
    redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i <= TO_UNSIGNED(0, 2);
            redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i = TO_UNSIGNED(1, 2)) THEN
                redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq <= '1';
            ELSE
                redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq <= '0';
            END IF;
            IF (redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_eq = '1') THEN
                redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i <= redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i + 2;
            ELSE
                redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i <= redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_i, 2)));

    -- frac_aSig_uid23_fpSubTest(BITSELECT,22)@1
    frac_aSig_uid23_fpSubTest_in <= aSig_uid17_fpSubTest_q(22 downto 0);
    frac_aSig_uid23_fpSubTest_b <= frac_aSig_uid23_fpSubTest_in(22 downto 0);

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr(REG,262)
    redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr_q <= "10";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr_q <= STD_LOGIC_VECTOR(redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_mem(DUALMEM,260)
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ia <= STD_LOGIC_VECTOR(frac_aSig_uid23_fpSubTest_b);
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_aa <= redist35_frac_aSig_uid23_fpSubTest_b_5_wraddr_q;
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ab <= redist35_frac_aSig_uid23_fpSubTest_b_5_rdcnt_q;
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_reset0 <= areset;
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 2,
        numwords_a => 3,
        width_b => 23,
        widthad_b => 2,
        numwords_b => 3,
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
        clocken1 => redist35_frac_aSig_uid23_fpSubTest_b_5_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_reset0,
        clock1 => clk,
        address_a => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_aa,
        data_a => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_ab,
        q_b => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_iq
    );
    redist35_frac_aSig_uid23_fpSubTest_b_5_mem_q <= redist35_frac_aSig_uid23_fpSubTest_b_5_mem_iq(22 downto 0);

    -- redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg(DELAY,259)
    redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist35_frac_aSig_uid23_fpSubTest_b_5_mem_q, xout => redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg_q, clk => clk, aclr => areset );

    -- oFracA_uid65_fpSubTest(BITJOIN,64)@6
    oFracA_uid65_fpSubTest_q <= VCC_q & redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg_q;

    -- oFracAE_uid66_fpSubTest(BITJOIN,65)@6
    oFracAE_uid66_fpSubTest_q <= GND_q & oFracA_uid65_fpSubTest_q & GND_q & GND_q;

    -- fracAddResult_uid73_fpSubTest(ADD,72)@6
    fracAddResult_uid73_fpSubTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 27 => oFracAE_uid66_fpSubTest_q(26)) & oFracAE_uid66_fpSubTest_q));
    fracAddResult_uid73_fpSubTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 27 => r_uid184_alignmentShifter_uid72_fpSubTest_q(26)) & r_uid184_alignmentShifter_uid72_fpSubTest_q));
    fracAddResult_uid73_fpSubTest_o <= STD_LOGIC_VECTOR(SIGNED(fracAddResult_uid73_fpSubTest_a) + SIGNED(fracAddResult_uid73_fpSubTest_b));
    fracAddResult_uid73_fpSubTest_q <= fracAddResult_uid73_fpSubTest_o(27 downto 0);

    -- fracAddResultNoSignExt_uid74_fpSubTest(BITSELECT,73)@6
    fracAddResultNoSignExt_uid74_fpSubTest_in <= fracAddResult_uid73_fpSubTest_q(26 downto 0);
    fracAddResultNoSignExt_uid74_fpSubTest_b <= fracAddResultNoSignExt_uid74_fpSubTest_in(26 downto 0);

    -- redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1(DELAY,235)
    redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracAddResultNoSignExt_uid74_fpSubTest_b, xout => redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1_q, clk => clk, aclr => areset );

    -- rVStage_uid122_lzCountVal_uid75_fpSubTest(BITSELECT,121)@7
    rVStage_uid122_lzCountVal_uid75_fpSubTest_b <= redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1_q(26 downto 11);

    -- vCount_uid123_lzCountVal_uid75_fpSubTest(LOGICAL,122)@7
    vCount_uid123_lzCountVal_uid75_fpSubTest_q <= "1" WHEN rVStage_uid122_lzCountVal_uid75_fpSubTest_b = zs_uid121_lzCountVal_uid75_fpSubTest_q ELSE "0";

    -- redist11_vCount_uid123_lzCountVal_uid75_fpSubTest_q_3(DELAY,231)
    redist11_vCount_uid123_lzCountVal_uid75_fpSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid123_lzCountVal_uid75_fpSubTest_q, xout => redist11_vCount_uid123_lzCountVal_uid75_fpSubTest_q_3_q, clk => clk, aclr => areset );

    -- vStage_uid125_lzCountVal_uid75_fpSubTest(BITSELECT,124)@7
    vStage_uid125_lzCountVal_uid75_fpSubTest_in <= redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1_q(10 downto 0);
    vStage_uid125_lzCountVal_uid75_fpSubTest_b <= vStage_uid125_lzCountVal_uid75_fpSubTest_in(10 downto 0);

    -- mO_uid124_lzCountVal_uid75_fpSubTest(CONSTANT,123)
    mO_uid124_lzCountVal_uid75_fpSubTest_q <= "11111";

    -- cStage_uid126_lzCountVal_uid75_fpSubTest(BITJOIN,125)@7
    cStage_uid126_lzCountVal_uid75_fpSubTest_q <= vStage_uid125_lzCountVal_uid75_fpSubTest_b & mO_uid124_lzCountVal_uid75_fpSubTest_q;

    -- vStagei_uid128_lzCountVal_uid75_fpSubTest(MUX,127)@7 + 1
    vStagei_uid128_lzCountVal_uid75_fpSubTest_s <= vCount_uid123_lzCountVal_uid75_fpSubTest_q;
    vStagei_uid128_lzCountVal_uid75_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid128_lzCountVal_uid75_fpSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid128_lzCountVal_uid75_fpSubTest_s) IS
                WHEN "0" => vStagei_uid128_lzCountVal_uid75_fpSubTest_q <= rVStage_uid122_lzCountVal_uid75_fpSubTest_b;
                WHEN "1" => vStagei_uid128_lzCountVal_uid75_fpSubTest_q <= cStage_uid126_lzCountVal_uid75_fpSubTest_q;
                WHEN OTHERS => vStagei_uid128_lzCountVal_uid75_fpSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select(BITSELECT,216)@8
    rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_b <= vStagei_uid128_lzCountVal_uid75_fpSubTest_q(15 downto 8);
    rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_c <= vStagei_uid128_lzCountVal_uid75_fpSubTest_q(7 downto 0);

    -- vCount_uid131_lzCountVal_uid75_fpSubTest(LOGICAL,130)@8
    vCount_uid131_lzCountVal_uid75_fpSubTest_q <= "1" WHEN rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_b = cstAllZWE_uid21_fpSubTest_q ELSE "0";

    -- redist9_vCount_uid131_lzCountVal_uid75_fpSubTest_q_2(DELAY,229)
    redist9_vCount_uid131_lzCountVal_uid75_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid131_lzCountVal_uid75_fpSubTest_q, xout => redist9_vCount_uid131_lzCountVal_uid75_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- zs_uid135_lzCountVal_uid75_fpSubTest(CONSTANT,134)
    zs_uid135_lzCountVal_uid75_fpSubTest_q <= "0000";

    -- vStagei_uid134_lzCountVal_uid75_fpSubTest(MUX,133)@8 + 1
    vStagei_uid134_lzCountVal_uid75_fpSubTest_s <= vCount_uid131_lzCountVal_uid75_fpSubTest_q;
    vStagei_uid134_lzCountVal_uid75_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid134_lzCountVal_uid75_fpSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid134_lzCountVal_uid75_fpSubTest_s) IS
                WHEN "0" => vStagei_uid134_lzCountVal_uid75_fpSubTest_q <= rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_b;
                WHEN "1" => vStagei_uid134_lzCountVal_uid75_fpSubTest_q <= rVStage_uid130_lzCountVal_uid75_fpSubTest_merged_bit_select_c;
                WHEN OTHERS => vStagei_uid134_lzCountVal_uid75_fpSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select(BITSELECT,217)@9
    rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_b <= vStagei_uid134_lzCountVal_uid75_fpSubTest_q(7 downto 4);
    rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_c <= vStagei_uid134_lzCountVal_uid75_fpSubTest_q(3 downto 0);

    -- vCount_uid137_lzCountVal_uid75_fpSubTest(LOGICAL,136)@9
    vCount_uid137_lzCountVal_uid75_fpSubTest_q <= "1" WHEN rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_b = zs_uid135_lzCountVal_uid75_fpSubTest_q ELSE "0";

    -- redist8_vCount_uid137_lzCountVal_uid75_fpSubTest_q_1(DELAY,228)
    redist8_vCount_uid137_lzCountVal_uid75_fpSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid137_lzCountVal_uid75_fpSubTest_q, xout => redist8_vCount_uid137_lzCountVal_uid75_fpSubTest_q_1_q, clk => clk, aclr => areset );

    -- zs_uid141_lzCountVal_uid75_fpSubTest(CONSTANT,140)
    zs_uid141_lzCountVal_uid75_fpSubTest_q <= "00";

    -- vStagei_uid140_lzCountVal_uid75_fpSubTest(MUX,139)@9
    vStagei_uid140_lzCountVal_uid75_fpSubTest_s <= vCount_uid137_lzCountVal_uid75_fpSubTest_q;
    vStagei_uid140_lzCountVal_uid75_fpSubTest_combproc: PROCESS (vStagei_uid140_lzCountVal_uid75_fpSubTest_s, rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_b, rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid140_lzCountVal_uid75_fpSubTest_s) IS
            WHEN "0" => vStagei_uid140_lzCountVal_uid75_fpSubTest_q <= rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid140_lzCountVal_uid75_fpSubTest_q <= rVStage_uid136_lzCountVal_uid75_fpSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid140_lzCountVal_uid75_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select(BITSELECT,218)@9
    rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b <= vStagei_uid140_lzCountVal_uid75_fpSubTest_q(3 downto 2);
    rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c <= vStagei_uid140_lzCountVal_uid75_fpSubTest_q(1 downto 0);

    -- vCount_uid143_lzCountVal_uid75_fpSubTest(LOGICAL,142)@9 + 1
    vCount_uid143_lzCountVal_uid75_fpSubTest_qi <= "1" WHEN rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b = zs_uid141_lzCountVal_uid75_fpSubTest_q ELSE "0";
    vCount_uid143_lzCountVal_uid75_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid143_lzCountVal_uid75_fpSubTest_qi, xout => vCount_uid143_lzCountVal_uid75_fpSubTest_q, clk => clk, aclr => areset );

    -- redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1(DELAY,222)
    redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c, xout => redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1(DELAY,221)
    redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b, xout => redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid146_lzCountVal_uid75_fpSubTest(MUX,145)@10
    vStagei_uid146_lzCountVal_uid75_fpSubTest_s <= vCount_uid143_lzCountVal_uid75_fpSubTest_q;
    vStagei_uid146_lzCountVal_uid75_fpSubTest_combproc: PROCESS (vStagei_uid146_lzCountVal_uid75_fpSubTest_s, redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1_q, redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid146_lzCountVal_uid75_fpSubTest_s) IS
            WHEN "0" => vStagei_uid146_lzCountVal_uid75_fpSubTest_q <= redist1_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid146_lzCountVal_uid75_fpSubTest_q <= redist2_rVStage_uid142_lzCountVal_uid75_fpSubTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid146_lzCountVal_uid75_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid148_lzCountVal_uid75_fpSubTest(BITSELECT,147)@10
    rVStage_uid148_lzCountVal_uid75_fpSubTest_b <= vStagei_uid146_lzCountVal_uid75_fpSubTest_q(1 downto 1);

    -- vCount_uid149_lzCountVal_uid75_fpSubTest(LOGICAL,148)@10
    vCount_uid149_lzCountVal_uid75_fpSubTest_q <= "1" WHEN rVStage_uid148_lzCountVal_uid75_fpSubTest_b = GND_q ELSE "0";

    -- r_uid150_lzCountVal_uid75_fpSubTest(BITJOIN,149)@10
    r_uid150_lzCountVal_uid75_fpSubTest_q <= redist11_vCount_uid123_lzCountVal_uid75_fpSubTest_q_3_q & redist9_vCount_uid131_lzCountVal_uid75_fpSubTest_q_2_q & redist8_vCount_uid137_lzCountVal_uid75_fpSubTest_q_1_q & vCount_uid143_lzCountVal_uid75_fpSubTest_q & vCount_uid149_lzCountVal_uid75_fpSubTest_q;

    -- aMinusA_uid78_fpSubTest(LOGICAL,77)@10 + 1
    aMinusA_uid78_fpSubTest_qi <= "1" WHEN r_uid150_lzCountVal_uid75_fpSubTest_q = cAmA_uid77_fpSubTest_q ELSE "0";
    aMinusA_uid78_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => aMinusA_uid78_fpSubTest_qi, xout => aMinusA_uid78_fpSubTest_q, clk => clk, aclr => areset );

    -- invAMinusA_uid100_fpSubTest(LOGICAL,99)@11
    invAMinusA_uid100_fpSubTest_q <= not (aMinusA_uid78_fpSubTest_q);

    -- redist23_sigA_uid51_fpSubTest_b_10(DELAY,243)
    redist23_sigA_uid51_fpSubTest_b_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist22_sigA_uid51_fpSubTest_b_1_q, xout => redist23_sigA_uid51_fpSubTest_b_10_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid19_fpSubTest(CONSTANT,18)
    cstAllOWE_uid19_fpSubTest_q <= "11111111";

    -- expXIsMax_uid39_fpSubTest(LOGICAL,38)@1 + 1
    expXIsMax_uid39_fpSubTest_qi <= "1" WHEN exp_bSig_uid36_fpSubTest_b = cstAllOWE_uid19_fpSubTest_q ELSE "0";
    expXIsMax_uid39_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid39_fpSubTest_qi, xout => expXIsMax_uid39_fpSubTest_q, clk => clk, aclr => areset );

    -- redist28_expXIsMax_uid39_fpSubTest_q_9(DELAY,248)
    redist28_expXIsMax_uid39_fpSubTest_q_9 : dspba_delay
    GENERIC MAP ( width => 1, depth => 8, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid39_fpSubTest_q, xout => redist28_expXIsMax_uid39_fpSubTest_q_9_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid44_fpSubTest(LOGICAL,43)@10
    invExpXIsMax_uid44_fpSubTest_q <= not (redist28_expXIsMax_uid39_fpSubTest_q_9_q);

    -- redist24_InvExpXIsZero_uid45_fpSubTest_q_8(DELAY,244)
    redist24_InvExpXIsZero_uid45_fpSubTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 8, reset_kind => "ASYNC" )
    PORT MAP ( xin => InvExpXIsZero_uid45_fpSubTest_q, xout => redist24_InvExpXIsZero_uid45_fpSubTest_q_8_q, clk => clk, aclr => areset );

    -- excR_bSig_uid46_fpSubTest(LOGICAL,45)@10 + 1
    excR_bSig_uid46_fpSubTest_qi <= redist24_InvExpXIsZero_uid45_fpSubTest_q_8_q and invExpXIsMax_uid44_fpSubTest_q;
    excR_bSig_uid46_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_bSig_uid46_fpSubTest_qi, xout => excR_bSig_uid46_fpSubTest_q, clk => clk, aclr => areset );

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_notEnable(LOGICAL,277)
    redist36_exp_aSig_uid22_fpSubTest_b_8_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_nor(LOGICAL,278)
    redist36_exp_aSig_uid22_fpSubTest_b_8_nor_q <= not (redist36_exp_aSig_uid22_fpSubTest_b_8_notEnable_q or redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q);

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_mem_last(CONSTANT,274)
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_last_q <= "0100";

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_cmp(LOGICAL,275)
    redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_b <= STD_LOGIC_VECTOR("0" & redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_q);
    redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_q <= "1" WHEN redist36_exp_aSig_uid22_fpSubTest_b_8_mem_last_q = redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_b ELSE "0";

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg(REG,276)
    redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid22_fpSubTest_b_8_cmp_q);
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena(REG,279)
    redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist36_exp_aSig_uid22_fpSubTest_b_8_nor_q = "1") THEN
                redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid22_fpSubTest_b_8_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_enaAnd(LOGICAL,280)
    redist36_exp_aSig_uid22_fpSubTest_b_8_enaAnd_q <= redist36_exp_aSig_uid22_fpSubTest_b_8_sticky_ena_q and VCC_q;

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt(COUNTER,272)
    -- low=0, high=5, step=1, init=0
    redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i <= TO_UNSIGNED(0, 3);
            redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq <= '1';
            ELSE
                redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq <= '0';
            END IF;
            IF (redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_eq = '1') THEN
                redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i <= redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i + 3;
            ELSE
                redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i <= redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_i, 3)));

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr(REG,273)
    redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr_q <= STD_LOGIC_VECTOR(redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_mem(DUALMEM,271)
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ia <= STD_LOGIC_VECTOR(exp_aSig_uid22_fpSubTest_b);
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_aa <= redist36_exp_aSig_uid22_fpSubTest_b_8_wraddr_q;
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ab <= redist36_exp_aSig_uid22_fpSubTest_b_8_rdcnt_q;
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_reset0 <= areset;
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 8,
        widthad_b => 3,
        numwords_b => 6,
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
        clocken1 => redist36_exp_aSig_uid22_fpSubTest_b_8_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_reset0,
        clock1 => clk,
        address_a => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_aa,
        data_a => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_ab,
        q_b => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_iq
    );
    redist36_exp_aSig_uid22_fpSubTest_b_8_mem_q <= redist36_exp_aSig_uid22_fpSubTest_b_8_mem_iq(7 downto 0);

    -- redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg(DELAY,270)
    redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist36_exp_aSig_uid22_fpSubTest_b_8_mem_q, xout => redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg_q, clk => clk, aclr => areset );

    -- expXIsMax_uid25_fpSubTest(LOGICAL,24)@9 + 1
    expXIsMax_uid25_fpSubTest_qi <= "1" WHEN redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg_q = cstAllOWE_uid19_fpSubTest_q ELSE "0";
    expXIsMax_uid25_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid25_fpSubTest_qi, xout => expXIsMax_uid25_fpSubTest_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid30_fpSubTest(LOGICAL,29)@10
    invExpXIsMax_uid30_fpSubTest_q <= not (expXIsMax_uid25_fpSubTest_q);

    -- excZ_aSig_uid17_uid24_fpSubTest(LOGICAL,23)@9 + 1
    excZ_aSig_uid17_uid24_fpSubTest_qi <= "1" WHEN redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg_q = cstAllZWE_uid21_fpSubTest_q ELSE "0";
    excZ_aSig_uid17_uid24_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_aSig_uid17_uid24_fpSubTest_qi, xout => excZ_aSig_uid17_uid24_fpSubTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid31_fpSubTest(LOGICAL,30)@10
    InvExpXIsZero_uid31_fpSubTest_q <= not (excZ_aSig_uid17_uid24_fpSubTest_q);

    -- excR_aSig_uid32_fpSubTest(LOGICAL,31)@10 + 1
    excR_aSig_uid32_fpSubTest_qi <= InvExpXIsZero_uid31_fpSubTest_q and invExpXIsMax_uid30_fpSubTest_q;
    excR_aSig_uid32_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_aSig_uid32_fpSubTest_qi, xout => excR_aSig_uid32_fpSubTest_q, clk => clk, aclr => areset );

    -- signRReg_uid101_fpSubTest(LOGICAL,100)@11
    signRReg_uid101_fpSubTest_q <= excR_aSig_uid32_fpSubTest_q and excR_bSig_uid46_fpSubTest_q and redist23_sigA_uid51_fpSubTest_b_10_q and invAMinusA_uid100_fpSubTest_q;

    -- redist21_sigB_uid52_fpSubTest_b_10(DELAY,241)
    redist21_sigB_uid52_fpSubTest_b_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist20_sigB_uid52_fpSubTest_b_1_q, xout => redist21_sigB_uid52_fpSubTest_b_10_q, clk => clk, aclr => areset );

    -- redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10(DELAY,249)
    redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_bSig_uid18_uid38_fpSubTest_q, xout => redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10_q, clk => clk, aclr => areset );

    -- redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2(DELAY,254)
    redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_aSig_uid17_uid24_fpSubTest_q, xout => redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- excAZBZSigASigB_uid105_fpSubTest(LOGICAL,104)@11
    excAZBZSigASigB_uid105_fpSubTest_q <= redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2_q and redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10_q and redist23_sigA_uid51_fpSubTest_b_10_q and redist21_sigB_uid52_fpSubTest_b_10_q;

    -- excBZARSigA_uid106_fpSubTest(LOGICAL,105)@11
    excBZARSigA_uid106_fpSubTest_q <= redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10_q and excR_aSig_uid32_fpSubTest_q and redist23_sigA_uid51_fpSubTest_b_10_q;

    -- signRZero_uid107_fpSubTest(LOGICAL,106)@11
    signRZero_uid107_fpSubTest_q <= excBZARSigA_uid106_fpSubTest_q or excAZBZSigASigB_uid105_fpSubTest_q;

    -- fracXIsZero_uid40_fpSubTest(LOGICAL,39)@2 + 1
    fracXIsZero_uid40_fpSubTest_qi <= "1" WHEN cstZeroWF_uid20_fpSubTest_q = redist30_frac_bSig_uid37_fpSubTest_b_1_q ELSE "0";
    fracXIsZero_uid40_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid40_fpSubTest_qi, xout => fracXIsZero_uid40_fpSubTest_q, clk => clk, aclr => areset );

    -- redist27_fracXIsZero_uid40_fpSubTest_q_8(DELAY,247)
    redist27_fracXIsZero_uid40_fpSubTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid40_fpSubTest_q, xout => redist27_fracXIsZero_uid40_fpSubTest_q_8_q, clk => clk, aclr => areset );

    -- excI_bSig_uid42_fpSubTest(LOGICAL,41)@10 + 1
    excI_bSig_uid42_fpSubTest_qi <= redist28_expXIsMax_uid39_fpSubTest_q_9_q and redist27_fracXIsZero_uid40_fpSubTest_q_8_q;
    excI_bSig_uid42_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_bSig_uid42_fpSubTest_qi, xout => excI_bSig_uid42_fpSubTest_q, clk => clk, aclr => areset );

    -- sigBBInf_uid102_fpSubTest(LOGICAL,101)@11
    sigBBInf_uid102_fpSubTest_q <= redist21_sigB_uid52_fpSubTest_b_10_q and excI_bSig_uid42_fpSubTest_q;

    -- fracXIsZero_uid26_fpSubTest(LOGICAL,25)@6 + 1
    fracXIsZero_uid26_fpSubTest_qi <= "1" WHEN cstZeroWF_uid20_fpSubTest_q = redist35_frac_aSig_uid23_fpSubTest_b_5_outputreg_q ELSE "0";
    fracXIsZero_uid26_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid26_fpSubTest_qi, xout => fracXIsZero_uid26_fpSubTest_q, clk => clk, aclr => areset );

    -- redist33_fracXIsZero_uid26_fpSubTest_q_4(DELAY,253)
    redist33_fracXIsZero_uid26_fpSubTest_q_4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid26_fpSubTest_q, xout => redist33_fracXIsZero_uid26_fpSubTest_q_4_q, clk => clk, aclr => areset );

    -- excI_aSig_uid28_fpSubTest(LOGICAL,27)@10 + 1
    excI_aSig_uid28_fpSubTest_qi <= expXIsMax_uid25_fpSubTest_q and redist33_fracXIsZero_uid26_fpSubTest_q_4_q;
    excI_aSig_uid28_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_aSig_uid28_fpSubTest_qi, xout => excI_aSig_uid28_fpSubTest_q, clk => clk, aclr => areset );

    -- sigAAInf_uid103_fpSubTest(LOGICAL,102)@11
    sigAAInf_uid103_fpSubTest_q <= redist23_sigA_uid51_fpSubTest_b_10_q and excI_aSig_uid28_fpSubTest_q;

    -- signRInf_uid104_fpSubTest(LOGICAL,103)@11
    signRInf_uid104_fpSubTest_q <= sigAAInf_uid103_fpSubTest_q or sigBBInf_uid102_fpSubTest_q;

    -- signRInfRZRReg_uid108_fpSubTest(LOGICAL,107)@11 + 1
    signRInfRZRReg_uid108_fpSubTest_qi <= signRInf_uid104_fpSubTest_q or signRZero_uid107_fpSubTest_q or signRReg_uid101_fpSubTest_q;
    signRInfRZRReg_uid108_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRInfRZRReg_uid108_fpSubTest_qi, xout => signRInfRZRReg_uid108_fpSubTest_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid41_fpSubTest(LOGICAL,40)@10
    fracXIsNotZero_uid41_fpSubTest_q <= not (redist27_fracXIsZero_uid40_fpSubTest_q_8_q);

    -- excN_bSig_uid43_fpSubTest(LOGICAL,42)@10 + 1
    excN_bSig_uid43_fpSubTest_qi <= redist28_expXIsMax_uid39_fpSubTest_q_9_q and fracXIsNotZero_uid41_fpSubTest_q;
    excN_bSig_uid43_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_bSig_uid43_fpSubTest_qi, xout => excN_bSig_uid43_fpSubTest_q, clk => clk, aclr => areset );

    -- redist25_excN_bSig_uid43_fpSubTest_q_2(DELAY,245)
    redist25_excN_bSig_uid43_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_bSig_uid43_fpSubTest_q, xout => redist25_excN_bSig_uid43_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid27_fpSubTest(LOGICAL,26)@10
    fracXIsNotZero_uid27_fpSubTest_q <= not (redist33_fracXIsZero_uid26_fpSubTest_q_4_q);

    -- excN_aSig_uid29_fpSubTest(LOGICAL,28)@10 + 1
    excN_aSig_uid29_fpSubTest_qi <= expXIsMax_uid25_fpSubTest_q and fracXIsNotZero_uid27_fpSubTest_q;
    excN_aSig_uid29_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_aSig_uid29_fpSubTest_qi, xout => excN_aSig_uid29_fpSubTest_q, clk => clk, aclr => areset );

    -- redist31_excN_aSig_uid29_fpSubTest_q_2(DELAY,251)
    redist31_excN_aSig_uid29_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excN_aSig_uid29_fpSubTest_q, xout => redist31_excN_aSig_uid29_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- excRNaN2_uid95_fpSubTest(LOGICAL,94)@12
    excRNaN2_uid95_fpSubTest_q <= redist31_excN_aSig_uid29_fpSubTest_q_2_q or redist25_excN_bSig_uid43_fpSubTest_q_2_q;

    -- redist19_effSub_uid53_fpSubTest_q_10(DELAY,239)
    redist19_effSub_uid53_fpSubTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist18_effSub_uid53_fpSubTest_q_1_q, xout => redist19_effSub_uid53_fpSubTest_q_10_q, clk => clk, aclr => areset );

    -- redist26_excI_bSig_uid42_fpSubTest_q_2(DELAY,246)
    redist26_excI_bSig_uid42_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_bSig_uid42_fpSubTest_q, xout => redist26_excI_bSig_uid42_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist32_excI_aSig_uid28_fpSubTest_q_2(DELAY,252)
    redist32_excI_aSig_uid28_fpSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_aSig_uid28_fpSubTest_q, xout => redist32_excI_aSig_uid28_fpSubTest_q_2_q, clk => clk, aclr => areset );

    -- excAIBISub_uid96_fpSubTest(LOGICAL,95)@12
    excAIBISub_uid96_fpSubTest_q <= redist32_excI_aSig_uid28_fpSubTest_q_2_q and redist26_excI_bSig_uid42_fpSubTest_q_2_q and redist19_effSub_uid53_fpSubTest_q_10_q;

    -- excRNaN_uid97_fpSubTest(LOGICAL,96)@12
    excRNaN_uid97_fpSubTest_q <= excAIBISub_uid96_fpSubTest_q or excRNaN2_uid95_fpSubTest_q;

    -- invExcRNaN_uid109_fpSubTest(LOGICAL,108)@12
    invExcRNaN_uid109_fpSubTest_q <= not (excRNaN_uid97_fpSubTest_q);

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- signRPostExc_uid110_fpSubTest(LOGICAL,109)@12 + 1
    signRPostExc_uid110_fpSubTest_qi <= invExcRNaN_uid109_fpSubTest_q and signRInfRZRReg_uid108_fpSubTest_q;
    signRPostExc_uid110_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExc_uid110_fpSubTest_qi, xout => signRPostExc_uid110_fpSubTest_q, clk => clk, aclr => areset );

    -- expInc_uid79_fpSubTest(ADD,78)@9 + 1
    expInc_uid79_fpSubTest_a <= STD_LOGIC_VECTOR("0" & redist36_exp_aSig_uid22_fpSubTest_b_8_outputreg_q);
    expInc_uid79_fpSubTest_b <= STD_LOGIC_VECTOR("00000000" & VCC_q);
    expInc_uid79_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expInc_uid79_fpSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expInc_uid79_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expInc_uid79_fpSubTest_a) + UNSIGNED(expInc_uid79_fpSubTest_b));
        END IF;
    END PROCESS;
    expInc_uid79_fpSubTest_q <= expInc_uid79_fpSubTest_o(8 downto 0);

    -- expPostNorm_uid80_fpSubTest(SUB,79)@10 + 1
    expPostNorm_uid80_fpSubTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid79_fpSubTest_q);
    expPostNorm_uid80_fpSubTest_b <= STD_LOGIC_VECTOR("00000" & r_uid150_lzCountVal_uid75_fpSubTest_q);
    expPostNorm_uid80_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expPostNorm_uid80_fpSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expPostNorm_uid80_fpSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNorm_uid80_fpSubTest_a) - UNSIGNED(expPostNorm_uid80_fpSubTest_b));
        END IF;
    END PROCESS;
    expPostNorm_uid80_fpSubTest_q <= expPostNorm_uid80_fpSubTest_o(9 downto 0);

    -- leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest(BITSELECT,210)@11
    leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_in <= leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q(25 downto 0);
    leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_in(25 downto 0);

    -- leftShiftStage2Idx1_uid212_fracPostNorm_uid76_fpSubTest(BITJOIN,211)@11
    leftShiftStage2Idx1_uid212_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage2Idx1Rng1_uid211_fracPostNorm_uid76_fpSubTest_b & GND_q;

    -- leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest(BITSELECT,205)@10
    leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_in <= leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q(20 downto 0);
    leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_in(20 downto 0);

    -- leftShiftStage1Idx3Pad6_uid205_fracPostNorm_uid76_fpSubTest(CONSTANT,204)
    leftShiftStage1Idx3Pad6_uid205_fracPostNorm_uid76_fpSubTest_q <= "000000";

    -- leftShiftStage1Idx3_uid207_fracPostNorm_uid76_fpSubTest(BITJOIN,206)@10
    leftShiftStage1Idx3_uid207_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx3Rng6_uid206_fracPostNorm_uid76_fpSubTest_b & leftShiftStage1Idx3Pad6_uid205_fracPostNorm_uid76_fpSubTest_q;

    -- leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest(BITSELECT,202)@10
    leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_in <= leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q(22 downto 0);
    leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_in(22 downto 0);

    -- leftShiftStage1Idx2_uid204_fracPostNorm_uid76_fpSubTest(BITJOIN,203)@10
    leftShiftStage1Idx2_uid204_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx2Rng4_uid203_fracPostNorm_uid76_fpSubTest_b & zs_uid135_lzCountVal_uid75_fpSubTest_q;

    -- leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest(BITSELECT,199)@10
    leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_in <= leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q(24 downto 0);
    leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_in(24 downto 0);

    -- leftShiftStage1Idx1_uid201_fracPostNorm_uid76_fpSubTest(BITJOIN,200)@10
    leftShiftStage1Idx1_uid201_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx1Rng2_uid200_fracPostNorm_uid76_fpSubTest_b & zs_uid141_lzCountVal_uid75_fpSubTest_q;

    -- leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest(BITSELECT,194)@10
    leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_in <= redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q(2 downto 0);
    leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_in(2 downto 0);

    -- leftShiftStage0Idx3Pad24_uid194_fracPostNorm_uid76_fpSubTest(CONSTANT,193)
    leftShiftStage0Idx3Pad24_uid194_fracPostNorm_uid76_fpSubTest_q <= "000000000000000000000000";

    -- leftShiftStage0Idx3_uid196_fracPostNorm_uid76_fpSubTest(BITJOIN,195)@10
    leftShiftStage0Idx3_uid196_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0Idx3Rng24_uid195_fracPostNorm_uid76_fpSubTest_b & leftShiftStage0Idx3Pad24_uid194_fracPostNorm_uid76_fpSubTest_q;

    -- redist10_vStage_uid125_lzCountVal_uid75_fpSubTest_b_3(DELAY,230)
    redist10_vStage_uid125_lzCountVal_uid75_fpSubTest_b_3 : dspba_delay
    GENERIC MAP ( width => 11, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vStage_uid125_lzCountVal_uid75_fpSubTest_b, xout => redist10_vStage_uid125_lzCountVal_uid75_fpSubTest_b_3_q, clk => clk, aclr => areset );

    -- leftShiftStage0Idx2_uid193_fracPostNorm_uid76_fpSubTest(BITJOIN,192)@10
    leftShiftStage0Idx2_uid193_fracPostNorm_uid76_fpSubTest_q <= redist10_vStage_uid125_lzCountVal_uid75_fpSubTest_b_3_q & zs_uid121_lzCountVal_uid75_fpSubTest_q;

    -- leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest(BITSELECT,188)@10
    leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_in <= redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q(18 downto 0);
    leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_b <= leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_in(18 downto 0);

    -- leftShiftStage0Idx1_uid190_fracPostNorm_uid76_fpSubTest(BITJOIN,189)@10
    leftShiftStage0Idx1_uid190_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0Idx1Rng8_uid189_fracPostNorm_uid76_fpSubTest_b & cstAllZWE_uid21_fpSubTest_q;

    -- redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4(DELAY,236)
    redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4 : dspba_delay
    GENERIC MAP ( width => 27, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist15_fracAddResultNoSignExt_uid74_fpSubTest_b_1_q, xout => redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q, clk => clk, aclr => areset );

    -- leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest(MUX,197)@10
    leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_s <= leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_b;
    leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_combproc: PROCESS (leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_s, redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q, leftShiftStage0Idx1_uid190_fracPostNorm_uid76_fpSubTest_q, leftShiftStage0Idx2_uid193_fracPostNorm_uid76_fpSubTest_q, leftShiftStage0Idx3_uid196_fracPostNorm_uid76_fpSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_s) IS
            WHEN "00" => leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q <= redist16_fracAddResultNoSignExt_uid74_fpSubTest_b_4_q;
            WHEN "01" => leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0Idx1_uid190_fracPostNorm_uid76_fpSubTest_q;
            WHEN "10" => leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0Idx2_uid193_fracPostNorm_uid76_fpSubTest_q;
            WHEN "11" => leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0Idx3_uid196_fracPostNorm_uid76_fpSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select(BITSELECT,219)@10
    leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_b <= r_uid150_lzCountVal_uid75_fpSubTest_q(4 downto 3);
    leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_c <= r_uid150_lzCountVal_uid75_fpSubTest_q(2 downto 1);
    leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d <= r_uid150_lzCountVal_uid75_fpSubTest_q(0 downto 0);

    -- leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest(MUX,208)@10 + 1
    leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_s <= leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_c;
    leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_s) IS
                WHEN "00" => leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage0_uid198_fracPostNorm_uid76_fpSubTest_q;
                WHEN "01" => leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx1_uid201_fracPostNorm_uid76_fpSubTest_q;
                WHEN "10" => leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx2_uid204_fracPostNorm_uid76_fpSubTest_q;
                WHEN "11" => leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1Idx3_uid207_fracPostNorm_uid76_fpSubTest_q;
                WHEN OTHERS => leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist0_leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d_1(DELAY,220)
    redist0_leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d, xout => redist0_leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d_1_q, clk => clk, aclr => areset );

    -- leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest(MUX,213)@11
    leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_s <= redist0_leftShiftStageSel4Dto3_uid197_fracPostNorm_uid76_fpSubTest_merged_bit_select_d_1_q;
    leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_combproc: PROCESS (leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_s, leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q, leftShiftStage2Idx1_uid212_fracPostNorm_uid76_fpSubTest_q)
    BEGIN
        CASE (leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_s) IS
            WHEN "0" => leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage1_uid209_fracPostNorm_uid76_fpSubTest_q;
            WHEN "1" => leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_q <= leftShiftStage2Idx1_uid212_fracPostNorm_uid76_fpSubTest_q;
            WHEN OTHERS => leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracPostNormRndRange_uid81_fpSubTest(BITSELECT,80)@11
    fracPostNormRndRange_uid81_fpSubTest_in <= leftShiftStage2_uid214_fracPostNorm_uid76_fpSubTest_q(25 downto 0);
    fracPostNormRndRange_uid81_fpSubTest_b <= fracPostNormRndRange_uid81_fpSubTest_in(25 downto 2);

    -- expFracR_uid82_fpSubTest(BITJOIN,81)@11
    expFracR_uid82_fpSubTest_q <= expPostNorm_uid80_fpSubTest_q & fracPostNormRndRange_uid81_fpSubTest_b;

    -- expRPreExc_uid88_fpSubTest(BITSELECT,87)@11
    expRPreExc_uid88_fpSubTest_in <= expFracR_uid82_fpSubTest_q(31 downto 0);
    expRPreExc_uid88_fpSubTest_b <= expRPreExc_uid88_fpSubTest_in(31 downto 24);

    -- redist13_expRPreExc_uid88_fpSubTest_b_2(DELAY,233)
    redist13_expRPreExc_uid88_fpSubTest_b_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExc_uid88_fpSubTest_b, xout => redist13_expRPreExc_uid88_fpSubTest_b_2_q, clk => clk, aclr => areset );

    -- wEP2AllOwE_uid83_fpSubTest(CONSTANT,82)
    wEP2AllOwE_uid83_fpSubTest_q <= "0011111111";

    -- rndExp_uid84_fpSubTest(BITSELECT,83)@11
    rndExp_uid84_fpSubTest_b <= expFracR_uid82_fpSubTest_q(33 downto 24);

    -- rOvf_uid85_fpSubTest(LOGICAL,84)@11 + 1
    rOvf_uid85_fpSubTest_qi <= "1" WHEN rndExp_uid84_fpSubTest_b = wEP2AllOwE_uid83_fpSubTest_q ELSE "0";
    rOvf_uid85_fpSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rOvf_uid85_fpSubTest_qi, xout => rOvf_uid85_fpSubTest_q, clk => clk, aclr => areset );

    -- regInputs_uid89_fpSubTest(LOGICAL,88)@11
    regInputs_uid89_fpSubTest_q <= excR_aSig_uid32_fpSubTest_q and excR_bSig_uid46_fpSubTest_q;

    -- redist12_regInputs_uid89_fpSubTest_q_1(DELAY,232)
    redist12_regInputs_uid89_fpSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regInputs_uid89_fpSubTest_q, xout => redist12_regInputs_uid89_fpSubTest_q_1_q, clk => clk, aclr => areset );

    -- rInfOvf_uid92_fpSubTest(LOGICAL,91)@12
    rInfOvf_uid92_fpSubTest_q <= redist12_regInputs_uid89_fpSubTest_q_1_q and rOvf_uid85_fpSubTest_q;

    -- excRInfVInC_uid93_fpSubTest(BITJOIN,92)@12
    excRInfVInC_uid93_fpSubTest_q <= rInfOvf_uid92_fpSubTest_q & redist25_excN_bSig_uid43_fpSubTest_q_2_q & redist31_excN_aSig_uid29_fpSubTest_q_2_q & redist26_excI_bSig_uid42_fpSubTest_q_2_q & redist32_excI_aSig_uid28_fpSubTest_q_2_q & redist19_effSub_uid53_fpSubTest_q_10_q;

    -- excRInf_uid94_fpSubTest(LOOKUP,93)@12
    excRInf_uid94_fpSubTest_combproc: PROCESS (excRInfVInC_uid93_fpSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRInfVInC_uid93_fpSubTest_q) IS
            WHEN "000000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "000001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "000010" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "000011" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "000100" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "000101" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "000110" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "000111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "001111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "010111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "011111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100000" => excRInf_uid94_fpSubTest_q <= "1";
            WHEN "100001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "100111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "101111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "110111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111000" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111001" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111010" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111011" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111100" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111101" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111110" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN "111111" => excRInf_uid94_fpSubTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRInf_uid94_fpSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- rUdf_uid86_fpSubTest(BITSELECT,85)@11
    rUdf_uid86_fpSubTest_b <= STD_LOGIC_VECTOR(expFracR_uid82_fpSubTest_q(33 downto 33));

    -- excRZeroVInC_uid90_fpSubTest(BITJOIN,89)@11
    excRZeroVInC_uid90_fpSubTest_q <= aMinusA_uid78_fpSubTest_q & rUdf_uid86_fpSubTest_b & regInputs_uid89_fpSubTest_q & redist29_excZ_bSig_uid18_uid38_fpSubTest_q_10_q & redist34_excZ_aSig_uid17_uid24_fpSubTest_q_2_q;

    -- excRZero_uid91_fpSubTest(LOOKUP,90)@11 + 1
    excRZero_uid91_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRZero_uid91_fpSubTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRZeroVInC_uid90_fpSubTest_q) IS
                WHEN "00000" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00001" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00010" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00011" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "00100" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00101" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00110" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "00111" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01000" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01001" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01010" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01011" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "01100" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "01101" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01110" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "01111" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10000" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10001" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10010" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10011" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "10100" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "10101" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10110" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "10111" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11000" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11001" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11010" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11011" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "11100" => excRZero_uid91_fpSubTest_q <= "1";
                WHEN "11101" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11110" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN "11111" => excRZero_uid91_fpSubTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRZero_uid91_fpSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- concExc_uid98_fpSubTest(BITJOIN,97)@12
    concExc_uid98_fpSubTest_q <= excRNaN_uid97_fpSubTest_q & excRInf_uid94_fpSubTest_q & excRZero_uid91_fpSubTest_q;

    -- excREnc_uid99_fpSubTest(LOOKUP,98)@12 + 1
    excREnc_uid99_fpSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excREnc_uid99_fpSubTest_q <= "01";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (concExc_uid98_fpSubTest_q) IS
                WHEN "000" => excREnc_uid99_fpSubTest_q <= "01";
                WHEN "001" => excREnc_uid99_fpSubTest_q <= "00";
                WHEN "010" => excREnc_uid99_fpSubTest_q <= "10";
                WHEN "011" => excREnc_uid99_fpSubTest_q <= "10";
                WHEN "100" => excREnc_uid99_fpSubTest_q <= "11";
                WHEN "101" => excREnc_uid99_fpSubTest_q <= "11";
                WHEN "110" => excREnc_uid99_fpSubTest_q <= "11";
                WHEN "111" => excREnc_uid99_fpSubTest_q <= "11";
                WHEN OTHERS => -- unreachable
                               excREnc_uid99_fpSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- expRPostExc_uid118_fpSubTest(MUX,117)@13
    expRPostExc_uid118_fpSubTest_s <= excREnc_uid99_fpSubTest_q;
    expRPostExc_uid118_fpSubTest_combproc: PROCESS (expRPostExc_uid118_fpSubTest_s, cstAllZWE_uid21_fpSubTest_q, redist13_expRPreExc_uid88_fpSubTest_b_2_q, cstAllOWE_uid19_fpSubTest_q)
    BEGIN
        CASE (expRPostExc_uid118_fpSubTest_s) IS
            WHEN "00" => expRPostExc_uid118_fpSubTest_q <= cstAllZWE_uid21_fpSubTest_q;
            WHEN "01" => expRPostExc_uid118_fpSubTest_q <= redist13_expRPreExc_uid88_fpSubTest_b_2_q;
            WHEN "10" => expRPostExc_uid118_fpSubTest_q <= cstAllOWE_uid19_fpSubTest_q;
            WHEN "11" => expRPostExc_uid118_fpSubTest_q <= cstAllOWE_uid19_fpSubTest_q;
            WHEN OTHERS => expRPostExc_uid118_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid111_fpSubTest(CONSTANT,110)
    oneFracRPostExc2_uid111_fpSubTest_q <= "00000000000000000000001";

    -- fracRPreExc_uid87_fpSubTest(BITSELECT,86)@11
    fracRPreExc_uid87_fpSubTest_in <= expFracR_uid82_fpSubTest_q(23 downto 0);
    fracRPreExc_uid87_fpSubTest_b <= fracRPreExc_uid87_fpSubTest_in(23 downto 1);

    -- redist14_fracRPreExc_uid87_fpSubTest_b_2(DELAY,234)
    redist14_fracRPreExc_uid87_fpSubTest_b_2 : dspba_delay
    GENERIC MAP ( width => 23, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRPreExc_uid87_fpSubTest_b, xout => redist14_fracRPreExc_uid87_fpSubTest_b_2_q, clk => clk, aclr => areset );

    -- fracRPostExc_uid114_fpSubTest(MUX,113)@13
    fracRPostExc_uid114_fpSubTest_s <= excREnc_uid99_fpSubTest_q;
    fracRPostExc_uid114_fpSubTest_combproc: PROCESS (fracRPostExc_uid114_fpSubTest_s, cstZeroWF_uid20_fpSubTest_q, redist14_fracRPreExc_uid87_fpSubTest_b_2_q, oneFracRPostExc2_uid111_fpSubTest_q)
    BEGIN
        CASE (fracRPostExc_uid114_fpSubTest_s) IS
            WHEN "00" => fracRPostExc_uid114_fpSubTest_q <= cstZeroWF_uid20_fpSubTest_q;
            WHEN "01" => fracRPostExc_uid114_fpSubTest_q <= redist14_fracRPreExc_uid87_fpSubTest_b_2_q;
            WHEN "10" => fracRPostExc_uid114_fpSubTest_q <= cstZeroWF_uid20_fpSubTest_q;
            WHEN "11" => fracRPostExc_uid114_fpSubTest_q <= oneFracRPostExc2_uid111_fpSubTest_q;
            WHEN OTHERS => fracRPostExc_uid114_fpSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- R_uid119_fpSubTest(BITJOIN,118)@13
    R_uid119_fpSubTest_q <= signRPostExc_uid110_fpSubTest_q & expRPostExc_uid118_fpSubTest_q & fracRPostExc_uid114_fpSubTest_q;

    -- xOut(GPOUT,4)@13
    q <= R_uid119_fpSubTest_q;

END normal;
