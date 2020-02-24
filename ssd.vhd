
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity ssd is
    Port ( clock_100Mhz,clk : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           input: in STD_LOGIC_VECTOR(7 downto 0);
           reset : in STD_LOGIC; -- reset

           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0));-- Cathode patterns of 7-segment display
end ssd;

architecture Behavioral of ssd is
signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
-- counter for generating 1-second clock enable
signal one_second_enable: std_logic;
-- one second enable for counting numbers
-- counting decimal number to be displayed on 4-digit 7-segment display
signal dig1: unsigned(6 downto 0);
signal dig2: unsigned(6 downto 0);
signal dig3: unsigned(6 downto 0);
signal dig4: unsigned(6 downto 0);
signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
-- creating 10.5ms refresh period
signal LED_activating_counter: std_logic_vector(1 downto 0);
signal split_factor: unsigned(6 downto 0);
-- the other 2-bit for creating 4 LED-activating signals
-- count         0    ->  1  ->  2  ->  3
-- activates    LED1    LED2   LED3   LED4
-- and repeat
begin
-- VHDL code for BCD to 7-segment decoder
-- Cathode patterns of the 7-segment LED display 

process(input)

begin
    if(input(7) = '1') then
        split_factor <= not(unsigned(input(6 downto 0))) + 1 ;
        if((split_factor > 99)) then
            dig1 <= "0001111" ;-- negative sign
            dig2 <= "0000001" ;-- 1
            dig3 <= (split_factor - 100)/10;
            dig4 <= (split_factor mod 10);
        elsif((split_factor < 100) and (split_factor > 9)) then
            dig1 <= "0001110"; -- off;
            dig2 <= "0001111"; -- negative sign
            dig3 <= (split_factor / 10);
            dig4 <= (split_factor mod 10);
        elsif(split_factor = 0) then
            dig1 <= "0001110";
            dig2 <= "0001110";
            dig3 <= "0001110";
            dig4 <= split_factor;
        else
            dig1 <= "0001110";
            dig2 <= "0001110";
            dig3 <= "0001111";
            dig4 <= split_factor;
        end if;
    else
        split_factor <= unsigned(input(6 downto 0));
        if((split_factor > 99)) then
            dig1 <= "0001110" ;-- off
            dig2 <= "0000001" ;--1
            dig3 <= (split_factor - 100)/10;
            dig4 <= (split_factor mod 10);
            
       elsif((split_factor < 100) and (split_factor > 9)) then
            dig1 <= "0001110"; -- off;
            dig2 <= "0001110"; -- off
            dig3 <= (split_factor / 10);
            dig4 <= (split_factor mod 10);
        else
            dig1 <= "0001110";
            dig2 <= "0001110";
            dig3 <= "0001110";
            dig4 <= split_factor;
        end if;
    end if;
end process;
            
process(LED_BCD)
begin
    case LED_BCD is
    when "0000" => LED_out <= "0000001"; -- "0"     
    when "0001" => LED_out <= "1001111"; -- "1" 
    when "0010" => LED_out <= "0010010"; -- "2" 
    when "0011" => LED_out <= "0000110"; -- "3" 
    when "0100" => LED_out <= "1001100"; -- "4" 
    when "0101" => LED_out <= "0100100"; -- "5" 
    when "0110" => LED_out <= "0100000"; -- "6" 
    when "0111" => LED_out <= "0001111"; -- "7" 
    when "1000" => LED_out <= "0000000"; -- "8"     
    when "1001" => LED_out <= "0000100"; -- "9" 
    when "1111" => LED_out <= "1111110";
    when "1110" => LED_out <= "1111111";
    when others => LED_out <= "1111111";
    end case;
end process;
-- 7-segment display controller
-- generate refresh period of 10.5ms
process(clock_100Mhz,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clock_100Mhz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 18);
-- 4-to-1 MUX to generate anode activating signals for 4 LEDs 

process(LED_activating_counter)
begin
    if(clk = '1') then
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "0111"; 
        -- activate LED1 and Deactivate LED2, LED3, LED4
        LED_BCD <= std_logic_vector(dig1(3 downto 0));
        -- the first hex digit of the 16-bit number
    when "01" =>
        Anode_Activate <= "1011"; 
        -- activate LED2 and Deactivate LED1, LED3, LED4
        LED_BCD <= std_logic_vector(dig2(3 downto 0));
        -- the second hex digit of the 16-bit number
    when "10" =>
        Anode_Activate <= "1101"; 
        -- activate LED3 and Deactivate LED2, LED1, LED4
        LED_BCD <= std_logic_vector(dig3(3 downto 0));
        -- the third hex digit of the 16-bit number
    when "11" =>
        Anode_Activate <= "1110"; 
        -- activate LED4 and Deactivate LED2, LED3, LED1
        LED_BCD <= std_logic_vector(dig4(3 downto 0));
        -- the fourth hex digit of the 16-bit number    
    end case;
    end if;
  --  Anode_Activate <= "1111"; 
end process;
-- Counting the number to be displayed on 4-digit 7-segment Display 
-- on Basys 3 FPGA board
process(clock_100Mhz, reset)
begin
        if(reset='1') then
            one_second_counter <= (others => '0');
        elsif(rising_edge(clock_100Mhz)) then
            if(one_second_counter>=x"5F5E0FF") then
                one_second_counter <= (others => '0');
            else
                one_second_counter <= one_second_counter + "0000001";
            end if;
        end if;
end process;
one_second_enable <= '1' when one_second_counter=x"5F5E0FF" else '0';

end Behavioral;