-- timestamp.vhd generated by mkfiles/timestamp.tcl:
-- Thu Oct 02 02:29:49 PM CST 2014 = 1412225989 = 0x542CDBC5
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timestamp is
   port( ts_o : out std_logic_vector (31 downto 0));
end timestamp ;

architecture rtl of timestamp is
begin
  ts_o <= conv_std_logic_vector(1412225989, 32);
end architecture rtl;

