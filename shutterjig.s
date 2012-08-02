	.module shutterjig.c
	.area text
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
;         status -> +3,x
;      strStatus -> +4,x
;        buttons -> +16,x
;         tmpstr -> +17,x
_main::
	jsr __enterb
	.byte 0xa6
; //=======================================================================
; //
; //
; //      File:       SHUTTERJIG.C
; //
; //      Function:   TH2 Shutter Jig Firmware
; //
; //      Author:     Corey Davyduke
; //
; //      Version:    1.00
; //
; //      Date:       July 31, 2012
; //
; //      Compiler:   Imagecraft C
; //
; //
; //-----------------------------------------------------------------------
; //
; //      History:    1.00    12/07/31    Genesis
; //
; //-----------------------------------------------------------------------
; //
; //      Notes:      text... 0xe000
; //                  data... 0x2000
; //                  sp..... 0x3fff
; //
; //=======================================================================
; 
; #include <hc11.h>
; #include <lib_optrex.h>
; #include <lib_timer.h>
; 
; // Definitions
; #define BUTTON_O 0x01
; #define BUTTON_C 0x02
; #define ON_TIME 100
; #define OFF_TIME 900
; 
; // External function prototypes
; extern void _start( );	                // entry point in crt11.s
; 
; // Local function prototypes
; void sc_init( void );
; unsigned char sc_get_buttons( void );
; void sc_set_driver( unsigned char val );
; unsigned char sc_get_driver( void );
; void TimerSleep( long msec );
; 
; unsigned long g_scycles;
; unsigned long gTimerSeconds;
; 
; int g_etime_hours;
; char g_etime_mins;
; char g_etime_secs;
; 
; long gFlipTarget;
; long gPulseTarget;
; long gTimerTicks;
; unsigned char g_flipside;
; 
; unsigned int shutter_opened;
; unsigned int shutter_closed;
; unsigned int shutter_open;
; unsigned int shutter_close;
; unsigned int open_shutter;
; unsigned int close_shutter;
; 
; void main( void )
; {
;   char tmpstr[21];
; 	char strStatus[12];
; 	unsigned char status;
;   unsigned char buttons;
; 
; 
;   //-------------------------
;   // initialize ram variable
;   //-------------------------
; 
;   gFlipTarget = 0;                    // important to set this before ints!
	ldy #L4
	jsr __ly2reg
	ldy #_gFlipTarget
	jsr __lreg2y
;   g_flipside = 0;
	clr _g_flipside
;   buttons = 0;
	clr 16,x
; 
;   sc_init( );
	jsr _sc_init
; 
;   g_scycles = 0;
	ldy #L5
	jsr __ly2reg
	ldy #_g_scycles
	jsr __lreg2y
;   g_etime_hours = 0;
	ldd #0
	std _g_etime_hours
;   g_etime_mins = 0;
	clr _g_etime_mins
;   g_etime_secs = 0;
	clr _g_etime_secs
; 	
; 	shutter_opened = 0;
	ldd #0
	std _shutter_opened
; 	shutter_closed = 0;
	ldd #0
	std _shutter_closed
; 	shutter_open = 0;
	ldd #0
	std _shutter_open
; 	shutter_close = 0;
	ldd #0
	std _shutter_close
; 	open_shutter = 0;
	ldd #0
	std _open_shutter
; 	close_shutter = 0;
	ldd #0
	std _close_shutter
; 
;   // Display an opening "banner" on the LCD screen.
;   OptrexClear( );
	jsr _OptrexClear
;   OptrexGotoXY( 2,1 );
	ldd #1
	pshb
	psha
	ldd #2
	jsr _OptrexGotoXY
	puly
;   OptrexWriteString( "TH2 Shutter Jig" );
	ldd #L6
	jsr _OptrexWriteString
;   OptrexGotoXY( 3,2 );
	ldd #2
	pshb
	psha
	ldd #3
	jsr _OptrexGotoXY
	puly
;   OptrexWriteString( "Version 1.00" );
	ldd #L7
	jsr _OptrexWriteString
;   TimerSleep( 3000 );
	ldy #L8
	jsr __ly2reg
	pshy
	pshy
	tsy
	jsr __lreg2y
	jsr _TimerSleep
	puly
	puly
;   OptrexClear( );
	jsr _OptrexClear
	jmp L10
L9:
; 
;   while( 1 )
; 	{
; 
;     if( shutter_opened )
	ldd _shutter_opened
	beq L12
; 		{
; 		  sprintf(strStatus, "opened" );
	ldd #L14
	pshb
	psha
	ldd 0,x
	addd #4
	jsr _sprintf
	puly
; 		}
	bra L13
L12:
; 		else if( shutter_closed )
	ldd _shutter_closed
	beq L15
; 		{
; 		  sprintf(strStatus, "closed" );
	ldd #L17
	pshb
	psha
	ldd 0,x
	addd #4
	jsr _sprintf
	puly
; 		}
	bra L16
L15:
; 		else
; 		{
;       sprintf(strStatus, "idle" );
	ldd #L18
	pshb
	psha
	ldd 0,x
	addd #4
	jsr _sprintf
	puly
; 		}
L16:
L13:
; 		
;     //----------------
;     // update display
;     //----------------
;     if( gTimerTicks % 50 )
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L21
	jsr __ly2reg2
	jsr __lmod
	ldy #L4
	jsr __ly2reg2
	jsr __lcmp
	bne X1
	jmp L19
X1:
;     {
;       sprintf( tmpstr, "shutter=%s", strStatus );
	ldd 0,x
	addd #4
	pshb
	psha
	ldd #L22
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	puly
	puly
;       OptrexGotoXY( 0,0 );
	ldd #0
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;       OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;       OptrexClearEOL( );
	jsr _OptrexClearEOL
; 
;       sprintf( tmpstr, "on=%d ms off=%d ms", ON_TIME, OFF_TIME );
	ldd #900
	pshb
	psha
	ldd #100
	pshb
	psha
	ldd #L23
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	jsr __movspb
	.byte 6
;       OptrexGotoXY( 0,1 );
	ldd #1
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;       OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;       OptrexClearEOL( );
	jsr _OptrexClearEOL
; 
;       sprintf( tmpstr, "time=%02d:%02d:%02d", g_etime_hours, g_etime_mins, g_etime_secs );
	ldab _g_etime_secs
	clra
	pshb
	psha
	ldab _g_etime_mins
	clra
	pshb
	psha
	ldd _g_etime_hours
	pshb
	psha
	ldd #L24
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	jsr __movspb
	.byte 8
;       OptrexGotoXY( 0,2 );
	ldd #2
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;       OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;       OptrexClearEOL( );
	jsr _OptrexClearEOL
; 
;       sprintf( tmpstr, "odometer=%07ld", g_scycles >> 1 );
	ldy #_g_scycles
	jsr __ly2reg
	ldd #1
	jsr __luirsh
	pshy
	pshy
	tsy
	jsr __lreg2y
	ldd #L25
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	jsr __movspb
	.byte 6
;       OptrexGotoXY( 0,3 );
	ldd #3
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;       OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;       OptrexClearEOL( );
	jsr _OptrexClearEOL
;     }
L19:
; 
;     buttons = sc_get_buttons( );
	jsr _sc_get_buttons
	stab 16,x
; 		
; 		// If the "open" button has been pressed, we want the shutter to open.
; 		if( buttons & BUTTON_O )
	brclr 16,x,#1,L26
; 		{
; 		  shutter_open = 1;
	ldd #1
	std _shutter_open
; 			
;       // If the user is requesting to open the shutter and it's already open, send a message.
; 			if( shutter_open && shutter_opened )
	ldd _shutter_open
	bne X2
	jmp L27
X2:
	ldd _shutter_opened
	bne X3
	jmp L27
X3:
; 			{
;         sprintf( tmpstr, "Already opened!" );
	ldd #L30
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	puly
;         OptrexGotoXY( 0,0 );
	ldd #0
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;         OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;         OptrexClearEOL( );
	jsr _OptrexClearEOL
;         TimerSleep( 200 );
	ldy #L31
	jsr __ly2reg
	pshy
	pshy
	tsy
	jsr __lreg2y
	jsr _TimerSleep
	puly
	puly
; 			}
; 		}
	bra L27
L26:
; 		// If the "close" button has been pressed, we want the shutter to close.
; 		else if( buttons & BUTTON_C )
	brclr 16,x,#2,L32
; 		{
; 		  shutter_close = 1;
	ldd #1
	std _shutter_close
; 
;       // If the user is requesting to close the shutter and it's already closed, send a message.			
; 			if( shutter_close && shutter_closed )
	ldd _shutter_close
	beq L34
	ldd _shutter_closed
	beq L34
; 			{
;         sprintf( tmpstr, "Already closed!" );
	ldd #L36
	pshb
	psha
	ldd 0,x
	addd #17
	jsr _sprintf
	puly
;         OptrexGotoXY( 0,0 );
	ldd #0
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;         OptrexWriteString( tmpstr );
	ldd 0,x
	addd #17
	jsr _OptrexWriteString
;         OptrexClearEOL( );
	jsr _OptrexClearEOL
;         TimerSleep( 200 );
	ldy #L31
	jsr __ly2reg
	pshy
	pshy
	tsy
	jsr __lreg2y
	jsr _TimerSleep
	puly
	puly
; 			}
L34:
; 		}
L32:
L27:
L10:
	jmp L9
X0:
; 	}
; }
L3:
	xgdx
	addd #38
	xgdx
	txs
	pulx
	.dbline 0 ; func end
	rts
