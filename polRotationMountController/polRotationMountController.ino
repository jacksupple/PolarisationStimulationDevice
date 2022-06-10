#include <math.h>

// setup stepper motor, based on a4988 driver
const int stepPin   = 3;
const int dirPin    = 4;
const int MS1Pin    = 5;
const int MS2Pin    = 6;
const int MS3Pin    = 7;

float microStepRes = 16.;         // microstep resolution, 1,2,4,8,16
float gearMultiplier = 1.;        // gear ratio = 1:1
float stepsPerRev = (200.*microStepRes)*gearMultiplier;
int steps;
float angleState = 0.0;           // current state of the polariser
float dAngle;
int interStep_dt = 200;
float msecPerStep;
float usecPerStep;
float stepDelay_ms;
int dir;

unsigned long previousTime = 0;
unsigned long currentTime = 0;
unsigned long tic;
unsigned long toc;

// zero button connected to A0
const int buttonPin = A0;
volatile int buttonVal;

volatile unsigned long timeStamp = micros();

//........... char input params
const byte numChars = 32;
char receivedChars[numChars];
char tempChars[numChars];     // temporary array for use when parsing
// variables to hold the parsed data
char mode[numChars] = {0};
float inputTarget_deg = 0.0;
float inputSpeed_degsec = 0.0;
boolean newData = false;

//============

void setup() {
    pinMode(stepPin,OUTPUT);
    pinMode(dirPin,OUTPUT);
    pinMode(MS1Pin,OUTPUT);
    pinMode(MS2Pin,OUTPUT);
    pinMode(MS3Pin,OUTPUT);

    pinMode(buttonPin,INPUT_PULLUP);
    buttonVal = !digitalRead(buttonPin);  
    PCICR   |= B00000010; // Enable pin change interrupt group. bit0: PCMSK0 group 0, D8-13; bit1: PCMSK1 group 1, A0-A5; bit2: PCMSK2 group 2, D2-7 
    PCMSK1  |= B00000001; // A0 will trigger interrupt
    
    Serial.begin(115200);
}

//============ interrupt for zero button
ISR (PCINT1_vect){
  buttonVal = !(PINC & B00000001);
}


void loop() {
  
    recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
        parseData();
//        showParsedData();
            
        runMode();
//        showStepperResults();
        newData = false;
    }
//    printData();
    
    while (buttonVal==1){
      buttonZero();
    }
//    digitalWrite(zeroOutPin,HIGH);

}

//============

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;

    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

//============

void parseData() {      // split the data into its parts

    char * strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok(tempChars,",");      // get the first part - the string
    strcpy(mode, strtokIndx); // copy it to mode
 
    strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    inputTarget_deg = atof(strtokIndx);     // convert this part to an integer

    strtokIndx = strtok(NULL, ",");
    inputSpeed_degsec = atof(strtokIndx);     // convert this part to a float

}

//============

void showParsedData() {
    Serial.print("Mode: ");
    Serial.println(mode);
    Serial.print("inputTarget_deg: ");
    Serial.println(inputTarget_deg);
    Serial.print("inputSpeed_degsec: ");
    Serial.println(inputSpeed_degsec);
}


//============

void runMode() {
    
    //============= speed =============
    microStepRes  = 16.;
    stepsPerRev   = (200.*microStepRes)*gearMultiplier;
    msecPerStep   = (1000.*360./(stepsPerRev * inputSpeed_degsec )) - 0.02;
    
    if (msecPerStep < 0){
      msecPerStep = 0;
    }
    usecPerStep = msecPerStep*1000.;

    //============= microstepper resolution =============
    while (msecPerStep < 5.*interStep_dt/1000.){
      microStepRes = microStepRes/2.;

      stepsPerRev = (200.*microStepRes)*gearMultiplier;//*1.97642;
      msecPerStep  = (1000.*360./(stepsPerRev * inputSpeed_degsec )) - 0.02;
      if (msecPerStep < 0){
        msecPerStep = 0;
      }
      usecPerStep = msecPerStep*1000.;
    }

    digitalWrite(MS1Pin,LOW);
    digitalWrite(MS2Pin,LOW);
    digitalWrite(MS3Pin,LOW);
    if (microStepRes == 2. || microStepRes == 8. || microStepRes == 16.){
      digitalWrite(MS1Pin,HIGH);
    }
    if (microStepRes == 4. || microStepRes == 8. || microStepRes == 16.){
      digitalWrite(MS2Pin,HIGH);
    }
    if (microStepRes == 16.){
      digitalWrite(MS3Pin,HIGH);
    }


    //============= dAngle ============= 
    if (String(mode) == "pos"){
      dAngle = round(fmod(inputTarget_deg - angleState,360.));
      if (dAngle < 0){
        dAngle = 360.+dAngle;
      }
    }
    else if (String(mode) == "rot"){
        dAngle = inputTarget_deg;
    }
    else{
      dAngle = 0.;
    }

    //============= steps =============
    steps = round(abs(dAngle)*stepsPerRev/360.);

    //============= direction =============
    dir   = dAngle/abs(dAngle);
    if (dir > 0){
      digitalWrite(dirPin, HIGH);
    }
    else{
      digitalWrite(dirPin, LOW);
    }
    
    //============= run motor =============
    tic = micros();
    for (int x = 1; x <= steps; x++){
      previousTime = micros();

      digitalWrite(stepPin, HIGH);
      delayMicroseconds(interStep_dt);
      digitalWrite(stepPin, LOW);
      delayMicroseconds(interStep_dt);
      
      angleState = fmod(angleState + dir*(360./stepsPerRev),360.);
//      Serial.println(angleState);
//      printData();
      
      currentTime = micros();
      while(currentTime-previousTime < (usecPerStep) ){
        currentTime = micros();
      }

    }
    toc = micros();


}


void buttonZero(){
      digitalWrite(dirPin, HIGH);

      digitalWrite(MS1Pin,HIGH);
      digitalWrite(MS2Pin,HIGH);
      digitalWrite(MS3Pin,HIGH);

      digitalWrite(stepPin, HIGH);
      delayMicroseconds(800);
      digitalWrite(stepPin, LOW);
      delayMicroseconds(2000);

      angleState = 0;  
      
}



//============


void printData(){

  timeStamp     = micros();
  Serial.print(buttonVal);    Serial.print(",");
  Serial.print(timeStamp);    Serial.print(",");
  Serial.println(angleState);
  
}


void showStepperResults(){

    Serial.println("time elapsed: "+(String)((toc-tic)/1000.)+" ms");
    Serial.print("TargetIn: ");
    Serial.print(inputTarget_deg);
    Serial.print(" ");
    Serial.print("angState: ");
    Serial.println(angleState);
//    Serial.print(" ");
//    Serial.print("dAngle: ");
//    Serial.println(dAngle);

    Serial.print("msecPerStep: ");
    Serial.print(msecPerStep);
    Serial.print(" ");

    float msecPerStep_eff = ((toc-tic)/1000.)/steps;
    float degPerSec_eff   = 360./( stepsPerRev/1000.*(msecPerStep_eff) );
    
    Serial.print("msecPerStep_eff: ");
    Serial.print( msecPerStep_eff );
    Serial.print(" ");
    Serial.print("degPerSec_eff: ");
    Serial.print( degPerSec_eff );
    Serial.println(" ");

    Serial.print("microStepRes: ");
    Serial.print(microStepRes);    
    Serial.print(" ");
    Serial.print("stepsPerRev: ");
    Serial.print(stepsPerRev);
    Serial.print(" ");
    Serial.print("steps: ");
    Serial.println(steps);
    
    delay(500);

  
}
