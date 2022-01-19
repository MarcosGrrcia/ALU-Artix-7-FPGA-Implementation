library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ALU is
	port( 
	        clk : in std_logic;	    --Internal clock
            btn : in std_logic;	    --Button
            op : in std_logic_vector(4 downto 0); --input to read ALU opcode (swtches)
            din : in signed(7 downto 0);	--Data In (Switches)
            sign : out std_logic; -- determine if read register is negative
            LED : out std_logic_vector(6 downto 0);	--7 Segment Display Cathode
            an : out std_logic_vector(3 downto 0));	--7 Segment Display Anode
end ALU;

architecture Behavioral of ALU is

component pulse is
	port(   clock : in std_logic;
            kkey : in std_logic;
            ppulse : out std_logic);
end component;

signal press : std_logic;	--Signal for button press
signal refresh : std_logic_vector(19 downto 0);	--Vector to control timing for 2 digit display
signal LED_act : std_logic_vector(1 downto 0) := "00";	--Bit to control 2 digit display (multiplexing)
signal LED_out : signed(3 downto 0) := "0000";	--Vector to transfer data to the LED_BCD
signal A0, B0 : signed(7 downto 0); --registers
signal a, b : signed(7 downto 0); --buffer signals
signal sa, sb : std_logic; --signed indicators
signal temp : signed(7 downto 0);
signal intb : integer;
signal AB : signed(15 downto 0); --multiplication sum

begin

pulse1: pulse port map(clock => clk, kkey => btn, ppulse => press);

process(clk)    --process increments a refresh counter for the 7-Seg display
begin
	if(rising_edge(clk)) then
		refresh <= refresh + 1;
	end if;
end process;

LED_act <= refresh(19 downto 18);   --reads refresh vector's most significant bit

--Takes a 4 bit input and transfers it to a 7-seg code in order to output it as a decimal
process(LED_out)
begin
	case LED_out is
		when "0000" => LED <= "0000001";	--"0"
		when "0001" => LED <= "1001111";	--"1"
		when "0010" => LED <= "0010010";	--"2"
		when "0011" => LED <= "0000110";	--"3"
		when "0100" => LED <= "1001100";	--"4"
		when "0101" => LED <= "0100100";	--"5"
		when "0110" => LED <= "0100000";	--"6"
		when "0111" => LED <= "0001111";	--"7"
		when "1000" => LED <= "0000000";	--"8"
		when "1001" => LED <= "0000100";	--"9"
		when "1010" => LED <= "0000010";	--a
		when "1011" => LED <= "1100000";	--b
		when "1100" => LED <= "0110001";	--c
		when "1101" => LED <= "1000010";	--d
		when "1110" => LED <= "0110000";	--e
		when "1111" => LED <= "0111000";	--f
    end case;
end process;

-- updates registers and variables
process(clk)
begin 
    if(rising_edge(clk)) then
        if sa = '1' then
            temp <= not a;
            A0 <= signed(unsigned(temp + 1));
        else
            A0 <= a;
        end if;
        if sb = '1' then
            temp <= not b;
            B0 <= signed(unsigned(temp + 1));
        else
            b0 <= b;
        end if;
    end if;
end process;

--Controls the switching between the LEDs on the 7 segment display
process(LED_act)
begin
    case LED_act is 
        when "00" =>
            if op = "10000" then    -- reads a0
                an <= "1110";   --activates LED1 and deactivates LED2,3,4
                LED_out <= a0(3 downto 0);
                if sa = '1' then
                    sign <= '1';
                else
                    sign <= '0';
                end if;
            elsif op = "10001" then    --read b0
                an <= "1110";   --activates LED1 and deactivates LED2,3,4
                LED_out <= b0(3 downto 0);
                if sb = '1' then
                    sign <= '1';
                else
                    sign <= '0';
                end if;
            elsif op = "10010" then     --read a0,b0
                an <= "1110";   --activates LED1 and deactivates LED2,3,4
                LED_out <= b0(3 downto 0);
            else
                an <= "1111"; --activates LED4
            end if;
        when "01" =>
            if op = "10000" then    -- reads a0
                an <= "1101";   --activates LED2
                LED_out <= a0(7 downto 4);
                if sa = '1' then
                    sign <= '1';
                else
                    sign <= '0';
                end if;
            elsif op = "10001" then    --read b0
                an <= "1101";   --activates LED2
                LED_out <= b0(7 downto 4);
                if sb = '1' then
                    sign <= '1';
                else
                    sign <= '0';
                end if;
            elsif op = "10010" then     --read a0,b0
                an <= "1101";   --activates LED2
                LED_out <= b0(7 downto 4);
            else
                an <= "1111"; --activates LED4
            end if;
        when "10" =>
            if op = "10010" then    --read a0,b0
                an <= "1011"; --activates LED3
                LED_out <= a0(3 downto 0);
            else
                an <= "1111"; --activates LED4
            end if;
        when "11" =>
            if op = "10010" then    --read a0,b0
                an <= "0111"; --activates LED4
                LED_out <= a0(7 downto 4);
            else 
                an <= "1111"; --activates LED4
            end if;
    end case;
    if(op /= "00010") and (op /= "00011") and (op /= "00100") then
        sign <= '0';
    end if;
end process;

intb <= to_integer(b);

process(press)
variable AB : signed(15 downto 0) := "0000000000000000"; --multiplication sum
begin
if (rising_edge(press)) then
    case op is
        when "00001" =>     --addition
            a <= signed(a) + signed(b);
        when "00010" => --subtraction
            a <= signed(a) - signed(b);
        when "00011" => --multiplication
            AB := a * b;
            a <= AB(15 downto 8);
            b <= AB(7 downto 0);
        when "00100" => --AND
            a <= a and b;
        when "00101" => --OR
            a <= a or b;
        when "00110" => --xor
            a <= a xor b;
        when "00111" => --not
            a <= a;
        when "01000" => --logical shift left
            a <= shift_left(a, intb);
        when "01001" => --logical shift right
            a <= shift_right(a, intb);
        when "01010" => --arithmetic shift left
            a <= shift_left(signed(a), intb);
        when "01011" => --arithmetic shift right
            a <= shift_right(signed(a), intb);
        when "01100" => --rotate shift left
            a <= rotate_left(a, intb);
        when "01101" =>    --rotate shift right
           a <= rotate_right(a, intb);
       when "00000"  =>  --load register a0
            a <= din(7 downto 0);
            if din(7) = '1' then
                sa <= '1';
            else
                sa <= '0';
            end if;
        when "11111" =>   --load register b0
            b <= din(7 downto 0);
            if din(7) = '1' then
                sb <= '1';
            else
                sb <= '0';
            end if;
        when others => 
            a <= a;
    end case;
end if;
end process;

end Behavioral;