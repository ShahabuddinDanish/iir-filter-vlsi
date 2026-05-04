library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;
use work.filter_package.ALL;

entity iirfilter is
    Port ( CLK      : in STD_LOGIC;
           RST_n    : in STD_LOGIC;
           VIN      : in STD_LOGIC;
           Bi0      : in SIGNED(NB-1 downto 0);           -- Filter coefficient b0
           Bi       : in SIGNED(NB-1 downto 0);           -- Filter coefficient b
           Ai       : in SIGNED(NB-1 downto 0);           -- Filter coefficient a
           DIN      : in SIGNED(NB-1 downto 0); 		  -- Input with NB bits
           VOUT     : out STD_LOGIC;
           DOUT     : out SIGNED(NB-1 downto 0)           -- Output with NB bits
    );
end iirfilter;

architecture Behavioral of iirfilter is
    
    signal sw_reg_in   : SIGNED(NB downto 0) := (others => '0');
	signal sw_reg_out  : SIGNED(NB downto 0) := (others => '0');
	signal y_reg_in    : SIGNED(NB-1 downto 0) := (others => '0'); 
	signal x_reg_out   : SIGNED(NB-1 downto 0) := (others => '0');
	signal ai_reg_out  : SIGNED(NB-1 downto 0) := (others => '0');
	signal bi_reg_out  : SIGNED(NB-1 downto 0) := (others => '0');
	signal bi0_reg_out : SIGNED(NB-1 downto 0) := (others => '0');
    signal ff_signal   : SIGNED(NB-1 downto 0) := (others => '0');
    signal fb_signal   : SIGNED(NB downto 0) := (others => '0');
	signal vin_reg_out : STD_LOGIC := '0';


begin

    VIN_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  '1',
            REG_IN  =>  VIN,
            REG_OUT =>  vin_reg_out
    );

    VOUT_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  '1',
            REG_IN  =>  vin_reg_out,
            REG_OUT =>  VOUT
    );

    DIN_reg   :   reg 
        generic map (
            WIDTH   => NB 
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  VIN,
            REG_IN  =>  DIN,
            REG_OUT =>  x_reg_out
    );

    SW_reg   :   reg 
        generic map (
            WIDTH   =>  NB+1
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  vin_reg_out,
            REG_IN  =>  sw_reg_in,
            REG_OUT =>  sw_reg_out
    );

    ai_reg   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  '1',
            REG_IN  =>  Ai,
            REG_OUT =>  ai_reg_out
    );

    bi_reg   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  '1',
            REG_IN  =>  Bi,
            REG_OUT =>  bi_reg_out
    );

    bi0_reg   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  '1',
            REG_IN  =>  Bi0,
            REG_OUT =>  bi0_reg_out
    );

    DOUT_reg   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_n   =>  RST_n,
            EN      =>  vin_reg_out,
            REG_IN  =>  y_reg_in,
            REG_OUT =>  DOUT
    );


    fb_signal <= extract_15_bits((((sw_reg_out * ai_reg_out) srl SHAMT) sll 8));

    ff_signal <= extract_14_bits((((sw_reg_out * bi_reg_out) srl SHAMT) sll 8));

    sw_reg_in <= (x_reg_out - fb_signal);
    
    y_reg_in <= (extract_14_bits(((sw_reg_in * bi0_reg_out) srl SHAMT) sll 8) + ff_signal);

end Behavioral;
