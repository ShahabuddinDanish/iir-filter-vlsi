library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.filter_package.all;

entity REG is
  generic (
    WIDTH : integer := NB
  );
  port (
      CLK       : in  STD_LOGIC;                           -- Clock input
      RST_N     : in  STD_LOGIC;                           -- Active low reset input
      EN        : in  STD_LOGIC;                           -- Enable input
      REG_IN    : in  SIGNED(WIDTH-1 downto 0);            -- Input data
      REG_OUT   : out SIGNED(WIDTH-1 downto 0)             -- Output data
  );
end entity REG;

architecture Behavioral of REG is

  signal data_out : SIGNED(WIDTH - 1 downto 0);

begin

  REG_OUT <= data_out;

  DELAY : process (CLK, RST_N) is
  begin

    if (RST_N = '0') then
      data_out <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      data_out <= data_out;
      if (EN = '1') then
        data_out <= REG_IN;
      end if;
    end if;

  end process DELAY;

end architecture Behavioral;

configuration REG_BEHAVIORAL_CFG of REG is
 for Behavioral
 end for;
end REG_BEHAVIORAL_CFG;


