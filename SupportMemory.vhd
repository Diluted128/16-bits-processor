library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity busint is
port
(    --  Control of MAR
     Smar : in bit;
	  -- Control of MBR
	  Smbr, WRin, RDin, MIOin : in bit;
	  -- input 32bit to MAR
     ADR : in signed(31 downto 0);
	  -- input 16bit to MBR
     DO : in signed(15 downto 0);
	  -- BUFFER 16bit
     D : inout signed (15 downto 0);
	  -- output 32bit
	  AD : out signed (31 downto 0);
	  -- output of MBR
     DI : out signed(15 downto 0);
	  -- extansion of WRin and RDin
     WR, RD, MIOout : out bit
);
end entity;
 
architecture rtl of busint is
begin
   process(Smar, ADR, Smbr, DO, D, WRin, RDin)
         variable MBRin, MBRout: signed(15 downto 0);
         variable MAR : signed(31 downto 0);
   begin
         if(Smar='1') then MAR := ADR; end if;
         if(Smbr='1') then MBRout := DO; end if;
         if (RDin='1') then MBRin := D; end if;
         if (WRin='1') then D <= MBRout;
         else D <= "ZZZZZZZZZZZZZZZZ";
         end if;
        
		   AD <= MAR;
         DI <= MBRin;
         WR <= WRin;
         RD <= RDin;
			MIOout <= MIOin;
   end process;
end rtl;