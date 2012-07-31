//===========================================================================
//
//      File:       LIB_ADC.H
//
//      Purpose:    ADC Function Prototypes
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
//      History:    1.00   2012-06-19    Genesis
//
//===========================================================================


//#include <hc11.h>

#define ADPU 0x80
#define MULT 0x10
#define CCF  0x80

void ADCInit(void);
void ADCTrigger(void);

