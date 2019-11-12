#include <stdio.h>
#include <stdlib.h>
#include "regfile.h"
#include "globalsig.h"
#include "memory.h"

/** \brief this is riscv cycle-accuracy simulator
 *
 * \param
 * \param
 * \return
 *
 */



int main(int argc, char** argv)
{
    int clock_counter=0;
    FILE* fp=fopen("watchpoint.log","w+");


    /**< init rom code */
    init_rom();
    if (argc >1)
        BOOTADDR = atoi(argv[1]);
    else
        BOOTADDR =0;
    printf("Booting from address %d\n", BOOTADDR);


    /**< power-on reset chip */
    g_resetz=0;
    ffout();
    dataram[0]=0x12345687;
    dataram[1]=0x9abcdef0;
    dataram[3]=0;
    g_resetz=1;


    ///**< 5 stage pipeline */
    /**< all signal communicate via globalsig.h which define signal global variable */

    /**< order reverse because pipeline data dependence check issue */
    while(clock_counter < 90){

    inst_wb();

    readram();

    inst_memacc();

    inst_mult();

    inst_execute();

    inst_decode();

    inst_fetch();

    //
    /**< flipflop clock latch */

    ffout();
     //
    watchpoint(fp, clock_counter);
    clock_counter ++;

    if (clock_counter>1 && de2ex_inst_valid_ffout==0)
    {
        printf("invalid instruction inst=%x, at PC=%x, clock_counter=%d\n", rom[(de2ex_pc_ffout >>2)], de2ex_pc_ffout, clock_counter);
        break;
    }

    if (fe_misaligned_exxeption || mem_misaligned_exxeption || load_misaligned_exxeption){
        printf("Error::misaligned happen at clock_counter=%d\n",  clock_counter);
    //    break;
    }

    }


    //
    fclose(fp);

    printf("Successful done!");

    return 0;
}
