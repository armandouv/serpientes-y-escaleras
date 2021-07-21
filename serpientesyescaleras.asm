* Declaración de constantes

TEMPORIZADOR EQU $100E

SCDR   EQU   $102F
SCCR2  EQU   $102D
SCSR   EQU   $102E
SCCR1  EQU   $102C
BAUD   EQU   $102B
HPRIO  EQU   $103C
SPCR   EQU   $1028
CSCTL  EQU   $105D
OPT2   EQU   $1038
DDRD   EQU   $1009


* Declaracion de variables

CASILLA_JUGADOR1 EQU $0000
CASILLA_JUGADOR2 EQU $0001
DADO1 EQU $0002
DADO2 EQU $0003
SUMA_DADOS EQU $0004
DIRACTUAL EQU $0005
DIRACTUAL1 EQU $0006
JUGADOR_ACTUAL EQU $0007
JUGADOR_ACTUAL_1 EQU $0008

ORDEN EQU $0009
U1    EQU $000A
U2    EQU $000B
U3    EQU $000C
U4    EQU $000D

CASILLA1_ASCII EQU $0010
CASILLA2_ASCII EQU $0014

DADO1_ASCII EQU $0020
DADO2_ASCII EQU $0024
SUMA_DADOS_ASCII EQU $0028


    ORG $8000
   
    
    
INICIO
    LDS #$00FF
    * Configurar puerto serial
    JSR SERIAL
    
    * Inicializar variables
    LDAA #$1
    STAA CASILLA_JUGADOR1
    STAA CASILLA_JUGADOR2
    CLR DADO1
    CLR DADO2
    CLR SUMA_DADOS
    CLR DIRACTUAL
    CLR DIRACTUAL1
    CLR JUGADOR_ACTUAL
    CLR JUGADOR_ACTUAL_1
    CLR U1
    CLR U2
    CLR U3
    CLR U4
    JSR INICIALIZAR_TABLERO
    
    JSR IMPRIMIR_CASILLAS
    JSR IMPRIMIR_DADOS
CICLATE
      LDAA #'?
      STAA ORDEN
CICLO
      LDAA ORDEN
      CMPA #'?
      BEQ  CICLO

      LDAB U1
      BNE  BRANCHES
BRANCHES
      CMPB #'D
      BEQ SIGUEA_DADOS
      JMP SIGUET
BORRA
      CLR U1
      CLR U2
      CLR U3
      CLR U4
      
      CMPA #'D
      BEQ VALIDA
      
      CMPA #'S
      BEQ VALIDA
      
      JMP CICLATE
VALIDA      
      STAA U1     * VALIDA S o D
      JMP CICLATE

SIGUET
      LDAB U2
      BNE  SIGUEA
      CMPA #'T
      BNE BORRA
      STAA U2     * VALIDA T
      JMP CICLATE

SIGUEA
      LDAB U3
      BNE  SIGUER
      CMPA #'A
      BNE BORRA
      STAA U3     * VALIDA A
      JMP CICLATE
      
SIGUER
      LDAB U4
      BNE  SIGUEF
      CMPA #'R
      BNE BORRA
      STAA U4     * VALIDA R
      JMP CICLATE

SIGUEF
      CMPA #'T
      BNE BORRA
EXITO_START
      *LDAA #'E
      *STAA ORDEN
      JSR INICIO


SIGUEA_DADOS
      LDAB U2
      BNE  SIGUED_DADOS
      CMPA #'A
      BNE BORRA
      STAA U2     * VALIDA A
      JMP CICLATE

SIGUED_DADOS
      LDAB U3
      BNE  SIGUEO_DADOS
      CMPA #'D
      BNE BORRA
      STAA U3     * VALIDA D
      JMP CICLATE
      
SIGUEO_DADOS
      LDAB U4
      BNE  SIGUES_DADOS
      CMPA #'O
      BNE BORRA
      STAA U4     * VALIDA O
      JMP CICLATE

SIGUES_DADOS
      CMPA #'S
      BNE BORRA
EXITO_DADOS
      *LDAA #'E
      *STAA ORDEN
      JSR TIRO
      JMP BORRA


    



