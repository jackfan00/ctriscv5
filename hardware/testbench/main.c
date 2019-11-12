#include <stdio.h>
#include <stdlib.h>
//#include "regfile.h"
//#include "globalsig.h"
#include "memory.h"

/** \brief this is riscv cycle-accuracy simulator
 *
 * \param
 * \param
 * \return
 *
 */
char* int2hex(int x)
{
//int x = SOME_INTEGER;
char res[9]; /* two bytes of hex = 4 characters, plus NULL terminator */

//if (x <= 0xFFFF)
//{
    sprintf(&res[0], "%08x", x);
    printf("%s\n", res);
//}
return(res);
}

int main(int argc, char** argv)
{


    /**< init rom code */
    init_rom();
    //dataram[0]=0x12345687;
    //dataram[1]=0x9abcdef0;
    //dataram[3]=0;
    
    const char* str;
    char res[18]; /* two bytes of hex = 4 characters, plus NULL terminator */

    FILE* fp=fopen("romcode.hex","w");
    for (int i=0; i< sizeof(rom)/sizeof(int); i=i+2){
    	if (rom[i] == -1) break;
    	sprintf(&res[0], "%08x%08x\n", rom[i+1],rom[i]);
    	//str = int2hex(rom[i]);
    	//printf("%s\n", str);
    	//fwrite(str , 1 , 8 , fp );
    	fputs(res, fp);
    	
    }
    fclose(fp);
    
    printf("Successful done!");

    return 0;
}
