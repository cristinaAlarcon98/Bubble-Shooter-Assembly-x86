

*-----------------------------------------------------------
* Title      : VISUALIZADOR GRÁFICO EN 68k PARA BUBBLE SHOOTER
* Written by : FULGENCIO
* Date       : 2019
* Description:
*-----------------------------------------------------------
 
BLACK  EQU $00000000
RED    EQU $00000FFF
GREEN  EQU $0035E84A
YELLOW EQU $0000FFFF
BLUE   EQU $00FF0000
WHITE  EQU $00FFFFFF
CYAN   EQU $00FFFF00
MAGENTA EQU $00FF00FF
AZULITO EQU $00CCEEFF 
   
SIZE EQU 30
ORIX EQU 20
ORIY EQU 20
 
 
   ORG    $1000
 
START              
                  JSR PONBOLA
VUELVE                  JSR SHOWMAP
                        
                  
CLIKMAPA
            MOVE.L #61,D0
            MOVE.L #0,D1
            TRAP #15
           
            BTST #0,D0   *Comprueba el bit 0 (corresponde con click izqdo)
            BEQ CLIKMAPA     *Si no hay click izqdo, se mantiene el bucle
           
            CLR.L D2
            SWAP D1      *En D1 tenemos 00|YY|00|XX
            MOVE.W D1,D2
            EXT.L D2     *Extiende el signo de Word a Long (para incluir negativos)
            CLR.W D1
            SWAP D1      *Hemos pasado Y a D2 y dejamos X en D1
            EXT.L D1    
            JMP EVALCLIK
            


   
       SIMHALT           
 
*************************************************************************
SHOWMAP ******************************** Subrutina que muestra el estado del mapa en las coordenadas ORIX, ORIY ************************************
    MOVE.L #ORIX,D1
    MOVE.L #ORIY,D2 *Coordenadas iniciales del tablero
    MOVE.L #MAPA+20,A3 *Posición de la primera casilla real
   
LOOPMAP
   MOVE.B (A3)+,D0 *Obtiene el contenido
    CMP.B #$80,D0
    BEQ NEXTROW
    CMP.B #$00,D0
    BEQ EMPTY       *Está vacía
 
FILLED             *Dibuja burbuja
    JSR BUBBLE
    ADD.L #SIZE,D1
    JMP LOOPMAP    
     
EMPTY
   ADD.L #SIZE,D1
    JMP LOOPMAP
 
 
 
NEXTROW
   MOVE.L #ORIX,D1  *Retorno coordenada X inicial
    ADD.L #SIZE,D2   *Avance coordenada Y
    CMP.B #$40,(A3)+ *Comprueba línea par/impar
    BNE NODESP
    ADD.L #SIZE/2,D1 *Si tiene un $40, la fila se desplaza medio hueco a derecha
NODESP  
    CMP.B #$80,(A3)
    BNE LOOPMAP  
    RTS
**************************************************************************
 
   
BUBBLE
   MOVEM.L D0-D4,-(A7)
    JSR FILLCOLOR   *Elijo un color de relleno
    MOVE.L #88,D0   *Circulo CON relleno
    MOVE.L D1,D3
    MOVE.L D2,D4    *Copio coordenadas esquina izquierda en D3,D4
    ADD.L #SIZE,D3
    ADD.L #SIZE,D4  *Creo coordenadas esquina derecha separándolas SIZE pixels
    TRAP #15
    MOVEM.L (A7)+,D0-D4
    RTS
   
FILLCOLOR
   MOVEM.L D0-D1/A1,-(A7)
    MOVE.L #TABLACOLOR,A1
    MULU #4,D0          *La tabla es de LONG
    MOVE.L (A1,D0),D1   *D1 tiene color de la bola
    MOVE.L #81,D0       *Color relleno
    TRAP #15
    MOVE.L #80,D0       *Color linea
    TRAP #15
    MOVEM.L (A7)+,D0-D1/A1
    RTS 

PONBOLA        
     MOVE.B #$02,D0
     MOVE.B D0, $4113   
     RTS

 

EVALCLIK
     SUB.L #230,D2
     CMP.L #0,D2
     BLT NADA
     
     CMP.L #30,D2
     BLT FILA8
     CMP.L #60,D2
     BLT FILA9
     CMP.L #90,D2
     BLT FILA10
     CMP.L #120,D2
     BLT FILA11
     CMP.L #150,D2
     BLT FILA12
     CMP.L #180,D2
     BLT FILA13
  JMP NADA
COMPRUEBA  
     MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     MOVE.B 1(A2),D3
     CMP.L D3,D4
     BNE NEXT
     ADD.L #1,D7
     *ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     ADD.L #1,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT
     MOVE.L A3, EVALUARBOLA0
     
NEXT MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     *SUB.L #1,A2
     MOVE.B -1(A2),D3
     CMP.L D3,D4
     BNE NEXT1
     ADD.L #1,D7
     *ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     SUB.L #1,A3
     ADD.L #$156,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT1
     MOVE.L A3, EVALUARBOLA1
     

NEXT1     
     MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     *SUB.L #19,A2
     MOVE.B -19(A2),D3
     CMP.L D3,D4
     BNE NEXT2
     ADD.L #1,D7
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     SUB.L #19,A3
     MOVE.B #1,(A3)

     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT2
     MOVE.L A3, EVALUARBOLA2
     
