#define LV_CMD_length 17 // MUST BE the same as in LabVIEW

#define PREADJUSTMENT 0
#define ADJUSTMENT 1
#define UP 2
#define DOWN 3
#define BACKTONORMAL 4

#include <Servo.h>

// servos definition
Servo myservo1;
Servo myservo2;
Servo myservo3;

// Salzmann
unsigned char LV_CMD[LV_CMD_length];
bool doUpdateParameter = false;       // need to update params, i.e. when all the params are received (3 x int16)

// Mode definition
int mode;

// Positions
float X, Y, Z=0, prevZ;
float dx = 0;
float dy = 0;
float pos1, pos2, pos3;
float adjustedPos1, adjustedPos2, adjustedPos3, pos1BeforeJump;

// Calibrate origin
float xOffsetOrigin = 165;
float yOffsetOrigin = 120;

// Calibrate offsets
float offset1 = -7;
float offset2 = 8;
float offset3 = 0;

// Control parameters
float neutralPos = 30;
float threshold = 50;
float kx = 20;
float ky = 40;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  pos1 = neutralPos;
  pos2 = neutralPos;
  pos3 = neutralPos;

  // servos setup
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos(pos1, pos2, pos3);

  // mode initialization
  mode = PREADJUSTMENT;
}

void loop() {  
  // update and ack params if any, note: async. arrival!
  if (doUpdateParameter) {
    X = getFloat(LV_CMD,0);
    Y = getFloat(LV_CMD,1);
    Z = getFloat(LV_CMD,2); 
  }

  dx = X - xOffsetOrigin;
  dy = Y - yOffsetOrigin;

  if(dx > 50)  {dx = 50;}
  if(dx < -50) {dx = -50;}
  if(dy > 50)  {dy = 50;}
  if(dy < -50) {dy = -50;}

  adjustedPos1 = pos1 + (dx/kx) - (dy/ky);
  adjustedPos2 = pos2 + (dx/kx) + (dy/ky);
  adjustedPos3 = pos3; 

  switch (mode) {
    case PREADJUSTMENT:
      if (Z >= threshold)
        mode = ADJUSTMENT;
      break;
      
    case ADJUSTMENT:
      pos1 = adjustedPos1;
      pos2 = adjustedPos2;
      pos3 = adjustedPos3;
      updateServos(pos1, pos2, pos3);
      mode = BACKTONORMAL;
      break;
      
    case BACKTONORMAL:
      pos1 = neutralPos;
      pos2 = neutralPos;
      pos3 = neutralPos;
      mode = PREADJUSTMENT; //we don't update servos in BACKTONORMAL
      break;
  }
}

void updateServos(float pos1, float pos2, float pos3) {
  myservo1.write(pos1 + offset1);
  myservo2.write(pos2 + offset2);
  myservo3.write(pos3 + offset3);
}

float getFloat(unsigned char LV_CMD[],int pos) {
  // assume that you ask for a valid position!!!!
  int offset = (4*pos);
  unsigned char tmp[4] = { LV_CMD[3+offset],LV_CMD[2+offset],LV_CMD[1+offset],LV_CMD[0+offset]};
  float tmpF= *(float*)&tmp[0];
  return tmpF;
}

/*
  SerialEvent occurs whenever a new data comes in the hardware serial RX. This
  routine is run between each time loop() runs, so using delay inside loop can
  delay response. Multiple bytes of data may be available.
*/

void serialEvent() {
  // assume fixed size command, 
  // assume last char should be '\n'

  int bytesInBuffer= Serial.available() ;
  if (bytesInBuffer >= LV_CMD_length) {// got a full CMD from LV

     for(int i=0; i<LV_CMD_length; i++) {
      LV_CMD[i] = Serial.read();
    }

     if (LV_CMD[LV_CMD_length-1] == '\n') {
     //terminal char OK, we're clear to go
      doUpdateParameter = true;
    }
  }
}
