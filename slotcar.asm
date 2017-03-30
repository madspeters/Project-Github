.INCLUDE "m32Adef.inc"
.EQU F_CPU = 16000000

;-------------------;
;  PIN DEFINITIONS  ;
;-------------------;
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

.EQU MOTOR_DDR = DDRD
.EQU MOTOR_PIN = PIND
.EQU MOTOR_PORT = PORTD
.EQU MOTOR = PIND7

.MACRO SSP
	LDI @0, low(@1)
	OUT SPL, @0
	LDI @0, high(@1)
	OUT SPH, @0
.ENDMACRO


;-------------------;
;   VECTOR TABLE    ;
;-------------------;
.ORG 0x00
RJMP setup ; Reset

.ORG 0x2A

;-------------------;
;	SETUP       ;
;-------------------;
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
	
	; Set MOTOR as output and low
	SBI MOTOR_DDR, MOTOR
	CBI MOTOR_PORT, MOTOR
	
	; Set up PWM on OC2
	;-------------------------------------------------------;
	; Bits of the timer/counter control register (TCCR): 	;
	; FOC2 WGM20 COM21 COM20 WGM21 CS22 CS21 CS20			;
	;  7     6     5     4     3     2    1    0			;
	;-------------------------------------------------------;
	; Prescaler set for 1 MHz clock (= 64), giving 15 kHz PWM
	; Set CS22:CS21:CS20 to 1:1:1 when at 16MHz for 1024 prescaler
	LDI R16, 0b01101100 ; Timer/Counter register
	OUT TCCR2, R16
	LDI R16, 90 ; Output compare register (duty cycle = 35%)
	OUT OCR2, R16
	
	RJMP main


;-------------------;
;     MAIN LOOP	    ;
;-------------------;
main:
	; Read FINISH_LINE sensor and if low (finish line detected), set RED_LED high
	SBIS FINISH_LINE_PIN, FINISH_LINE ; Skip next instruction if bit is clear (low)
	SBI RED_LED_PORT, RED_LED
	
	SBIC FINISH_LINE_PIN, FINISH_LINE ; Skip next instruction if bit is set (high)
	CBI RED_LED_PORT, RED_LED
	
	; Read DISTANCE sensor and if low (active), set GREEN_LED high
	SBIS DISTANCE_PIN, DISTANCE ; Skip next instruction if bit is clear (low)
	SBI GREEN_LED_PORT, GREEN_LED
	
	SBIC DISTANCE_PIN, DISTANCE ; Skip next instruction if bit is clear (low)
	CBI GREEN_LED_PORT, GREEN_LED
	
	RJMP main
	
	
;-------------------;
; DELAY SUB-ROUTINE ;
;-------------------;
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
