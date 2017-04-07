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

.EQU default_motorspeed = 90

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

.ORG 0x02
RJMP distance_interrupt ; Interrupt on INT0 (PD2)

.ORG 0x04
RJMP finish_line_interrupt ; Interrupt on INT1 (PD3)

;-------------------;
;       SETUP	    ;
;-------------------;
.ORG 0x2A
setup:
	SSP R16, RAMEND ; Set stack pointer
	
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
	; FOC2 WGM20 COM21 COM20 WGM21 CS22 CS21 CS20		;
	;  7     6     5     4     3     2    1    0		;
	;-------------------------------------------------------;
	; No prescaler (PWM frequency = 1MHz / 256)
	LDI R16, 0b01101001 ; (1<<WGM20)|(1<<COM21)|(1<<WGM21)|(1<<CS20)
	OUT TCCR2, R16
	
	; Set motor speed
	LDI R17, default_motorspeed
	OUT OCR2, R17 ; R17 is also used in main loop for motor speed
	
	; Enable interrupts
	LDI R16, 0b10000000 ; (1<<INT1)|(1<<INT0)
                        ; Enable INT1 (finish line) and INT0 (distance)
	OUT GICR, R16
	LDI R16, 0b00000101 ; (1<<ISC00)|(1<<ISC10)
                        ; Set INT1 and INT0 to trigger on any logical change
	OUT MCUCR, R16
	SEI ; Enable global interrupts
	
	; Set up ADC
	;--------------------------------------------;
	; REFS1 REFS0 ADLAR MUX4 MUX3 MUX2 MUX1 MUX0 ;
    	;   7     6     5    4    3    2    1    0   ;
    	;--------------------------------------------;
	LDI R16, 0b00100000 ; (1<<ADLAR)
                        ; AREF, LEFT ADJUSTED (only 8 bit precision, read ADCH), ADC0
	OUT ADMUX, R16
	
	;---------------------------------------------;
	; ADEN ADSC ADATE ADIF ADIE ADPS2 ADPS1 ADPS0 ;
	;  7    6     5    4    3     2     1     0   ;
	;---------------------------------------------;
	LDI R16, 0b11100011 ; (1<<ADPS0)|(1<<ADPS1)|(1<<ADATE)|(1<<ADSC)|(1<<ADEN)
                        ; Enable, start conversion, auto-trigger, prescaler = 8
	OUT ADCSRA, R16
    
	;-------------------;
	; ADTS2 ADTS1 ADTS0 ;
	;   7     6     5   ;
	;-------------------;
	LDI R16, 0b00000000 ; Set trigger-source to free running mode
	OUT SFIOR, R16
	
	; BLUETOOTH
	LDI R16, (1<<TXEN)|(1<<RXEN)
	OUT UCSRB, R16
	LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL)
	OUT UCSRC, R16
	;LDI R16, 103		;16MHz Sætter baudrate til 9600, med U2X = 0 og error = 0,2%
	LDI R16, 12		;1 MHz
	OUT UBRRL, R16 
	SBI UCSRA, U2X		;bruges til 1MHz baudrate
    
	RJMP main

;-------------------;
;     MAIN LOOP	    ;
;-------------------;
main:
	; Set motor speed via bluetooth
	;RCALL Receive
	;OUT OCR2, R17
    
    ;RCALL read_adc
	
    IN R19, ADCH
    RCALL TRANSMIT
    
    RCALL delay_1sec
    
    ;SBIS DISTANCE_PIN, DISTANCE
    ;SBI GREEN_LED_PORT, GREEN_LED
    
    ;SBIC DISTANCE_PIN, DISTANCE
    ;CBI GREEN_LED_PORT, GREEN_LED
    
    ;RCALL read_adc
    
	RJMP main
	
;-------------------;
;    INTERRUPTS     ;
;-------------------;

finish_line_interrupt:
	; Ignore interrupt if sensor is high (leaving the finish line)
	SBIC FINISH_LINE_PIN, FINISH_LINE
	RETI
    
    PUSH R16
    PUSH R17
	
    IN R17, OCR2
    
	LDI R16, 0 ; Turn off motor
	OUT OCR2, R16
	
	SBI RED_LED_PORT, RED_LED ; Turn on red LED
	
	RCALL delay_1sec
    
    LDI R16, 10     ; Increase motor speed by 10
    ADD R17, R16
    LDI R17, 90
	OUT OCR2, R17
	
	CBI RED_LED_PORT, RED_LED ; Turn off red LED
	
    POP R17
    POP R16
    
	RETI

distance_interrupt:
	PUSH R16
	PUSH R17
    
	; Toggle green LED
    IN R16, GREEN_LED_PORT 
    LDI R17, (1 << GREEN_LED)
    EOR R16, R17
	OUT GREEN_LED_PORT, R16
	
    POP R17
	POP R16
	
	RETI

;-------------------;
;   SUB-ROUTINES 	;
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

Receive:
	SBIS UCSRA, RXC
	RET
	IN	R17, UDR
	RET
    
Transmit:
    SBIS UCSRA, UDRE	;Is UDR empty?
    RJMP Transmit		;if not, wait some more
    OUT  UDR, R19		;Send R17 to UDR
    RET

read_adc:
    ; Turn on green LED if value between 117 and 137 (for calibration)
    IN R19, ADCH
    
    ;send_adc:
    ;    SBIS UCSRA, UDRE
    ;    RJMP send_adc
    ;    OUT UDR, R19
    
    CPI R19, 130
    BRLO threshold1
    CBI GREEN_LED_PORT, GREEN_LED
    RET
    threshold1:
        CPI R19, 120
        BRSH turn_on_green
        CBI GREEN_LED_PORT, GREEN_LED
        RET
    turn_on_green:
        SBI GREEN_LED_PORT, GREEN_LED
        RET