NEXT2     
     MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     
     MOVE.B 19(A2),D3
     CMP.L D3,D4
     BNE NEXT3
     ADD.L #1,D7
     *ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     ADD.L #19,A3
     MOVE.B #1,(A3)
     
          SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT3
     MOVE.L A3, EVALUARBOLA3
     
NEXT3      
     MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     *ADD.L #20,A2
     MOVE.B 20(A2),D3
     CMP.L D3,D4
     BNE NEXT4
     ADD.L #1,D7
     *ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     ADD.L #20,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT4
     MOVE.L A3, EVALUARBOLA4
     

NEXT4 MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     *SUB.L #20,A2
     MOVE.B -20(A2),D3
     CMP.L D3,D4
     BNE NEXT5
     ADD.L #1,D7
     *ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     SUB.L #20,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT5
     MOVE.L A3, EVALUARBOLA5

NEXT5 MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     *ADD.L #18,A2
     MOVE.B 18(A2),D3
     CMP.L D3,D4
     BNE NEXT6
     ADD.L #1,D7
    * ADD.L #$156,A2
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A2
     ADD.L #18,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT5
     MOVE.L A3, EVALUARBOLA5
     
NEXT6 
     MOVE.B (A2),D4 *COMPRUEBA LAS VECINAS
     
     MOVE.B -18(A2),D3
     CMP.L D3,D4
     BNE NEXT7
     ADD.L #1,D7
     
     MOVE.L #0,A3
     ADD.L A2,A3
     ADD.L #$156,A3
     SUB.L #18,A3
     MOVE.B #1,(A3)
     
     SUB.L #$156,A3
     CMP.L (A3),D4
     BNE NEXT7
     MOVE.L A3, EVALUARBOLA6

       
NEXT7 
     
     JMP VUELVE

 RTS     


FILA8
     MOVE.L #MAPA,A2
     ADD.L #$99,A2
     CMP #$221,D1
     BHI VUELVE 
     SUB.L #$23,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 *COLUMNA
     MOVE.B #$02,(A2)
 JSR COMPRUEBA      

FILA9
     MOVE.L #MAPA,A2
     ADD.L #$AC,A2
     CMP #$213,D1
     BHI VUELVE
     SUB.L #$14,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 
     MOVE.B #$02,(A2)
     
     JSR COMPRUEBA 
FILA10
     MOVE.L #MAPA,A2
     ADD.L #$BF,A2
     CMP #$221,D1
     BHI VUELVE
     SUB.L #$23,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 
     MOVE.B #$02,(A2)
     
     JSR COMPRUEBA 
FILA11
     MOVE.L #MAPA,A2
     ADD.L #$D2,A2

     CMP #$213,D1
     BHI VUELVE 
     SUB.L #$14,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 
      MOVE.B #$02,(A2)
      
     JSR COMPRUEBA 
FILA12
     MOVE.L #MAPA,A2
     ADD.L #$E5,A2
     CMP #$221,D1
     BHI VUELVE 
     SUB.L #$23,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 
     MOVE.B #$02,(A2)
     
     JSR COMPRUEBA 
FILA13
     MOVE.L #MAPA,A2
     ADD.L #$F8,A2

     CMP #$213,D1
     BHI VUELVE 
     SUB.L #$14,D1
     DIVU #30,D1 *RESTO/COCIENTE
     MOVE.L #0,D2
     MOVE.W D1,D2
     ADD.L D2,A2 
     MOVE.B #$02,(A2)
     
     JSR COMPRUEBA

NADA
 JMP VUELVE


    ORG $4000
    *El borde izquierdo está marcado con $80 o $40, para indicar fila par o impar
MAPA
 DC.B $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 DC.B $80,$02,$03,$06,$04,$06,$03,$01,$06,$01,$05,$02,$01,$05,$06,$04,$03,$05,$80
 DC.B $40,$03,$03,$05,$02,$06,$05,$04,$04,$03,$06,$01,$05,$01,$05,$05,$01,$02,$80
 DC.B $80,$06,$03,$01,$06,$04,$04,$01,$04,$01,$02,$03,$05,$02,$05,$01,$04,$04,$80
 DC.B $40,$02,$04,$05,$02,$06,$01,$04,$05,$04,$01,$02,$04,$05,$01,$01,$02,$05,$80
 DC.B $80,$05,$06,$06,$02,$01,$06,$05,$06,$05,$01,$05,$02,$03,$03,$06,$05,$01,$80
 DC.B $40,$02,$04,$02,$02,$02,$01,$04,$03,$03,$06,$05,$03,$03,$04,$02,$06,$01,$80
 DC.B $80,$06,$01,$04,$06,$06,$04,$05,$03,$02,$04,$03,$01,$02,$02,$06,$04,$06,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
MAPAEXPLOT
 DC.B $40,$40,$40,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80
 DC.B $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80

 ORG $5000 
TABLACOLOR
    DC.L BLACK
    DC.L RED
    DC.L GREEN
    DC.L BLUE
    DC.L MAGENTA
    DC.L YELLOW
    DC.L CYAN
    DC.L AZULITO
 
    END    START























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
