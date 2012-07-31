	.module shutterjig.c
	.area text
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
;         tmpstr -> +3,x
_main::
	jsr __enterb
	.byte 0x98
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
; #include <lib_eeprom.h>
; #include <lib_adc.h>
; #include <lib_timer.h>
; 
; // definitions
; #define BUTTON_O 0x01
; #define BUTTON_C 0x02
; #define ON_TIME 100
; #define OFF_TIME 900
; 
; // external proto's
; extern void _start();	                // entry point in crt11.s
; 
; // local proto's
; void sc_init(void);
; void sc_acquire_buttons(void);
; unsigned char sc_get_buttons(void);
; void sc_set_driver(unsigned char val);
; unsigned char sc_get_driver(void);
; void TimerSleep(long msec);
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
; unsigned char new_buttons, old_buttons;
; 
; 
; void main(void)
; {
; 	char tmpstr[21];
; 
;     //-------------------------
;     // initialize ram variable
;     //-------------------------
; 
;     gFlipTarget = 0;                    // important to set this before ints!
	ldy #L4
	jsr __ly2reg
	ldy #_gFlipTarget
	jsr __lreg2y
;     g_flipside = 0;
	clr _g_flipside
;     new_buttons = old_buttons = 0;
	clr _old_buttons
	clr _new_buttons
; 
;     sc_init();
	jsr _sc_init
; 
;     g_scycles = 0;
	ldy #L5
	jsr __ly2reg
	ldy #_g_scycles
	jsr __lreg2y
;     g_etime_hours = 0;
	ldd #0
	std _g_etime_hours
;     g_etime_mins = 0;
	clr _g_etime_mins
;     g_etime_secs = 0;
	clr _g_etime_secs
; 
;     sc_acquire_buttons();
	jsr _sc_acquire_buttons
; 
;     OptrexClear();
	jsr _OptrexClear
;     OptrexGotoXY(2,1);
	ldd #1
	pshb
	psha
	ldd #2
	jsr _OptrexGotoXY
	puly
;     OptrexWriteString("TH2 Shutter Jig");
	ldd #L6
	jsr _OptrexWriteString
;     OptrexGotoXY(3,2);
	ldd #2
	pshb
	psha
	ldd #3
	jsr _OptrexGotoXY
	puly
;     OptrexWriteString("Version 1.00");
	ldd #L7
	jsr _OptrexWriteString
;     TimerSleep(3000);
	ldy #L8
	jsr __ly2reg
	pshy
	pshy
	tsy
	jsr __lreg2y
	jsr _TimerSleep
	puly
	puly
;     OptrexClear();
	jsr _OptrexClear
	jmp L10
L9:
; 
;     while(1)
; 	{
;         //----------------
;         // update display
;         //----------------
;         if (gTimerTicks % 50)
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L14
	jsr __ly2reg2
	jsr __lmod
	ldy #L4
	jsr __ly2reg2
	jsr __lcmp
	bne X1
	jmp L12
X1:
;         {
;             OptrexGotoXY(0,0);
	ldd #0
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;             OptrexWriteString("----- Cycling ------");
	ldd #L15
	jsr _OptrexWriteString
; 
;             sprintf(tmpstr, "on=%d ms off=%d ms", ON_TIME, OFF_TIME);
	ldd #900
	pshb
	psha
	ldd #100
	pshb
	psha
	ldd #L16
	pshb
	psha
	ldd 0,x
	addd #3
	jsr _sprintf
	jsr __movspb
	.byte 6
;             OptrexGotoXY(0,1);
	ldd #1
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;             OptrexWriteString(tmpstr);
	ldd 0,x
	addd #3
	jsr _OptrexWriteString
;             OptrexClearEOL();
	jsr _OptrexClearEOL
; 
;             sprintf(tmpstr, "et=%02d:%02d:%02d", g_etime_hours, g_etime_mins, g_etime_secs);
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
	ldd #L17
	pshb
	psha
	ldd 0,x
	addd #3
	jsr _sprintf
	jsr __movspb
	.byte 8
;             OptrexGotoXY(0,2);
	ldd #2
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;             OptrexWriteString(tmpstr);
	ldd 0,x
	addd #3
	jsr _OptrexWriteString
; 
;             sprintf(tmpstr, "odometer=%07ld", g_scycles >> 1);
	ldy #_g_scycles
	jsr __ly2reg
	ldd #1
	jsr __luirsh
	pshy
	pshy
	tsy
	jsr __lreg2y
	ldd #L18
	pshb
	psha
	ldd 0,x
	addd #3
	jsr _sprintf
	jsr __movspb
	.byte 6
;             OptrexGotoXY(0,3);
	ldd #3
	pshb
	psha
	ldd #0
	jsr _OptrexGotoXY
	puly
;             OptrexWriteString(tmpstr);
	ldd 0,x
	addd #3
	jsr _OptrexWriteString
;         }
L12:
	jsr _sc_acquire_buttons
L10:
	jmp L9
X0:
; 
;         sc_acquire_buttons();
; 	}
; }
L3:
	xgdx
	addd #24
	xgdx
	txs
	pulx
	.dbline 0 ; func end
	rts
