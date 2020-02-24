----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2019 02:10:36 PM
-- Design Name: 
-- Module Name: comparator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparator is
  port( A, B : in std_logic_vector(7 downto 0);
        C : out std_logic
        );
end comparator;

architecture behav of comparator is
  begin
    C <= (A(7) xnor B(7)) and
          (A(6) xnor B(6)) and
          (A(5) xnor B(5)) and
          (A(4) xnor B(4)) and
          (A(3) xnor B(3)) and
          (A(2) xnor B(2)) and
          (A(1) xnor B(1)) and
          (A(0) xnor B(0));
  end architecture;
