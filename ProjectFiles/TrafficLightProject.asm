
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;TrafficLightProject.c,10 :: 		void interrupt(void){
;TrafficLightProject.c,11 :: 		if(INTCON&0x04){//TMR0 Overflow ISR, every 1ms
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;TrafficLightProject.c,12 :: 		TMR0=248;// 8 counts to overflow
	MOVLW      248
	MOVWF      TMR0+0
;TrafficLightProject.c,13 :: 		Dcntr++;
	INCF       _Dcntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _Dcntr+1, 1
;TrafficLightProject.c,14 :: 		cntr++;
	INCF       _cntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cntr+1, 1
;TrafficLightProject.c,15 :: 		for(k=0;k<4;k++){ //Check the 4 counters
	CLRF       _k+0
L_interrupt1:
	MOVLW      4
	SUBWF      _k+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt2
;TrafficLightProject.c,16 :: 		laneCntrPorts = (1<<k);
	MOVF       _k+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__interrupt89:
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt90
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__interrupt89
L__interrupt90:
	MOVF       R0+0, 0
	MOVWF      _laneCntrPorts+0
;TrafficLightProject.c,17 :: 		if((PORTD&laneCntrPorts) && !didRead[k]){
	MOVF       PORTD+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt6
	MOVF       _k+0, 0
	ADDLW      _didRead+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt6
L__interrupt83:
;TrafficLightProject.c,18 :: 		laneCntr[k]++;
	MOVF       _k+0, 0
	ADDLW      _laneCntr+0
	MOVWF      R1+0
	MOVF       R1+0, 0
	MOVWF      FSR
	INCF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;TrafficLightProject.c,19 :: 		didRead[k] = 1;
	MOVF       _k+0, 0
	ADDLW      _didRead+0
	MOVWF      FSR
	MOVLW      1
	MOVWF      INDF+0
;TrafficLightProject.c,20 :: 		}
	GOTO       L_interrupt7
L_interrupt6:
;TrafficLightProject.c,21 :: 		else if(!(PORTD&laneCntrPorts)&& didRead[k]){
	MOVF       _laneCntrPorts+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R0+0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
	MOVF       _k+0, 0
	ADDLW      _didRead+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
L__interrupt82:
;TrafficLightProject.c,22 :: 		didRead[k] = 0;
	MOVF       _k+0, 0
	ADDLW      _didRead+0
	MOVWF      FSR
	CLRF       INDF+0
;TrafficLightProject.c,23 :: 		}
L_interrupt10:
L_interrupt7:
;TrafficLightProject.c,15 :: 		for(k=0;k<4;k++){ //Check the 4 counters
	INCF       _k+0, 1
;TrafficLightProject.c,24 :: 		}
	GOTO       L_interrupt1
L_interrupt2:
;TrafficLightProject.c,25 :: 		if(PORTB & 0x10){ambulanceFlag = 1;}
	BTFSS      PORTB+0, 4
	GOTO       L_interrupt11
	MOVLW      1
	MOVWF      _ambulanceFlag+0
L_interrupt11:
;TrafficLightProject.c,27 :: 		INTCON = INTCON & 0xFB;//clear T0IF (overflow Flag)
	MOVLW      251
	ANDWF      INTCON+0, 1
;TrafficLightProject.c,28 :: 		}
L_interrupt0:
;TrafficLightProject.c,29 :: 		}
L_end_interrupt:
L__interrupt88:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;TrafficLightProject.c,31 :: 		void main() {
;TrafficLightProject.c,33 :: 		OPTION_REG = 0x87; //Slowest Prescaler option
	MOVLW      135
	MOVWF      OPTION_REG+0
;TrafficLightProject.c,34 :: 		TMR0=248; //To count 8 times
	MOVLW      248
	MOVWF      TMR0+0
;TrafficLightProject.c,35 :: 		INTCON = INTCON | 0xA0;//Enable global INT, Enable overflow INT
	MOVLW      160
	IORWF      INTCON+0, 1
;TrafficLightProject.c,38 :: 		TRISB = 0x10;
	MOVLW      16
	MOVWF      TRISB+0
;TrafficLightProject.c,39 :: 		TRISC = 0x08; //RC3: Bus IR Sensor
	MOVLW      8
	MOVWF      TRISC+0
;TrafficLightProject.c,40 :: 		TRISD = 0x0F; //IR Sensors RD0 - RD3
	MOVLW      15
	MOVWF      TRISD+0
;TrafficLightProject.c,43 :: 		PORTB = 0x00; //RB0 -> RB3 : Traffic lights 1 - 4
	CLRF       PORTB+0
;TrafficLightProject.c,44 :: 		PORTC = 0x00; //RC0:Red, RC1:Yellow, RC2:Green
	CLRF       PORTC+0
;TrafficLightProject.c,45 :: 		PORTD = 0x10; //Bus Traffic Light RD0: Red, RD1:Green
	MOVLW      16
	MOVWF      PORTD+0
;TrafficLightProject.c,47 :: 		mymsDelay(500);
	MOVLW      244
	MOVWF      FARG_mymsDelay+0
	MOVLW      1
	MOVWF      FARG_mymsDelay+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,48 :: 		for(k=0;k<4;k++){
	CLRF       _k+0
L_main12:
	MOVLW      4
	SUBWF      _k+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main13
;TrafficLightProject.c,49 :: 		laneCntr[k] = 0;
	MOVF       _k+0, 0
	ADDLW      _laneCntr+0
	MOVWF      FSR
	CLRF       INDF+0
;TrafficLightProject.c,48 :: 		for(k=0;k<4;k++){
	INCF       _k+0, 1
;TrafficLightProject.c,50 :: 		}
	GOTO       L_main12
L_main13:
;TrafficLightProject.c,52 :: 		while (1){
L_main15:
;TrafficLightProject.c,54 :: 		trafficLights(currentGreen);
	MOVF       _currentGreen+0, 0
	MOVWF      FARG_trafficLights+0
	CALL       _trafficLights+0
;TrafficLightProject.c,56 :: 		enableDefaultCntr = 1;
	MOVLW      1
	MOVWF      _enableDefaultCntr+0
;TrafficLightProject.c,58 :: 		if(savedGreen != 8){
	MOVF       _savedGreen+0, 0
	XORLW      8
	BTFSC      STATUS+0, 2
	GOTO       L_main17
;TrafficLightProject.c,59 :: 		if(currentGreen == savedGreen+1){currentGreen = savedGreen+2;}
	MOVF       _savedGreen+0, 0
	ADDLW      1
	MOVWF      R1+0
	CLRF       R1+1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVLW      0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main92
	MOVF       R1+0, 0
	XORWF      _currentGreen+0, 0
L__main92:
	BTFSS      STATUS+0, 2
	GOTO       L_main18
	MOVLW      2
	ADDWF      _savedGreen+0, 0
	MOVWF      _currentGreen+0
	GOTO       L_main19
L_main18:
;TrafficLightProject.c,60 :: 		else{currentGreen = savedGreen+1;}
	INCF       _savedGreen+0, 0
	MOVWF      _currentGreen+0
L_main19:
;TrafficLightProject.c,61 :: 		savedGreen = 8;
	MOVLW      8
	MOVWF      _savedGreen+0
;TrafficLightProject.c,62 :: 		enableDefaultCntr = 0;
	CLRF       _enableDefaultCntr+0
;TrafficLightProject.c,63 :: 		}
L_main17:
;TrafficLightProject.c,65 :: 		for(i=0;i<4;i++){
	CLRF       _i+0
L_main20:
	MOVLW      4
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;TrafficLightProject.c,66 :: 		if(laneCntr[i] >=3 && orderChanged == 0){
	MOVF       _i+0, 0
	ADDLW      _laneCntr+0
	MOVWF      FSR
	MOVLW      3
	SUBWF      INDF+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main25
	MOVF       _orderChanged+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main25
L__main86:
;TrafficLightProject.c,67 :: 		if(i <= currentGreen || i == currentGreen+1){continue;}//Disallowing giving priortey to an already green light OR if next in queue
	MOVF       _i+0, 0
	SUBWF      _currentGreen+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L__main85
	MOVF       _currentGreen+0, 0
	ADDLW      1
	MOVWF      R1+0
	CLRF       R1+1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVLW      0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main93
	MOVF       R1+0, 0
	XORWF      _i+0, 0
L__main93:
	BTFSC      STATUS+0, 2
	GOTO       L__main85
	GOTO       L_main28
L__main85:
	GOTO       L_main22
L_main28:
;TrafficLightProject.c,68 :: 		if(i == 2){specialFlagThree = 1;}
	MOVF       _i+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main29
	MOVLW      1
	MOVWF      _specialFlagThree+0
L_main29:
;TrafficLightProject.c,69 :: 		laneCntr[i] = 0;
	MOVF       _i+0, 0
	ADDLW      _laneCntr+0
	MOVWF      FSR
	CLRF       INDF+0
;TrafficLightProject.c,70 :: 		savedGreen = currentGreen;
	MOVF       _currentGreen+0, 0
	MOVWF      _savedGreen+0
;TrafficLightProject.c,71 :: 		currentGreen = i;
	MOVF       _i+0, 0
	MOVWF      _currentGreen+0
;TrafficLightProject.c,72 :: 		orderChanged = 1;
	MOVLW      1
	MOVWF      _orderChanged+0
;TrafficLightProject.c,73 :: 		enableDefaultCntr = 0;
	CLRF       _enableDefaultCntr+0
;TrafficLightProject.c,74 :: 		break;
	GOTO       L_main21
;TrafficLightProject.c,75 :: 		}
L_main25:
;TrafficLightProject.c,76 :: 		}
L_main22:
;TrafficLightProject.c,65 :: 		for(i=0;i<4;i++){
	INCF       _i+0, 1
;TrafficLightProject.c,76 :: 		}
	GOTO       L_main20
L_main21:
;TrafficLightProject.c,77 :: 		if(enableDefaultCntr && specialFlagThree){currentGreen = currentGreen + 2;specialFlagThree = 0;}
	MOVF       _enableDefaultCntr+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main32
	MOVF       _specialFlagThree+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main32
L__main84:
	MOVLW      2
	ADDWF      _currentGreen+0, 1
	CLRF       _specialFlagThree+0
	GOTO       L_main33
L_main32:
;TrafficLightProject.c,78 :: 		else if(enableDefaultCntr){currentGreen++;}
	MOVF       _enableDefaultCntr+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main34
	INCF       _currentGreen+0, 1
L_main34:
L_main33:
;TrafficLightProject.c,80 :: 		if(currentGreen > 3){
	MOVF       _currentGreen+0, 0
	SUBLW      3
	BTFSC      STATUS+0, 0
	GOTO       L_main35
;TrafficLightProject.c,81 :: 		currentGreen = 0;
	CLRF       _currentGreen+0
;TrafficLightProject.c,82 :: 		}
L_main35:
;TrafficLightProject.c,83 :: 		if(numCycle==4){orderChanged = 0;currentGreen = 0;numCycle=0;}
	MOVF       _numCycle+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main36
	CLRF       _orderChanged+0
	CLRF       _currentGreen+0
	CLRF       _numCycle+0
L_main36:
;TrafficLightProject.c,85 :: 		if(ambulanceFlag){
	MOVF       _ambulanceFlag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main37
;TrafficLightProject.c,86 :: 		Ambulance();
	CALL       _Ambulance+0
;TrafficLightProject.c,87 :: 		ambulanceFlag = 0;
	CLRF       _ambulanceFlag+0
;TrafficLightProject.c,88 :: 		}
L_main37:
;TrafficLightProject.c,90 :: 		if(ambulanceFlag){
	MOVF       _ambulanceFlag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main38
;TrafficLightProject.c,91 :: 		Ambulance();
	CALL       _Ambulance+0
;TrafficLightProject.c,92 :: 		ambulanceFlag = 0;
	CLRF       _ambulanceFlag+0
;TrafficLightProject.c,93 :: 		}
L_main38:
;TrafficLightProject.c,95 :: 		if(PORTC & 0x08){//Check Bus
	BTFSS      PORTC+0, 3
	GOTO       L_main39
;TrafficLightProject.c,96 :: 		PORTD = 0x20;
	MOVLW      32
	MOVWF      PORTD+0
;TrafficLightProject.c,97 :: 		redAllLights();
	CALL       _redAllLights+0
;TrafficLightProject.c,98 :: 		PORTD = 0x10;
	MOVLW      16
	MOVWF      PORTD+0
;TrafficLightProject.c,99 :: 		}
L_main39:
;TrafficLightProject.c,100 :: 		}
	GOTO       L_main15
;TrafficLightProject.c,101 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_mymsDelay:

;TrafficLightProject.c,103 :: 		void mymsDelay(unsigned int d){
;TrafficLightProject.c,104 :: 		Dcntr=0;
	CLRF       _Dcntr+0
	CLRF       _Dcntr+1
;TrafficLightProject.c,105 :: 		while(Dcntr<d);
L_mymsDelay40:
	MOVF       FARG_mymsDelay_d+1, 0
	SUBWF      _Dcntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__mymsDelay95
	MOVF       FARG_mymsDelay_d+0, 0
	SUBWF      _Dcntr+0, 0
L__mymsDelay95:
	BTFSC      STATUS+0, 0
	GOTO       L_mymsDelay41
	GOTO       L_mymsDelay40
L_mymsDelay41:
;TrafficLightProject.c,106 :: 		}
L_end_mymsDelay:
	RETURN
; end of _mymsDelay

_trafficLights:

;TrafficLightProject.c,108 :: 		void trafficLights(unsigned char currentGreen){
;TrafficLightProject.c,109 :: 		numCycle++;
	INCF       _numCycle+0, 1
;TrafficLightProject.c,110 :: 		for (i = 0; i<4; i++){    //Fill redtrafficLightArr with the 3 lights that should be red.
	CLRF       _i+0
L_trafficLights42:
	MOVLW      4
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_trafficLights43
;TrafficLightProject.c,111 :: 		if(currentGreen == trafficLightArr[i])
	MOVF       _i+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       FARG_trafficLights_currentGreen+0, 0
	XORWF      INDF+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_trafficLights45
;TrafficLightProject.c,113 :: 		continue;
	GOTO       L_trafficLights44
;TrafficLightProject.c,114 :: 		}else
L_trafficLights45:
;TrafficLightProject.c,116 :: 		redtrafficLightArr[redtrafficLightCntr] = trafficLightArr[i];
	MOVF       _redtrafficLightCntr+0, 0
	ADDLW      _redtrafficLightArr+0
	MOVWF      R1+0
	MOVF       _i+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;TrafficLightProject.c,117 :: 		redtrafficLightCntr++;
	INCF       _redtrafficLightCntr+0, 1
;TrafficLightProject.c,119 :: 		}
L_trafficLights44:
;TrafficLightProject.c,110 :: 		for (i = 0; i<4; i++){    //Fill redtrafficLightArr with the 3 lights that should be red.
	INCF       _i+0, 1
;TrafficLightProject.c,119 :: 		}
	GOTO       L_trafficLights42
L_trafficLights43:
;TrafficLightProject.c,120 :: 		redtrafficLightCntr = 0;
	CLRF       _redtrafficLightCntr+0
;TrafficLightProject.c,122 :: 		while(currentGreen != 8 & cntr < 2000){ //Red all lights
L_trafficLights47:
	MOVF       FARG_trafficLights_currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      7
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__trafficLights97
	MOVLW      208
	SUBWF      _cntr+0, 0
L__trafficLights97:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_trafficLights48
;TrafficLightProject.c,123 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,124 :: 		for(j = 0; j<4; j++){
	CLRF       _j+0
L_trafficLights49:
	MOVLW      4
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_trafficLights50
;TrafficLightProject.c,125 :: 		PORTB = trafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,126 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,124 :: 		for(j = 0; j<4; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,127 :: 		}
	GOTO       L_trafficLights49
L_trafficLights50:
;TrafficLightProject.c,128 :: 		}
	GOTO       L_trafficLights47
L_trafficLights48:
;TrafficLightProject.c,129 :: 		cntr = 0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,131 :: 		while(currentGreen != 8 & cntr < 8000){ //Green currentGreen PORT and Red the other
L_trafficLights52:
	MOVF       FARG_trafficLights_currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      31
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__trafficLights98
	MOVLW      64
	SUBWF      _cntr+0, 0
L__trafficLights98:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_trafficLights53
;TrafficLightProject.c,132 :: 		PORTC = 0x04;
	MOVLW      4
	MOVWF      PORTC+0
;TrafficLightProject.c,133 :: 		PORTB = currentGreen;
	MOVF       FARG_trafficLights_currentGreen+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,134 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,135 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,136 :: 		for(j = 0; j<3; j++){
	CLRF       _j+0
L_trafficLights54:
	MOVLW      3
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_trafficLights55
;TrafficLightProject.c,137 :: 		PORTB = redtrafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _redtrafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,138 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,136 :: 		for(j = 0; j<3; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,139 :: 		}
	GOTO       L_trafficLights54
L_trafficLights55:
;TrafficLightProject.c,140 :: 		}
	GOTO       L_trafficLights52
L_trafficLights53:
;TrafficLightProject.c,141 :: 		cntr =  0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,143 :: 		while(currentGreen != 8 & cntr < 1000){ //Yellow currentGreen PORT and Red the other
L_trafficLights57:
	MOVF       FARG_trafficLights_currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      3
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__trafficLights99
	MOVLW      232
	SUBWF      _cntr+0, 0
L__trafficLights99:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_trafficLights58
;TrafficLightProject.c,144 :: 		PORTC = 0x02;
	MOVLW      2
	MOVWF      PORTC+0
;TrafficLightProject.c,145 :: 		PORTB = currentGreen;
	MOVF       FARG_trafficLights_currentGreen+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,146 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,147 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,148 :: 		for(j = 0; j<3; j++){
	CLRF       _j+0
L_trafficLights59:
	MOVLW      3
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_trafficLights60
;TrafficLightProject.c,149 :: 		PORTB = redtrafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _redtrafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,150 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,148 :: 		for(j = 0; j<3; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,151 :: 		}
	GOTO       L_trafficLights59
L_trafficLights60:
;TrafficLightProject.c,152 :: 		}
	GOTO       L_trafficLights57
L_trafficLights58:
;TrafficLightProject.c,153 :: 		cntr =  0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,154 :: 		}
L_end_trafficLights:
	RETURN
; end of _trafficLights

_redAllLights:

;TrafficLightProject.c,156 :: 		void redAllLights(){
;TrafficLightProject.c,157 :: 		while (cntr < 10000){ //Red all lights
L_redAllLights62:
	MOVLW      39
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__redAllLights101
	MOVLW      16
	SUBWF      _cntr+0, 0
L__redAllLights101:
	BTFSC      STATUS+0, 0
	GOTO       L_redAllLights63
;TrafficLightProject.c,158 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,159 :: 		for(j = 0; j<4; j++){
	CLRF       _j+0
L_redAllLights64:
	MOVLW      4
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_redAllLights65
;TrafficLightProject.c,160 :: 		PORTB = trafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,161 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,159 :: 		for(j = 0; j<4; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,162 :: 		}
	GOTO       L_redAllLights64
L_redAllLights65:
;TrafficLightProject.c,163 :: 		}
	GOTO       L_redAllLights62
L_redAllLights63:
;TrafficLightProject.c,164 :: 		cntr = 0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,165 :: 		}
L_end_redAllLights:
	RETURN
; end of _redAllLights

_Ambulance:

;TrafficLightProject.c,167 :: 		void Ambulance(){
;TrafficLightProject.c,168 :: 		while(currentGreen != 8 & cntr < 3000){ //Red all lights
L_Ambulance67:
	MOVF       _currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      11
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Ambulance103
	MOVLW      184
	SUBWF      _cntr+0, 0
L__Ambulance103:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_Ambulance68
;TrafficLightProject.c,169 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,170 :: 		for(j = 0; j<4; j++){
	CLRF       _j+0
L_Ambulance69:
	MOVLW      4
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Ambulance70
;TrafficLightProject.c,171 :: 		PORTB = trafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,172 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,170 :: 		for(j = 0; j<4; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,173 :: 		}
	GOTO       L_Ambulance69
L_Ambulance70:
;TrafficLightProject.c,174 :: 		}
	GOTO       L_Ambulance67
L_Ambulance68:
;TrafficLightProject.c,175 :: 		cntr = 0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,177 :: 		while(currentGreen != 8 & cntr < 10000){ //Green currentGreen PORT and Red the other
L_Ambulance72:
	MOVF       _currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      39
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Ambulance104
	MOVLW      16
	SUBWF      _cntr+0, 0
L__Ambulance104:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_Ambulance73
;TrafficLightProject.c,178 :: 		PORTC = 0x04;
	MOVLW      4
	MOVWF      PORTC+0
;TrafficLightProject.c,179 :: 		PORTB = 0;
	CLRF       PORTB+0
;TrafficLightProject.c,180 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,181 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,182 :: 		for(j = 1; j<4; j++){
	MOVLW      1
	MOVWF      _j+0
L_Ambulance74:
	MOVLW      4
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Ambulance75
;TrafficLightProject.c,183 :: 		PORTB = trafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,184 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,182 :: 		for(j = 1; j<4; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,185 :: 		}
	GOTO       L_Ambulance74
L_Ambulance75:
;TrafficLightProject.c,186 :: 		}
	GOTO       L_Ambulance72
L_Ambulance73:
;TrafficLightProject.c,187 :: 		cntr =  0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,189 :: 		while(currentGreen != 8 & cntr < 1000){ //Yellow currentGreen PORT and Red the other
L_Ambulance77:
	MOVF       _currentGreen+0, 0
	XORLW      8
	MOVLW      1
	BTFSC      STATUS+0, 2
	MOVLW      0
	MOVWF      R1+0
	MOVLW      3
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Ambulance105
	MOVLW      232
	SUBWF      _cntr+0, 0
L__Ambulance105:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R1+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_Ambulance78
;TrafficLightProject.c,190 :: 		PORTC = 0x02;
	MOVLW      2
	MOVWF      PORTC+0
;TrafficLightProject.c,191 :: 		PORTB = 0;
	CLRF       PORTB+0
;TrafficLightProject.c,192 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,193 :: 		PORTC = 0x01;
	MOVLW      1
	MOVWF      PORTC+0
;TrafficLightProject.c,194 :: 		for(j = 1; j<4; j++){
	MOVLW      1
	MOVWF      _j+0
L_Ambulance79:
	MOVLW      4
	SUBWF      _j+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Ambulance80
;TrafficLightProject.c,195 :: 		PORTB = trafficLightArr[j];
	MOVF       _j+0, 0
	ADDLW      _trafficLightArr+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      PORTB+0
;TrafficLightProject.c,196 :: 		mymsDelay(5);
	MOVLW      5
	MOVWF      FARG_mymsDelay_d+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_d+1
	CALL       _mymsDelay+0
;TrafficLightProject.c,194 :: 		for(j = 1; j<4; j++){
	INCF       _j+0, 1
;TrafficLightProject.c,197 :: 		}
	GOTO       L_Ambulance79
L_Ambulance80:
;TrafficLightProject.c,198 :: 		}
	GOTO       L_Ambulance77
L_Ambulance78:
;TrafficLightProject.c,199 :: 		cntr =  0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;TrafficLightProject.c,200 :: 		}
L_end_Ambulance:
	RETURN
; end of _Ambulance
