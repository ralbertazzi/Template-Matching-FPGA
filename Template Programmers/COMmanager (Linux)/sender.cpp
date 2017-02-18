/*
 * sender.cpp
 * sends the pixels of an image to a COM port
 * parameters: rotation flag, COM serial port, image path
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
#include <opencv2/highgui/highgui.hpp>
#include "COMconfigLib.hpp"

using namespace cv;
using namespace std;

typedef uchar pixel;

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

void rot90(Mat &matImage, int rotflag) {
	//0=hold rotation 1=90, 2=180, 3=270

	if (rotflag == 1) {
		transpose(matImage, matImage);
		flip(matImage, matImage, 1);
	} else if (rotflag == 2) {
		flip(matImage, matImage, -1);
	} else if (rotflag == 3) {
		transpose(matImage, matImage);
		flip(matImage, matImage, 0);
	} else if (rotflag != 0) {
		printf("unknown rotation\n");
	}

}

int sendImage(int com, int module_id, Mat &img) {
	int cont = 0, i, j;

	//module_id
	write(com,&((unsigned char)module_id) , 1);
	
	//template's pixel, by row
	for (i = 0; i < img.rows; i++) {
		for (j = 0; j < img.cols; j++) {
			write(com, &img.at<pixel>(i, j), 1);
			cont++;
//			printf("%d\n", cont);
//			sleep(1);
		}
	}
	return cont;
}

int main(int argc, char* argv[]) {

	int com, n, i, size;
	Mat templates[4];
	pixel pixel;
	char portname[14] = "/dev/ttyUSB";

	//config variables
	int numberOfTemplates;
	char * comPort;
	char * templateName;

	//test parameters
	printf("initializing...\n");
	if (argc == 4 && !strcmp(argv[1], "-r")) {
		numberOfTemplates = 4;
		comPort = argv[2];
		templateName = argv[3];
	} else if (argc == 3) {
		numberOfTemplates = 1;
		comPort = argv[1];
		templateName = argv[2];
	} else {
		fprintf(stderr,
				"parameters -> [-r] <number of com port> <template path>\n");
		exit(-1);
	}

	//calculate port name
	strcat(portname, comPort);

	//open COM port
	com = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	if (com < 0) {
		printf("error %d opening %s: %s\n", errno, portname, strerror(errno));
		exit(-1);
	}

	//set COM properties
	set_interface_attribs(com, B9600, 0); // set speed to 9,600 bps, 8n1 (no parity)
	set_blocking(com, 0);                 // set no blocking

	//open image
	Mat img = imread(templateName, CV_LOAD_IMAGE_GRAYSCALE);
	if (!img.data) {
		printf("error %d opening %s: %s\n", errno, templateName,
				strerror(errno));
		exit(-1);
	}

	//rotated images
	for (i = 0; i < numberOfTemplates; i++) {
		templates[i] = img.clone();
		rot90(templates[i], i);
	}
	printf("done...\nsending %s to %s...\n", templateName, portname);

	//send image
	for (i = 0; i < numberOfTemplates; i++) {
		namedWindow("Display window", WINDOW_AUTOSIZE);
		imshow("Display window", templates[i]);
		waitKey(0);
		size = sendImage(com, i, templates[i]);
		printf("[%d bytes sent]\n", size);

	}

	//end main
	printf("ending...\n");
	close(com);
	exit(0);
}