* Desplegar el valor de cada dado
* Desplegar la suma para cada tiro
* Restablecer contador con START
* Realizar tiro con secuencia DADOS
* Actualizar casilla de jugador tomando en cuenta el tablero
* Comprobar si la casilla es ganadora y desplegar mensaje
* Comprobar si la casilla es mayor a 100 y actualizar la casilla correspondiente
* Codificar tablero

TIRO:
* Generar número aleatorio de 16 bits (se lee el valor del temporizador)
* Dado 1
    LDX TEMPORIZADOR
    XGDX
    PSHA
    JSR MODULO_6
    INCB
    STAB DADO1
    
    * dado 2
    PULB
    JSR MODULO_6
    INCB
    STAB DADO2
    
    * obtener suma
    LDAA DADO1
    LDAB DADO2
    ABA
    STAA SUMA_DADOS
    
    JSR IMPRIMIR_DADOS

    LDAA SUMA_DADOS
    * obtener casilla actual más suma de dados
    LDX JUGADOR_ACTUAL
    ADDA 0,X
    
    LDAB #100
    CBA
    BEQ GANASTE
    BLO TRUNCADA
    * si es mayor a 100 se resta la diferencia
    SBA
    TAB
    LDAA #100
    SBA
    
TRUNCADA:
* guardar casilla obtenida
    LDX JUGADOR_ACTUAL
    STAA 0,X
    * actualizar si es serpiente o escalera
    LDAB #$0040
    ABA
    TAB
    CLRA
    XGDX
    LDAA 0,X
    LDAB #$FF
    CBA
    BEQ CASILLAS_LISTAS
    
    * La casilla es serpiente o escalera, actualizarla
    LDX JUGADOR_ACTUAL
    STAA 0,X
    
CASILLAS_LISTAS:
    JSR IMPRIMIR_CASILLAS
     
    * Intercambiar jugador
    LDAA JUGADOR_ACTUAL_1
    LDAB #$0
    CBA
    BNE CAMBIAR * no es necesario cambiar el valor del nuevo jugador
    LDAB #$1
    
CAMBIAR
    STAB JUGADOR_ACTUAL_1
    
    RTS
    
    


GANASTE:
    LDAA #'Y
    STAA $0030
    LDAA #'A
    STAA $0031
    LDAA #32
    STAA $0032
    LDAA #'G
    STAA $0033
    LDAA #'A
    STAA $0034
    LDAA #'N
    STAA $0035
    LDAA #'A
    STAA $0036
    LDAA #'S
    STAA $0037
    LDAA #'T
    STAA $0038
    LDAA #'E
    STAA $0039
    LDAA #'!
    STAA $003A
    LDAA #'!
    STAA $003B
    LDAA #'!
    STAA $003C
LOOP
    BRA LOOP



IMPRIMIR_DADOS:
    LDAB DADO1
    LDX #DADO1_ASCII
    STX DIRACTUAL
    JSR IMPRIMIR_NUMERO
    
    LDAB DADO2
    LDX #DADO2_ASCII
    STX DIRACTUAL
    JSR IMPRIMIR_NUMERO
    
    LDAB SUMA_DADOS
    LDX #SUMA_DADOS_ASCII
    STX DIRACTUAL
    JSR IMPRIMIR_NUMERO
    
    RTS


IMPRIMIR_CASILLAS:
    LDAB CASILLA_JUGADOR1
    LDX #CASILLA1_ASCII
    STX DIRACTUAL
    JSR IMPRIMIR_NUMERO
    
    LDAB CASILLA_JUGADOR2
    LDX #CASILLA2_ASCII
    STX DIRACTUAL
    JSR IMPRIMIR_NUMERO
    
    RTS



* Subrutina para imprimir nÃºmero de tres dÃ­gitos en ASCII dado en B
IMPRIMIR_NUMERO:
    CLRA * Numero de 8 bits a imprimir se coloca en D 
    
    PSHB * Guardar numero
    
    LDX #100
    IDIV   * D / X = Numero a imprimir / 100, produce cociente en X
    * Obtener modulo 10, pasar cociente a b
    XGDX
    CLRA * redundante, asumiendo que cociente es de 8 bits
    JSR MODULO_10 * modulo ahora en B
    JSR IMPRIMIR_DIGITO
    
    CLRA
    PULB
    PSHB
    LDX #10
    IDIV
    XGDX
    CLRA
    JSR MODULO_10
    JSR IMPRIMIR_DIGITO
    
    CLRA
    PULB
    LDX #1
    IDIV
    XGDX
    CLRA
    JSR MODULO_10
    JSR IMPRIMIR_DIGITO
    
    RTS


