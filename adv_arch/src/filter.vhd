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
    signal sw_reg_in  : SIGNED(NB downto 0) := (others => '0');
	signal sw_reg_out : SIGNED(NB downto 0) := (others => '0');
	signal x_reg_out : SIGNED(NB-1 downto 0) := (others => '0');
	signal ai_reg_out : SIGNED(NB-1 downto 0) := (others => '0');
	signal bi_reg_out : SIGNED(NB-1 downto 0) := (others => '0');
	signal bi0_reg_out : SIGNED(NB-1 downto 0) := (others => '0');
    signal ff_signal : SIGNED(NB-1 downto 0) := (others => '0');
    signal fb_signal : SIGNED(NB downto 0) := (others => '0');
	signal vin_reg_out : STD_LOGIC := '0';
    signal vout_reg_out : STD_LOGIC := '0';
    signal vout_reg2_out : STD_LOGIC := '0';

    signal x_n1 : SIGNED(NB-1 downto 0) := (others => '0');
    signal fb_0 : SIGNED(NB downto 0) := (others => '0');
    signal fb_1 : SIGNED(NB downto 0) := (others => '0');
    signal fb_2 : SIGNED(NB downto 0) := (others => '0');
    signal fb_3 : SIGNED(NB downto 0) := (others => '0');
    signal ff_1 : SIGNED(NB-1 downto 0) := (others => '0');
    signal temp1 : SIGNED(NB-1 downto 0) := (others => '0');
    signal temp2 : SIGNED(NB-1 downto 0) := (others => '0');
    signal y_temp : SIGNED(NB-1 downto 0) := (others => '0');

begin

    vin_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  VIN,
            REG_OUT =>  vin_reg_out
        );

    vout_temp_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  vin_reg_out,
            REG_OUT =>  vout_reg_out
        );

    vout_temp2_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  vout_reg_out,
            REG_OUT =>  vout_reg2_out
        );

    vout_reg   :   logicreg 
        generic map (
            WIDTH   => 1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  vout_reg2_out,
            REG_OUT =>  VOUT
        );

    input_reg   :   reg 
        generic map (
            WIDTH   => NB 
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  VIN,
            REG_IN  =>  DIN,
            REG_OUT =>  x_reg_out
        );

    x_n1_reg   :   reg 
        generic map (
            WIDTH   => NB 
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  vin_reg_out,
            REG_IN  =>  x_reg_out,
            REG_OUT =>  x_n1
        );

    sw_reg   :   reg 
        generic map (
            WIDTH   =>  NB+1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
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
            RST_N   =>  RST_N,
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
            RST_N   =>  RST_N,
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
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  Bi0,
            REG_OUT =>  bi0_reg_out
        );

    output_reg   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  vout_reg2_out,
            REG_IN  =>  y_temp,
            REG_OUT =>  DOUT
        );

    pipeline_reg1   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  temp1,
            REG_OUT =>  temp2
        );

    pipeline_reg2   :   reg 
        generic map (
            WIDTH   =>  NB
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  '1',
            REG_IN  =>  ff_1,
            REG_OUT =>  ff_signal
        );

    retiming_reg1   :   reg 
        generic map (
            WIDTH   =>  NB+1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  vin_reg_out,
            REG_IN  =>  fb_0,
            REG_OUT =>  fb_1
        );

    retiming_reg2   :   reg 
        generic map (
            WIDTH   =>  NB+1
        )
        port map (
            CLK     =>  CLK,
            RST_N   =>  RST_N,
            EN      =>  vin_reg_out,
            REG_IN  =>  fb_3,
            REG_OUT =>  fb_signal
        );


    fb_0 <= (extract_15_bits((sw_reg_in * ai_reg_out) srl SHAMT) sll SHAMT-NB+1);
    fb_2 <= (x_n1 - fb_1);
    fb_3 <= (extract_15_bits(((fb_2 * ai_reg_out) srl SHAMT) sll SHAMT-NB+1));

    sw_reg_in <= (x_n1 - fb_signal);

    temp1 <= (extract_14_bits(((sw_reg_in * bi0_reg_out) srl SHAMT) sll SHAMT-NB+1));

    ff_1 <= (extract_14_bits((sw_reg_out * bi_reg_out) srl SHAMT) sll SHAMT-NB+1);

    y_temp <= resize(temp2 + ff_signal, 14);

end Behavioral;

