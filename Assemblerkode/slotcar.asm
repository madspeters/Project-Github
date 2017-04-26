.INCLUDE "m32Adef.inc"
.EQU F_CPU = 1000000 ; 1 MHz, change this when fuse bits have been set

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

.EQU DEFAULT_MOTORSPEED = 90

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
RJMP reset

.ORG 0x02
RJMP distance_interrupt ; (INT0, PD2)

.ORG 0x04
RJMP finish_line_interrupt ; (INT1, PD3)
;-------------------;
;       SETUP	    ;
;-------------------;
.ORG 0x2A
reset:
	SSP R16, RAMEND ; Set stack pointer
	
    ;--------------;
    ; Input/Output ;
    ;--------------;
    
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
	
	; Set MOTOR PWM as output and low
	SBI MOTOR_DDR, MOTOR
	CBI MOTOR_PORT, MOTOR
	
	;-----;
    ; PWM ;
    ;-----;
    
    ; Set up PWM on OC2
	; No prescaler (PWM frequency = 1 MHz / 256 = 3900 Hz)
    ; Change prescaler when fuse bits for 16 MHz clock has been set!
	LDI R16, 0b01101001 ; (1<<WGM20)|(1<<COM21)|(1<<WGM21)|(1<<CS20)
	OUT TCCR2, R16
	
	; Set motor speed
	LDI R16, DEFAULT_MOTORSPEED
	OUT OCR2, R16 ; Output compare register - OC2 pin is set LOW when
                  ; the value in OCR2 matches the value in the
                  ; timer/counter register (TCNT2)
    
	;------------;
    ; INTERRUPTS ;
    ;------------;
    
    ; Enable interrupts
	LDI R16, (1<<INT0)|(1<<INT1) ; Enable INT0 and INT1
	OUT GICR, R16
	LDI R16, (1<<ISC01)|(1<<ISC11) ; Set INT0 and INT1 to trigger on falling edge
	OUT MCUCR, R16
	SEI ; Enable global interrupts

	;--------------------;
    ; SRAM START POINTER ;
    ;--------------------;
    
    LDI ZL, low(SRAM_START)  ; SRAM_START er addresse 0x60. ZL og ZH er
    LDI ZH, high(SRAM_START) ; hhv. R30 og R31, som tilsammen udgør et
                             ; særligt 16-bit pointer register
                             ; http://www.avr-asm-tutorial.net/avr_en/beginner/REGISTER.html
    ;-----------;              
    ; BLUETOOTH ;
    ;-----------;
	LDI R16, (1<<TXEN)|(1<<RXEN) ; Enable transmit/receive
	OUT UCSRB, R16
	LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL) ; Set character size = 8 bits
	OUT UCSRC, R16
	;LDI R16, 103		;16MHz Sætter baudrate til 9600, med U2X = 0 og error = 0,2%
	LDI R16, 12		;1 MHz
	OUT UBRRL, R16 
	SBI UCSRA, U2X		;bruges til 1MHz baudrate



		;------------;
	; Set up ADC ;
	;------------;
	;--------------------------------------------;
	; REFS1 REFS0 ADLAR MUX4 MUX3 MUX2 MUX1 MUX0 ;
    ;   7     6     5    4    3    2    1    0   ;
    ;--------------------------------------------;
	LDI R16, 0b00100000 ; AREF, left adjusted, ADC0, 
						; 0b11100000 to use 2.56V reference (MÅ KUN
						; BRUGES NÅR DER IKKE ER SPÆNDING PÅ AREF! Der
						; skal tilgengæld være en afkoblingskondensator
						; til GND)
	OUT ADMUX, R16
	
	;---------------------------------------------;
	; ADEN ADSC ADATE ADIF ADIE ADPS2 ADPS1 ADPS0 ;
	;  7    6     5    4    3     2     1     0   ;
	;---------------------------------------------;
	LDI R16, 0b11100011 ; Enable, start conversion, auto-trigger, prescaler = 8
	OUT ADCSRA, R16
	
	;-------------------;
	; ADTS2 ADTS1 ADTS0 ;
	;   7     6     5   ;
	;-------------------;
	LDI R16, 0b00000000 ; Set trigger-source to free running mode
	OUT SFIOR, R16



