-- megafunction wizard: %LPM_DECODE%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: LPM_DECODE 

-- ============================================================
-- File Name: decoder_param.vhd
-- Megafunction Name(s):
-- 			LPM_DECODE
--
-- Simulation Library Files(s):
-- 			lpm
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 15.0.0 Build 145 04/22/2015 SJ Web Edition
-- ************************************************************


--Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, the Altera Quartus II License Agreement,
--the Altera MegaCore Function License Agreement, or other 
--applicable license agreement, including, without limitation, 
--that your use is for the sole purpose of programming logic 
--devices manufactured by Altera and sold by Altera or its 
--authorized distributors.  Please refer to the applicable 
--agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY decoder_param IS
	GENERIC
	(
		INPUT_WIDTH 	: natural := 2;
		OUTPUT_DECODES : natural := 4
	);
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (INPUT_WIDTH - 1 DOWNTO 0);
		enable	: IN STD_LOGIC;
		selected : OUT STD_LOGIC_VECTOR(OUTPUT_DECODES - 1 DOWNTO 0)
	);
END decoder_param;


ARCHITECTURE SYN OF decoder_param IS

	COMPONENT lpm_decode
	GENERIC (
		lpm_decodes		: NATURAL;
		lpm_type			: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			data		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			enable	: IN STD_LOGIC;
			eq			: OUT STD_LOGIC_VECTOR (lpm_decodes -1 downto 0)
	);
	END COMPONENT;

BEGIN

	LPM_DECODE_component : LPM_DECODE
	GENERIC MAP (
		lpm_decodes => OUTPUT_DECODES,
		lpm_type => "LPM_DECODE",
		lpm_width => INPUT_WIDTH
	)
	PORT MAP (
		data 		=> data,
		enable 	=> enable,
		eq 		=> selected
	);



END SYN;