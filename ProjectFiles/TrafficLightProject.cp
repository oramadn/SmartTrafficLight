#line 1 "C:/Users/omarr/Desktop/Uni stuff/Y4S2/Embedded Systems/ProjectFiles/TrafficLightProject.c"
unsigned char currentGreen = 0, trafficLightArr[]= {0, 1, 2, 3},redtrafficLightArr[3],redtrafficLightCntr = 0,i,j,k;
unsigned char laneCntr[4], didRead[] = {0,0,0,0},laneCntrPorts,numCycle = 0,savedGreen=8,enableDefaultCntr = 1;
unsigned char orderChanged=0,specialFlagThree = 0,ambulanceFlag = 0;
unsigned int Dcntr = 0, cntr = 0;
void mymsDelay(unsigned int);
void trafficLights(unsigned char);
void redAllLights(void);
void Ambulance(void);

void interrupt(void){
 if(INTCON&0x04){
 TMR0=248;
 Dcntr++;
 cntr++;
 for(k=0;k<4;k++){
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

 INTCON = INTCON & 0xFB;
 }
}

void main() {

 OPTION_REG = 0x87;
 TMR0=248;
 INTCON = INTCON | 0xA0;


 TRISB = 0x10;
 TRISC = 0x08;
 TRISD = 0x0F;


 PORTB = 0x00;
 PORTC = 0x00;
 PORTD = 0x10;

 mymsDelay(500);
 for(k=0;k<4;k++){
 laneCntr[k] = 0;
 }

 while (1){

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
 if(i <= currentGreen || i == currentGreen+1){continue;}
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

 if(ambulanceFlag){
 Ambulance();
 ambulanceFlag = 0;
 }

 if(PORTC & 0x08){
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
 for (i = 0; i<4; i++){
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

 while(currentGreen != 8 & cntr < 2000){
 PORTC = 0x01;
 for(j = 0; j<4; j++){
 PORTB = trafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;

 while(currentGreen != 8 & cntr < 8000){
 PORTC = 0x04;
 PORTB = currentGreen;
 mymsDelay(5);
 PORTC = 0x01;
 for(j = 0; j<3; j++){
 PORTB = redtrafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;

 while(currentGreen != 8 & cntr < 1000){
 PORTC = 0x02;
 PORTB = currentGreen;
 mymsDelay(5);
 PORTC = 0x01;
 for(j = 0; j<3; j++){
 PORTB = redtrafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;
}

void redAllLights(){
 while (cntr < 10000){
 PORTC = 0x01;
 for(j = 0; j<4; j++){
 PORTB = trafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;
}

void Ambulance(){
 while(currentGreen != 8 & cntr < 3000){
 PORTC = 0x01;
 for(j = 0; j<4; j++){
 PORTB = trafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;

 while(currentGreen != 8 & cntr < 10000){
 PORTC = 0x04;
 PORTB = 0;
 mymsDelay(5);
 PORTC = 0x01;
 for(j = 1; j<4; j++){
 PORTB = trafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;

 while(currentGreen != 8 & cntr < 1000){
 PORTC = 0x02;
 PORTB = 0;
 mymsDelay(5);
 PORTC = 0x01;
 for(j = 1; j<4; j++){
 PORTB = trafficLightArr[j];
 mymsDelay(5);
 }
 }
 cntr = 0;
}
