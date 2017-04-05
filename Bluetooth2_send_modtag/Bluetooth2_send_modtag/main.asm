.include "m32adef.inc" ; The ATMEGA32A Microcontroller
.org 0x0000 ; Program execution is started at address: 0

rjmp Reset
.org 0x002A
Reset:	 ldi R16,HIGH(RAMEND) ; Stack setup
		 out SPH,R16 ; Load SPH
		 ldi R16,LOW(RAMEND) ;
		 out SPL,R16 ; Load SPL
		 
		 LDI R16, 0xFF
		 OUT DDRB, R16
		 LDI R16, 0x00
		 OUT DDRC, R16
		 LDI R16, 0xFF
		 OUT PORTC, R16

		 LDI R16, (1<<TXEN)|(1<<RXEN)
		 OUT UCSRB, R16
		 LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL)
		 OUT UCSRC, R16
		 ;LDI R16, 103		;16MHz Sætter baudrate til 9600, med U2X = 0 og error = 0,2%
		 LDI R16, 12		;1 MHz
		 OUT UBRRL, R16 
		 SBI UCSRA, U2X		;bruges til 1MHz baudrate

Main:	
		


		;DI R17, 'S'
		;SBIS PINC, 2
		;RCALL transmit
		RCALL delay_1sec
		RCALL recieve
		OUT PORTB, R17

		rjmp Main

Recieve:
		SBIS UCSRA, RXC
		ret 
		IN	R17, UDR
		RET

Transmit:
		SBIS UCSRA, UDRE	;Is UDR empty?
		RJMP Transmit		;if not, wait some more
		OUT  UDR, R17		;Send R17 to UDR
		RET

delay_1sec:
	LDI R23, 4 ;Load 61 into R23 (16 MHz = 61 loops, 1 MHz = 4 loops)
	outer_loop: 
		LDI R24, low(65535) ;Clear R24 and R25 to use for a 16-bit word
		LDI R25, high(65535)
		inner_loop: ; 4 instructions per loop if no overflow
			SBIW R25:R24, 1 ;Subtract 1 from 16-bit word in R25:R24
			BRNE inner_loop ;Unless R25:R24 overflows, go back to inner_loop
	
	DEC R23 ;Decrement R23
	BRNE outer_loop ;Unless R23 overflows go back to outer_loop
RET

