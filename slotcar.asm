.INCLUDE "m32Adef.inc"
.EQU F_CPU = 16000000


; Setting up "variables"
.EQU RED_LED_DDR = DDRB
.EQU RED_LED_PORT = PORTB
.EQU RED_LED = PINB1

.EQU GREEN_LED_DDR = DDRB
.EQU GREEN_LED_PORT = PORTB
.EQU GREEN_LED = PINB2

.EQU STRAIN_GAUGE_DDR = DDRA
.EQU STRAIN_GAUGE_PIN = PINA
.EQU STRAIN_GAUGE_PORT = PORTA
.EQU STRAIN_GAUGE = PINA0

.EQU FINISH_LINE_DDR = DDRD
.EQU FINISH_LINE_PIN = PIND
.EQU FINISH_LINE_PORT = PORTD
.EQU FINISH_LINE = PIND3

.EQU DISTANCE_DDR = DDRD
.EQU DISTANCE_PIN = PIND
.EQU DISTANCE_PORT = PORTD
.EQU DISTANCE = PIND2

.MACRO SSP
	LDI @0, low(@1)
	OUT SPL, @0
	LDI @0, high(@1)
	OUT SPH, @0
.ENDMACRO

.ORG 0x00
RJMP setup ; On reset

.ORG 0x2A
setup:
	SSP R16, RAMEND
	
	; Set RED_LED as output and low
	SBI RED_LED_DDR, RED_LED
	CBI RED_LED_PORT, RED_LED
	
	; Set GREEN_LED as output and low
	SBI GREEN_LED_DDR, GREEN_LED
	CBI GREEN_LED_PORT, GREEN_LED
	
	; Set FINISH_LINE as input without internal pull-up
	CBI FINISH_LINE_DDR, FINISH_LINE
	CBI FINISH_LINE_PORT, FINISH_LINE
	
	; Set DISTANCE as input without internal pull-up
	CBI DISTANCE_DDR, DISTANCE
	CBI DISTANCE_PORT, DISTANCE
	
	; Set STRAIN_GAUGE as input without internal pull_up
	CBI STRAIN_GAUGE_DDR, STRAIN_GAUGE
	CBI STRAIN_GAUGE_PORT, STRAIN_GAUGE
	
	RJMP main
	
main:
	; Read FINISH_LINE sensor and if high, set RED_LED high
	;SBIC FINISH_LINE_PIN, FINISH_LINE ; Skip next instruction if bit is clear (low)
	;SBI RED_LED_PORT, RED_LED
	
	;SBIS FINISH_LINE_PIN, FINISH_LINE ; Skip next instruction if bit is set (high)
	;CBI RED_LED_PORT, RED_LED
	
	; Read DISTANCE sensor and if high, set GREEN_LED high
	;SBIC DISTANCE_PIN, DISTANCE ; Skip next instruction if bit is clear (low)
	;SBI GREEN_LED_PORT, GREEN_LED
	
	;SBIC DISTANCE_PIN, DISTANCE ; Skip next instruction if bit is clear (low)
	;CBI GREEN_LED_PORT, GREEN_LED
	
	SBI GREEN_LED_PORT, GREEN_LED
	CBI RED_LED_PORT, RED_LED
	
	RCALL delay_1sec
	
	CBI GREEN_LED_PORT, GREEN_LED
	SBI RED_LED_PORT, RED_LED
	
	RCALL delay_1sec
	
	RJMP main
	
	
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
