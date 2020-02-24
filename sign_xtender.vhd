library ieee;
use ieee.std_logic_1164.all;

entity sign_xtender is
  port( A : in std_logic_vector(3 downto 0);
        B : out std_logic_vector(7 downto 0)
        );
end sign_xtender;

architecture behav of sign_xtender is
  begin
  B(3 downto 0) <= A;
  with A(3) select B(7 downto 4) <=
   "1111" when '1',
   "0000" when others;

end architecture;
