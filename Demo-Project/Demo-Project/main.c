#include <msp430.h>
// #include <header.h>  Commenting out because it does not want to build properly with an empty header

int d = 0;

void main(void)
	{
	WDTCTL = WDTPW|WDTHOLD;

	int a = 1;
	float b = -255.25;
	char c = 'c';
	d = d+1;

	while(1);
	}
