#include "xdevcfg.h"
#include "xaxidma.h"
#include "xparameters.h"
#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"
#include <stdlib.h>
#include "xscugic.h"
#include "ff.h"
#include "xil_cache.h"
#define MAX_BS_NUM 3
#define PR_BIT_SIZE 475556
#define XPAR_PS7_SD_0_S_AXI_BASEADDR XPAR_PS7_SD_0_BASEADDR

typedef struct bit_info{
        char name[128];
        int  size;
        int  addr;
        struct bit_info *prev;
        struct bit_info *next;
} bs_info;

#define TX_INTR_ID		XPAR_FABRIC_ZYCAP_0_MM2S_INTROUT_INTR

/******************************************************************/

/* Canonical definitions for Fabric interrupts connected to ps7_scugic_0 */
#define XPAR_FABRIC_AXIDMA_0_MM2S_INTROUT_VEC_ID XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR
#define XPAR_FABRIC_AXIDMA_0_S2MM_INTROUT_VEC_ID XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR

/******************************************************************/

#define RESET_TIMEOUT_COUNTER	10000

#define XDCFG_CTRL_ICAP_PR_MASK	  	0xF7FFFFFF /**< Disable PCAP for PR */

/* Flags interrupt handlers use to notify the application context the events.
*/
volatile int TxDone;
volatile int Error;

int Init_Zycap(u32 BaseAddr, XScuGic * InterruptController);
int Config_PR_Bitstream(char *bs_name,int sync_intr);
int Prefetch_PR_Bitstream(char *bs_name);
int Sync_Zycap();
