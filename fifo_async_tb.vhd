---------------------------------------------------------------------------------------------
--Arquivo: fifo_async_tb.vhd
--Autor: Bruno Bavaresco Zaffari
--E mail : bruno.zaffari@edu.pucrs.br
--Projeto: TB FIFO ASYNC
---------------------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo_async_tb is
end fifo_async_tb;

architecture fifo_async_tb of fifo_async_tb is
    signal wr_clk_tb, rd_clk_tb : std_logic := '1';
    signal rst_tb : std_logic := '0';
    signal wr_en_tb : std_logic := '0';
    signal wr_data_tb : std_logic_vector ( 7 downto 0 ) := (others=>'0');
    signal rd_en_tb : std_logic := '0';
    signal rd_data_tb : std_logic_vector ( 7 downto 0 );
    signal sts_full_tb : std_logic;
    signal sts_empty_tb : std_logic;
    signal sts_high_tb : std_logic;
    signal sts_low_tb : std_logic;
    signal sts_error_tb : std_logic;
begin

    wr_clk_tb <= not wr_clk_tb after 5 ns;
	rd_clk_tb <= not rd_clk_tb after 10 ns;
    rst_tb <= '1', '0' after 10 ns,  '1' after 110 ns, '0' after 115 ns;
				--funciona como waveform concurrente

    fifo: entity work.FIFO_async port map(
        wr_clk  => wr_clk_tb,
		rd_clk =>  rd_clk_tb,
        rst => rst_tb,
        wr_en => wr_en_tb,
        wr_data => wr_data_tb,
        rd_en => rd_en_tb,
        rd_data => rd_data_tb,
        sts_full => sts_full_tb,
        sts_empty => sts_empty_tb,
        sts_high => sts_high_tb,
        sts_low => sts_low_tb,
        sts_error => sts_error_tb
    );

    stim_proc: process
    begin
		wait for 20 ns; -- T: 20
        -------------------------------------------------------------------
        ------------- Escrita e leitura simultânea na FIFO vazia ----------
        -------------------------------------------------------------------
		-- Baypess
        wr_en_tb <= '1';
		rd_en_tb <= '1';
		wr_data_tb <= x"B1";
		wait for 10 ns; -- T: 30
		wr_en_tb <= '0'; -- dentro de 20 segundos teve somente uma leitura e uma Escrita
        wait for 10 ns;   -- T: 40 -- Espera uma operação completa
		rd_en_tb <= '0';
        wait for 10 ns; 
		-- 0 elements -- T: 50
        -------------------------------------------------------------------
        ------------------ Escrita sozinha (sem leitura) ------------------
        -------------------------------------------------------------------
		wr_data_tb <= x"B2";
		wr_en_tb <= '1';
		wait for 10 ns;
		-- 1 Element State = LOWS -- T: 60
        ---------------------------------------------------------------------
        -------- Leitura sozinha (sem escrita) -> deve gerar underflow ------
        ---------------------------------------------------------------------
        wr_en_tb <= '0';
        rd_en_tb <= '1';
		---- 0 Element State = EMPTY
		---- sig_error_underflow State = ERROR
        wait for 40 ns; -- T: 100
		
		-------------------------------------------------------------------
        ------------------------------- RESET -----------------------------
        -------------------------------------------------------------------
		-- STOP
		wr_en_tb <= '0';
        rd_en_tb <= '0';
		-- STOP
		
		wait for 20 ns;
		-- T: 120
		
		-------------------------------------------------------------------
        -------- Preenchimento até quase HIGH (threshold superior) --------
        -------------------------------------------------------------------
		wr_en_tb <= '1';
		rd_en_tb <= '0';
		
		wr_data_tb <= x"EE";
		wait for 600 ns;
		-- T: 720 state: HIGH
		
		-- STOP
		wr_en_tb <= '0';
        rd_en_tb <= '0';
		-- STOP
		wait for 150 ns;
		-- T: 870 state: HIGH
		
		wr_en_tb <= '1';
        rd_en_tb <= '0';
		wr_data_tb <= x"AA";
		wait for 30 ns;
		---- T: 900 state: FULL
		--
		---- STOP
		wr_en_tb <= '0';
        rd_en_tb <= '0';
		---- STOP
		wait for 30 ns;
		-- T: 930 state: FULL
		
		
        -------------------------------------------------------------------
        ------------- Escrita e leitura simultânea na FIFO cheia ----------
        -------------------------------------------------------------------
		-- Baypess
        wr_en_tb <= '1';
		rd_en_tb <= '1';
		wr_data_tb <= x"B1";
		wait for 10 ns; -- T: 940
		wr_en_tb <= '0';-- dentro de 20 segundos teve somente uma leitura e uma Escrita
        wait for 10 ns; -- T: 950 -- Espera uma operação completa
		rd_en_tb <= '0';
        wait for 10 ns; 
		-- 63 elements -- T: 960
		-------------------------------------------------------------------
        ------------------ Escrita sozinha (sem leitura) ------------------
        -------------------------------------------------------------------
		wr_data_tb <= x"B2";
		wr_en_tb <= '1';
		wait for 60 ns;
		-- 63+ Element State = ERROR -- T: 1020
		
        
		-- -------------------------------------------------------------------
        ---- Fim do teste
        ---------------------------------------------------------------------
        wr_en_tb <= '0';
        rd_en_tb <= '0';
        wait;
    end process;


end fifo_async_tb;
