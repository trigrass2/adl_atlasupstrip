-------------------------------------------------------------------------------
-- Title      : Virtex-4 Ethernet MAC Example Design Wrapper
-- Project    : Virtex-4 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : eth_gmii_example_design.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you
-- a license to use this text/file solely for design, simulation,
-- implementation and creation of design files limited
-- to Xilinx devices or technologies. Use with non-Xilinx
-- devices or technologies is expressly prohibited and
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information
-- "as is" solely for use in developing programs and
-- solutions for Xilinx devices. By providing this design,
-- code, or information as one possible implementation of
-- this feature, application or standard, Xilinx is making no
-- representation that this implementation is free from any
-- claims of infringement. You are responsible for
-- obtaining any rights you may require for your implementation.
-- Xilinx expressly disclaims any warranty whatsoever with
-- respect to the adequacy of the implementation, including
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied
-- warranties of merchantability or fitness for a particular
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications are
-- expressly prohibited.
--
-- This copyright and support notice must be retained as part
-- of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
-- All rights reserved.

-------------------------------------------------------------------------------
-- Description:  This is the VHDL example design for the Virtex-4 
--               Embedded Ethernet MAC.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               This level:
--
--               * instantiates the TEMAC local link file that instantiates 
--                 the TEMAC top level together with a RX and TX FIFO with a 
--                 local link interface;
--
--               * instantiates a simple client I/F side example design,
--                 providing an address swap and a simple
--                 loopback function;
--
--               * Instantiates IBUFs on the GTX_CLK, REFCLK and HOSTCLK inputs 
--                 if required;
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-4 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--
--
--
--    ---------------------------------------------------------------------
--    | EXAMPLE DESIGN WRAPPER                                            |
--    |           --------------------------------------------------------|
--    |           |LOCAL LINK WRAPPER                                     |
--    |           |              -----------------------------------------|
--    |           |              |BLOCK LEVEL WRAPPER                     |
--    |           |              |    ---------------------               |
--    | --------  |  ----------  |    | ETHERNET MAC      |               |
--    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
--    | |      |->|->|        |--|--->| Tx            Tx  |--|       |--->|
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | | ADDR |  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
--    | | SWAP |  |  |  LINK  |  |    |                   |  | PHY   |    |
--    | |      |  |  |  FIFO  |  |    |                   |  | I/F   |    |
--    | |      |  |  |        |  |    |                   |  |       |    |
--    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | |      |<-|<-|        |<-|----| I/F           I/F |<-|       |<---|
--    | |      |  |  |        |  |    |                   |  ---------    |
--    | --------  |  ----------  |    ---------------------               |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
-------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;



-------------------------------------------------------------------------------
-- The entity declaration for the example design.
-------------------------------------------------------------------------------
entity eth_gmii_example_design is
   port(
 
      GTX_CLK_0                       : in  std_logic;
      -- GMII Interface - EMAC0
      GMII_TXD_0                      : out std_logic_vector(7 downto 0);
      GMII_TX_EN_0                    : out std_logic;
      GMII_TX_ER_0                    : out std_logic;
      GMII_TX_CLK_0                   : out std_logic;
      GMII_RXD_0                      : in  std_logic_vector(7 downto 0);
      GMII_RX_DV_0                    : in  std_logic;
      GMII_RX_ER_0                    : in  std_logic;
      GMII_RX_CLK_0                   : in  std_logic;

      MII_TX_CLK_0                    : in  std_logic;
      GMII_COL_0                      : in  std_logic;
      GMII_CRS_0                      : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- Generic Host Interface
      HOSTOPCODE                      : in  std_logic_vector(1 downto 0);
      HOSTREQ                         : in  std_logic;
      HOSTMIIMSEL                     : in  std_logic;
      HOSTADDR                        : in  std_logic_vector(9 downto 0);
      HOSTWRDATA                      : in  std_logic_vector(31 downto 0);
      HOSTMIIMRDY                     : out std_logic;
      HOSTRDDATA                      : out std_logic_vector(31 downto 0);
      HOSTEMAC1SEL                    : in  std_logic;
      HOSTCLK                         : in  std_logic;
      -- Reference clock for RGMII IODELAYs
      REFCLK                          : in  std_logic; 
        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );

   attribute X_CORE_INFO : string;
   attribute X_CORE_INFO of eth_gmii_example_design : entity is "v4_emac_v4_6, Coregen 10.1i_ip0";
