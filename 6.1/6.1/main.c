#include <msp430.h> 
/*
 * main.c
 */
int main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    // int a; // the integer and its value to be operated on
    int count;
    int b;
    int c;
    int z[10]; // making an array of size 10
    int *z_pointer; // making pointer for navigating array z
    int error = 0;

    // storing a to the 3rd power a^3 in the variable b;
    // This array stores the computation for n in the location n-1
    for(count = 1; count < 11; count++){
    	if(count > abs(31)){		// Keeping track of conditions that would cause a buffer overflow (in this case 31.999^3 would trigger one)
    		error = 1;
    		return error;
    	}

    	if(count==0) {
    		b = 1;
    		z_pointer  = z + count;
    		*z_pointer = b;
    	}
    	else {
    		b = count * count;
			b *= count;
			z_pointer  = z + count -1;
			*z_pointer = b;
    	}

    }
    // Locking the program in a while loop to maitain output from above
    while(1) {
    	c = 1;
    }
	return error;
}
