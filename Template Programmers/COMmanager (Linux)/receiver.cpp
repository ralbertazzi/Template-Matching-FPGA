/*
 * receiver.c
 * read bytes from a specified COM port
 * parameters: COM serial port
 *
 * Created on: Dec 8, 2016
 *      Author: gcorni, tab, piano, alfo
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include "COMconfigLib.hpp"
#define MAXBUFF 50000


int set_interface_attribs(int fd, int speed, int parity) {
	struct termios tty;
	memset(&tty, 0, sizeof tty);
	if (tcgetattr(fd, &tty) != 0) {
		fprintf(stderr, "error %d from tcgetattr", errno);
		return -1;
	}

	cfsetospeed(&tty, speed);
	cfsetispeed(&tty, speed);

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
	// disable IGNBRK for mismatched speed tests; otherwise receive break
	// as \000 chars
	tty.c_iflag &= ~IGNBRK;         // disable break processing
	tty.c_lflag = 0;                // no signaling chars, no echo,
									// no canonical processing
	tty.c_oflag = 0;                // no remapping, no delays
	tty.c_cc[VMIN] = 0;            // read doesn't block
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

	tty.c_cflag |= (CLOCAL | CREAD); // ignore modem controls,
									 // enable reading
	tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	if (tcsetattr(fd, TCSANOW, &tty) != 0) {
		fprintf(stderr, "error %d from tcsetattr", errno);
		return -1;
	}
	return 0;
}

void set_blocking(int fd, int should_block) {
	struct termios tty;
	memset(&tty, 0, sizeof tty);
	if (tcgetattr(fd, &tty) != 0) {
		fprintf(stderr, "error %d from tggetattr", errno);
		return;
	}

	tty.c_cc[VMIN] = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	if (tcsetattr(fd, TCSANOW, &tty) != 0)
		fprintf(stderr, "error %d setting term attributes", errno);
}






int main(int argc, char* argv[]) {
	char buf[MAXBUFF];
	int com, n, flag = 0;
	char portname[14] = "/dev/ttyUSB";

	//test parameters
	printf("initializing...\n");
	if (argc != 2) {
		fprintf(stderr, "call -> sudo ./ts <number of com port>\n");
		exit(-1);
	}

	//calculate port name
	strcat(portname, argv[1]);

	//open COM port
	com = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	if (com < 0) {
		printf("error %d opening %s: %s", errno, portname, strerror(errno));
		exit(-1);
	}

	//set COM properties
	set_interface_attribs(com, B9600, 0); // set speed to 9,600 bps, 8n1 (no parity)
	set_blocking(com, 0);                 // set no blocking

	printf("done...\nreceiving from %s...\n", portname);


	while ((n = read(com, buf, sizeof buf)) >= 0) {
		if (n > 0) {
			buf[n] = '\0';
			printf("[%d] %s\n", n, buf);
			sleep(1);
			flag = 0;
		} else if (flag == 0) {
			printf("waiting for data...\n");
			flag = 1;
		}

	}

	//end main
	close(com);
	exit(0);
}




