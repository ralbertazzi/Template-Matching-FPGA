# SerialWindows

Simple Windows application to program a template with a unique color
Must be called with 3 parameters:
- COM_NUMBER: number of the COM port where the serial cable to the FPGA is connected
- TEMPLATE_INDEX: number of the template that we want to program [0, TEMPLATE_MATCHING_MODULES - 1]
- TEMPLATE_INTENSITY: grayscale color (0 to 255) that must be recognized (all the template pixels will be programmed with this color)

The protocol used to exchange information with the FPGA is the following:
1) Host sends the TEMPLATE_INDEX in the first byte
2) Host sends TEMPLATE_SIZE * TEMPLATE_SIZE bytes; each byte contains one of the pixels of the template ((row,col) = (0,0), (0,1) ... (SIZE - 1, SIZE -1))
