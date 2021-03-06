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
#include <lib_timer.h>

// Definitions
#define BUTTON_O 0x01
#define BUTTON_C 0x02
#define ON_TIME 100
#define OFF_TIME 900

// External function prototypes
extern void _start( );	                // entry point in crt11.s

// Local function prototypes
void sc_init( void );
unsigned char sc_get_buttons( void );
void sc_set_driver( unsigned char val );
unsigned char sc_get_driver( void );
void TimerSleep( long msec );

unsigned long g_scycles;
unsigned long gTimerSeconds;

int g_etime_hours;
char g_etime_mins;
char g_etime_secs;

long gFlipTarget;
long gPulseTarget;
long gTimerTicks;
unsigned char g_flipside;

unsigned int shutter_opened;
unsigned int shutter_closed;
unsigned int shutter_open;
unsigned int shutter_close;
unsigned int open_shutter;
unsigned int close_shutter;

void main( void )
{
  char tmpstr[21];
	char strStatus[12];
	unsigned char status;
  unsigned char buttons;


  //-------------------------
  // initialize ram variable
  //-------------------------

  gFlipTarget = 0;                    // important to set this before ints!
  g_flipside = 0;
  buttons = 0;

  sc_init( );

  g_scycles = 0;
  g_etime_hours = 0;
  g_etime_mins = 0;
  g_etime_secs = 0;
	
	shutter_opened = 0;
	shutter_closed = 0;
	shutter_open = 0;
	shutter_close = 0;
	open_shutter = 0;
	close_shutter = 0;

  // Display an opening "banner" on the LCD screen.
  OptrexClear( );
  OptrexGotoXY( 2,1 );
  OptrexWriteString( "TH2 Shutter Jig" );
  OptrexGotoXY( 3,2 );
  OptrexWriteString( "Version 1.00" );
  TimerSleep( 3000 );
  OptrexClear( );

  while( 1 )
	{

    if( shutter_opened )
		{
		  sprintf(strStatus, "opened" );
		}
		else if( shutter_closed )
		{
		  sprintf(strStatus, "closed" );
		}
		else
		{
      sprintf(strStatus, "idle" );
		}
		
    //----------------
    // update display
    //----------------
    if( gTimerTicks % 50 )
    {
      sprintf( tmpstr, "shutter=%s", strStatus );
      OptrexGotoXY( 0,0 );
      OptrexWriteString( tmpstr );
      OptrexClearEOL( );

      sprintf( tmpstr, "on=%d ms off=%d ms", ON_TIME, OFF_TIME );
      OptrexGotoXY( 0,1 );
      OptrexWriteString( tmpstr );
      OptrexClearEOL( );

      sprintf( tmpstr, "time=%02d:%02d:%02d", g_etime_hours, g_etime_mins, g_etime_secs );
      OptrexGotoXY( 0,2 );
      OptrexWriteString( tmpstr );
      OptrexClearEOL( );

      sprintf( tmpstr, "odometer=%07ld", g_scycles >> 1 );
      OptrexGotoXY( 0,3 );
      OptrexWriteString( tmpstr );
      OptrexClearEOL( );
    }

    buttons = sc_get_buttons( );
		
		// If the "open" button has been pressed, we want the shutter to open.
		if( buttons & BUTTON_O )
		{
		  shutter_open = 1;
			
      // If the user is requesting to open the shutter and it's already open, send a message.
			if( shutter_open && shutter_opened )
			{
        sprintf( tmpstr, "Already opened!" );
        OptrexGotoXY( 0,0 );
        OptrexWriteString( tmpstr );
        OptrexClearEOL( );
        TimerSleep( 200 );
			}
		}
		// If the "close" button has been pressed, we want the shutter to close.
		else if( buttons & BUTTON_C )
		{
		  shutter_close = 1;

      // If the user is requesting to close the shutter and it's already closed, send a message.			
			if( shutter_close && shutter_closed )
			{
        sprintf( tmpstr, "Already closed!" );
        OptrexGotoXY( 0,0 );
        OptrexWriteString( tmpstr );
        OptrexClearEOL( );
        TimerSleep( 200 );
			}
		}
	}
}

void sc_init( void )
{
  sc_set_driver( 0 );

  OptrexInit( );
  TimerInit( );
}

unsigned char sc_get_buttons( void )
{
  unsigned char retval;

  retval = PORTA & 0x3;

  return( retval );
}

void sc_set_driver( unsigned char val )
{
  unsigned char stat;

  val &= 0x03;
  stat = sc_get_driver( );

  if( stat != val )
  {
    PORTA &= ~0x30;                 // prevent any shoot through
    PORTA |= ( val << 4 );
  }
}