;-------------------;
;     MAIN LOOP	    ;
;-------------------;
main:
    
    ; Jespers bluetooth kode -------------------------------------------
	RCALL Receive				;Modtag Byte1
	CPI R17, 0x55
	BREQ set1					;Branch hvis det var en SET kommand
	CPI R17, 0xAA
	BREQ get1					;Branch hvis det er en GET kommand
	RJMP main					;Loop hvis det var en fejl eller intet er modtaget

    set1: ;SET----------------------------------------------------------
        RCALL Receive			;Modtag Byte2
        CPI R17, 0x10
        BREQ set1_hastighed2	;Branch hvis det er en set1_hastighed2 kommand
        CPI R17, 0x11
        BREQ set1_stop2			;Branch hvis det er en set1_stop2 kommand
        CPI R17, 0x12
        BREQ set1_auto2			;Branch hvis det er en set1_auto2 kommand
		CPI R17, 0x13
        BREQ set1_blink2		;Brand hvis det er en set1_blink2 kommand

        RJMP main				;Loop tilbage til main, hvis protokol var forkert

    get1: ;GET-------------------------------------------------------------
		RCALL Receive			;Modtag byte 2
		CPI R17, 0x02			
        BREQ get1_hastighed2	;Branch hvis det er en get1_hastighed2 kommand
		CPI R17, 0x03
        BREQ get1_position2		;Branch hvis det er en get1_position2 kommand
		CPI R17, 0x05
        BREQ get1_straingauge2	;Branch hvis det er en get1_straingauge2 kommand
		CPI R17, 0x06
        BREQ get1_positionssensor2;Branch hvis det er en get1_positionsensor2 kommand
		CPI R17, 0x07
        BREQ get1_maalstregssensor2;Branch hvis det er en get_1maalstregssensor2 kommand

        RJMP main				;Loop tilbage til main, hvis protokol var forkert
   
		;SET2-----------------------------------------------------------------------
		set1_hastighed2:
			RCALL Receive		;Modtag byte3
			MOV R2, R17			;Flyt modtaget byte over i R2
			OUT OCR2, R2		;Output R2 til OCR2
			RJMP main			;Loop tilbage til main

		set1_stop2:				;Se eksempel set1_hastighed2
			LDI R17, 0			
			MOV R2, R17
			OUT OCR2, R2
			RJMP main
		
		set1_auto2:				;Se eksempel set1_hastighed2
			LDI R17, 120		;Midlertidig værdi - denne værdi skal starte automode
			MOV R2, R17
			OUT OCR2, R2
			RJMP main

		set1_blink2:			;Se eksempel set1_hastighed2
			RCALL Receive		
			MOV R8, R17
			;Kode der sender R8 ud til en blink
			RJMP main ;der mangler kode til blink

		;GET2-----------------------------------------------------------------------

        get1_hastighed2:
		MOV R17, R2				;Flyt R2 (hastighed) over til R17 
		RCALL Transmit			;R17 sendes via bluetooth
		RJMP main				;Loop til main

        get1_position2:			;Se eksempel get1_position2
		MOV R17, R3
		RCALL Transmit
		MOV R17, R4
		RCALL transmit
		RJMP main

        get1_straingauge2:		;Se eksempel get1_position2
		MOV R17, R5
		RCALL Transmit
		RJMP main

        get1_positionssensor2:	;Se eksempel get1_position2
		MOV R17, R6
		RCALL Transmit
		RJMP main

        get1_maalstregssensor2:	
		MOV R17, R7
		RCALL Transmit
		RJMP main


;-------------------;
;   SUB-ROUTINES 	;
;-------------------;
delay_1sec:
	PUSH R23
    PUSH R24
    PUSH R25
    
    LDI R23, 4 ;Load 61 into R23 (16 MHz = 61 loops, 1 MHz = 4 loops)
	outer_loop: 
		LDI R24, low(65535) ;Clear R24 and R25 to use for a 16-bit word
		LDI R25, high(65535)
		inner_loop: ; 4 instructions per loop if no overflow
			SBIW R25:R24, 1 ;Subtract 1 from 16-bit word in R25:R24
			BRNE inner_loop ;Unless R25:R24 overflows, go back to inner_loop
	
	DEC R23 ;Decrement R23
	BRNE outer_loop ;Unless R23 overflows go back to outer_loop
    
    POP R25
    POP R24
    POP R23
    
	RET

Receive:
	SBIS UCSRA, RXC
	RJMP Receive
	IN	R17, UDR
	RET
    
Transmit:
    SBIS UCSRA, UDRE	;Is UDR empty?
    RJMP Transmit		;if not, wait some more
    OUT  UDR, R17		;Send R17 to UDR
    RET


;----------------------------;
; INTERRUPT SERVICE ROUTINES ;
;----------------------------;
distance_interrupt:
	PUSH R16
   	PUSH R17
	
	INC R4				;Incrementer position(LOW)
	SBRC SREG, 1		;Hvis zeroflag er = 1, så udføres næste linje
	INC R3				;Incrementer position(HIGH)

	IN R16, ADCH		;aflæs straingauge
	CPI R16, 0xF0		;Sammenlign med en konstant værdi - V_th
	BRSH detekt_sving			;BRSH - Branch if Same or Higher (Unsigned)
	
	POP R17
	POP R16
	RETI

detekt_sving:
	ldi R16, 0x00		;antal tikz som vi måler forkert
	LDI R17, 0x00		; R16:R17
	
	SUB R4, R17			;R3:R4 - R16:R17
	SBC	R3, R16

	st Z+, R3			;Gem position(HIGH) og incrementer pointer
	st Z+, R4			;Gem position(LOW)	og incrementer pointer
						;Pointeren vil allerede være incrementeret til vi får et nyt interrupt

	POP R17
	POP R16
    RETI
    
finish_line_interrupt:
	PUSH R16
    
	INC R9				;Incrementer antal omgange
	LDI R16, 0x00		
	MOV R3, R16			;Nulstil positionsensor(HIGH)
	MOV R4, R16			;Nulstil positionsensor(LOW)

	POP R16
    RETI