_sc_init::
; 
; void sc_init( void )
; {
;   sc_set_driver( 0 );
	ldd #0
	jsr _sc_set_driver
; 
;   OptrexInit( );
	jsr _OptrexInit
;   TimerInit( );
	jsr _TimerInit
; }
L37:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;         retval -> +3,x
_sc_get_buttons::
	jsr __enterb
	.byte 0x4
; 
; unsigned char sc_get_buttons( void )
; {
;   unsigned char retval;
; 
;   retval = PORTA & 0x3;
	; vol
	ldab 0x1000
	andb #3
	stab 3,x
; 
;   return( retval );
	ldab 3,x
	clra
L38:
	inx
	inx
	inx
	inx
	txs
	pulx
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;  rMEM -> 2,x
;           stat -> +5,x
;            val -> +9,x
_sc_set_driver::
	jsr __enterb
	.byte 0x46
; }
; 
; void sc_set_driver( unsigned char val )
; {
;   unsigned char stat;
; 
;   val &= 0x03;
	bclr 9,x,#0xfc
;   stat = sc_get_driver( );
	jsr _sc_get_driver
	stab 5,x
; 
;   if( stat != val )
	ldab 5,x
	cmpb 9,x
	beq L40
;   {
;     PORTA &= ~0x30;                 // prevent any shoot through
	ldy #0x1000
	bclr 0,y,#0x30
;     PORTA |= ( val << 4 );
	ldab 9,x
	lslb
	lslb
	lslb
	lslb
	stab 2,x
	; vol
	ldab 0x1000
	orab 2,x
	stab 0x1000
;   }
L40:
; }
L39:
	xgdx
	addd #6
	xgdx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
