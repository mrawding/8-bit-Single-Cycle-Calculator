----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2019 05:21:10 PM
-- Design Name: 
-- Module Name: calc - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity calc is
    Port (clock,btn: in std_logic;
     I: in std_logic_vector(7 downto 0);
     B: out std_logic;
     Anode_Activate1 : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
     LED_out1 : out STD_LOGIC_VECTOR (6 downto 0));-- Cathode patterns of 7-segment display
end calc;


architecture Behavioral of calc is

component ssd is
     Port ( clock_100Mhz,clk : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           input: in STD_LOGIC_VECTOR(7 downto 0);
           reset : in STD_LOGIC; -- reset
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0));-- Cathode patterns of 7-segment display
end component;

component button_debouncer is
    port(clk: in std_logic;
    button : in std_logic;
    button_out: out std_logic
  );
end component;

component comparator is
    port( A, B : in std_logic_vector(7 downto 0);
        C : out std_logic
        );
end component;

component reg_file is
    port(reg_a,reg_b,reg_des: in std_logic_vector(1 downto 0);
        write_en, clk: in std_logic;
        write_data : in std_logic_vector(7 downto 0);
        ra_out, rb_out: out std_logic_vector(7 downto 0)
        );
end component;
component sign_xtender is
    port(
        A : in std_logic_vector(3 downto 0);
        B : out std_logic_vector(7 downto 0)
        );
end component;
component skip_count is
    port(ct: in std_logic_vector(1 downto 0);
        clk : in std_logic;
        skip: out std_logic_vector(1 downto 0)
        );
end component;

component add_sub_8b is
    port(A,B: in std_logic_vector(7 downto 0);
		sel: in std_logic_vector(1 downto 0);
		O: out std_logic_vector(7 downto 0)
	);
end component;
signal clk,ssd_en: std_logic;
signal reset: std_logic := '0';
signal rs,rt,rd: std_logic_vector(1 downto 0);
signal rs_d, rt_d,alu_res,imm_res,wrt_d: std_logic_vector(7 downto 0);
signal wrt_en, wrt_en1,wrt_en_sel,wd_sel: std_logic;
signal btn_cnt: unsigned(1 downto 0);
signal cmp_res: std_logic;
signal imm: std_logic_vector(3 downto 0);
signal op,skip_ct,skip_sel: std_logic_vector(1 downto 0);
signal skip,func: std_logic;
begin

    butt: button_debouncer port map(clock,btn,clk);
    reg:  reg_file port map(rs,rt,rd,wrt_en,clk,wrt_d,rs_d,rt_d);
    sev_seg: ssd port map(clock,ssd_en,rs_d,reset,Anode_Activate1,LED_out1);
    alu: add_sub_8b port map(rs_d,rt_d,op,alu_res);
    comp: comparator port map(rs_d,rt_d, cmp_res);
   -- xtend: sign_xtender port map(imm,imm_res);
    skipper: skip_count port map(skip_ct,clk,skip_sel);
   
    
    B <= clk;
    imm_res(3 downto 0) <= I(3 downto 0);
    with I(3) select imm_res(7 downto 4) <= 
        "1111" when '1',
        "0000" when others;
    wd_sel <= I(7);
    with wd_sel select wrt_d <=
         alu_res when '0',
         imm_res when others;
    op <= I(7 downto 6);
    func <= I(5);
    skip <= I(4);
    rd <= I(5 downto 4);
    rs <= I(3 downto 2);
    rt <= I(1 downto 0);
    wrt_en1 <= not(op(1) and op(0));
    with skip_sel select skip_ct <=
        "10" when "11",
         (0 => skip, others => (cmp_res and op(0) and op(1) and (not(func))))when others;
    wrt_en_sel <= skip_sel(1);
    with wrt_en_sel select wrt_en <=
        '0' when '1',
        wrt_en1 when others;
    
    process(I) is 
    begin
        ssd_en <= (I(7) and I(6) and I(5));
    end process;
--    process(clk) is
--        begin
--            if(clk'event and clk = '1') then
--             op <= I(7 downto 6); -- assign op field on rising edge of clock
--             end if;
--        end process;
--    process(skip_ct1) is -- controls skip flip flop
--        begin
--            if(skip_ct1(1) = '1') then -- if first bit of skip_ct1 is '1' then automatically skip
--                wrt_en <= '0'; -- reg_file cannot write 
--            else
--                wrt_en <= wrt_en1; -- if it's anything else, wrt_en defaults to another control logic
--             end if;
--        end process;
--    process(skip_ct1) is
--        begin
--            if(skip_ct1 = "11") then --controls input to skip_count flip_flop, skip 2
--                skip_ct <= "10";
--            end if;
--         end process;
   -- process(op(1)) is 
      --  begin
         --   if(op(1) = '1') then
           --   rs_d <= imm_res;
            --else
               -- rs_d <= rs_d;
          --  end if;
  --  end process;
                  
                      
--    process(op) is
--        begin 
--            if((op = "00") or (op = "01" )) then  --add/sub
--                rs <= I(5 downto 4);
--                rt <= I(3 downto 2);
--                rd <= I(1 downto 0);
--                wrt_en1 <= '1'; --write depending on skip instructions
--            elsif(op = "10") then --load
--                rd <= I(5 downto 4);
--                imm <= I(3 downto 0);
--                wrt_en1 <= '1';
--            elsif(op = "11") then
--                wrt_en1 <= '0';
--                func <= I(5);
--                rs <= I(3 downto 2);
--                if(func = '0') then
--                    rt <= I(1 downto 0);
--                    skip <= I(4);
--                end if;
--             end if;
--    end process;
                
end Behavioral;
