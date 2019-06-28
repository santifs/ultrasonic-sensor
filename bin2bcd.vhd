----------------------------------------------------------------------------------
-- Company: DTE-US
-- Engineer: CJJF
-- 
-- Create Date:    17:32:29 05/08/2014 
-- Design Name: 
-- Module Name:    bin2bcd - Behavioral 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity bin2bcd is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           num_bin : in  STD_LOGIC_VECTOR (12 downto 0);
           ud : out  STD_LOGIC_VECTOR (3 downto 0);
           dec : out  STD_LOGIC_VECTOR (3 downto 0);
           cen : out  STD_LOGIC_VECTOR (3 downto 0);
           mil : out  STD_LOGIC_VECTOR (3 downto 0));
end bin2bcd;

architecture Behavioral of bin2bcd is

  signal ud_i, dec_i, cen_i, mil_i: unsigned(3 downto 0);
  signal num_bin_reg: std_logic_vector(12 downto 0);
  signal bcd4: unsigned(15 downto 0);
  type tipo_estado is (carga, despl, compr, fin);
  signal comp_u, comp_d, comp_c, comp_m: std_logic;
  signal sumar: std_logic;

begin

  P1:process(clk, reset)
  
     variable i: integer range 0 to num_bin'high;
     variable state: tipo_estado;
     
  begin
     if reset = '1' then
        bcd4 <= (others => '0');
        state := carga;
     elsif rising_edge(clk) then
        case state is
           when carga =>
              num_bin_reg <= num_bin;
              bcd4 <= (others => '0');
              i := num_bin'high;
              state := despl;
            when despl =>
              bcd4(15 downto 1) <= bcd4(14 downto 0);
              bcd4(0) <= std_logic(num_bin_reg(12));
              num_bin_reg <= num_bin_reg(11 downto 0) & '0';
              if i > 0 then
                 i := i - 1;
                 state := compr;
              else
                 state := fin;
              end if;
            when compr =>
              if (sumar = '1') then
                if (comp_u = '1') then
                   bcd4( 3 downto  0) <= bcd4( 3 downto  0) + 3;
                end if;
                if (comp_d = '1') then
                   bcd4( 7 downto  4) <= bcd4( 7 downto  4) + 3;
                end if;
                if (comp_c = '1') then
                   bcd4(11 downto  8) <= bcd4(11 downto  8) + 3;
                end if;
                if (comp_m = '1') then
                   bcd4 (15 downto 12) <= bcd4 (15 downto 12) + 3;
                end if;
                state := despl;
              else
                bcd4(15 downto 1) <= bcd4(14 downto 0);
                bcd4(0) <= std_logic(num_bin_reg(12));
                num_bin_reg <= num_bin_reg(11 downto 0) & '0';
                if i > 0 then
                   i := i - 1;
                   state := compr;
                else
                   state := fin;
                end if;
              end if;
            when fin =>
              ud  <= std_logic_vector(bcd4( 3 downto  0));
              dec <= std_logic_vector(bcd4( 7 downto  4));
              cen <= std_logic_vector(bcd4(11 downto  8));
              mil <= std_logic_vector(bcd4(15 downto 12));
              state := carga;
        end case;
     end if;
  end process;           

   comp_u <= '1' when bcd4( 3 downto  0) > 4 else '0';
   comp_d <= '1' when bcd4( 7 downto  4) > 4 else '0';
   comp_c <= '1' when bcd4(11 downto  8) > 4 else '0';
   comp_m <= '1' when bcd4(15 downto 12) > 4 else '0';
   
   sumar <= comp_u OR comp_d OR comp_c OR comp_m;

end Behavioral;