_sc_get_driver::
; 
; unsigned char sc_get_driver( void )
; {
;   return( ( PORTA >> 4 ) & 0x03 );
	; vol
	ldab 0x1000
	clra
	lsrd
	lsrd
	lsrd
	lsrd
	anda #0
	andb #3
	clra
L42:
	.dbline 0 ; func end
	rts
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
_TimerInit::
	jsr __enterb
	.byte 0x82
; }
; 
; #pragma interrupt_handler TimerTOC2Isr
; 
; void TimerInit( void )
; {
;   TMSK1 = OC2F;                       // enable interrupts on OC2
	ldab #64
	stab 0x1022
;   TCTL1 = 0x00;                       // setup OC2 for n.c.
	clr 0x1020
; 
;   gTimerTicks = 0;
	ldy #L4
	jsr __ly2reg
	ldy #_gTimerTicks
	jsr __lreg2y
;   gTimerSeconds = 0;
	ldy #L5
	jsr __ly2reg
	ldy #_gTimerSeconds
	jsr __lreg2y
; 
;   INTR_ON( );
			cli

; }
L43:
	inx
	inx
	txs
	pulx
	.dbline 0 ; func end
	rts
	.area data
L45:
	.blkb 1
	.area idata
	.byte 0
	.area data
	.area text
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
;              i -> +3,x
_TimerTOC2Isr::
	jsr __enterb
	.byte 0x84
