
# An FPGA-based pipeline for multiple real-time Template Matching

Project for the course of Digital Systems M at University of Bologna, Italy (2016-2017).

Implementation of real-time template matching algorithms using Altera DE2 board (Quartus 15.0)
Technical details:
- Entirely developed using VHDL
- Developed interfaces for OV7670 camera and VGA and RS-232 standards
- Parallel recognition of 4 templates up to 64x64 pixel on a 30 fps video stream

Demo: video examples of the results achieved

Quartus Projects: "Plug&Play" quartus projects (and .sof files where you can program the FPGA without need to compile)

Template programmers: applications for a general purpose host where you can program the FPGA templates using serial cable (complete project for Linux and a simpler project for Windows)

Vhdl: source code for the FPGA part

*Albertazzi Riccardo<br />
Andraghetti Lorenzo<br />
Berlati Alessandro<br />
Corni Gabriele*
