#include "../drivers/VGA.h"
#include "paging.h"

/*TODO:Implement a cpuid detection 
Configure the APIC
Configure the IDT
Improve the bootloader
Remap the kernel to higher half
*/



void kernel_main() 
{
	/* Initialize terminal interface */
	terminal_initialize();

	terminal_writestring("Kernel loaded..."
  "\nHello from kernel in 64 bits !");

  mapme();

	/*uint32_t rand;  
  asm("rdrand %[rand]"
   : [rand] "=r" (rand)
   :
   : "cc"); */
}
