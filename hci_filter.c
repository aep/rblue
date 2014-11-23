#include <ctype.h>
#include <stdint.h>
#include <unistd.h>
#include <inttypes.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

void printBits(void const * const ptr, const size_t size)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, n;

    for (i=0;i<size;i++)
    {
        byte = b[i];
        for(n=0; n<8; n++)
        {
            if((byte & 0x80) !=0)
            {
                printf("1");
            }
            else
            {
                printf("0");
            }
            byte = byte << 1;
        }
    }
    puts("");
}


int  main()
{


    struct hci_filter f;
    hci_filter_clear(&f);
    hci_filter_set_ptype(HCI_EVENT_PKT, &f);
    hci_filter_set_event(EVT_LE_META_EVENT, &f);


    printBits(&f, 1);
}
