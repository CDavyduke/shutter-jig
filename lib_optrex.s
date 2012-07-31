	.module lib_optrex.c
	.area text
_OptrexInit::
;  
; //===========================================================================
; //
; //      File:       OPTREX_LIB.C
; //
; //      Purpose:    Axiom 68HC11 LCD Routines for Optrex Displays
; //
; //      Version:    1.20
; //
; //      Date:       March 13, 2001
; //
; //      Author:     Wayne Mah
; //
; //      Compiler:   ImageCraft C
; //
; //---------------------------------------------------------------------------
; //
; //      History:    0.90    99/01/31    Genesis
; //                  1.00    00/12/10    Update
; //                  1.10    01/02/17    Update
; //                  1.11    01/03/11    Renamed to OPTREX_LIB.C
; //                  1.20    01/03/12    Update
; //
; //===========================================================================
; 
; #include <stdio.h>
; #include <lib_optrex.h>
; 
; //----------------------------------------------
; //  LCD is memory mapped on the CMD/CMM boards
; //----------------------------------------------
; 
; #define OPTREX_CMDREG  *(unsigned char volatile *)(0xB5F0)
; #define OPTREX_DATAREG *(unsigned char volatile *)(0xB5F1)
; 
; 
; //---------------
; //  local globs
; //---------------
; 
; unsigned char g_dispmode;
; 
; 
; //-----------------------------
; //  Local Function Prototypes
; //-----------------------------
; 
; void OptrexBusy(void);
; 
; 
; 
; //---------------------------------------------------------------------------
; //  LCD Initialization
; //---------------------------------------------------------------------------
; 
; void OptrexInit(void)
; {
;     g_dispmode = 0x0c;
	ldab #12
	stab _g_dispmode
; 
;     OptrexCommand(0x3C);                   // initialize command
	ldd #60
	jsr _OptrexCommand
;     OptrexCommand(g_dispmode);             // display on, cursor off
	ldab _g_dispmode
	clra
	jsr _OptrexCommand
;     OptrexCommand(0x06);
	ldd #6
	jsr _OptrexCommand
; 
;     OptrexClear();
	jsr _OptrexClear
; }
L1:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;          ?temp -> +2,x
;           sptr -> +6,x
_OptrexWriteString::
	jsr __enterb
	.byte 0x44
; 
; 
; void OptrexWriteString(char *sptr)
; {
	bra L4
L3:
	ldd 6,x
	std 2,x
	addd #1
	std 6,x
	ldy 2,x
	ldab 0,y
	clra
	jsr _OptrexWrite
L4:
; 	while(*sptr)
	ldy 6,x
	tst 0,y
	bne L3
; 		OptrexWrite(*sptr++);
; }
L2:
	inx
	inx
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
_OptrexClear::
; 
; 
; 
; //-----------------------------------------------------------------------
; //
; //  OptrexClear()
; //
; //  Writes the space code 0x20 into all addresses of DDRAM.  Returns
; //  display to its original position if it was shifted.  In other words,
; //  the display clears and the cursor or blink moves to the upper left
; //  edge of the display.  The execution of clear display set entry mode
; //  to incremental mode.
; //
; //-----------------------------------------------------------------------
; 
; void OptrexClear(void)
; {
;     OptrexCommand(0x01);
	ldd #1
	jsr _OptrexCommand
; }
L6:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;     start_addr -> +3,x
;       end_addr -> +4,x
;              i -> +5,x
_OptrexClearEOL::
	jsr __enterb
	.byte 0x6
