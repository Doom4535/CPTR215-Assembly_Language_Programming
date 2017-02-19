#include <msp430.h>

/*
 * main.c
 */
int main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

    int a = 0; // First input for Fibonacci series
    int b = 1; // Second input for Fibonacci series
    int c = 0;
    int count;
    int z[10];
    int *z_pointer;
    int *p_1; // used to point towards the preceding number (n-1)
    int *p_2; // used to point towards n - 2

    // A Fibonaccia series is a series where each number is the sum of
    // the previous two numbers

    for(count = 0; count < 11; count++) {
    	if(count == 0) {  			  // addressing the first value
    		z_pointer = z + count;
    		*z_pointer = a;
    	}
    	else if(count == 1) {		  // addressing the second value
    		z_pointer = z + count;
    		*z_pointer = b;
    	}
    	else {
    		z_pointer = z + count;
    		p_1 = z_pointer - 1;
    		p_2 = z_pointer - 2;
    		*z_pointer =  *p_1 + *p_2;  // summing the preceding two numbers
    	}
    }

    // Locking in loop to preserve values
    while(1) {
    	c = 1;
    }
	return 0;
}
