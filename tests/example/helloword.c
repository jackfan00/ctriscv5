//#include <stdio.h>
volatile char * UART0DR;// = (char *)0x90000000;
void myprintf(char * ptr)
{
   int i;
   for (i=0;i<9;i++)
    {
      *UART0DR = *ptr;
      UART0DR++;
      ptr++;
    }
}
int main()
{
  UART0DR = (char *)0x90001000;
  myprintf("123456789 hello world\n");
}

