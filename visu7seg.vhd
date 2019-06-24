----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:35:43 04/23/2019 
-- Design Name: 
-- Module Name:    visu7seg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity visu7seg is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           ud : in  STD_LOGIC_VECTOR (3 downto 0);
           dec : in  STD_LOGIC_VECTOR (3 downto 0);
           cen : in  STD_LOGIC_VECTOR (3 downto 0);
           mil : in  STD_LOGIC_VECTOR (3 downto 0);
           an : out  STD_LOGIC_VECTOR (7 downto 0);
           ca : out  STD_LOGIC;
           cb : out  STD_LOGIC;
           cc : out  STD_LOGIC;
           cd : out  STD_LOGIC;
           ce : out  STD_LOGIC;
           cf : out  STD_LOGIC;
           cg : out  STD_LOGIC);
end visu7seg;

architecture Behavioral of visu7seg is
   signal cont : unsigned (18 downto 0);
   signal visu : std_logic_vector (6 downto 0);
   signal q_u : std_logic_vector (3 downto 0);

begin

   P1_cont:process(clk, reset)
   begin
      if (reset = '1') then
         cont <= (others => '0');
      elsif rising_edge(clk) then
         cont <= cont + 1;
      end if;
   end process;
   
   an(7 downto 4) <= "1111";
   
   with cont(18 downto 17) & reset select
    an(3 downto 0) <= "1110" when "000",  -- 0
                      "1101" when "010",  -- 1
                      "1011" when "100",  -- 2
                      "0111" when "110",  -- 3
                      "1111" when others;  -- apagado 
   
   with cont(18 downto 17) select
    q_u <=  ud when "00",
           dec when "01",
           cen when "10",
           mil when "11";
           
   with q_u select
    visu <= "0000001" when "0000",  -- 0
            "1001111" when "0001",  -- 1
            "0010010" when "0010",  -- 2
            "0000110" when "0011",  -- 3
            "1001100" when "0100",  -- 4
            "0100100" when "0101",  -- 5
            "0100000" when "0110",  -- 6
            "0001111" when "0111",  -- 7
            "0000000" when "1000",  -- 8
            "0000100" when "1001",  -- 9
            "1111111" when others;  -- apagado
            
  ca <= visu(6);
  cb <= visu(5);
  cc <= visu(4);
  cd <= visu(3);
  ce <= visu(2);
  cf <= visu(1);
  cg <= visu(0);

end Behavioral;

