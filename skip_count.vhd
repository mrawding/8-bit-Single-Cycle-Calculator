library ieee;
use ieee.std_logic_1164.all;

entity skip_count is
  port(ct: in std_logic_vector(1 downto 0);
        clk : in std_logic;
        skip: out std_logic_vector(1 downto 0)
        );
end skip_count;

architecture behav of skip_count is
signal hold_ct: std_logic_vector(1 downto 0) := "00";
  begin
  skip <= hold_ct;
  process(clk)
    begin
      if(clk'event and clk = '1') then
        hold_ct <= ct;
      end if;
    end process;
  end architecture;
