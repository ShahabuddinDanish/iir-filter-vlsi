library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

package filter_package is
    constant N      : integer := 1;                 -- Order of the filter
    constant NTm1   : integer := N;                 -- Number of coefficients minus one (order)
    constant NB     : integer := 14;                -- Number of bits
    constant SHAMT  : integer := 21;                -- Shift amount

  function extract_14_bits(data: signed) return signed;
  function extract_15_bits(data: signed) return signed;

  component reg is
    generic (
      WIDTH     : integer := NB                   -- Register data width
    );
    port (
      CLK       : in  STD_LOGIC;                           -- Clock input
      RST_N     : in  STD_LOGIC;                           -- Active low reset input
      EN        : in  STD_LOGIC;                           -- Enable input
      REG_IN    : in  SIGNED (WIDTH-1 downto 0);            -- Input data
      REG_OUT   : out SIGNED (WIDTH-1 downto 0)             -- Output data
    );
  end component;

  component logicreg is
    generic (
      WIDTH     : integer := 1                   -- Register data width
    );
    port (
      CLK       : in  STD_LOGIC;                           -- Clock input
      RST_N     : in  STD_LOGIC;                           -- Active low reset input
      EN        : in  STD_LOGIC;                           -- Enable input
      REG_IN    : in  STD_LOGIC;            -- Input data
      REG_OUT   : out STD_LOGIC             -- Output data
    );
  end component;

end package filter_package;

package body filter_package is

  function extract_14_bits(data: signed) return signed is
  begin
      return data(13 downto 0);
  end function;

  function extract_15_bits(data: signed) return signed is
  begin
      return data(14 downto 0);
  end function;

end package body filter_package;
