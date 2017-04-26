distance_interrupt:
	
	; R21:R20 indeholder antal motorticks, kan evt. flyttes til SRAM for at frigøre R21:R20
	ADIW	R21:R20,1		; Antal ticks = Antal ticks + 1

	;-----------;
    ; HASTIGHED ;
    ;-----------;
    ; Hastighed = (afstand pr. tick) / (cycles * tid pr. cycle * prescaler)
    IN	R17, 165 ; Load 165 (som er 1,055 cm /(62,5 ns * 1024 prescaler) = 164,8)  ind i highbyte på tæller
	LDI R18, TCNT0 ; Load timerværdien ind i lowbyte på nævner
				; timerværdi er fra 109.9 cycles (ved v = 1.5 m/s) til 32.9 cycles (ved v = 5 m/s) prescaler = 1024
	
	RCALL div16u ; Resultatet lagres i dres16uH:dres16uL (R17:R16)
	
	LSR R17 ; Ryk resultatet ned i R16 som et 3Q5 tal
	ROR R16
	LSR R17
	ROR R16
	LSR R17
	ROR R16
	; Nu er resultatet i R16

    ;--------------;
    ; BREMSELÆNGDE ;
    ;--------------;
    
	; Load max-hastighed ind i R17
	LDI R17, 0b010,01000 ; 2,25 m/s i 3Q5 format
	    
	; Beregn bremselængde ud fra formel om konstant acceleration
	; (v_slut^2 – v_0^2) / 2 * a = s
	; a sættes til -4, for nemmere division
	; For at undgå negative tal beregnes:
	; (v_0^2 – v_slut^2) / 8

	MUL R16, R16 ; Husk at det er i 3Q5 format, så det bliver 6Q10 format i R1:R0
	MOVW R3:R2, R1:R0
	MUL R17, R17
	SUB R2, R0 ; Træk lowbytes fra hinanden
	SBC R3, R1 ; Træk highbytes fra hinanden med carry
	
	
	;Shift tallet 5 gange til højre (for at få et 3Q5 tal igen)
	LSR R3
	ROR R2
	LSR R3
	ROR R2
	LSR R3
	ROR R2
	LSR R3
	ROR R2
	LSR R3
	ROR R2 ; Nu er 3Q5 tallet i R2
	
	; Divider med 8 ved at shifte til højre 3 gange
	LSR R2
	LSR R2
	LSR R2
	
	; Nu haves afstanden i meter som et 3Q5 tal. Gang det med 1/0,01055 = 94,78 = 95 (ticks pr. meter)
	LDI R16, 95
	MUL R16, R2
	
	; Shift til højre 5 gange for at slippe af med kommaerne
	LSR R1
	ROR R0
	LSR R1
	ROR R0
	LSR R1
	ROR R0
	LSR R1
	ROR R0
	LSR R1
	ROR R0
	
	; Nu haves bremselængden i antal ticks i R1:R0. Hvis bremselængden er større end antallet af ticks 	
    ; til næste sving. BREMS!
	LDS R16, 0x60 ; Et sted i hukommelsen hvor tick antallet ved sving-indgang er lagret, low byte
	LDS R17, 0x61 ; high byte (tick antallet ved indgang til sving)
    SUB R16, R20 ; Trækker nuværende antal motorticks fra antallet ved sving-indgang (low byte)
	SBC R17, R21 ; Trækker nuværende antal motorticks fra antallet ved sving-indgang (high byte)
	;Sammenligner antallet ticks vi nu er fra svinget og antal ticks i bremselængden
	SUB R16, R0 ; Trækker afstand til indgangs til sving fra bremselængde (low byte)
	SBC R17, R1 ; Trækker afstand til indgangs til sving fra bremselængde (high byte)
	BRLO brake ; Hvis R17:R16 er lavere end R1:R0, så er det tid til at bremse!
	accelerate:	
		LDI R16, 0xFF
		OUT OCR2, R16
		RETI

	brake:
		LDI R16, 0x00
		OUT OCR2, R16
		RETI
