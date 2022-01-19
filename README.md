# ALU-Artix-7-FPGA-Implementation
This is an implementation of an Arithmetic and Logic Unit (ALU) on an Artix-7 FPGA using a BASYS3 board.

The purpose this project is to use Vivado operators and type cast functions available in the 
numeric_std package to implement theALU operations. This project uses the 7-Segment Display, 
a pushbutton, and switches to implement these programs.

I came up with five processes, a process based on the clock that updates the registers,
buffers, and signals; one for updating the anodes of each 7 segment digit and displays
accordingly; a refresh process for the 7 segment to update a refresh variable; a binary to
decimal conversion process for the 7 segment display; and a process based on the simulated
button press that updates the buffers based on the imputed opcode. This way, there is a
whole section where op code is checked, then code is ran. The variable sand signals are also
constantly updated based on when the button is pressed. 

I also made Testbench code that used each operation using 4 test cases each. The
following is the resulting simulation:
![alt text] (https://github.com/MarcosGrrcia/ALU-Artix-7-FPGA-Implementation/blob/main/Simulation%20Results.jpg?raw=true)
