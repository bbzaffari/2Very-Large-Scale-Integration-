---------------------------------------------------------------------------------------------
--Autor: Bruno Bavaresco Zaffari
--E mail : bruno.zaffari@edu.pucrs.br
-- Nota: Supoem o mais rapido sendo o Write
---------------------------------------------------------------------------------------------
library ieee;
        use ieee.std_logic_1164.all;
        use ieee.std_logic_unsigned.all;
        use ieee.std_logic_arith.all;

entity fifo_async is
    generic (
        MEMORY_SIZE : integer := 64;
		DEBUG_MODE  : boolean := true
    );
	port(
			wr_clk          : in std_logic;
			rd_clk          : in std_logic;
			rst             : in std_logic;
			wr_en           : in std_logic;
			wr_data         : in std_logic_vector(7 downto 0);
			rd_en           : in std_logic;
			rd_data         : out std_logic_vector(7 downto 0);
			sts_full        : out std_logic;
			sts_empty       : out std_logic;
			sts_high        : out std_logic;
			sts_low         : out std_logic;
			sts_error       : out std_logic
	);
end fifo_async;

architecture rtl of fifo_async is
        type MEMORY is array (0 to MEMORY_SIZE-1) of std_logic_vector(7 downto 0);
        type STATES is (LIMBO, EMPTY, LOWS, HIGHS, FULL , ERROR);
		--=====================================================================--
		-- xxxxx synthesis ramstyle = "block_ram"--
        signal fifo_data : MEMORY := (others => (others => '0'));
        signal filled :integer range 0 to MEMORY_SIZE+1 := 0;
        signal wp, rp :integer range 0 to MEMORY_SIZE-1 := 0;
        signal state, prev_state : STATES := EMPTY;
        signal sig_full, sig_empty , sig_high, sig_low, sig_overflow, sig_underflow: std_logic;
		--=====================================================================--
		signal event_rw: std_logic := '0';
		signal sig_r_clk, sig_w_clk: std_logic;
		signal sig_nr_clk, sig_nw_clk: std_logic;
		signal data_temp : std_logic_vector(7 downto 0);

begin   
		--============================= SANITY CHECK =============================--
		sanity_limit_check: assert MEMORY_SIZE >= 8
		  report "MEMORY_SIZE tem que ser_event maior_event que 8" severity FAILURE;
		  
	
		-- =========================
	    -- Processo de escrita
	    -- =========================
	    write_proc: process(wr_clk, rst)
	    begin
			prev_state <=state;
			sig_nw_clk <= not wr_clk;
			if rst = '1' then
				wp   <= 0;
				prev_state <= EMPTY; 
				sig_overflow  <= '0'; 
			elsif rising_edge(wr_clk) and wr_en = '1' then
				case (state) is 
					when EMPTY => 
						if (event_rw = '0')  then 
							fifo_data(wp) <= wr_data;
							wp <= (wp + 1) mod MEMORY_SIZE;
						end if;
						--bypass
					
					when FULL => -- Almost OVERFLOW 
						if event_rw = '1' then -- Esta tendo uma leitura agora
							fifo_data(wp) <= wr_data;
							wp <= (wp + 1) mod MEMORY_SIZE;
						else 
							sig_overflow  <= '1';
						end if;				
					when ERROR  => -- Tratamento de OVERFLOW 
						if DEBUG_MODE then 
							report "Pressione o RST (ERROR!)" severity WARNING;
						end if;
					when others =>
						fifo_data(wp) <= wr_data;
						wp <= (wp + 1) mod MEMORY_SIZE;
				end case;
			end if;
	    end process write_proc;
	    -- ================================
	    -- Processo de leitura 
	    -- ================================
	    read_proc: process(rd_clk, rst)
	    begin
		sig_nr_clk <= not rd_clk;
	    if rst = '1' then 
			rp <= 0;
			sig_underflow <= '0';
		elsif rising_edge(rd_clk) and rd_en = '1'then
			case (state) is 
				when EMPTY => 
					if (event_rw = '1') then 
						rd_data <= data_temp; --Bypass
					else
						sig_underflow <= '1'; -- UNDERFLOW 
						if DEBUG_MODE then -- Tratamento de UNDERFLOW 
							report "Tentativa de leitura em FIFO vazia (UNDERFLOW!)" severity WARNING;
						end if;
					end if;
				when ERROR =>
				    -- Tratamento de ERROR
					rd_data <= (others => '1'); 
				when others =>
					rd_data <= fifo_data(rp);
					rp <= (rp + 1) mod MEMORY_SIZE;
			end case;
		end if;
	    end process read_proc;
		--============================= READ SIGNAL =============================--
		sig_w_clk <= wr_clk;
		sig_r_clk <= rd_clk;
		
		event_rw <= '1' when (sig_w_clk = '1' and sig_nw_clk = '0' and rd_en = '1' and wr_en = '1' and sig_r_clk = '1' and sig_nr_clk = '0') else      -- Usefull  - RW
					   '0'; 
		
		data_temp <= wr_data when (sig_w_clk = '1' and sig_nw_clk = '0' and rd_en = '1'and sig_r_clk = '1' and sig_nr_clk = '0') else      -- Usefull  - RW
					 (others => '0');
		
		
		--============================= COMBINACIONAL =============================--
        filled <= 0 when rst = '1' else -- Tava pensando em por os sts_* mas assim é melhor
				  0 when (wp = rp and (prev_state /= FULL or prev_state = EMPTY or prev_state = LOWS)) else
				  MEMORY_SIZE when (wp = rp and prev_state = FULL) else
				  (wp - rp) when (wp > rp) else
				  (MEMORY_SIZE - rp + wp + 1) when (wp < rp and (prev_state = FULL or prev_state /= EMPTY or prev_state /= LOWS)) else
				  0;
        ---------------- empty -------------------
        sig_empty <= '1' when rst = '1' else
					 '0' when sig_overflow  = '1' or sig_underflow = '1' else 
                     '1' when (filled = 0 and prev_state /= HIGHS) else
                     '0';
        sts_empty <= sig_empty;
        ---------------- low_event  ---------------------
        sig_low  <= '1' when rst = '1' else
					'0' when sig_overflow  = '1' or sig_underflow = '1'  else 
                   '1' when (filled <= 4 and filled >= 1) else
                   '0';
        sts_low  <= sig_low ;
        ---------------- high ---------------------
        sig_high <= '0' when rst = '1' else
					'0' when sig_overflow  = '1' or sig_underflow = '1'  else 
                    '1' when (filled >= MEMORY_SIZE-4 and filled <MEMORY_SIZE) else
                    '0';
        sts_high <= sig_high;
        ---------------- full ---------------------
        sig_full <= '0' when rst = '1' else
					'0' when sig_overflow  = '1' or sig_underflow = '1'  else 
                    '1' when (filled = MEMORY_SIZE-1) else
                    '0';
        sts_full <= sig_full;
        ---------------- error --------------------
        sts_error <= '0' when rst = '1' else
					 '1' when sig_overflow  = '1' else
					 '1' when sig_underflow = '1' else
					 '0';
        ---------------- STATES -------------------
        state <= EMPTY when rst = '1' else
				 ERROR when sig_overflow  = '1' else
                 ERROR when sig_underflow = '1' else
				 EMPTY when sig_empty = '1' else 
				 LOWS  when sig_low = '1' else
				 FULL  when sig_full = '1' else
				 HIGHS when sig_high = '1' else
				 LIMBO;
end rtl;
