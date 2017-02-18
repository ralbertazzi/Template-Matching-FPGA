///
// serial.c / serial.cpp
// A simple serial port writing example
// Written by Ted Burke - last updated 13-2-2013
//
// To compile with MinGW:
//
//      gcc -o serial.exe serial.c
//
// To run:
//
//      SerialWindows COM_NUMBER TEMPLATE_INDEX TEMPLATE_INTENSITY
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

using namespace std;
#include <string>

#define TEMPLATE_SIZE 32

int main(int argc, char** argv)
{
	// Define the five bytes to send ("hello")
	char bytes_to_send[1 + TEMPLATE_SIZE*TEMPLATE_SIZE];

	// Declare variables and structures
	HANDLE hSerial;
	DCB dcbSerialParams = { 0 };
	COMMTIMEOUTS timeouts = { 0 };

	if (argc != 4)
	{
		fprintf(stderr, "SerialWindow [COM_NUMBER] [TEMPLATE_INDEX] [TEMPLATE_INTENSITY]\n");
		system("PAUSE");
		return 1;
	}

	char* porta = argv[1];
	int index = atoi(argv[2]);
	int init = atoi(argv[3]);

	bytes_to_send[0] = index;
	for (int i = 1; i < TEMPLATE_SIZE*TEMPLATE_SIZE + 1; i++)
		bytes_to_send[i] = init;

	char comArray[50];

	strcpy(comArray, "\\\\.\\COM");
	strcat(comArray, porta);


	std::string com = comArray;

	std::wstring stemp = std::wstring(com.begin(), com.end());
	LPCWSTR sw = stemp.c_str();

	// Open the highest available serial port number
	fprintf(stderr, "Opening serial port...");
	hSerial = CreateFile(
		sw, GENERIC_READ | GENERIC_WRITE, 0, NULL,
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hSerial == INVALID_HANDLE_VALUE)
	{
		fprintf(stderr, "Error\n");
		system("PAUSE");
		return 1;
	}
	else fprintf(stderr, "OK\n");

	// Set device parameters (38400 baud, 1 start bit,
	// 1 stop bit, no parity)
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	if (GetCommState(hSerial, &dcbSerialParams) == 0)
	{
		fprintf(stderr, "Error getting device state\n");
		CloseHandle(hSerial);
		system("PAUSE");
		return 1;
	}

	dcbSerialParams.BaudRate = CBR_9600;
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.StopBits = ONESTOPBIT;
	dcbSerialParams.Parity = NOPARITY;
	if (SetCommState(hSerial, &dcbSerialParams) == 0)
	{
		fprintf(stderr, "Error setting device parameters\n");
		CloseHandle(hSerial);
		system("PAUSE");
		return 1;
	}

	// Set COM port timeout settings
	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 10;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;
	if (SetCommTimeouts(hSerial, &timeouts) == 0)
	{
		fprintf(stderr, "Error setting timeouts\n");
		CloseHandle(hSerial);
		system("PAUSE");
		return 1;
	}

	// Send specified text (remaining command line arguments)
	DWORD bytes_written, total_bytes_written = 0;
	fprintf(stderr, "Sending bytes...");
	if (!WriteFile(hSerial, bytes_to_send, TEMPLATE_SIZE*TEMPLATE_SIZE + 1, &bytes_written, NULL))
	{
		fprintf(stderr, "Error\n");
		CloseHandle(hSerial);
		system("PAUSE");
		return 1;
	}
	fprintf(stderr, "%d bytes written\n", bytes_written);

	// Close serial port
	fprintf(stderr, "Closing serial port...");
	if (CloseHandle(hSerial) == 0)
	{
		fprintf(stderr, "Error\n");
		system("PAUSE");
		return 1;
	}
	fprintf(stderr, "OK\n");

	// exit normally
	system("PAUSE");

	return 0;
}