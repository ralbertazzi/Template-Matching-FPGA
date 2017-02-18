# COMmanager
C++ software for exchanging data with a COM port.

sender.cpp -> initialized with a COM port index and the path of an image (passed as command line parameters), sends image's bytes to the COM port.
receiver.cpp -> initialized with a COM port index passed as parameters, receives bytes from the COM port and prints them on the screen with an ASCII encoding.
COMconfigLib.cpp / COMconfigLib.hpp -> library with the configuration functions for a COM port.
