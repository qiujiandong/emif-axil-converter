#ifndef _EMIF2AXIL_H_
#define _EMIF2AXIL_H_

// NOTE: you should include your GPIO driver header in this file

#define EMIF2AXIL_BASE (0x7C000000)
// NOTE the AXIL_SPACE_SIZE should same with FPGA
#define AXIL_SPACE_SIZE (0x1000)

static inline Bool isRdFifoEmpty(){
    // read rd_fifo_empty flag
	return CSL_gpioGetInputBit(CSL_GPIO_PIN4); 
}

static inline Bool isAddrFifoFull(){
    // read addr_fifo flag
	return CSL_gpioGetInputBit(CSL_GPIO_PIN5); 
}

static inline Bool isBusy(){
    // read busy flag
	return CSL_gpioGetInputBit(CSL_GPIO_PIN6); 
}

static inline void writeReg(Uint32 offset, Uint32 val){
    // waiting for FPGA not busy
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN5));
	*((Uint32 *)(EMIF2AXIL_BASE + offset)) = val;
}

static inline Uint32 readReg(Uint32 offset){
    // waiting for FPGA not busy
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN5));
    // write read address
	*((Uint32 *)(EMIF2AXIL_BASE + offset + AXIL_SPACE_SIZE)) = 0;
    // waiting for data ready
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN4));
    // read back data
	return *((Uint32 *)(EMIF2AXIL_BASE));
}

#endif
