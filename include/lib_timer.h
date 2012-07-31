//===========================================================================
//
//      File:       LIB_TIMER.H
//
//      Purpose:    Timer Function Prototypes
//
//      Version:    1.0
//
//      Date:       2012-06-19
//
//      Author:     Corey Davyduke
//
//      Compiler:   ImageCraft C
//
//---------------------------------------------------------------------------
//
//      History:    1.0    2012-06-19    Genesis
//
//===========================================================================

//#include <hc11.h>
//#include <lib_timer.h>


//#pragma interrupt_handler TimerTOC2Isr


//unsigned char gTimerTOC2;
//unsigned int  gTimerSeconds;

#define OC2F 0x40

void TimerInit(void);
void TimerTOC2Isr(void);
unsigned int TimerGetSeconds(void);
