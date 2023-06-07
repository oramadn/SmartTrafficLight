unsigned char currentGreen = 0, trafficLightArr[]= {0, 1, 2, 3},redtrafficLightArr[3],redtrafficLightCntr = 0,i,j,k;
unsigned char laneCntr[4], didRead[] = {0,0,0,0},laneCntrPorts,numCycle = 0,savedGreen=8,enableDefaultCntr = 1;
unsigned char orderChanged=0,specialFlagThree = 0,ambulanceFlag = 0;
unsigned int Dcntr = 0, cntr = 0;
void mymsDelay(unsigned int);
void trafficLights(unsigned char);
void redAllLights(void);
void Ambulance(void);

void interrupt(void){
      if(INTCON&0x04){//TMR0 Overflow ISR, every 1ms
      TMR0=248;// 8 counts to overflow
      Dcntr++;
      cntr++;
      for(k=0;k<4;k++){ //Check the 4 counters
        laneCntrPorts = (1<<k);
        if((PORTD&laneCntrPorts) && !didRead[k]){
          laneCntr[k]++;
          didRead[k] = 1;
        }
        else if(!(PORTD&laneCntrPorts)&& didRead[k]){
          didRead[k] = 0;
        }
      }
      if(PORTB & 0x10){ambulanceFlag = 1;}
      
      INTCON = INTCON & 0xFB;//clear T0IF (overflow Flag)
      }
}

void main() {
     //Initialiaztion
     OPTION_REG = 0x87; //Slowest Prescaler option
     TMR0=248; //To count 8 times
     INTCON = INTCON | 0xA0;//Enable global INT, Enable overflow INT

     //Port Directions
     TRISB = 0x10;
     TRISC = 0x08; //RC3: Bus IR Sensor
     TRISD = 0x0F; //IR Sensors RD0 - RD3

     //Initial Port Values
     PORTB = 0x00; //RB0 -> RB3 : Traffic lights 1 - 4
     PORTC = 0x00; //RC0:Red, RC1:Yellow, RC2:Green
     PORTD = 0x10; //Bus Traffic Light RD4: Red, RD5:Green

     mymsDelay(500);
     for(k=0;k<4;k++){
       laneCntr[k] = 0;
     }

     while (1){
        //Normal Traffic Light Order
        trafficLights(currentGreen);

        enableDefaultCntr = 1;

        if(savedGreen != 8){
           if(currentGreen == savedGreen+1){currentGreen = savedGreen+2;}
           else{currentGreen = savedGreen+1;}
           savedGreen = 8;
           enableDefaultCntr = 0;
        }

        for(i=0;i<4;i++){
         if(laneCntr[i] >=3 && orderChanged == 0){
          if(i <= currentGreen || i == currentGreen+1){continue;}//Disallowing giving priortey to an already green light OR if next in queue
          if(i == 2){specialFlagThree = 1;}
          laneCntr[i] = 0;
          savedGreen = currentGreen;
          currentGreen = i;
          orderChanged = 1;
          enableDefaultCntr = 0;
          break;
         }
        }
        if(enableDefaultCntr && specialFlagThree){currentGreen = currentGreen + 2;specialFlagThree = 0;}
        else if(enableDefaultCntr){currentGreen++;}

        if(currentGreen > 3){
          currentGreen = 0;
        }
        if(numCycle==4){orderChanged = 0;currentGreen = 0;numCycle=0;}

        if(ambulanceFlag){
         Ambulance();
         ambulanceFlag = 0;
        }

        if(PORTC & 0x08){//Check Bus
          PORTD = 0x20;
          redAllLights();
          PORTD = 0x10;
        }
     }
}

void mymsDelay(unsigned int d){
   Dcntr=0;
   while(Dcntr<d);
}

void trafficLights(unsigned char currentGreen){
  numCycle++;
  for (i = 0; i<4; i++){    //Fill redtrafficLightArr with the 3 lights that should be red.
    if(currentGreen == trafficLightArr[i])
    {
      continue;
    }else
    {
      redtrafficLightArr[redtrafficLightCntr] = trafficLightArr[i];
      redtrafficLightCntr++;
    }
  }
  redtrafficLightCntr = 0;

  while(currentGreen != 8 & cntr < 2000){ //Red all lights
    PORTC = 0x01;
    for(j = 0; j<4; j++){
      PORTB = trafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr = 0;

  while(currentGreen != 8 & cntr < 8000){ //Green currentGreen PORT and Red the other
    PORTC = 0x04;
    PORTB = currentGreen;
    mymsDelay(5);
    PORTC = 0x01;
    for(j = 0; j<3; j++){
      PORTB = redtrafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr =  0;

  while(currentGreen != 8 & cntr < 1000){ //Yellow currentGreen PORT and Red the other
    PORTC = 0x02;
    PORTB = currentGreen;
    mymsDelay(5);
    PORTC = 0x01;
    for(j = 0; j<3; j++){
      PORTB = redtrafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr =  0;
}

void redAllLights(){
  while (cntr < 10000){ //Red all lights
    PORTC = 0x01;
    for(j = 0; j<4; j++){
      PORTB = trafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr = 0;
}

void Ambulance(){
  while(currentGreen != 8 & cntr < 3000){ //Red all lights
    PORTC = 0x01;
    for(j = 0; j<4; j++){
      PORTB = trafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr = 0;

  while(currentGreen != 8 & cntr < 10000){ //Green currentGreen PORT and Red the other
    PORTC = 0x04;
    PORTB = 0;
    mymsDelay(5);
    PORTC = 0x01;
    for(j = 1; j<4; j++){
      PORTB = trafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr =  0;

  while(currentGreen != 8 & cntr < 1000){ //Yellow currentGreen PORT and Red the other
    PORTC = 0x02;
    PORTB = 0;
    mymsDelay(5);
    PORTC = 0x01;
    for(j = 1; j<4; j++){
      PORTB = trafficLightArr[j];
      mymsDelay(5);
    }
  }
  cntr =  0;
}