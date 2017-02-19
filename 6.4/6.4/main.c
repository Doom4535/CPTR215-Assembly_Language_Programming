#include <msp430.h>

/*
 * main.c
 */

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
    //int count;
    int c;
    //for(count = 0; count < 11; count++) {
    int g = 5; // the given intput to compare
    int r = 3; // the reference value that is to be compared against
    int err;   // the variable to hold the difference
    int cont;  // control signal


    err = r - g;
    if(err > 1){
    	cont = -1;
    }
    else if(err < 1){
    	cont = 1;
    }
    else{
    	cont = 0;
    }

    //}

    return(0);

}
