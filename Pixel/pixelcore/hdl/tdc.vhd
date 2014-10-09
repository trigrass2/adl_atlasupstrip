  
--------------------------------------------------------------
-- Serializer for High Speed I/O board (ATLAS Pixel teststand)
-- Martin Kocian 01/2009
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity tdc is

port(	sysclk:     in std_logic;
        sysrst:    in std_logic;
        edge1: 	    in std_logic;
        edge2:      in std_logic;
        start:      in std_logic;
        ready:      out std_logic;
        counter1:    out std_logic_vector(31 downto 0);
        counter2:    out std_logic_vector(31 downto 0)
);
end tdc;

---------------------------------------------------------------

architecture TDC of tdc is
  component FDCPE
    generic(INIT:bit:='0');
    port(
      Q : out std_logic;
      C : in STD_LOGIC;
      CE : in STD_LOGIC;
      CLR : in STD_LOGIC;
      D : in STD_LOGIC;
      PRE : in STD_LOGIC); 
  end component;
  component LUT1_D
    generic(INIT:bit_vector(1 downto 0));
    port(
      LO: out std_logic;
      O : out std_logic;
      I0: in std_logic
    );
  end component;
  component BUFG 
    port (
      O: out std_logic;
      I: in std_logic
      );
  end component;
  component BUFR 
    generic (BUFR_DIVIDE : string := "BYPASS");
    port (
      O: out std_logic;
      CE: in std_logic;
      CLR: in std_logic;
      I: in std_logic
      );
  end component;
  constant numdel:integer:=64;
  attribute LUT_MAP : string;
  attribute LUT_MAP of LUT1_D : component is "lut";
  signal clear: std_logic;
  signal isready: std_logic;
  signal oldstart: std_logic;
  signal oldoldstart: std_logic;
  signal controlstop: std_logic;
  signal controlstopb: std_logic;
  signal controlstartb: std_logic;
  signal carry: std_logic_vector(numdel downto 0);
  signal result: std_logic_vector(numdel-1 downto 0);
  signal localtap: std_logic_vector(numdel-1 downto 0);
  signal ss: std_logic_vector(numdel-1 downto 0);
  signal st: std_logic_vector(numdel-1 downto 0);
  
--  attribute U_SET: string;
  attribute RLOC: string;
--  attribute U_SET of startcontrol: label is "TDC";
  attribute RLOC of startcontrol : label is "X0Y-1";
--  attribute U_SET of stopcontrol: label is "TDC";
  attribute RLOC of stopcontrol : label is "X0Y0";
  --attribute U_SET of TAP: label is "TDC";
  --attribute U_SET of DELAYY: label is "TDC";

  --attribute U_SET of MUX: label is "TDC";
  attribute Keep: boolean;
  attribute Keep of carry : signal is true;
  attribute Keep of localtap : signal is true;
  attribute Keep of controlstop : signal is true;
  attribute Keep of ss : signal is true;
  attribute Keep of st : signal is true;
  attribute OPT: string;
  attribute OPT of carry : signal is "KEEP";
  attribute OPT of localtap : signal is "KEEP";
  attribute OPT of controlstop : signal is "KEEP";
  attribute OPT of st : signal is "KEEP";
begin
 ready<=isready;
 process (sysrst, sysclk)
 begin
   if(sysrst='1') then
     isready<='0';
     oldstart<='0';
     oldoldstart<='0';
     clear<='1';
   elsif(rising_edge(sysclk)) then
     if(start='1' and oldstart='0')then
       clear<='1';
     elsif(oldstart='1' and oldoldstart='0')then
       clear<='0';
       isready<='1';
     elsif(controlstop='1')then
       isready<='0';
     end if;
     oldstart<=start;
     oldoldstart<=oldstart;
   end if;
 end process;
     
   CHAIN:
   for I in 0 to numdel-1 generate
     constant lfour :natural:=(I mod 8)/4;
     constant sfour :natural:= 1-lfour;
     constant row :natural:=sfour*((I mod 4)*2+(I/8) mod 2)+lfour*(6-(I mod 4)*2 + (I/8) mod 2);
     constant column:natural:=((I/4)mod 2)*2+I/32+1;
     constant rloc_str : string := "X" & natural'image(row) & "Y" & natural'image(column);
     attribute RLOC of TAP: label is rloc_str;
     attribute RLOC of DELAYY: label is rloc_str;
     begin
     TAP: FDCPE
       port map (
         Q=>result(I),
         C=>controlstop,
         CE=>'1',
         CLR=>clear,
         D=>st(i), --localtap(I),
         PRE=>'0'
         ); 
  --   MUX: MUXF5_D
   --    port map (
   --      LO => localtap(I),
   --      O  => carry(I+1),
   --      I0 => ss(I),
   --      I1 => carry(I),
   --      S  => '1' 
   --      );
   -- DELAYX: LUT1_D
   --   generic map ( INIT => "11" )
   --   port map (
   --           LO => ss(I),
   --           O => open,
   --           I0 => isready 
   --           );
    DELAYY: LUT1_D
      generic map ( INIT => "10" )
      port map (
              LO => st(I),
              O => carry(I+1),
              I0 => carry(I) 
              );
   end generate CHAIN;


     
   startcontrol: FDCPE
    port map (
             Q=>carry(0),
             C=>edge1,
             CE=>'1',
             CLR=>clear,
             D=>'1',
             PRE=>'0'
             ); 
  stopcontrol: FDCPE
    port map (
             Q=>controlstopb,
             C=>edge2,
             CE=>carry(0),
             CLR=>clear,
             D=>'1',
             PRE=>'0'
             );
 -- BUFG_stop: BUFG
  --  port map(
  --           O => controlstop,
  --           I => controlstopb
  --           );
 BUFR_stop : BUFR
   generic map (
     BUFR_DIVIDE => "BYPASS")
   port map (
     O => controlstop, -- Clock buffer output
     CE => '1', -- Clock enable input
     CLR => '0', -- Clock buffer reset input
     I => controlstopb -- Clock buffer input
     );
  --BUFG_start: BUFG
    --port map(
             --O => carry(0),
             --I => controlstartb
             --);  
  
--  ex: for i in 0 to numdel/2-1 generate
--   counter1(i)<=result(I*2);
--  end generate ex;
    counter1<=result(31 downto 0);
    counter2<=result(63 downto 32);
end TDC;
           
           
           
           