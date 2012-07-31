//===========================================================================
//
//      File:       LIB_EEPROM.H
//
//      Purpose:    EEPROM Function Prototypes
//
//      Version:    1.00
//
//      Date:       2012-06-19
//
//      Author:     Corey Davyduke
//
//      Compiler:   ImageCraft C
//
//---------------------------------------------------------------------------
//
//      History:    1.00    2012-06-19    Genesis
//
//---------------------------------------------------------------------------
//
//      Definition Example
//
//      #define EEBASE    0xb600
//      #define ee_test   *(unsigned long *)(EEBASE+0)
//
//===========================================================================

#define EEBYTE  0x10
#define EEERASE 0x04
#define EELAT   0x02
#define EEPGM   0x01

void EEWriteInt(int *, int);
void EEWriteLong(unsigned long *, unsigned long);
void EEWrite(unsigned char *, unsigned char);

