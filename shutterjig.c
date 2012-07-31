//=======================================================================
//
//
//      File:       SHUTTERJIG.C
//
//      Function:   TH2 Shutter Jig Firmware
//
//      Author:     Corey Davyduke
//
//      Version:    1.00
//
//      Date:       July 31, 2012
//
//      Compiler:   Imagecraft C
//
//
//-----------------------------------------------------------------------
//
//      History:    1.00    12/07/31    Genesis
//
//-----------------------------------------------------------------------
//
//      Notes:      text... 0xe000
//                  data... 0x2000
//                  sp..... 0x3fff
//
//=======================================================================

#include <hc11.h>
#include <lib_optrex.h>
#include <lib_eeprom.h>
#include <lib_adc.h>
#include <lib_timer.h>

// definitions
#define BUTTON_O 0x01
#define BUTTON_C 0x02
#define ON_TIME 100
#define OFF_TIME 900

// external proto's
extern void _start();	                // entry point in crt11.s

// local proto's
void sc_init(void);
void sc_acquire_buttons(void);
unsigned char sc_get_buttons(void);
void sc_set_driver(unsigned char val);
unsigned char sc_get_driver(void);
void TimerSleep(long msec);

unsigned long g_scycles;
unsigned long gTimerSeconds;

int g_etime_hours;
char g_etime_mins;
char g_etime_secs;

long gFlipTarget;
long gPulseTarget;
long gTimerTicks;
unsigned char g_flipside;

unsigned char new_buttons, old_buttons;


void main(void)
{
	char tmpstr[21];

    //-------------------------
    // initialize ram variable
    //-------------------------

    gFlipTarget = 0;                    // important to set this before ints!
    g_flipside = 0;
    new_buttons = old_buttons = 0;

    sc_init();

    g_scycles = 0;
    g_etime_hours = 0;
    g_etime_mins = 0;
    g_etime_secs = 0;

    sc_acquire_buttons();

    OptrexClear();
    OptrexGotoXY(2,1);
    OptrexWriteString("TH2 Shutter Jig");
    OptrexGotoXY(3,2);
    OptrexWriteString("Version 1.00");
    TimerSleep(3000);
    OptrexClear();

    while(1)
	{
        //----------------
        // update display
        //----------------
        if (gTimerTicks % 50)
        {
            OptrexGotoXY(0,0);
            OptrexWriteString("----- Cycling ------");

            sprintf(tmpstr, "on=%d ms off=%d ms", ON_TIME, OFF_TIME);
            OptrexGotoXY(0,1);
            OptrexWriteString(tmpstr);
            OptrexClearEOL();

            sprintf(tmpstr, "et=%02d:%02d:%02d", g_etime_hours, g_etime_mins, g_etime_secs);
            OptrexGotoXY(0,2);
            OptrexWriteString(tmpstr);

            sprintf(tmpstr, "odometer=%07ld", g_scycles >> 1);
            OptrexGotoXY(0,3);
            OptrexWriteString(tmpstr);
        }

        sc_acquire_buttons();
	}
}


void sc_init(void)
{
    sc_set_driver(0);

    OptrexInit();
    TimerInit();
}


void sc_acquire_buttons(void)
{
    //--------------------
    // button acquisition
    //--------------------

    old_buttons = new_buttons;
    new_buttons = sc_get_buttons();
}


unsigned char sc_get_buttons(void)
{
    unsigned char retval;

    retval = PORTA & 0x3;

    return (retval);
}

void sc_set_driver(unsigned char val)
{
    unsigned char stat;

    val &= 0x03;
    stat = sc_get_driver();

    if (stat != val)
    {
        PORTA &= ~0x30;                 // prevent any shoot through
        PORTA |= (val << 4);
    }

}

unsigned char sc_get_driver(void)
{
    return ((PORTA >> 4) & 0x03);
}


#pragma interrupt_handler TimerTOC2Isr

void TimerInit(void)
{
    TMSK1 = OC2F;                       // enable interrupts on OC2
    TCTL1 = 0x00;                       // setup OC2 for n.c.

    gTimerTicks = 0;
    gTimerSeconds = 0;

    INTR_ON();
}

void TimerTOC2Isr()
{
    static char gTimerTOC2 = 0;
    unsigned char log_current = 0;
    unsigned char i;

    TFLG1 = OC2F;                       // clear compare flag
    TOC2 = TCNT + 20000;                // setup next interrupt 10 msec later

    gTimerTicks++;
    gTimerTOC2++;                       // advance 10 msec counter

    if (gTimerTOC2 >= 100)              // check for 100 & 10 msec
    {
        gTimerTOC2 = 0;

        g_etime_secs++;

        if (g_etime_secs > 59)
        {
            g_etime_secs = 0;
            g_etime_mins++;
        }

        if (g_etime_mins > 59)
        {
            g_etime_mins = 0;
            g_etime_hours++;
        }

        gTimerSeconds++;                // advance seconds
    }

    //------------------------
    // process solenoid stuff
    //------------------------

    if (gTimerTicks > gFlipTarget)  // flip target reached?
    {
        // calculate new pulse and flip target

        gPulseTarget = gTimerTicks + (ON_TIME / 10);
        gFlipTarget = gPulseTarget + (OFF_TIME / 10);

        // flip h-bridge
        g_flipside ^= 1;

        switch (g_flipside)
        {
            case 0: sc_set_driver(1); break;
            case 1: sc_set_driver(2); break;
            default: sc_set_driver(0); break;
        }

        g_scycles++;        // increment cycle counter
    }
    else                            // not time to flip yet
    {
        if (sc_get_driver())        // if pulse is still on...
        {
            if (gTimerTicks > gPulseTarget) // pulse target reached?
            {
                sc_set_driver(0);   // turn off pulse
            }
        }
    }
}


void TimerSleep(long msec)
{
    long target;

    target = gTimerTicks + (msec / 10);

    while(target > gTimerTicks);
}


#define DUMMY_ENTRY	(void (*)())0xFFFF

void _HC11Setup(void)
{
    CONFIG = 0x05;
}

#pragma abs_address:0xffd6

void (*interrupt_vectors[])() =
{
	DUMMY_ENTRY,	/* SCI */
	DUMMY_ENTRY,	/* SPI */
	DUMMY_ENTRY,	/* PAIE */
	DUMMY_ENTRY,	/* PAO */
	DUMMY_ENTRY,	/* TOF */
	DUMMY_ENTRY,	/* TOC5 */	/* HC12 TC7 */
	DUMMY_ENTRY,	/* TOC4 */	/* TC6 */
	DUMMY_ENTRY,	/* TOC3 */	/* TC5 */
    TimerTOC2Isr,   /* TOC2 */  /* TC4 */
	DUMMY_ENTRY,	/* TOC1 */	/* TC3 */
	DUMMY_ENTRY,	/* TIC3 */	/* TC2 */
	DUMMY_ENTRY,	/* TIC2 */	/* TC1 */
	DUMMY_ENTRY,	/* TIC1 */	/* TC0 */
	DUMMY_ENTRY,	/* RTI */
	DUMMY_ENTRY,	/* IRQ */
	DUMMY_ENTRY,	/* XIRQ */
	DUMMY_ENTRY,	/* SWI */
	DUMMY_ENTRY,	/* ILLOP */
	DUMMY_ENTRY,	/* COP */
	DUMMY_ENTRY,	/* CLM */
    _start          /* RESET */
};

#pragma end_abs_address

