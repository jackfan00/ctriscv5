#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include "memory.h"
#include "opcode_define.h"

int str2Hex( char *pstr)
{
    int ans = 0;
    char *pt;
    pt = pstr;
    if( !pstr )
        {
            return 0;
        }
    while( *pt )
        {
            ans = ans<<4;
            if( ( *pt >= 'A' && *pt <= 'F' ) || ( *pt >= 'a' && *pt <= 'f' ) )
                ans = ans | ((*pt & 0x5f) -0x37);
            else ans = ans | (*pt) -0x30; pt++;
        }
    return ans;
}

char *trimwhitespace(char *str)
{
  char *end;

  // Trim leading space
  while(isspace((unsigned char)*str)) str++;

  if(*str == 0)  // All spaces?
    return str;

  // Trim trailing space
  end = str + strlen(str) - 1;
  while(end > str && isspace((unsigned char)*end)) end--;

  // Write new null terminator character
  end[1] = '\0';

  return str;
}

void myasm2mccode()
{
    int addr=0;
    char * token1s;
    char * token2s;
    char str[400];
    FILE* fp=fopen("myasmcode.txt","r");
    //
    int opcode;
    int func3,func7;
    int rs1, rs2,rd;
    int imm;
    int shamt;
    int mccode;

    //
    while (fgets(str,400,fp)!=NULL)
    {
        char * strp = strdup(str);
        token1s = strsep(&strp, "//");
        if (*token1s==NULL)
            continue;
        //
        mccode=-1;
        opcode=-1;func3=-1;func7=-1;rs1=-1,rs2=-1,rd=-1,imm=-1;shamt=-1;

        //
        token2s = strsep(&token1s, ",");

        while (token2s!=NULL)
        {
            char * token3s = strsep(&token2s,"=");
            if (strcmp(trimwhitespace(token3s),"opcode")==0)
            {
                 opcode = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"func3")==0)
            {
                 func3 = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"func7")==0)
            {
                 func7 = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"rs1")==0)
            {
                 rs1 = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"rs2")==0)
            {
                 rs2 = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"rd")==0)
            {
                 rd = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"imm")==0)
            {
                 imm = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }
            else if (strcmp(trimwhitespace(token3s),"shamt")==0)
            {
                 shamt = (int)strtol(trimwhitespace(token2s), NULL, 0);
            }

            token2s = strsep(&token1s, ",");
        }



        /**< generate machine code */
        switch (opcode)
        {
            case OPCODE_IMM:
                if (imm!=-1){
                    mccode = (imm<<20) + (rs1<<15) +(func3<<12) +(rd<<7) + opcode;
                }
                else{
                    mccode = (func7<<25) +(shamt<<20) + (rs1<<15) +(func3<<12) +(rd<<7) + opcode;
                }
                break;
            case OPCODE_OP:
                mccode = (func7<<25) +(rs2<<20) + (rs1<<15) +(func3<<12) +(rd<<7) + opcode;
                break;
            case OPCODE_LUI:
                mccode = (imm<<12) +(rd<<7) + opcode;
                break;
            case OPCODE_AUIPC:
                mccode = (imm<<12) +(rd<<7) + opcode;
                break;
            case OPCODE_JAL:
                mccode = ((imm>>20)<<31) + (((imm>>1)&0x3ff)<<21) + (((imm>>11)&0x1)<<20) + (((imm>>12)&0xff)<<12) +(rd<<7) + opcode;
                break;
            case OPCODE_JALR:
                mccode = (imm<<20) + (rs1<<15) +(rd<<7) + opcode;
                break;
            case OPCODE_BRANCH:
                mccode = ((imm>>12)<<31) + (((imm>>11)&0x1)<<7) + (((imm>>5)&0x3f)<<25) + (((imm>>1)&0xf)<<8) +(rs2<<20) + (rs1<<15) +(func3<<12) + opcode;
                break;
             case OPCODE_LOAD:
                mccode = (imm<<20) + (rs1<<15) +(func3<<12) +(rd<<7) + opcode;
                break;
             case OPCODE_STORE:
                mccode = (((imm>>5)&0x7f)<<25) + ((imm&0x1f)<<7) + (rs1<<15) +(rs2<<20) +(func3<<12) + opcode;
                break;
           default:
                ;
        }
        //
        if (mccode!=-1)
            rom[addr++] = mccode;
    };
    //
    fclose(fp);

}
void read_hexcode()
{
    int addr=0;
    char str[60];
    FILE* fp=fopen("romcode.hex","r");
    while (fgets(str,60,fp)!=NULL)
    {
        char *pos;
        if ((pos=strchr(str, '\n')) != NULL)
        *pos = '\0';
        int code = str2Hex(str);
        rom[addr++] = code;
        printf("%s, value=%x\n",str, code);
    };
    fclose(fp);
}

void init_rom()
{
    //read_hexcode();
    myasm2mccode();
}

