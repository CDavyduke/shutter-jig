//===========================================================================
//
//      File:       LIB_TIMER.C
//
//      Purpose:    Timer Routines
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

#include <hc11.h>
#include <lib_timer.h>

#pragma interrupt_handler TimerTOC2Isr

unsigned char gTimerTOC2;
unsigned int  gTimerSeconds;

void TimerInit(void)
{
    TMSK1 = OC2F;                       // enable interrupts on OC2
    TCTL1 = 0x00;                       // setup OC2 for n.c.

    gTimerTOC2 = 0;
    gTimerSeconds = 0;

    INTR_ON();
}



void TimerTOC2Isr()
{
    TFLG1 = OC2F;                       // clear compare flag
    TOC2 = TCNT + 20000;                // setup next interrupt 10 msec later

    gTimerTOC2++;                       // advance 10 msec counter

    if (gTimerTOC2 == 100)              // check for 100 & 10 msec
    {
        gTimerTOC2 = 0;
        gTimerSeconds++;                // advance seconds
    }
}


unsigned int TimerGetSeconds(void)
{
    return (gTimerSeconds);
}