; 
; void TimerTOC2Isr( )
; {
;   static char gTimerTOC2 = 0;
;   unsigned char i;
; 
;   TFLG1 = OC2F;                       // clear compare flag
	ldab #64
	stab 0x1023
;   TOC2 = TCNT + 20000;                // setup next interrupt 10 msec later
	; vol
	ldd 0x100e
	addd #20000
	std 0x1018
; 
;   gTimerTicks++;
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L46
	jsr __ly2reg2
	jsr __ladd
	ldy #_gTimerTicks
	jsr __lreg2y
;   gTimerTOC2++;                       // advance 10 msec counter
	ldab L45
	addb #1
	stab L45
; 
;   if( gTimerTOC2 >= 100 )              // check for 100 & 10 msec
	ldab L45
	cmpb #100
	blo L47
;   {
;     gTimerTOC2 = 0;
	clr L45
; 
;     g_etime_secs++;
	ldab _g_etime_secs
	addb #1
	stab _g_etime_secs
; 
;     if( g_etime_secs > 59 )
	ldab _g_etime_secs
	cmpb #59
	bls L49
;     {
;       g_etime_secs = 0;
	clr _g_etime_secs
;       g_etime_mins++;
	ldab _g_etime_mins
	addb #1
	stab _g_etime_mins
;     }
L49:
; 
;     if( g_etime_mins > 59 )
	ldab _g_etime_mins
	cmpb #59
	bls L51
;     {
;       g_etime_mins = 0;
	clr _g_etime_mins
;       g_etime_hours++;
	ldd _g_etime_hours
	addd #1
	std _g_etime_hours
;     }
L51:
; 
;     gTimerSeconds++;                // advance seconds
	ldy #_gTimerSeconds
	jsr __ly2reg
	ldy #L53
	jsr __ly2reg2
	jsr __ladd
	ldy #_gTimerSeconds
	jsr __lreg2y
;   }
L47:
; 
;   //------------------------
;   // process solenoid stuff
;   //------------------------
; 
;   // If either one of the buttons has been pressed, the user is requesting an action.
; 	if( shutter_open || shutter_close )
	ldd _shutter_open
	bne L56
	ldd _shutter_close
	bne X4
	jmp L54
X4:
L56:
; 	{
;     // Set up the delay timers.
; 	  gPulseTarget = gTimerTicks + ( ON_TIME / 10 );
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L57
	jsr __ly2reg2
	jsr __ladd
	ldy #_gPulseTarget
	jsr __lreg2y
; 		gFlipTarget = gPulseTarget + ( OFF_TIME / 10 );
	ldy #_gPulseTarget
	jsr __ly2reg
	ldy #L58
	jsr __ly2reg2
	jsr __ladd
	ldy #_gFlipTarget
	jsr __lreg2y
; 		
; 		// If the desired action is shutter open, signal to open the shutter ...
; 		if( shutter_open )
	ldd _shutter_open
	beq L59
; 		{
;       // ... but only if the shutter is not already opened.
; 		  if( !shutter_opened )
	ldd _shutter_opened
	bne L61
;       {
; 			  open_shutter = 1;
	ldd #1
	std _open_shutter
; 			  close_shutter = 0;
	ldd #0
	std _close_shutter
; 			}
	bra L60
L61:
; 
; 			// If the shutter is already opened, set the request back to zero.
; 			else
; 			{
; 			  open_shutter = close_shutter = 0;
	ldd #0
	std _close_shutter
	ldd #0
	std _open_shutter
; 			}
; 		}
	bra L60
L59:
; 
; 		// If the desired action is shutter close, signal to close the shutter ...
; 		else if( shutter_close )
	ldd _shutter_close
	beq L63
; 		{
;       // ... but only if the shutter is not already closed.
;       if( !shutter_closed )
	ldd _shutter_closed
	bne L65
; 			{
;         open_shutter = 0;
	ldd #0
	std _open_shutter
; 		    close_shutter = 1;
	ldd #1
	std _close_shutter
; 			}
	bra L64
L65:
; 
;       // If the shutter is already closed, set the request back to zero.
; 			else
; 			{
; 			  open_shutter = close_shutter = 0;
	ldd #0
	std _close_shutter
	ldd #0
	std _open_shutter
; 			}
; 		}
	bra L64
L63:
; 
; 		// If no requests have been made, turn both signals off.
; 		else
; 		{
; 		  open_shutter = close_shutter = 0;
	ldd #0
	std _close_shutter
	ldd #0
	std _open_shutter
; 		}
L64:
L60:
; 
; 		// After the appropriate flag has been set, set the "request" back to zero.
; 		shutter_open = shutter_close = 0;
	ldd #0
	std _shutter_close
	ldd #0
	std _shutter_open
; 	}
L54:
; 
; 	// If the pulse has been on for the desired number of milliseconds ...
;   if( gTimerTicks < gPulseTarget )
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #_gPulseTarget
	jsr __ly2reg2
	jsr __lcmp
	bge L67
;   {
; 
;     // ... open the shutter, if that is the desired action.
; 	  if( open_shutter )
	ldd _open_shutter
	beq L69
; 		{
;       sc_set_driver( 2 );
	ldd #2
	jsr _sc_set_driver
; 			shutter_opened = 1;
	ldd #1
	std _shutter_opened
; 			shutter_closed = 0;
	ldd #0
	std _shutter_closed
;       g_scycles++;        // increment cycle counter
	ldy #_g_scycles
	jsr __ly2reg
	ldy #L53
	jsr __ly2reg2
	jsr __ladd
	ldy #_g_scycles
	jsr __lreg2y
; 		}
	bra L68
L69:
; 
; 		// .. or close the shutter, if that is the desired action.
; 		else if( close_shutter )
	ldd _close_shutter
	beq L71
; 		{
;       sc_set_driver( 1 );
	ldd #1
	jsr _sc_set_driver
; 			shutter_opened = 0;
	ldd #0
	std _shutter_opened
; 			shutter_closed = 1;
	ldd #1
	std _shutter_closed
;       g_scycles++;        // increment cycle counter
	ldy #_g_scycles
	jsr __ly2reg
	ldy #L53
	jsr __ly2reg2
	jsr __ladd
	ldy #_g_scycles
	jsr __lreg2y
; 		}
	bra L68
L71:
; 
; 		// ... the default is to set the driver back to the idle state.
; 		else
; 		{
;       sc_set_driver( 0 );
	ldd #0
	jsr _sc_set_driver
; 		}
;   }
	bra L68
L67:
; 
;   // If the desired number of milliseconds has passed, set the driver back to the idle state.
;   else
;   {
;     // If the pulse is still on ...
;     if( sc_get_driver( ) )
	jsr _sc_get_driver
	cmpb #0
	beq L73
;     {
;       // ... turn off the pulse.
;       sc_set_driver( 0 );
	ldd #0
	jsr _sc_set_driver
;     }
L73:
; 
;     // Set the requests back to zero.
; 		open_shutter = close_shutter = 0;
	ldd #0
	std _close_shutter
	ldd #0
	std _open_shutter
;   }
L68:
; }
L44:
	inx
	inx
	inx
	inx
	txs
	pulx
	.dbline 0 ; func end
	rti
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
;         target -> +2,x
;           msec -> +10,x
_TimerSleep::
	jsr __enterb
	.byte 0x86
