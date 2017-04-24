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
.EQU GREEN_LED = PINB2 ; Move this to PINB3 (OC0) for timer interrupt

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

.EQU DEFAULT_MOTORSPEED = 125

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

;.org 0x16 ; TIMER0 overflow interrupt
;RJMP timer0_overflow

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
	
	LDI R31, low(0)
	LDI R30, high(0)

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
	CPI R5, 0
	BREQ main
	
	IN R17, ADCH
	RCALL TRANSMIT
    
    LDI R24, low(250)
	LDI R25, high(250)
    wait_loop: ; Vent 1 ms	
		SBIW R25:R24, 1
		BRNE wait_loop
	
	RJMP main
    
    ; Jespers bluetooth kode -------------------------------------------
	;RCALL Receive				;Modtag Byte1
	;CPI R17, 0x55
	;BREQ set1					;Branch hvis det var en SET kommand
	;CPI R17, 0xAA
	;BREQ get1					;Branch hvis det er en GET kommand
	;RJMP main					;Loop hvis det var en fejl eller intet er modtaget

    set1: ;SET----------------------------------------------------------
        RCALL Receive
        CPI R17, 0x10
        BREQ set1_hastighed2		;Branch hvis det er en set1_hastighed2 kommand
        CPI R17, 0x11
        BREQ set1_stop2
        CPI R17, 0x12
        BREQ set1_auto2
        RJMP set1					;Loop hvis intet er modtaget

    get1: ;-------------------------------------------------------------
        
        RJMP main
    
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
	;RET
	IN	R17, UDR
	RET
    
Transmit:
    SBIS UCSRA, UDRE	;Is UDR empty?
    RJMP Transmit		;if not, wait some more
    OUT  UDR, R17		;Send R17 to UDR
    RET
    
set1_hastighed2:
	RCALL Receive
	MOV R2, R17
	OUT OCR2, R2

	RJMP main

set1_stop2:
	RCALL Receive
	LDI R17, 0
	MOV R3, R17
	
	OUT OCR2, R3
	
	RJMP main
	
set1_auto2:
	RCALL Receive
	LDI R17, 120
	MOV R4, R17
	
	OUT OCR2, R4
	
	RJMP main

;----------------------------;
; INTERRUPT SERVICE ROUTINES ;
;----------------------------;
distance_interrupt:
	ADIW R30, 1 ; Tæl op på tick counter wordet
    ; Toggle green LED on any logical change
    
    SBIS GREEN_LED_PORT, GREEN_LED ; If bit is clear, go to turn_on_green
    RJMP turn_on_green
    
    CBI GREEN_LED_PORT, GREEN_LED ; If bit is set, clear it and return
    RETI
    
    turn_on_green:
        SBI GREEN_LED_PORT, GREEN_LED ; Set bit
    
    
    RETI
    
finish_line_interrupt:
    ; Stop motor and turn on the red LED for 1 sec
    PUSH R16
    PUSH R17
    
    IN R17, OCR2
    
    ;LDI R16, 0
    ;OUT OCR2, R16
    
    SBI RED_LED_PORT, RED_LED
    
    ;RCALL delay_1sec
    
    ;CBI RED_LED_PORT, RED_LED
    
    ;LDI R16, 2 ; Increase motor speed by 2
    ;ADD R16, R17
    ;OUT OCR2, R16

	; Send number of motor ticks via bluetooth
    ;MOV R17, R31
    ;RCALL TRANSMIT
    ;MOV R17, R30
    ;RCALL TRANSMIT
    
    ; Reset tick counter
    LDI R31, low(0)
    LDI R30, high(0)
    
    
    ; Set logger active
    MOV R16, R5
    CPI R16, 1
    BREQ set_zero
    LDI R16, 1
    MOV R5, R16
    
	set_zero:
		LDI R16, 0
		MOV R5, R16
    
    
    POP R17
    POP R16
    
       
    RETI

