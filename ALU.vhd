library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ALU is
port (
      -- ALU input
      A : in signed(15 downto 0);
      B : in signed(15 downto 0);
      Salu : in bit_vector (3 downto 0);
		-- flag enabler
      LDF : in bit;
      clk : in bit;
		-- ALU output
      Y : out signed (15 downto 0);
      C,Z,S : out std_logic
		-- Z - zero flag
		-- S - negative flag
		-- C - overflow flag
);
end entity;
 
architecture rtl of ALU is
begin
  process (Salu, A, B, clk)
       variable res, AA, BB,CC: signed (16 downto 0);
       variable CF,ZF,SF : signed (16 downto 0);
       begin
         AA(16) := A(15);
         AA(15 downto 0) := A;
         BB(16) := B(15);
         BB(15 downto 0) := B;
         CC(0) := CF(0);
         CC(16 downto 1) := "0000000000000000";
         case Salu is
            when "0000" => res := AA; 
            when "0001" => res := BB;
            when "0010" => res := AA + BB; --jest
            when "0011" => res := AA - BB; --jest
				when "0100" => res := AA OR BB; --jiest
				when "0101" => res := AA AND BB; --jest
				when "0110" => res := AA XOR BB; --jest
				when "0111" => res := AA XNOR BB; 
				when "1000" => res := not AA; -- jest
				when "1001" => res := -AA; -- jest
				when "1010" => res := "00000000000000000";
				when "1011" => res := AA + BB + CC;
				when "1100" => res := AA - BB - CC;
				when "1101" => res := AA + "0000000000000001"; -- jest
				when "1110" => res := shift_left(AA,1);   -- jest
				when "1111" => res := shift_right(AA,1); -- jest
            when others => null;
         end case;
         Y <= res(15 downto 0);
         Z <= ZF(0);
         S <= SF(0);
         C <= CF(0);
         if (clk'event and clk='1') then
            if (LDF='1') then
               if (res = "00000000000000000") then ZF:= "00000000000000001"; -- zero flag
               else ZF:= "00000000000000000";
               end if;
               if (res(16)='1') then SF:= "00000000000000001"; -- negative flag
               else SF:= "00000000000000000"; 
					end if;
               CF(0) := res(16) xor res(15); -- overflow flag
            end if;
         end if;
  end process;
end rtl;