; 
; void TimerSleep( long msec )
; {
;   long target;
; 
;   target = gTimerTicks + ( msec / 10 );
	ldd 0,x
	addd #10
	xgdy
	jsr __ly2reg
	ldy #L57
	jsr __ly2reg2
	jsr __ldiv
	jsr __lregmov
	ldy #_gTimerTicks
	jsr __ly2reg
	jsr __ladd
	ldd 0,x
	addd #2
	xgdy
	jsr __lreg2y
L76:
L77:
; 
;   while( target > gTimerTicks );
	ldd 0,x
	addd #2
	xgdy
	jsr __ly2reg
	ldy #_gTimerTicks
	jsr __ly2reg2
	jsr __lcmp
	bgt L76
; }
L75:
	xgdx
	addd #6
	xgdx
	txs
	pulx
	.dbline 0 ; func end
	rts
__HC11Setup::
; 
; #define DUMMY_ENTRY	(void (*)())0xFFFF
; 
; void _HC11Setup( void )
; {
;   CONFIG = 0x05;
	ldab #5
	stab 0x103f
; }
L79:
	.dbline 0 ; func end
	rts
	.area memory(abs)
	.org 0xffd6
_interrupt_vectors::
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word _TimerTOC2Isr
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word 65535
	.word __start
	.area data
	.area bss
