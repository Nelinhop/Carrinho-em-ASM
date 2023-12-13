#include <P16F877A.INC> 	; Arquivo de include do uC usado, no caso PIC16F877A

; Palavra de configura??o, desabilita e habilita algumas op??es internas
  __CONFIG  _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC

  
;***** defini??o de Vari?veis  *****************************
;cria vari?veis para o programa

  	cblock 0x20
		tempo0		
		tempo1			; Vari?veis usadas na rotina de delay.
		tempo2
		filtro
        					
	endc 
	
	
 ;******** Vetor de Reset do uC**************
 org 0x00		      ; Vetor de reset do uC.
 goto inicio		  ; Desvia para o inicio do programa.

;*************** Rotinas e Sub-Rotinas *****************************************
; Rotina de delay (De 1ms at? 256 ms)
delay_ms:
	    movlw   .5	    ; vai carrega tempo2 com constante  
	    movwf   tempo2	; carrega tempo2   
denovo2:movlw	.250	; vai carrega tempo1 com constante
	    movwf	tempo1	; Carrega tempo1 
denovo:	movlw	.250    ; vai carregar tempo0 com constante
	    movwf	tempo0	; Carrega tempo0 
volta:	nop			    ; gasta 1 ciclo de m?quina(1us para clock 4Mhz)
	    decfsz	tempo0,F; Fim de tempo0 ? (gasta 2 us)
	    goto	volta	; N?o - Volta (gasta 1us)
				        ; Sim - Passou-se 1ms. (4us x 250 = 1ms)
    	decfsz	tempo1,F; Fim de tempo1?
	    goto	denovo	; N?o - Volta 
				        ; Sim. 250 x 1ms = 250ms	
	    decfsz	tempo2,F; Fim de tempo2?
	    goto	denovo2	; N?o - Volta 
				        ; Sim. 4 x 250 = 1s				
 return   		    	; Retorna.

;****************** Inicio do programa *****************************************
inicio:
	clrf	PORTD
	clrf	PORTB		; Inicializa o Port B com zero

	banksel	TRISA		; Seleciona banco de mem?ria 1
	
	movlw	0xff
	movwf	TRISB		; Configura PortB como entrada
	
	movlw	0x00
	movwf	TRISD		; Configura PortD como saida
	
	movlw	0x00	    
	movwf	OPTION_REG	; Configura Op??es:
				; Pull-Up habilitados.
				; Interrup??o na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.
	banksel PORTA		; Seleciona banco de mem?ria 0.

;*********************** Loop principal ****************************************
loopstart: ;testa o bot o
    btfsc PORTB,0 ;se bot o apertado vai para mright
    goto loopstart
mright: ;motor come a a andar para a direita
    bsf PORTD,1 ;liga o motor para a direita
    btfsc PORTB,2 ;se sensor ativo vai para weight se n o continua ligado o motor
    goto mright
weight: ;ativa a comporta e espera a balan a
    bcf PORTD,1  ;desliga o motor para direita
    bsf PORTD,0  ;abre a comporta 
    btfsc PORTB,3 ;testa a balan a se ativada avan a se n o continua com comporta aberta
    goto weight
    call delay_ms ;chama rotina de 5 segundos de delay
    bcf PORTD,0 ;fecha comporta 
mleft:
    bsf PORTD,2 ;liga motor para a esquerda
    btfsc PORTB,1 ;testa se sensor ativo se n o motor continua ligado se n o desliga motor e volta ao inicio
    goto mleft
backstart:
    bcf PORTD,2 ;desliga motor
    goto loopstart ;volta ao inicio
    
    end		
