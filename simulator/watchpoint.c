#include <stdio.h>
#include "regfile.h"
void watchpoint(FILE * fp, int clock_counter)
{

    fprintf(fp, "clock_counter=%d, ", clock_counter);
    fprintf(fp, "pc=%x, ", regfile_pc);
    for (int i=1;i<32;i++){
        fprintf(fp, "r_%x=%x, ",i, regfile_x[i]);
    }
    fprintf(fp, "\n");

    //

}
