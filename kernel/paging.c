#include "../drivers/VGA.h"
#include "paging.h"



char* itoa(int val, int base){
	
	static char buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= base)
	
		buf[i] = "0123456789abcdef"[val % base];
	
	return &buf[i+1];
	
}
	
void memcpy (void* src, void* dest, size_t size)
{
    Uint8 *dest8 = (Uint8*) dest, *src8 = (Uint8*) src;
    while(size--)
        *dest8++ = *src8++;
 }

 void mapme()
 {

     static struct page_table_entry pdpte;
     pdpte.present = 1;
     pdpte.rw = 1;
     pdpte.addr = (0xC000 >> 12);
  //memcpy(&pdpte.entry, (void*)0xB000 +8*3, sizeof(pdpte.entry));
 }
