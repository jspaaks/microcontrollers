            list        P=PIC16F690
            #include    p16f690.inc ; include header file for selected device

onreset     code 0x0000
            goto init
	    
interrupts  code 0x0004
	    goto on_button_pressed
    
	    code 0x0005
init
	    ; clock related
	    banksel OSCCON          ; select bank containing OSCCON register
            bsf OSCCON, SCS         ; select the internal oscillator as the system clock
            bcf OSCCON, IRCF0       ; clearing these 3 bits sets the oscillator to its 
            bcf OSCCON, IRCF0       ; lowest frequency of 31kHz
            bcf OSCCON, IRCF0       ; 
	    
	    ; led related
	    banksel TRISC           ; select bank containing TRISC register
            bcf TRISC, TRISC7       ; set pin 7 of port C as an output pin
	    
	    ; button related
	    bsf TRISA, TRISA0       ; set pin 0 on port A as button press input
	    bsf IOCA, IOCA0         ; enable interrupts onchange
	    
	    ; interrupt related
	    banksel INTCON          ; select bank containing INTCON
	    bsf INTCON, GIE         ; enable interrupts globally 
	    bsf INTCON, PEIE        ; enable peripheral interrupts
	    bsf INTCON, RABIE       ; enable button press interrupts
	    bcf INTCON, RABIF       ; clear button pressed interrupt flag
	    
	    banksel PIE1            ; select bank containing PIE1 register
	    bsf PIE1, TMR2IE        ; enable interrupts by timer 2
	    
	    banksel PR2             ; select bank containing PR2 register
	    movlw 0x0A              ; set the value at which to generate a timer 2 interrupt
	    movwf PR2               ; set the value at which to generate a timer 2 interrupt (continued)
	    
	    banksel PIR1            ; select bank containing PIR1 register
	    bcf PIR1, TMR2IF        ; clear the timer 2 interrupt flag 
	    
	    ; timer related
	    banksel T2CON           ; select bank containing T2CON register
	    bsf T2CON, T2CKPS1      ; set timer 2 prescaler to 1:16
	    bsf T2CON, T2CKPS0      ; set timer 2 prescaler to 1:16 (continued)
	    bcf T2CON, TOUTPS3      ; set timer 2 postscaler to 1:1
	    bcf T2CON, TOUTPS2      ; set timer 2 postscaler to 1:1 (continued)
	    bcf T2CON, TOUTPS1      ; set timer 2 postscaler to 1:1 (continued)
	    bcf T2CON, TOUTPS0      ; set timer 2 postscaler to 1:1 (continued)
	    
	    goto main               ; continue at 'main' label

delay	    
	    bsf T2CON, TMR2ON       ; start incrementing timer 2
	    return
	    
flash
	    bsf PORTC, RC7          ; turn on led
	    call delay
            bcf PORTC, RC7          ; turn off led
	    call delay
	    return
	    
on_button_pressed
	    bcf INTCON, RABIE       ; disable button press interrupts
	    bcf INTCON, RABIF       ; clear button pressed interrupt flag 
	    call flash
	    bsf INTCON, RABIE       ; enable button press interrupts
	    return

main	    
	    ;goto $                  ; loop here, wait for an interrupt
	    nop
	    nop
	    bsf PORTA, RA0  ; artificially force interrupt
	    bcf PORTA, RA0  ; artificially force interrupt (continued)
	    nop
	    nop
	    
            end
   