end eth_gmii_example_design;


architecture TOP_LEVEL of eth_gmii_example_design is

-------------------------------------------------------------------------------
-- Component Declarations for lower hierarchial level entities
-------------------------------------------------------------------------------
  -- Component Declaration for the TEMAC wrapper with 
  -- Local Link FIFO.
  component eth_gmii_locallink is
   port(
      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   : in  std_logic; 
      RX_LL_RESET_0                   : in  std_logic;
      RX_LL_DATA_0                    : out std_logic_vector(7 downto 0);
      RX_LL_SOF_N_0                   : out std_logic;
      RX_LL_EOF_N_0                   : out std_logic;
      RX_LL_SRC_RDY_N_0               : out std_logic;
      RX_LL_DST_RDY_N_0               : in  std_logic;
      RX_LL_FIFO_STATUS_0             : out std_logic_vector(3 downto 0);

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   : in  std_logic;
      TX_LL_RESET_0                   : in  std_logic;
      TX_LL_DATA_0                    : in  std_logic_vector(7 downto 0);
      TX_LL_SOF_N_0                   : in  std_logic;
      TX_LL_EOF_N_0                   : in  std_logic;
      TX_LL_SRC_RDY_N_0               : in  std_logic;
      TX_LL_DST_RDY_N_0               : out std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       : in  std_logic;
      RX_CLIENT_CLK_0                 : out std_logic;
      TX_CLIENT_CLK_0                 : out std_logic;

      -- GMII Interface - EMAC0
      GMII_TXD_0                      : out std_logic_vector(7 downto 0);
      GMII_TX_EN_0                    : out std_logic;
      GMII_TX_ER_0                    : out std_logic;
      GMII_TX_CLK_0                   : out std_logic;
      GMII_RXD_0                      : in  std_logic_vector(7 downto 0);
      GMII_RX_DV_0                    : in  std_logic;
      GMII_RX_ER_0                    : in  std_logic;
      GMII_RX_CLK_0                   : in  std_logic;

      MII_TX_CLK_0                    : in  std_logic;
      GMII_COL_0                      : in  std_logic;
      GMII_CRS_0                      : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- Generic Host Interface
      HOSTOPCODE                      : in  std_logic_vector(1 downto 0);
      HOSTREQ                         : in  std_logic;
      HOSTMIIMSEL                     : in  std_logic;
      HOSTADDR                        : in  std_logic_vector(9 downto 0);
      HOSTWRDATA                      : in  std_logic_vector(31 downto 0);
      HOSTMIIMRDY                     : out std_logic;
      HOSTRDDATA                      : out std_logic_vector(31 downto 0);
      HOSTEMAC1SEL                    : in  std_logic;
      HOSTCLK                         : in  std_logic;
      -- Reference clock for RGMII IODELAYs
      REFCLK                          : in  std_logic; 
 
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
  end component;
 
   ---------------------------------------------------------------------
   --  Component Declaration for 8-bit address swapping module
   ---------------------------------------------------------------------
   component address_swap_module_8
   port (
      rx_ll_clock         : in  std_logic;                     -- Input CLK from MAC Reciever
      rx_ll_reset         : in  std_logic;                     -- Synchronous reset signal
      rx_ll_data_in       : in  std_logic_vector(7 downto 0);  -- Input data
      rx_ll_sof_in_n      : in  std_logic;                     -- Input start of frame
      rx_ll_eof_in_n      : in  std_logic;                     -- Input end of frame
      rx_ll_src_rdy_in_n  : in  std_logic;                     -- Input source ready
      rx_ll_data_out      : out std_logic_vector(7 downto 0);  -- Modified output data
      rx_ll_sof_out_n     : out std_logic;                     -- Output start of frame
      rx_ll_eof_out_n     : out std_logic;                     -- Output end of frame
      rx_ll_src_rdy_out_n : out std_logic;                     -- Output source ready
      rx_ll_dst_rdy_in_n  : in  std_logic                      -- Input destination ready
      );
   end component;

-----------------------------------------------------------------------
-- Signal Declarations
-----------------------------------------------------------------------

    -- Global asynchronous reset
    signal reset_i               : std_logic;

    -- client interface clocking signals - EMAC0
    signal tx_clk_0_i            : std_logic;
    signal rx_clk_0_i            : std_logic;

    -- address swap transmitter connections - EMAC0
    signal tx_ll_data_0_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_0_i     : std_logic;
    signal tx_ll_eof_n_0_i     : std_logic;
    signal tx_ll_src_rdy_n_0_i : std_logic;
    signal tx_ll_dst_rdy_n_0_i : std_logic;

   -- address swap receiver connections - EMAC0
    signal rx_ll_data_0_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_0_i          : std_logic;
    signal rx_ll_eof_n_0_i          : std_logic;
    signal rx_ll_src_rdy_n_0_i      : std_logic;
    signal rx_ll_dst_rdy_n_0_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal tx_pre_reset_0_i          : std_logic_vector(5 downto 0);
    signal tx_reset_0_i              : std_logic;

    attribute async_reg : string;
    attribute async_reg of tx_pre_reset_0_i : signal is "true";


    -- Reference clock for RGMII IODELAYs
    signal refclk_ibufg_i    : std_logic;
    signal refclk_bufg_i     : std_logic;
    -- GTX_CLK input for EMAC0
    signal gtx_clk_ibufg_0_i : std_logic;
    -- HOSTCLK input to MAC
    signal host_clk_i        : std_logic;

     signal CLIENTEMAC0TXIFGDELAY : std_logic_vector(7 downto 0);
     signal CLIENTEMAC0PAUSEREQ : std_logic;
     signal CLIENTEMAC0PAUSEVAL : std_logic_vector(15 downto 0);

     signal CLIENTEMAC1TXIFGDELAY : std_logic_vector(7 downto 0);
     signal CLIENTEMAC1PAUSEREQ : std_logic;
     signal CLIENTEMAC1PAUSEVAL : std_logic_vector(15 downto 0);

     signal EMAC0CLIENTRXDVLD          : std_logic;
     signal EMAC0CLIENTRXFRAMEDROP     : std_logic;
     signal EMAC0CLIENTRXSTATS         : std_logic_vector(6 downto 0);
     signal EMAC0CLIENTRXSTATSVLD      : std_logic;
     signal EMAC0CLIENTRXSTATSBYTEVLD  : std_logic;
     signal EMAC0CLIENTTXSTATS         : std_logic;
     signal EMAC0CLIENTTXSTATSVLD      : std_logic;
     signal EMAC0CLIENTTXSTATSBYTEVLD  : std_logic;
--     signal EMAC0CLIENTSYNCACQSTATUS   : std_logic;

     signal EMAC1CLIENTRXDVLD          : std_logic;
     signal EMAC1CLIENTRXFRAMEDROP     : std_logic;
     signal EMAC1CLIENTRXSTATS         : std_logic_vector(6 downto 0);
     signal EMAC1CLIENTRXSTATSVLD      : std_logic;
     signal EMAC1CLIENTRXSTATSBYTEVLD  : std_logic;
     signal EMAC1CLIENTTXSTATS         : std_logic;
     signal EMAC1CLIENTTXSTATSVLD      : std_logic;
     signal EMAC1CLIENTTXSTATSBYTEVLD  : std_logic;
--     signal EMAC1CLIENTSYNCACQSTATUS   : std_logic;

     attribute buffer_type : string;
     attribute buffer_type of GTX_CLK_0  : signal is "ibuf";
     attribute buffer_type of HOSTCLK    : signal is "ibuf";

-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------


begin

    ---------------------------------------------------------------------------
    -- Reset Input Buffer
    ---------------------------------------------------------------------------
    reset_ibuf : IBUF port map (I => RESET, O => reset_i);

    CLIENTEMAC0TXIFGDELAY <= X"3F";
    CLIENTEMAC1TXIFGDELAY <= X"3F";
    CLIENTEMAC0PAUSEREQ   <= '0'; 
    CLIENTEMAC1PAUSEREQ   <= '0'; 
    CLIENTEMAC0PAUSEVAL   <= X"0000"; 
    CLIENTEMAC1PAUSEVAL   <= X"0000"; 

    ------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper with LL FIFO 
    -- (eth_gmii_locallink.v)
    ------------------------------------------------------------------------
    v4_emac_ll : eth_gmii_locallink
    port map (
      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   => tx_clk_0_i,
      RX_LL_RESET_0                   => tx_reset_0_i,
      RX_LL_DATA_0                    => rx_ll_data_0_i,
      RX_LL_SOF_N_0                   => rx_ll_sof_n_0_i,
      RX_LL_EOF_N_0                   => rx_ll_eof_n_0_i,
      RX_LL_SRC_RDY_N_0               => rx_ll_src_rdy_n_0_i,
      RX_LL_DST_RDY_N_0               => rx_ll_dst_rdy_n_0_i,
      RX_LL_FIFO_STATUS_0             => open,

      -- Client Clocks and Unused Receiver signals - EMAC0
      RX_CLIENT_CLK_0                 => rx_clk_0_i,
      EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
      EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
      EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
      EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
      EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   => tx_clk_0_i,
      TX_LL_RESET_0                   => tx_reset_0_i,
      TX_LL_DATA_0                    => tx_ll_data_0_i,
      TX_LL_SOF_N_0                   => tx_ll_sof_n_0_i,
      TX_LL_EOF_N_0                   => tx_ll_eof_n_0_i,
      TX_LL_SRC_RDY_N_0               => tx_ll_src_rdy_n_0_i,
      TX_LL_DST_RDY_N_0               => tx_ll_dst_rdy_n_0_i,

      -- Client Clocks and Unused Transmitter signals - EMAC0
      TX_CLIENT_CLK_0                 => tx_clk_0_i,
      CLIENTEMAC0TXIFGDELAY           => CLIENTEMAC0TXIFGDELAY,
      EMAC0CLIENTTXSTATS              => EMAC0CLIENTTXSTATS,
      EMAC0CLIENTTXSTATSVLD           => EMAC0CLIENTTXSTATSVLD,
      EMAC0CLIENTTXSTATSBYTEVLD       => EMAC0CLIENTTXSTATSBYTEVLD,

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             => CLIENTEMAC0PAUSEREQ,
      CLIENTEMAC0PAUSEVAL             => CLIENTEMAC0PAUSEVAL,

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       => gtx_clk_ibufg_0_i,
      -- GMII Interface - EMAC0
      GMII_TXD_0                      => GMII_TXD_0,
      GMII_TX_EN_0                    => GMII_TX_EN_0,
      GMII_TX_ER_0                    => GMII_TX_ER_0,
      GMII_TX_CLK_0                   => GMII_TX_CLK_0,
      GMII_RXD_0                      => GMII_RXD_0,
      GMII_RX_DV_0                    => GMII_RX_DV_0,
      GMII_RX_ER_0                    => GMII_RX_ER_0,
      GMII_RX_CLK_0                   => GMII_RX_CLK_0,

      MII_TX_CLK_0                    => MII_TX_CLK_0,
      GMII_COL_0                      => GMII_COL_0,
      GMII_CRS_0                      => GMII_CRS_0,

      -- MDIO Interface - EMAC0
      MDC_0                           => MDC_0,
      MDIO_0_I                        => MDIO_0_I,
      MDIO_0_O                        => MDIO_0_O,
      MDIO_0_T                        => MDIO_0_T,

      -- Generic Host Interface
      HOSTOPCODE                      => HOSTOPCODE,
      HOSTREQ                         => HOSTREQ,
      HOSTMIIMSEL                     => HOSTMIIMSEL,
      HOSTADDR                        => HOSTADDR,
      HOSTWRDATA                      => HOSTWRDATA,
      HOSTMIIMRDY                     => HOSTMIIMRDY,
      HOSTRDDATA                      => HOSTRDDATA,
      HOSTEMAC1SEL                    => HOSTEMAC1SEL,
      HOSTCLK                         => host_clk_i,
      -- Reference Clock inputs for RGMII IODELAYs
      REFCLK                          => refclk_bufg_i,
        
        
      -- Asynchronous Reset
      RESET                           => reset_i
    );

    ---------------------------------------------------------------------
    --  Instatiate the address swapping module
    ---------------------------------------------------------------------
    client_side_asm_emac0 : address_swap_module_8
      port map (
        rx_ll_clock         => tx_clk_0_i,
        rx_ll_reset         => tx_reset_0_i,
        rx_ll_data_in       => rx_ll_data_0_i,
        rx_ll_sof_in_n      => rx_ll_sof_n_0_i,
        rx_ll_eof_in_n      => rx_ll_eof_n_0_i,
        rx_ll_src_rdy_in_n  => rx_ll_src_rdy_n_0_i,
        rx_ll_data_out      => tx_ll_data_0_i,
        rx_ll_sof_out_n     => tx_ll_sof_n_0_i,
        rx_ll_eof_out_n     => tx_ll_eof_n_0_i,
        rx_ll_src_rdy_out_n => tx_ll_src_rdy_n_0_i,
        rx_ll_dst_rdy_in_n  => tx_ll_dst_rdy_n_0_i
    );

    rx_ll_dst_rdy_n_0_i     <= tx_ll_dst_rdy_n_0_i;


    -- Create synchronous reset in the transmitter clock domain.
    gen_tx_reset_emac0 : process (tx_clk_0_i, reset_i)
    begin
      if reset_i = '1' then
        tx_pre_reset_0_i <= (others => '1');
        tx_reset_0_i     <= '1';
      elsif tx_clk_0_i'event and tx_clk_0_i = '1' then
        tx_pre_reset_0_i(0)          <= '0';
        tx_pre_reset_0_i(5 downto 1) <= tx_pre_reset_0_i(4 downto 0);
        tx_reset_0_i                 <= tx_pre_reset_0_i(5);
      end if;
    end process gen_tx_reset_emac0;
 
    ------------------------------------------------------------------------
    -- REFCLK used for RGMII IODELAYCTRL primitive - Need to supply a 200MHz clock
    ------------------------------------------------------------------------
    refclk_ibufg : IBUFG port map(I => REFCLK, O => refclk_ibufg_i);
    refclk_bufg  : BUFG  port map(I => refclk_ibufg_i, O => refclk_bufg_i);

    ------------------------------------------------------------------------
    -- GTX_CLK Clock Management - 125 MHz clock frequency supplied by the user
    -- (Connected to PHYEMAC#GTXCLK of the EMAC primitive)
    ------------------------------------------------------------------------
    gtx_clk_ibufg : IBUF port map(I => GTX_CLK_0, O => gtx_clk_ibufg_0_i);


    ------------------------------------------------------------------------
    -- HOSTCLK Clock Management - Clock input for the generic management 
    -- interface. This clock could be tied to a 125MHz reference clock 
    -- to save on clocking resources
    ------------------------------------------------------------------------
    host_clk : IBUF port map(I => HOSTCLK, O => host_clk_i);


    -- EMAC0 Client clock outputs to user logic
--    RX_CLIENT_CLK_0 <= rx_clk_0_i;
--    TX_CLIENT_CLK_0 <= tx_clk_0_i;
 
end TOP_LEVEL;
