library ieee;
use ieee.std_logic_1164.all;

entity reg_file is
  port(reg_a,reg_b,reg_des: in std_logic_vector(1 downto 0);
        write_en, clk: in std_logic;
        write_data : in std_logic_vector(7 downto 0);
        ra_out, rb_out: out std_logic_vector(7 downto 0)
        );
end reg_file;

architecture behav of reg_file is
  signal r0 : std_logic_vector(7 downto 0) := "00000000";
  signal r1 : std_logic_vector(7 downto 0) := "00000000";
  signal r2 : std_logic_vector(7 downto 0) := "00000000";
  signal r3 : std_logic_vector(7 downto 0) := "00000000";
  begin
    with reg_a select ra_out <=
       r0 when "00",
       r1 when "01",
       r2 when "10",
       r3 when others;
    with reg_b select rb_out <=
      r0 when "00",
      r1 when "01",
      r2 when "10",
      r3 when others;

    process(clk) is
      begin
        if(clk'event and clk = '1') then
          if(write_en = '1') then
            if(reg_des = "00") then
              r0 <= write_data;
            elsif(reg_des = "01") then
              r1 <= write_data;
            elsif(reg_des = "10") then
              r2 <= write_data;
            else --elsif(reg_des = "11") then
              r3 <= write_data;
            end if;
          end if;
        end if;
      end process;
  end architecture;