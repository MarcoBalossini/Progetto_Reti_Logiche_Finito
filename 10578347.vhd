library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity project_reti_logiche is
    Port (
        i_clk : in STD_LOGIC;
        i_start : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
        );
        
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
--Datapath component
    component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           rIN_load : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR;
           o_done : out STD_LOGIC);
end component;

--Registri: input + selection e Onehot
    signal o_regIN : STD_LOGIC_VECTOR (7 downto 0);
    signal rIN_load : STD_LOGIC;
    
    signal o_regSel : STD_LOGIC_VECTOR (2 downto 0);
    signal rSel_load : STD_LOGIC;
    
    signal o_regOH : STD_LOGIC_VECTOR (3 downto 0);
    signal rOH_load : STD_LOGIC;
    
    signal o_regAdd : STD_LOGIC_VECTOR (15 downto 0);
    signal rAdd_load : STD_LOGIC;

--Sommatori
    signal add1 : STD_LOGIC_VECTOR(7 downto 0);
    signal add2 : STD_LOGIC_VECTOR(7 downto 0);
    signal add3 : STD_LOGIC_VECTOR(7 downto 0);
    signal Addnwz : STD_LOGIC_VECTOR (2 downto 0);

--Mux    
    signal mux : STD_LOGIC_VECTOR (2 downto 0);
    signal sel : STD_LOGIC;
        
--Controllo finale
    signal ctrl0 : STD_LOGIC_VECTOR (3 downto 0);
    signal ctrl1 : STD_LOGIC_VECTOR (3 downto 0);
    signal ctrl2 : STD_LOGIC_VECTOR (3 downto 0);
    signal ctrl3 : STD_LOGIC_VECTOR (3 downto 0);
    signal not_again : STD_LOGIC_VECTOR (3 downto 0);
    signal lastwz : STD_LOGIC;
    
--Sottrattori
--    signal sub0 : STD_LOGIC_VECTOR(7 downto 0);
--    signal sub1 : STD_LOGIC_VECTOR(7 downto 0);
--    signal sub2 : STD_LOGIC_VECTOR(7 downto 0);
--    signal sub3 : STD_LOGIC_VECTOR(7 downto 0);

type Stato is (IDLE,GET_IN,CTRL_WZ,UWZ,UX,DONE);
signal cur_state, next_state : Stato;
begin

--
----
------ DATAPATH
----    
--

--Registro input
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regIN <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(rIN_load = '1') then
                o_regIN <= i_data;
            end if;
        end if;
    end process;

--Registri Sel/OneHot
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regSel <= "000";
        elsif i_clk'event and i_clk = '1' then
            if(rSel_load = '1') then
                o_regSel <= Mux;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regOH <= "0000";
        elsif i_clk'event and i_clk = '1' then
            if(rOH_load = '1') then
                o_regOH <= not_again;
            end if;
        end if;
    end process;
       
--Sommatori
    add1 <= i_data + "00000001";
    add2 <= i_data + "00000010";
    add3 <= i_data + "00000011";
    Addnwz <= o_regSel + "001";
    
--Mux
    with sel select
        mux <= "000" when '0',
               Addnwz when '1',
               "XXX" when others;

--Sottrattori        
--    sub0 <= i_data - o_regIN;
--    sub1 <= add1 - o_regIN;
--    sub2 <= add2 - o_regIN;
--    sub3 <= add3 - o_regIN;
    
--CONTROLLI
    ctrl0 <= "0001" when (i_data = o_regIN) else "0000";
    ctrl1 <= "0010" when (add1 = o_regIN) else "0000";
    ctrl2 <= "0100" when (add2 = o_regIN) else "0000";
    ctrl3 <= "1000" when (add3 = o_regIN) else "0000";
    lastwz <= '1' when (o_regSel = "111") else '0';
    
--    ctrl0 <= "0001" when (sub0 = "00000000") else "0000";
--    ctrl1 <= "0010" when (sub1 = "00000000") else "0000";
--    ctrl2 <= "0100" when (sub2 = "00000000") else "0000";
--    ctrl3 <= "1000" when (sub3 = "00000000") else "0000";
--    lastwz <= '1' when (o_regSel = "111") else '0';
    
    not_again <= (ctrl0(3) or ctrl1(3) or ctrl2(3) or ctrl3(3)) & (ctrl0(2) or ctrl1(2) or ctrl2(2) or ctrl3(2)) &(ctrl0(1) or ctrl1(1) or ctrl2(1) or ctrl3(1)) & (ctrl0(0) or ctrl1(0) or ctrl2(0) or ctrl3(0));
--
----
------ MACCHINA A STATI
----    
--

--Dichiarazione stati
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= IDLE;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_rst, i_start, not_again, o_regSel)
    begin
        next_state <= cur_state;
        case cur_state is
            when IDLE =>
                if i_start = '1' then
                    next_state <= GET_IN;
                end if;
            when GET_IN =>
                next_State <= CTRL_WZ;
            when CTRL_WZ =>
                if not_again /= "0000" then
                    next_state <= UWZ;
                elsif o_regSel = "111" then
                    next_state <= UX;
                end if;
            when UWZ =>
                next_state <= DONE;
            when UX =>
                next_state <= DONE;
            when DONE =>
                next_state <= IDLE;
        end case;
    end process;
    
--Gestione segnali
    process(cur_state, not_again, o_regSel, o_regOH, o_regIN, Addnwz, lastwz)
    begin
        rIN_load <= '0';
        rSel_load <= '0';
        rOH_load <= '0';
        o_address <= "0000000000001000";
        o_en <= '1';
        o_we <= '0';
        o_done <= '0';
        o_data <= "00000000";
        sel <= '0';
        
        case cur_state is
            when IDLE =>
            when GET_IN =>
                o_en <= '1';
                o_address <= "0000000000000000";
                o_en <= '1';
                rIN_load <= '1';
                rSel_load <= '1';
                rOH_load <= '0';
            when CTRL_WZ =>
                o_address <= "000000000000" & lastwz & Addnwz;
                rSel_load <= '1';
                rOH_load <= '1';
                rIN_load <= '0';
                o_en <= '1';
                sel <= '1';
            when UWZ =>
                o_address <= "0000000000001001";
                rIN_load <= '0';
                o_en <= '1';
                o_we <= '1';
                o_data <= ('1' & (o_regSel-"001") & o_regOH);
            when UX =>
                o_address <= "0000000000001001";
                rIN_load <= '0';
                o_en <= '1';
                o_we <= '1';
                o_data <= o_regIN;
            when DONE =>
                o_done <= '1';
        end case;
    end process;

end Behavioral;
