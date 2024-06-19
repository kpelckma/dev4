------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2018-10-25
--! @author Radoslaw Rybaniec
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Address Space Definition for DS8VM1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_ii.all;

use work.PKG_APP_CONFIG.all;


package pkg_address_space_rtm_ds8vm1 is

  constant WORD_ID             : natural := 0  ;
  constant WORD_VERSION        : natural := 1  ;
  constant WORD_NAME           : natural := 2  ;
  constant WORD_RF_PERMIT      : natural := 3  ;
  constant WORD_ATT_SEL        : natural := 4  ;
  constant WORD_ATT_VAL        : natural := 5  ;
  --constant WORD_ATT_START      : natural := 6  ;
  constant WORD_ATT_STATUS     : natural := 6  ;
  constant WORD_ADC_STATUS     : natural := 7  ;
  
  constant WORD_ADC_A          : natural := 8  ;
  constant WORD_ADC_B          : natural := 9  ;

  constant WORD_DAC_A          : natural := 10 ;
  constant WORD_DAC_B          : natural := 11 ;
  constant WORD_DAC_STATUS     : natural := 12 ;
 
  constant WORD_PLL_DATA       : natural := 13 ;
  constant WORD_PLL_STATUS     : natural := 14 ;
  
  constant WORD_SCI_SDI_FIX    : natural := 15 ;
 
  constant WORD_SW_VCTL        : natural := 16 ;
  constant WORD_DIV_B          : natural := 17 ;
  constant WORD_VCO_MUX        : natural := 18 ;
  constant WORD_IO_STATUS      : natural := 19 ;
  
  constant WORD_TEMP_A         : natural := 20 ;
  constant WORD_TEMP_B         : natural := 21 ;
  constant WORD_TEMP_C         : natural := 22 ;
  constant WORD_TEMP_D         : natural := 23 ;
  constant WORD_TEMP_E         : natural := 24 ;
  constant WORD_TEMP_F         : natural := 25 ;
  
  constant WORD_EXT_INTERLOCK  : natural := 26 ;
  
  constant WORD_CLK_RST_SELECT : natural := 27 ;
  constant WORD_CLK_RST_SOURCE : natural := 28 ;
  constant WORD_CLK_RST_ENABLE : natural := 29 ;
  constant WORD_SYNC_CLK_SELECT: natural := 30 ;
  

  constant VIIItemDeclList : TVIIItemDeclList := (

    VII_WORD , WORD_ID,         32  , 1 , VII_WNOACCESS  , VII_REXTERNAL , 0  , VII_UNSIGNED , 
    VII_WORD , WORD_VERSION,    32  , 1 , VII_WNOACCESS  , VII_REXTERNAL , 3  , VII_UNSIGNED , 
    VII_WORD , WORD_NAME,       32  , 2 , VII_WNOACCESS  , VII_REXTERNAL , 4  , VII_UNSIGNED , 
    
    VII_WORD , WORD_RF_PERMIT   , 1  , 1 , VII_WACCESS   , VII_RINTERNAL , 16 , VII_UNSIGNED , 
    VII_WORD , WORD_ATT_SEL     , 9  , 1 , VII_WACCESS   , VII_RINTERNAL , 17 , VII_UNSIGNED , 
    VII_WORD , WORD_ATT_VAL     , 6  , 1 , VII_WACCESS   , VII_RINTERNAL , 18 , VII_UNSIGNED ,
    --VII_WORD , WORD_ATT_START   , 1  , 1 , VII_WACCESS   , VII_RINTERNAL , 19 , VII_UNSIGNED ,     
    VII_WORD , WORD_ATT_STATUS  , 1  , 1 , VII_WNOACCESS , VII_REXTERNAL , 20 , VII_UNSIGNED ,
    VII_WORD , WORD_ADC_STATUS  , 4  , 1 , VII_WNOACCESS , VII_REXTERNAL , 21 , VII_UNSIGNED , 
    VII_WORD , WORD_ADC_A       , 25 , 1 , VII_WNOACCESS , VII_REXTERNAL , 22 , VII_SIGNED   , 
    VII_WORD , WORD_ADC_B       , 25 , 1 , VII_WNOACCESS , VII_REXTERNAL , 23 , VII_SIGNED   , 
    VII_WORD , WORD_DAC_A       , 16 , 1 , VII_WACCESS   , VII_RINTERNAL , 24 , VII_SIGNED   ,
    VII_WORD , WORD_DAC_B       , 16 , 1 , VII_WACCESS   , VII_RINTERNAL , 25 , VII_SIGNED   ,
    VII_WORD , WORD_DAC_STATUS  , 4  , 1 , VII_WNOACCESS , VII_REXTERNAL , 26 , VII_UNSIGNED , 
    VII_WORD , WORD_PLL_DATA    , 32 , 1 , VII_WACCESS   , VII_RINTERNAL , 27 , VII_UNSIGNED , 
    VII_WORD , WORD_PLL_STATUS  , 1  , 1 , VII_WNOACCESS , VII_REXTERNAL , 28 , VII_UNSIGNED , 
    VII_WORD , WORD_SCI_SDI_FIX , 1  , 1 , VII_WACCESS   , VII_RINTERNAL , 29 , VII_UNSIGNED , 
    VII_WORD , WORD_SW_VCTL     ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 30 , VII_UNSIGNED ,
    VII_WORD , WORD_DIV_B       ,  2 , 1 , VII_WACCESS   , VII_RINTERNAL , 31 , VII_UNSIGNED ,
    VII_WORD , WORD_VCO_MUX     ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 32 , VII_UNSIGNED ,
    VII_WORD , WORD_IO_STATUS   ,  8 , 1 , VII_WNOACCESS , VII_REXTERNAL , 33 , VII_UNSIGNED ,
    
    VII_WORD , WORD_TEMP_A       , 25 , 1 , VII_WNOACCESS , VII_REXTERNAL , 34 , VII_SIGNED  , 
    VII_WORD , WORD_TEMP_B       , 25 , 1 , VII_WNOACCESS , VII_REXTERNAL , 35 , VII_SIGNED  , 
    VII_WORD , WORD_TEMP_C       , 12 , 1 , VII_WNOACCESS , VII_REXTERNAL , 36 , VII_SIGNED  , 
    VII_WORD , WORD_TEMP_D       , 12 , 1 , VII_WNOACCESS , VII_REXTERNAL , 37 , VII_SIGNED  ,
    VII_WORD , WORD_TEMP_E       , 12 , 1 , VII_WNOACCESS , VII_REXTERNAL , 38 , VII_SIGNED  ,
    VII_WORD , WORD_TEMP_F       , 12 , 1 , VII_WNOACCESS , VII_REXTERNAL , 39 , VII_SIGNED  ,
    
    VII_WORD , WORD_EXT_INTERLOCK,  1 , 1 , VII_WNOACCESS , VII_REXTERNAL , 40 , VII_UNSIGNED ,
    
    VII_WORD , WORD_CLK_RST_SELECT   ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 41 , VII_UNSIGNED ,
    VII_WORD , WORD_CLK_RST_SOURCE   ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 42 , VII_UNSIGNED ,
    VII_WORD , WORD_CLK_RST_ENABLE   ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 43 , VII_UNSIGNED ,
    VII_WORD , WORD_SYNC_CLK_SELECT  ,  1 , 1 , VII_WACCESS   , VII_RINTERNAL , 44 , VII_UNSIGNED
    
  );
end pkg_address_space_rtm_ds8vm1;