; 
; void OptrexClearEOL(void)
; {
;     unsigned char start_addr, end_addr, i;
; 
;     start_addr = OptrexGetAddress();
	jsr _OptrexGetAddress
	stab 3,x
; 
;     if (start_addr >= 0x00 && start_addr <= 0x13)
	tst 3,x
	blo L8
	ldab 3,x
	cmpb #19
	bhi L8
;     {
;         end_addr = 0x13;
	ldab #19
	stab 4,x
;     }
	bra L9
L8:
;     else if (start_addr >= 0x40 && start_addr <= 0x53)
	ldab 3,x
	cmpb #64
	blo L10
	ldab 3,x
	cmpb #83
	bhi L10
;     {
;         end_addr = 0x53;
	ldab #83
	stab 4,x
;     }
	bra L11
L10:
;     else if (start_addr >= 0x14 && start_addr <= 0x27)
	ldab 3,x
	cmpb #20
	blo L12
	ldab 3,x
	cmpb #39
	bhi L12
;     {
;         end_addr = 0x27;
	ldab #39
	stab 4,x
;     }
L12:
L11:
L9:
;     if (start_addr >= 0x54 && start_addr <= 0x67)
	ldab 3,x
	cmpb #84
	blo L14
	ldab 3,x
	cmpb #103
	bhi L14
;     {
;         end_addr = 0x67;
	ldab #103
	stab 4,x
;     }
L14:
; 
;     for (i = start_addr; i <= end_addr; i++)
	ldab 3,x
	stab 5,x
	bra L19
L16:
	ldd #32
	jsr _OptrexWrite
L17:
	ldab 5,x
	addb #1
	stab 5,x
L19:
	ldab 5,x
	cmpb 4,x
	bls L16
;     {
;         OptrexWrite(' ');
;     }
; 
;     OptrexSetAddress(start_addr);
	ldab 3,x
	clra
	jsr _OptrexSetAddress
; }
L7:
	xgdx
	addd #6
	xgdx
	txs
	pulx
	.dbline 0 ; func end
	rts
_OptrexHome::
; 
; 
; 
; 
; //-----------------------------------------------------------------------
; //
; //  OptrexHome()
; //
; //  Set the DDRAM address "0" in address counter.  Return display to its
; //  original position if it was shifted.  DDRAM contents do not change.
; //
; //  The cursor or the blink moves to teh upper left edge of the display.
; //  Text on the display remains unchanged.
; //
; //-----------------------------------------------------------------------
; 
; void OptrexHome(void)
; {
;     OptrexCommand(0x02);
	ldd #2
	jsr _OptrexCommand
; }
L20:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;           mode -> +5,x
_OptrexEntryMode::
	pshb
	psha
	pshx
	pshx
	tsx
	stx 0,x
; 
; 
; //-----------------------------------------------------------------------
; //
; //  OptrexEntryMode()
; //
; //  Sets the INC/DEC and shift modes to the desired settings.
; //
; //  Bit 1 = 1 increments, Bit1 = 0 decrements the DDRAM address by 1
; //  when a character code is written into or read from the DDRAM
; //
; //-----------------------------------------------------------------------
;  void OptrexEntryMode(char mode)
; {
;     OptrexCommand(0x04|(0x03&mode));
	ldab 5,x
	andb #3
	orab #4
	clra
	jsr _OptrexCommand
; }
L21:
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;  rMEM -> 2,x
;            val -> +7,x
_OptrexSetBlink::
	jsr __enterb
	.byte 0x44
; 
; 
; void OptrexSetBlink(char val)
; {
;     OptrexSetDisplayControl((g_dispmode & ~0x01) | (val & 1));
	ldab 7,x
	andb #1
	stab 2,x
	ldab _g_dispmode
	andb #-2
	orab 2,x
	clra
	jsr _OptrexSetDisplayControl
; }
L22:
	inx
	inx
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;  rMEM -> 2,x
;            val -> +7,x
_OptrexSetCursor::
	jsr __enterb
	.byte 0x44
; 
; void OptrexSetCursor(char val)
; {
;     OptrexSetDisplayControl((g_dispmode & ~0x02) | ((val & 1) << 1));
	ldab 7,x
	andb #1
	lslb
	stab 2,x
	ldab _g_dispmode
	andb #-3
	orab 2,x
	clra
	jsr _OptrexSetDisplayControl
; }
L23:
	inx
	inx
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;  rMEM -> 2,x
;            val -> +7,x
_OptrexSetDisplay::
	jsr __enterb
	.byte 0x44