_close_shutter::
	.blkb 2
_open_shutter::
	.blkb 2
_shutter_close::
	.blkb 2
_shutter_open::
	.blkb 2
_shutter_closed::
	.blkb 2
_shutter_opened::
	.blkb 2
_g_flipside::
	.blkb 1
_gTimerTicks::
	.blkb 4
_gPulseTarget::
	.blkb 4
_gFlipTarget::
	.blkb 4
_g_etime_secs::
	.blkb 1
_g_etime_mins::
	.blkb 1
_g_etime_hours::
	.blkb 2
_gTimerSeconds::
	.blkb 4
_g_scycles::
	.blkb 4
	.area text
L58:
	.word 0,90
L57:
	.word 0,10
L53:
	.word 0,1
L46:
	.word 0,1
L36:
	.byte 'A,'l,'r,'e,'a,'d,'y,32,'c,'l,'o,'s,'e,'d,33,0
L31:
	.word 0,200
L30:
	.byte 'A,'l,'r,'e,'a,'d,'y,32,'o,'p,'e,'n,'e,'d,33,0
L25:
	.byte 'o,'d,'o,'m,'e,'t,'e,'r,61,37,48,55,'l,'d,0
L24:
	.byte 't,'i,'m,'e,61,37,48,50,'d,58,37,48,50,'d,58,37
	.byte 48,50,'d,0
L23:
	.byte 'o,'n,61,37,'d,32,'m,'s,32,'o,'f,'f,61,37,'d,32
	.byte 'm,'s,0
L22:
	.byte 's,'h,'u,'t,'t,'e,'r,61,37,'s,0
L21:
	.word 0,50
L18:
	.byte 'i,'d,'l,'e,0
L17:
	.byte 'c,'l,'o,'s,'e,'d,0
L14:
	.byte 'o,'p,'e,'n,'e,'d,0
L8:
	.word 0,3000
L7:
	.byte 'V,'e,'r,'s,'i,'o,'n,32,49,46,48,48,0
L6:
	.byte 'T,'H,50,32,'S,'h,'u,'t,'t,'e,'r,32,'J,'i,'g,0
L5:
	.word 0,0
L4:
	.word 0,0
