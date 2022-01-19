----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2021 01:44:05 PM
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity testbench is
end testbench;

architecture simu of testbench is

    component ALU is
	port(
	        clk : in std_logic;	    --Internal clock
            btn : in std_logic;	    --Button
            op : in std_logic_vector(4 downto 0); --input to read ALU opcode (swtches)
            din : in signed(7 downto 0);	--Data In (Switches)
            sign : out std_logic; -- determine if read register is negative
            LED : out std_logic_vector(6 downto 0);	--7 Segment Display Cathode
            an : out std_logic_vector(3 downto 0));	--7 Segment Display Anode
    end component;
    
    signal op : std_logic_vector(4 downto 0) := "00000";
    signal din : signed(7 downto 0) := "00000000";
    signal clk, btn, x : std_logic := '0';  --UUT input signals
    signal sign : std_logic := '0';            --UUT out bit
    signal LED : std_logic_vector(6 downto 0) := "0000000";
    signal an : std_logic_vector(3 downto 0) := "0000";
    
begin

 uut: ALU port map(clk => clk,
            btn => btn,
            op => op,
            din => din,
            sign => sign,
            LED => LED,
            an => an);
        
clk_process: process
begin
                    clk <= '0'; wait for 5 ns; 
                    clk <= '1'; wait for 5 ns;
end process;



stim_process: process
begin
    btn <= '0';
    for g in 0 to 11 loop
        for i in 0 to 1 loop
            op <= "00000"; Din <= "00010000" + i; wait for 10 ns;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
            op <= "00001"; Din <= "00000100" + i; wait for 10 ns;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
            op <= "00101" + g;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
        end loop;
        for i in 0 to 1 loop
            op <= "00000"; Din <= "11111000" - i; wait for 10 ns;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
            op <= "00001"; Din <= "00000010" + i; wait for 10 ns;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
            op <= "00101" + g;
            btn <= '1'; wait for 10 ns; btn <= '0'; wait for 10 ns;
        end loop;
    end loop;
end process;

end simu;