* digito esta en b
IMPRIMIR_DIGITO
    ADDB #48 * ascii
    LDX DIRACTUAL
    STAB $0000,X
    INC DIRACTUAL1
    RTS
    


* Obtener mod 6, operando en B, resultado en B
MODULO_6:
    *Dividir aleatorio entre 6
    PSHB
    CLRA
    LDX #6
    IDIV
    
    *Obtener x = cociente * 6
    XGDX   * X en D, cociente en B
    LDAA #6
    MUL
    
    * x esta en B
    PULA
    * aleatorio en A
    
    *Obtener aleatorio - x
    SBA
    TAB
    CLRA
    RTS
    

* Obtener mod 10, operando en B, resultado en B
MODULO_10:
    *Dividir aleatorio entre 10
    PSHB
    CLRA
    LDX #10
    IDIV
    
    *Obtener x = cociente * 10
    XGDX   * X en D, cociente en B
    LDAA #10
    MUL
    
    * x esta en B
    PULA
    * aleatorio en A
    
    *Obtener aleatorio - x
    SBA
    TAB
    RTS



* empieza en 0041, codificar serpientes y escaleras. Las demás casillas contendrán #FF
INICIALIZAR_TABLERO:
    LDAA #25
    STAA $0044
    
    LDAA #46
    STAA $004D
    
    LDAA #5
    STAA $005B
    
    LDAA #49
    STAA $0061
    
    LDAA #3
    STAA $0068

    LDAA #63
    STAA $006A
    
    LDAA #18
    STAA $006B
    
    LDAA #69
    STAA $0072
    
    LDAA #31
    STAA $0076
    
    LDAA #81
    STAA $007E
    
    LDAA #45
    STAA $0082
    
    LDAA #92
    STAA $008A
    
    LDAA #58
    STAA $008C
    
    LDAA #53
    STAA $0099
    
    LDAA #41
    STAA $00A3


* Configuracion de puerto serial
SERIAL
       LDD   #$302C  * CONFIGURA PUERTO SERIAL
       STAA  BAUD    * BAUD  9600  para cristal de 8MHz
       STAB  SCCR2   * HABILITA  RX Y TX PERO INTERRUPCN SOLO RX
       LDAA  #$00
       STAA  SCCR1   * 8 BITS

       LDAA  #$FE    * CONFIG PUERTO D COMO SALIDAS (EXCEPTO PD0)
       STAA  DDRD    * SEA  ENABLE DEL DISPLAY  PD4  Y RS PD3
                     
      
       LDAA  #$04
       STAA  HPRIO

       LDAA  #$00
       TAP
       RTS


***********************************
* ATENCION A INTERRUPCION SERIAL
***********************************
       ORG  $F100

       LDAA SCSR
       LDAA SCDR
       STAA ORDEN
         
       RTI

***********************************
* VECTOR INTERRUPCION SERIAL
***********************************
       ORG   $FFD6
       FCB   $F1,$00       


***********************************
*RESET
***********************************
       ORG    $FFFE
RESET  FCB    $80,$00
***********************************
       END   $8000


* Desplegar el valor de cada dado, asi como la suma en ASCII en decimal para cada tiro
* El contador de número de casillas se restablece con la secuencia START.
* Se realiza una tirada de dados mediante la secuencia DADOS transmitida en el puerto serial.
* Cada que se tiren los dados, la casilla del jugador se actualiza de acuerdo a la suma
* Si la casilla de destino es el pie o una serpiente, se conducirá a la casilla respectiva.
* Guardar escaleras y serpientes.
* Cuando un jugador llega a la casilla 100, se despliega YA GANASTE!!!
* Si la cifra es mayor a 100, el jugador regresa el número de casillas equivalente a la diferencia de puntos.
