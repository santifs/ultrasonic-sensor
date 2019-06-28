----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:45:25 05/21/2019 
-- Design Name: 
-- Module Name:    control_maxsonar - Behavioral 
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

entity control_maxsonar is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           inicio : in  STD_LOGIC;
           echo : in  STD_LOGIC;
           trigger : out  STD_LOGIC;
           data_valid : out  STD_LOGIC;
           distancia : out  STD_LOGIC_VECTOR (10 downto 0));
end control_maxsonar;

architecture Behavioral of control_maxsonar is

   type tipo_estado is (s0,s1,s2);
   signal estado: tipo_estado;
   signal cuenta: unsigned(10 downto 0);
   signal clki: std_logic;
   signal cont_echo: unsigned(10 downto 0);

begin

   P1_clk:process(clk, reset)
   begin
      if (reset = '1') then
         cuenta <= (others => '0');
      elsif rising_edge(clk) then
         if cuenta < 1450 then
            cuenta <= cuenta + 1;
         else
            cuenta <= (others => '0');
         end if;
      end if;
   end process;
   clki <= cuenta(10);
   
   Pprincipal:process(clki, reset)
   begin
      if (reset = '1') then
         estado <= s0;
         cont_echo <= (others => '0');
         data_valid <= '0';
         distancia <= (others => '0');
         trigger <= '0';
      elsif rising_edge(clki) then
         case estado is
            when s0 =>           -- Espera inicio para activar trigger
               data_valid <= '0';
               cont_echo <= (others => '0'); -- Reinicia cuenta echo
               if inicio = '1' then
                  trigger <= '1';
                  estado <= s1;             
               end if;
               
            when s1 =>           -- Desactiva trigger después de 14,5us
               trigger <= '0';
               if echo = '1' then
                  estado <= s2;
               end if;
 
            when s2 =>
               if echo = '0' then
                  distancia <= std_logic_vector(cont_echo/4);
                  data_valid <= '1';
                  estado <= s0;
               else
                  if cont_echo < 1600 then
                     cont_echo <= cont_echo + 1;
                  end if;
               end if;          
         end case;
      end if;
   end process;

end Behavioral;