_sc_init::
; 
; 
; void sc_init(void)
; {
;     sc_set_driver(0);
	ldd #0
	jsr _sc_set_driver
; 
;     OptrexInit();
	jsr _OptrexInit
;     TimerInit();
	jsr _TimerInit
; }
L19:
	.dbline 0 ; func end
	rts
_sc_acquire_buttons::
; 
; 
; void sc_acquire_buttons(void)
; {
;     //--------------------
;     // button acquisition
;     //--------------------
; 
;     old_buttons = new_buttons;
	ldab _new_buttons
	stab _old_buttons
;     new_buttons = sc_get_buttons();
	jsr _sc_get_buttons
	stab _new_buttons
; }
L20:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;         retval -> +3,x
_sc_get_buttons::
	jsr __enterb
	.byte 0x4
; 
; 
; unsigned char sc_get_buttons(void)
; {
;     unsigned char retval;
; 
;     retval = PORTA & 0x3;
	; vol
	ldab 0x1000
	andb #3
	stab 3,x
; 
;     return (retval);
	ldab 3,x
	clra
L21:
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
; void sc_set_driver(unsigned char val)
; {
;     unsigned char stat;
; 
;     val &= 0x03;
	bclr 9,x,#0xfc
;     stat = sc_get_driver();
	jsr _sc_get_driver
	stab 5,x
; 
;     if (stat != val)
	ldab 5,x
	cmpb 9,x
	beq L23
;     {
;         PORTA &= ~0x30;                 // prevent any shoot through
	ldy #0x1000
	bclr 0,y,#0x30
;         PORTA |= (val << 4);
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
;     }
L23:
; 
; }
L22:
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
; unsigned char sc_get_driver(void)
; {
;     return ((PORTA >> 4) & 0x03);
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
L25:
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
; 
; #pragma interrupt_handler TimerTOC2Isr
; 
; void TimerInit(void)
; {
;     TMSK1 = OC2F;                       // enable interrupts on OC2
	ldab #64
	stab 0x1022
;     TCTL1 = 0x00;                       // setup OC2 for n.c.
	clr 0x1020
; 
;     gTimerTicks = 0;
	ldy #L4
	jsr __ly2reg
	ldy #_gTimerTicks
	jsr __lreg2y
;     gTimerSeconds = 0;
	ldy #L5
	jsr __ly2reg
	ldy #_gTimerSeconds
	jsr __lreg2y
; 
;     INTR_ON();
			cli

; }
L26:
	inx
	inx
	txs
	pulx
	.dbline 0 ; func end
	rts
	.area data
L28:
	.blkb 1
	.area idata
	.byte 0
	.area data
	.area text
;  lreg1 -> -4,x
;  lreg2 -> -8,x
;  IX -> 0,x
;          ?temp -> +2,x
;              i -> +4,x
;    log_current -> +5,x
_TimerTOC2Isr::
	jsr __enterb
	.byte 0x86
; 
; void TimerTOC2Isr()
; {
;     static char gTimerTOC2 = 0;
;     unsigned char log_current = 0;
	clr 5,x
;     unsigned char i;
; 
;     TFLG1 = OC2F;                       // clear compare flag
	ldab #64
	stab 0x1023
;     TOC2 = TCNT + 20000;                // setup next interrupt 10 msec later
	; vol
	ldd 0x100e
	addd #20000
	std 0x1018
; 
;     gTimerTicks++;
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L29
	jsr __ly2reg2
	jsr __ladd
	ldy #_gTimerTicks
	jsr __lreg2y
;     gTimerTOC2++;                       // advance 10 msec counter
	ldab L28
	addb #1
	stab L28
; 
;     if (gTimerTOC2 >= 100)              // check for 100 & 10 msec
	ldab L28
	cmpb #100
	blo L30
;     {
;         gTimerTOC2 = 0;
	clr L28
; 
;         g_etime_secs++;
	ldab _g_etime_secs
	addb #1
	stab _g_etime_secs
; 
;         if (g_etime_secs > 59)
	ldab _g_etime_secs
	cmpb #59
	bls L32
;         {
;             g_etime_secs = 0;
	clr _g_etime_secs
;             g_etime_mins++;
	ldab _g_etime_mins
	addb #1
	stab _g_etime_mins
;         }
L32:
; 
;         if (g_etime_mins > 59)
	ldab _g_etime_mins
	cmpb #59
	bls L34
;         {
;             g_etime_mins = 0;
	clr _g_etime_mins
;             g_etime_hours++;
	ldd _g_etime_hours
	addd #1
	std _g_etime_hours
;         }
L34:
; 
;         gTimerSeconds++;                // advance seconds
	ldy #_gTimerSeconds
	jsr __ly2reg
	ldy #L36
	jsr __ly2reg2
	jsr __ladd
	ldy #_gTimerSeconds
	jsr __lreg2y
;     }
L30:
; 
;     //------------------------
;     // process solenoid stuff
;     //------------------------
; 
; 
;     if (gTimerTicks > gFlipTarget)  // flip target reached?
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #_gFlipTarget
	jsr __ly2reg2
	jsr __lcmp
	bgt X3
	jmp L37
X3:
;     {
;         // calculate new pulse and flip target
; 
;         gPulseTarget = gTimerTicks + (ON_TIME / 10);
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #L39
	jsr __ly2reg2
	jsr __ladd
	ldy #_gPulseTarget
	jsr __lreg2y
;         gFlipTarget = gPulseTarget + (OFF_TIME / 10);
	ldy #_gPulseTarget
	jsr __ly2reg
	ldy #L40
	jsr __ly2reg2
	jsr __ladd
	ldy #_gFlipTarget
	jsr __lreg2y
; 
;         // flip h-bridge
;         g_flipside ^= 1;
	ldab _g_flipside
	eorb #1
	stab _g_flipside
; 
;         switch (g_flipside)
	ldab _g_flipside
	clra
	std 2,x
	beq L44
	ldd 2,x
	cpd #1
	beq L45
	bra L41
X2:
;         {
L44:
;             case 0: sc_set_driver(1); break;
	ldd #1
	jsr _sc_set_driver
	bra L42
L45:
;             case 1: sc_set_driver(2); break;
	ldd #2
	jsr _sc_set_driver
	bra L42
L41:
;             default: sc_set_driver(0); break;
	ldd #0
	jsr _sc_set_driver
L42:
;         }
; 
;         g_scycles++;        // increment cycle counter
	ldy #_g_scycles
	jsr __ly2reg
	ldy #L36
	jsr __ly2reg2
	jsr __ladd
	ldy #_g_scycles
	jsr __lreg2y
;     }
	bra L38
L37:
;     else                            // not time to flip yet
;     {
;         if (sc_get_driver())        // if pulse is still on...
	jsr _sc_get_driver
	cmpb #0
	beq L46
;         {
;             if (gTimerTicks > gPulseTarget) // pulse target reached?
	ldy #_gTimerTicks
	jsr __ly2reg
	ldy #_gPulseTarget
	jsr __ly2reg2
	jsr __lcmp
	ble L48
;             {
;                 sc_set_driver(0);   // turn off pulse
	ldd #0
	jsr _sc_set_driver
;             }
L48:
;         }
L46:
;     }
L38:
; }
L27:
	xgdx
	addd #6
	xgdx
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
; 
; void TimerSleep(long msec)
; {
;     long target;
; 
;     target = gTimerTicks + (msec / 10);
	ldd 0,x
	addd #10
	xgdy
	jsr __ly2reg
	ldy #L39
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
L51:
L52:
; 
;     while(target > gTimerTicks);
	ldd 0,x
	addd #2
	xgdy
	jsr __ly2reg
	ldy #_gTimerTicks
	jsr __ly2reg2
	jsr __lcmp
	bgt L51
; }
L50:
	xgdx
	addd #6
	xgdx
	txs
	pulx
	.dbline 0 ; func end
	rts
__HC11Setup::
; 
; 
; #define DUMMY_ENTRY	(void (*)())0xFFFF
; 
; void _HC11Setup(void)
; {
;     CONFIG = 0x05;
	ldab #5
	stab 0x103f
; }
L54:
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
_old_buttons::
	.blkb 1
_new_buttons::
	.blkb 1
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
L40:
	.word 0,90
L39:
	.word 0,10
L36:
	.word 0,1
L29:
	.word 0,1
L18:
	.byte 'o,'d,'o,'m,'e,'t,'e,'r,61,37,48,55,'l,'d,0
L17:
	.byte 'e,'t,61,37,48,50,'d,58,37,48,50,'d,58,37,48,50
	.byte 'd,0
L16:
	.byte 'o,'n,61,37,'d,32,'m,'s,32,'o,'f,'f,61,37,'d,32
	.byte 'm,'s,0
L15:
	.byte 45,45,45,45,45,32,'C,'y,'c,'l,'i,'n,'g,32,45,45
	.byte 45,45,45,45,0
L14:
	.word 0,50
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