; 
; void OptrexSetDisplay(char val)
; {
;     OptrexSetDisplayControl((g_dispmode & ~0x04) | ((val & 1) << 2));
	ldab 7,x
	andb #1
	lslb
	lslb
	stab 2,x
	ldab _g_dispmode
	andb #-5
	orab 2,x
	clra
	jsr _OptrexSetDisplayControl
; }
L24:
	inx
	inx
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;            val -> +5,x
_OptrexSetDisplayControl::
	pshb
	psha
	pshx
	pshx
	tsx
	stx 0,x
; 
; void OptrexSetDisplayControl(char val)
; {
;     OptrexCommand(0x08|val);
	ldab 5,x
	orab #8
	clra
	jsr _OptrexCommand
;     
;     g_dispmode = val;
	ldab 5,x
	stab _g_dispmode
; }
L25:
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;           addr -> +5,x
_OptrexSetAddress::
	pshb
	psha
	pshx
	pshx
	tsx
	stx 0,x
; 
; void OptrexSetAddress(unsigned char addr)
; {
;     OptrexCommand(0x80|addr);              // set DDRAM address
	ldab 5,x
	orab #128
	clra
	jsr _OptrexCommand
; }
L26:
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
_OptrexGetAddress::
; 
; unsigned char OptrexGetAddress(void)
; {
;    return (OPTREX_CMDREG & 0x7f);
	; vol
	ldab 0xb5f0
	andb #127
	clra
L27:
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;           dval -> +5,x
_OptrexWrite::
	pshb
	psha
	pshx
	pshx
	tsx
	stx 0,x
; }
; 
; void OptrexWrite(char dval)
; {
;     OptrexBusy();                          // wait for busy to clear
	jsr _OptrexBusy
;     OPTREX_DATAREG = dval;                 // ouptut data
	ldab 5,x
	stab 0xb5f1
; }
L28:
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;          ?temp -> +3,x
;           addr -> +5,x
;              y -> +13,x
;              x -> +9,x
_OptrexGotoXY::
	jsr __enterb
	.byte 0x46
; 
; 
; void OptrexGotoXY(char x, char y)
; {
;     char addr;
; 
;     switch (y)
	ldab 13,x
	clra
	std 3,x
	beq L33
	ldd 3,x
	cpd #1
	beq L34
	ldd 3,x
	cpd #2
	beq L35
	ldd 3,x
	cpd #3
	beq L36
	bra L30
X0:
;     {
L33:
;         case 0 : addr = 0x00; break;
	clr 5,x
	bra L31
L34:
;         case 1 : addr = 0x40; break;
	ldab #64
	stab 5,x
	bra L31
L35:
;         case 2 : addr = 0x14; break;
	ldab #20
	stab 5,x
	bra L31
L36:
;         case 3 : addr = 0x54; break;
	ldab #84
	stab 5,x
L30:
L31:
;     }
; 
;     addr += x;
	ldab 5,x
	addb 9,x
	stab 5,x
; 
;     OptrexSetAddress(addr);
	ldab 5,x
	clra
	jsr _OptrexSetAddress
; }
L29:
	xgdx
	addd #6
	xgdx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
;  IX -> 0,x
;           cval -> +5,x
_OptrexCommand::
	pshb
	psha
	pshx
	pshx
	tsx
	stx 0,x
; 
; 
; void OptrexCommand(unsigned char cval)
; {
;     OptrexBusy();                          // wait for busy to clear
	jsr _OptrexBusy
;     OPTREX_CMDREG = cval;                  // output command
	ldab 5,x
	stab 0xb5f0
; }
L37:
	inx
	inx
	txs
	pulx
	puly
	.dbline 0 ; func end
	rts
_OptrexBusy::
; 
; 
; //
; //               ***************************************
; //               *   local functions after this point  *
; //               ***************************************
; //
; 
; 
; //---------------------------------------------------------------------------
; //  Wait for the LCD busy pin to clear
; //---------------------------------------------------------------------------
; 
; void OptrexBusy(void)
; {
L39:
L40:
;     while (OPTREX_CMDREG & 0x80);
	ldy #0xb5f0
	brclr 0,y,#128,X1
	bra L39
X1:
; }
L38:
	.dbline 0 ; func end
	rts
	.area bss
_g_dispmode::
	.blkb 1
