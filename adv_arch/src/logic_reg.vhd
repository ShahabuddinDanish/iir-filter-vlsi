library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.filter_package.all;

entity LOGICREG is
  generic (
    WIDTH : integer := 1
  );
  port (
      CLK       : in  STD_LOGIC;                           -- Clock input
      RST_N     : in  STD_LOGIC;                           -- Active low reset input
      EN        : in  STD_LOGIC;                           -- Enable input
      REG_IN    : in  STD_LOGIC;            -- Input data
      REG_OUT   : out STD_LOGIC             -- Output data
  );
end entity LOGICREG;

architecture Behavioral of LOGICREG is

  signal data_out : STD_LOGIC;

begin

  REG_OUT <= data_out;

  DELAY : process (CLK, RST_N) is
  begin

    if (RST_N = '0') then
      data_out <= '0';
    elsif (CLK'event and CLK = '1') then
      data_out <= data_out;
      if (EN = '1') then
        data_out <= REG_IN;
      end if;
    end if;

  end process DELAY;

end architecture Behavioral;

configuration REG2_BEHAVIORAL_CFG of LOGICREG is
 for Behavioral
 end for;
end REG2_BEHAVIORAL_CFG;