unsigned char sc_get_driver( void )
{
  return( ( PORTA >> 4 ) & 0x03 );
}

#pragma interrupt_handler TimerTOC2Isr

void TimerInit( void )
{
  TMSK1 = OC2F;                       // enable interrupts on OC2
  TCTL1 = 0x00;                       // setup OC2 for n.c.

  gTimerTicks = 0;
  gTimerSeconds = 0;

  INTR_ON( );
}

void TimerTOC2Isr( )
{
  static char gTimerTOC2 = 0;
  unsigned char i;

  TFLG1 = OC2F;                       // clear compare flag
  TOC2 = TCNT + 20000;                // setup next interrupt 10 msec later

  gTimerTicks++;
  gTimerTOC2++;                       // advance 10 msec counter

  if( gTimerTOC2 >= 100 )              // check for 100 & 10 msec
  {
    gTimerTOC2 = 0;

    g_etime_secs++;

    if( g_etime_secs > 59 )
    {
      g_etime_secs = 0;
      g_etime_mins++;
    }

    if( g_etime_mins > 59 )
    {
      g_etime_mins = 0;
      g_etime_hours++;
    }

    gTimerSeconds++;                // advance seconds
  }

  //------------------------
  // process solenoid stuff
  //------------------------

  // If either one of the buttons has been pressed, the user is requesting an action.
	if( shutter_open || shutter_close )
	{
    // Set up the delay timers.
	  gPulseTarget = gTimerTicks + ( ON_TIME / 10 );
		gFlipTarget = gPulseTarget + ( OFF_TIME / 10 );
		
		// If the desired action is shutter open, signal to open the shutter ...
		if( shutter_open )
		{
      // ... but only if the shutter is not already opened.
		  if( !shutter_opened )
      {
			  open_shutter = 1;
			  close_shutter = 0;
			}

			// If the shutter is already opened, set the request back to zero.
			else
			{
			  open_shutter = close_shutter = 0;
			}
		}

		// If the desired action is shutter close, signal to close the shutter ...
		else if( shutter_close )
		{
      // ... but only if the shutter is not already closed.
      if( !shutter_closed )
			{
        open_shutter = 0;
		    close_shutter = 1;
			}

      // If the shutter is already closed, set the request back to zero.
			else
			{
			  open_shutter = close_shutter = 0;
			}
		}

		// If no requests have been made, turn both signals off.
		else
		{
		  open_shutter = close_shutter = 0;
		}

		// After the appropriate flag has been set, set the "request" back to zero.
		shutter_open = shutter_close = 0;
	}

	// If the pulse has been on for the desired number of milliseconds ...
  if( gTimerTicks < gPulseTarget )
  {

    // ... open the shutter, if that is the desired action.
	  if( open_shutter )
		{
      sc_set_driver( 2 );
			shutter_opened = 1;
			shutter_closed = 0;
      g_scycles++;        // increment cycle counter
		}

		// .. or close the shutter, if that is the desired action.
		else if( close_shutter )
		{
      sc_set_driver( 1 );
			shutter_opened = 0;
			shutter_closed = 1;
      g_scycles++;        // increment cycle counter
		}

		// ... the default is to set the driver back to the idle state.
		else
		{
      sc_set_driver( 0 );
		}
  }

  // If the desired number of milliseconds has passed, set the driver back to the idle state.
  else
  {
    // If the pulse is still on ...
    if( sc_get_driver( ) )
    {
      // ... turn off the pulse.
      sc_set_driver( 0 );
    }

    // Set the requests back to zero.
		open_shutter = close_shutter = 0;
  }
}

void TimerSleep( long msec )
{
  long target;

  target = gTimerTicks + ( msec / 10 );

  while( target > gTimerTicks );
}

#define DUMMY_ENTRY	(void (*)())0xFFFF

void _HC11Setup( void )
{
  CONFIG = 0x05;
}

#pragma abs_address:0xffd6

void ( *interrupt_vectors[] )( ) =
{
	DUMMY_ENTRY,	/* SCI */
	DUMMY_ENTRY,	/* SPI */
	DUMMY_ENTRY,	/* PAIE */
	DUMMY_ENTRY,	/* PAO */
	DUMMY_ENTRY,	/* TOF */
	DUMMY_ENTRY,	/* TOC5 */	/* HC12 TC7 */
	DUMMY_ENTRY,	/* TOC4 */	/* TC6 */
	DUMMY_ENTRY,	/* TOC3 */	/* TC5 */
  TimerTOC2Isr, /* TOC2 */  /* TC4 */
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
  _start        /* RESET */
};

#pragma end_abs_address

