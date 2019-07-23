#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define PLM4 = 0xA000; //Where the PLM4 structure is stored, old address from the bootloader

typedef unsigned char Uint8;
typedef unsigned short Uint16;
typedef unsigned int Uint32;
typedef unsigned long long Uint64;


struct page_table_entry
{
	union
	{
		struct
		{
			Uint64 present :1;
			Uint64 rw      :1;
			Uint64 us      :1;
			Uint64 pwt     :1;
			Uint64 pcd     :1;
			Uint64 a       :1;
			Uint64 dirty   :1;
			Uint64 pat     :1;
			Uint64 global  :1;
			Uint64 ignore2 :3;
			Uint64 addr    :40;
      Uint64 free    :11;
			Uint64 nx      :1;
		};
		Uint64 entry;
	};
};

struct page_table
{
	struct page_table_entry e[512];
};




void memcpy (void* src, void* dest, size_t size);