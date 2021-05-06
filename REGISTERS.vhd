library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Rejestry is
   port
   (
	   clk : in std_logic;
		  
		-- [INPUT LINES]
		-- external bus line
      DI : in signed (15 downto 0);
		-- line to save data in registers from ALU
      BA : in signed (15 downto 0);
		  
		-- [CONTROL LINES] 
		-- Decide which data from register put to ALU
      Sbb : in signed (3 downto 0);
      Sbc : in signed (3 downto 0);
		-- control line to save data
      Sba : in signed (3 downto 0);
		-- line controling processor's registers
      Sid : in signed (2 downto 0);
		-- line concidering data to export
      Sa : in signed (1 downto 0);
		  
		-- [OUTPUT LINES] 
		-- output lines to ALU
      BB : out signed (15 downto 0);
      BC : out signed (15 downto 0);
		-- ????????
      ADR : out signed (31 downto 0);
      IRout : out signed (15 downto 0)
   );
end entity;
 
architecture rtl of Rejestry is
begin
process (clk, Sbb, Sbc, Sba, Sid, Sa, DI)
         variable ADH,ADL,IR, TMP, A, B, C, D, E, F: signed (15 downto 0);
         variable PC, SP, ATMP : signed (31 downto 0);
       begin
       if (clk'event and clk='1') then
         case Sid is
                  when "001" =>  PC := PC + 1;
                  when "010" =>  SP := SP + 1;
                  when "011" =>  SP := SP - 1;
						when "100" =>  ADL := ADL + 1;
						when "101" =>  ADL := ADL + 1;
						when "110" =>  ADH := ADH + 1;
						when "111" =>  ADH := ADH - 1;
                  when others => null;
         end case;
         case Sba is
                  when "0000" => IR := BA;
                  when "0001" => TMP := BA;
                  when "0010" => A := BA;
                  when "0011" => B := BA;
                  when "0100" => C := BA;
						when "0101" => D := BA;
						when "0110" => E := BA;
						when "0111" => F := BA;
						when "1000" => ADH := BA;
						when "1001" => ADL := BA;
						when "1010" => PC := BA & X"00";
						when "1011" => PC := X"00" & BA;
						when "1100" => SP := BA & X"00";
						when "1101" => SP := X"00" & BA;
						when "1110" => ATMP := BA & X"00";
						when "1111" => ATMP := X"00" & BA;
         end case;
       end if;
         case Sbb is
                  when "0000" => BB <= DI;
                  when "0001" => BB <= TMP;
                  when "0010" => BB <= A;
                  when "0011" => BB <= B;
                  when "0100" => BB <= C;
						when "0101" => BB <= D;
						when "0110" => BB <= E;
						when "0111" => BB <= F;
						when "1000" => BB <= ADH;
						when "1001" => BB <= ADL;
						when "1010" => BB <= PC(31 downto 16);
						when "1011" => BB <= PC(15 downto 0);
						when "1100" => BB <= SP(31 downto 16);
						when "1101" => BB <= SP(15 downto 0);
						when "1110" => BB <= ATMP(31 downto 16);
						when "1111" => BB <= ATMP(15 downto 0);
         end case;
         case Sbc is
                  when "0000" => BC <= DI;
                  when "0001" => BC <= TMP;
                  when "0010" => BC <= A;
                  when "0011" => BC <= B;
                  when "0100" => BC <= C;
						when "0101" => BC <= D;
						when "0110" => BC <= E;
						when "0111" => BC <= F;
						when "1000" => BC <= ADH;
						when "1001" => BC <= ADL;
						when "1010" => BC <= PC(31 downto 16);
						when "1011" => BC <= PC(15 downto 0);
						when "1100" => BC <= SP(31 downto 16);
						when "1101" => BC <= SP(15 downto 0);
						when "1110" => BC <= ATMP(31 downto 16);
						when "1111" => BC <= ATMP(15 downto 0);
         end case;
         case Sa is
                  when "00" => ADR <= ADH & ADL;
                  when "01" => ADR <= PC;
                  when "10" => ADR <= SP;
                  when "11" => ADR <= ATMP;
         end case;
         IRout <= IR;
end process;
end rtl;