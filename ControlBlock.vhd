library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity control is
port(
     clk : in std_logic;
	  
	  -- 16 bit control vector
     IR : in signed(15 downto 0);
	  
     reset, C, Z, S, INT : in std_logic;
     Salu : out bit_vector(3 downto 0);
	  Sbb : out bit_vector(3 downto 0);
	  Sbc : out bit_vector(3 downto 0);
	  Sba : out bit_vector(3 downto 0);
     Sid : out bit_vector(2 downto 0);
     Sa : out bit_vector(1 downto 0);
	  
     LDF, Smar, Smbr, WR, RD, INTA, MIO : out bit
);
end entity;
 
architecture rtl of control is
type state_type is (m0, m1, m10, m11, m12, m13, m14, m15, m16, m17, m20, m21, m22, m23, m24, m25, m26, m27, m28,
m29, m30, m31, m32, m33, m34, m35, m36, m37, m38, m40, m41, m50, m60, m61, m62, m63, m64, m65, m66, m67, m68,
m69, m70, m80, m81, m82, m83, m84, m9, m91, m92, m93, m94);
signal state : state_type;
begin
process (clk, reset)
   begin
	   -- pobranie instrukcji fetch
      if(reset = '1') then
         state <= m0;
      elsif (clk'event and clk='1') then
         case state is
           when m0=>
              state <= m1;
           when m1=>
			   ----------------------------- M1 Rozkodowywanie sygnalu
               case IR(15 downto 13) is
					
					   -- Rozkazy bez argumentow
                  when "000" =>
                     case IR(12 downto 11) is
							   -- NOP
                        when "00" =>
							 
                          if(INT='0') then state <= m0;
                          else state <= m9;            -- ????
                          end if;
								-- WAIT
                        when "01" => state <= m10;
								-- CALL
                        when "10" => state <= m11;
								-- RET
                        when "11" => state <= m15;
								
                    end case;
						  
						-- Rozkazy z argumentem R  
                  when "001" =>
                     case IR(12 downto 8) is
							   -- PUSH 
                        when "00000" => state <= m20;
								-- POP 
                        when "00001" => state <= m21;
								-- NEG 
                        when "00010" => state <= m23;
								-- NOT 
                        when "00011" => state <= m24;
								-- DEC 
                        when "00100" => state <= m25;
								-- INC
                        when "00101" => state <= m26;
								-- SHR
                        when "00110" => state <= m27;
								-- SHL
                        when "00111" => state <= m28;
								-- MOV R, M
                        when "01000" => state <= m29;
								-- MOV M, R
                        when "01001" => state <= m30;
								-- ADD
                        when "01010" => state <= m31;
								-- SUB
                        when "01011" => state <= m32;
								-- CMP
                        when "01100" => state <= m33;
								-- AND
                        when "01101" => state <= m34;
								-- OR
                        when "01110" => state <= m35;
								-- XOR
                        when "01111" => state <= m36;
								-- IN
                        when "10000" => state <= m37;
								-- OUT
                        when "10001" => state <= m38;
                        when others => state <= m0;
								
                     end case;
						-- Rozkazy z argumentem 16b
                  when "010" => state <= m40;
						-- Rozkazy z argumentem 32b
                  when "011" => state <= m50;
						-- Rozkazy z argumentami R i st16b
                  when "100" => state <= m60;
						-- Rozkazy z argumentami R i adr32b
                  when "101" => state <= m80;
                  when others => state <= m0;
				----------------------------- M1 Koniec rozkodowywania sygnalu
               end case;
            when m10=>
              if INT = '1' then state <= m9;
              else state <= m10;
              end if;
            when m11 => state <= m12;
            when m12 => state <= m13;
            when m13 => state <= m14;
            when m14 =>
              if INT = '1' then state <= m9;
              else state <= m0;
              end if;
          -- ... ---------------------------    <- dodac
        end case;
     end if;
end process;
 
process (state)
begin
    case state is
	      -- FETCH | NOP
			-- zapis z zewnątrz instrukcji do wykonania, wysłanie licznika na wyjscie
	      -- IR <- DI | PC <- PC + 1 | ADR (out) <- PC
         when m0 =>
           Sa <= "01"; Sbb <= "0000"; Sba <= "0000"; Sid <="001"; MIO <='1';
           Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; 
			------------------------------------------------------------------------------------
         when m1 =>
			-- Dekodowanie rozkazu
		   -- stan przejSciowy, procesor stoi w miejscu, sygnal 16 bitowy jest rozkodowywany wyżej
           MIO <='0';
           Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000";
			------------------------------------------------------------------------------------
			-- Rozkaz WAIT
         when m10 =>
           MIO <='0';
           Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; 
			------------------------------------------------------------------------------------
			-- Rozkaz CALL
			-- REJESTRY:             Zmniejszenie PC o jeden.
			-- Wspomaganie pamięci:  przesłanie SP do AD
			-- Wspomaganie pamięci:  odebranie PC(31 down to 16) i przeslanie na D.
         when m11 =>
            Sa <= "10"; Sbb <= "1010"; Sid <="011";  MIO <='1';
            Smar <='1'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0000"; 
			-- REJESTRY:             Zmniejszenie PC o jeden.
			-- Wspomaganie pamięci:  przesłanie SP do AD
			-- Wspomaganie pamięci:  pobranie czesci PC(15 downto 0) i przypisanie do D.
			when m12 =>
            Sa <= "10"; Sbb <= "1011"; Sid <="011"; MIO <='1';
            Smar <='1'; Smbr <= '1'; WR <='1'; RD <='0'; Salu <="0000";
			-- 
			when m13 =>
			-- REJESTRY:             Przypisanie do PCL wartości z ADL
            Sbb <= "1000"; Sba <= "1010"; MIO <='0';
            Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000";
			-- REJESTRY:             Przypisanie do PCH wartości z ADH
			when m14 =>
            Sbb <= "1011"; Sba <= "1011"; MIO <='0';
            Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000";
			------------------------------------------------------------------------------------
		   -- Rozkaz RET
			-- REJESTRY:             Zmniejszenie PC o dwa.
         when m15 =>
            Sid <="011";  MIO <='0';
            Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; 
			-- REJESTRY:             Zwiekszenie PC o jeden.
			-- Wspomaganie pamięci:  przesłanie SP do AD
			-- Wspomaganie pamięci:  przesłanie z zewnątrz przez DI do PCH
			when m16 =>
            Sa <= "10"; Sbb <= "0000"; Sba <= "1011"; Sid <="010"; MIO <='1';
            Smar <='1'; Smbr <= '0'; WR <='1'; RD <='1'; Salu <="0000";
			-- 
			when m17 =>
			-- Wspomaganie pamięci:  przesłanie SP do AD
			-- Wspomaganie pamięci:  przesłanie z zewnątrz przez DI do PCL            
            Sa <= "10"; Sbb <= "0000"; Sba <= "1010"; MIO <='1';
            Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000";
			------------------------------------------------------------------------------------
			-- Rozkaz PUSH R
			-- Rejestry: zwiekszamy wskaznik stosu o jeden
			-- Wspomaganie pamięci: wysyłamy wartosc wskaznika stosu na AD
			-- Zapis z D do DI a nastepnie do zapisujemy DI do rejestru określonego w IR
         when m20 =>
		     Sa <= "10"; Sbb <= "0000"; Sba <= "0" & IR(3 downto 0); Sid<="010"; MIO <='1';
			  Smar <='1'; Smbr <='0'; WR <='0'; RD <='1'; Salu <="0000";  
			------------------------------------------------------------------------------------
			-- Rozkaz POP R
			-- Rejestry: zmniejszamy wskaznik stosu o jeden
			-- Wspomaganie pamięci: przesylamy wartosc SP na AD
			-- Wspomaganie pamięci: IR(3 downto 0) <- decyzja ktora wartosc z rejestru zwolnic (wyslac na zatrzask MBR(MBR(out))
			when m21 =>
		     Sa <= "10"; Sbb := "0" & IR(3 downto 0); Sid<="011"; MIO <='1';                
			  Smar <='1'; Smbr <= '1'; WR <='0'; RD <='0'; Salu <="0000"; 
			------------------------------------------------------------------------------------
			-- Rozkaz NEG R
			-- Wybieramy ktora wartosc rejestru chcemy poddać negacji poprzez Sbb
			-- Zapisujemy otrzymana wartosc do tego samego rejestru z ktorego wczesniej pobralismy wartosc.
			when m23 =>
		     Sbb <= "0" & IR(3 downto 0); Sba <= "0" & IR(3 downto 0); MIO <='0';
			  Salu <="1001"; 
			------------------------------------------------------------------------------------
			-- INC R
			when m24 =>
			------------------------------------------------------------------------------------
			-- DEC R
			when m25 =>
			------------------------------------------------------------------------------------
			-- NOT R
			when m26 =>
			------------------------------------------------------------------------------------
			-- SHR R
			when m27 =>
			------------------------------------------------------------------------------------
			-- SHL R
			when m28 =>
			------------------------------------------------------------------------------------
			-- MOV R,RM
			when m29 =>
			------------------------------------------------------------------------------------
			-- MOV RM,R
			when m30 =>
			------------------------------------------------------------------------------------
			-- ADD R,RM
			when m31 =>
			------------------------------------------------------------------------------------
			-- SUB R,RM
			when m32 =>
			------------------------------------------------------------------------------------
			--CMP R, RM
			when m33 =>
			------------------------------------------------------------------------------------
			-- AND R,RM
			when m34 =>
			------------------------------------------------------------------------------------
			-- OR R, RM
			when m35 =>
			------------------------------------------------------------------------------------
			-- XOR R,RM
			when m36 =>
			------------------------------------------------------------------------------------
			-- IN R.IO(AD)
			when m37 =>
			------------------------------------------------------------------------------------
			-- OUT IO(AD),R
			when m38 =>
			------------------------------------------------------------------------------------
			-- Rozkazy skoków
			when m40 =>
		     Sa <= "01"; Sbb <= "0000"; Sba <= "0001"; Sid<="001"; Sbc<="0000"; MIO <='1';
			  Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; Salu <="0000"; LDF <='0'; INTA <='0';
			when m41 =>
			  Sa <= "00"; Sbb <= "1010"; Sba <= "0001"; Sid<="000"; Sbc<="0001"; MIO <='0';
			  Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0010"; LDF <='0'; INTA <='0';
			------------------------------------------------------------------------------------
			-- Rozkaz skoku długiego
			when m50 =>
			------------------------------------------------------------------------------------
			-- Rozkazy dwuargumentowe
			when m60 =>
			------------------------------------------------------------------------------------
			-- Rozkazy dwuargumentowe
			when m80 =>
			------------------------------------------------------------------------------------
         when others =>
           Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; MIO <='1';
           Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; Salu <="0000"; LDF <='0'; INTA <='0';
			
      end case;
   end process;
end rtl;