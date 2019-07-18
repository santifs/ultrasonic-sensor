----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Santiago Fernandez Scagliusi
-- 
-- Create Date:    15:50:38 05/27/2019 
-- Design Name:    Main
-- Module Name:    sistema_maxsonar - Behavioral 
-- Project Name:   Ultrasonic Car Parking Sensor
-- Target Devices: Nexys 4 DDR FPGA
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

entity sistema_maxsonar is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           echo : in  STD_LOGIC;
           mide : in  STD_LOGIC;
           modo : in  STD_LOGIC;
           alarma : OUT STD_LOGIC;           
		     trigger : OUT std_logic;
		     data_valid : OUT std_logic;
           an : OUT std_logic_vector(7 downto 0);
		     ca : OUT std_logic;
		     cb : OUT std_logic;
		     cc : OUT std_logic;
		     cd : OUT std_logic;
		     ce : OUT std_logic;
		     cf : OUT std_logic;
		     cg : OUT std_logic
           );
end sistema_maxsonar;

architecture Behavioral of sistema_maxsonar is

   COMPONENT control_maxsonar
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		inicio : IN std_logic;
		echo : IN std_logic;          
		trigger : OUT std_logic;
		data_valid : OUT std_logic;
		distancia : OUT std_logic_vector(10 downto 0)
		);
	END COMPONENT;
   
   COMPONENT bin2bcd
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		num_bin : IN std_logic_vector(12 downto 0);          
		ud : OUT std_logic_vector(3 downto 0);
		dec : OUT std_logic_vector(3 downto 0);
		cen : OUT std_logic_vector(3 downto 0);
		mil : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
   
   COMPONENT visu7seg
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		ud : IN std_logic_vector(3 downto 0);
		dec : IN std_logic_vector(3 downto 0);
		cen : IN std_logic_vector(3 downto 0);
		mil : IN std_logic_vector(3 downto 0);          
		an : OUT std_logic_vector(7 downto 0);
		ca : OUT std_logic;
		cb : OUT std_logic;
		cc : OUT std_logic;
		cd : OUT std_logic;
		ce : OUT std_logic;
		cf : OUT std_logic;
		cg : OUT std_logic
		);
	END COMPONENT;
   
   signal ud, dec, cen, mil : std_logic_vector(3 downto 0);
   signal num_bin : std_logic_vector(12 downto 0);
   signal inicio : std_logic;         
	signal distancia : std_logic_vector(10 downto 0);
   signal distancia_ampliada : std_logic_vector(12 downto 0);
   type tipo_estado is (continuo, unitario);
   signal estado: tipo_estado;
   signal clk_largo : unsigned(26 downto 0);

begin

   Inst_control_maxsonar: control_maxsonar PORT MAP(
		clk => clk,
		reset => reset,
		inicio => inicio,
		echo => echo,
		trigger => trigger,
		data_valid => data_valid,
		distancia => distancia
	);
   
   Inst_bin2bcd: bin2bcd PORT MAP(
		clk => clk,
		reset => reset,
		num_bin => distancia_ampliada,
		ud => ud,
		dec => dec,
		cen => cen,
		mil => mil
	);
   
   Inst_visu7seg: visu7seg PORT MAP(
		clk => clk,
		reset => reset,
		ud => ud,
		dec => dec,
		cen => cen,
		mil => mil,
		an => an,
		ca => ca,
		cb => cb,
		cc => cc,
		cd => cd,
		ce => ce,
		cf => cf,
		cg => cg
	);
   
   Pprincipal:process(clk, reset)
   begin
      if (reset = '1') then
         estado <= continuo;
         inicio <= '0';
      elsif rising_edge(clk) then
         case estado is
            when continuo =>
               inicio <= '1';
               if modo = '0' then
                  estado <= unitario;
               end if;
            when unitario =>
               inicio <= mide;
               if modo = '1' then
                  estado <= continuo;
               end if;
         end case;
      end if;
   end process;
   
   Pclk_muylargo:process(clk, reset)
   begin
      if (reset = '1') then
         clk_largo <= (others => '0');
      elsif rising_edge(clk) then
         clk_largo <= clk_largo + 1;
      end if;
   end process;
   
   distancia_ampliada <= "00" & distancia;
   
   alarma <= not clk_largo(26) when (distancia > "00001001011" and distancia < "00001100100") else
             not clk_largo(25) when (distancia > "00000110010" and distancia < "00001001011") else
             not clk_largo(24) when (distancia > "00000011001" and distancia < "00000110010") else
             not clk_largo(23) when (distancia > "00000001010" and distancia < "00000011001") else
             '0' when (distancia < "00000001010") else
             '1';
   
end Behavioral;

