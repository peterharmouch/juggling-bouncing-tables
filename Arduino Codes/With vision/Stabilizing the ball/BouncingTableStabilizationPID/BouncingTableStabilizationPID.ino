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
float X, Y, Z=0, prevX=0, prevY=0;
float dx = 0;
float dy = 0;
float pos1, pos2, pos3;

// Calibrate origin
float xOffsetOrigin = 160;
float yOffsetOrigin = 110;

// Calibrate offsets
float offset1 = -11;
float offset2 = 9;
float offset3 = 0;

// Errors
unsigned long lastTime = 0;
float lastErrorX = 0;
float lastErrorY = 0;
float cumErrorX = 0;
float cumErrorY = 0;
float errorX = 0;
float errorY = 0;
float deltaErrorX =0;
float deltaErrorY =0;
unsigned long currentTime, deltaTime;
float maxPosDifference = 15;
float maxError = 60;
float antiWindup = 6000;

// Control parameters
float neutralPos = 30;
float threshold = 50;
float P = 0.05;    //0.5;
float I = 0; //0.000001; //0.0002;    //0.02;
float D = 0;//0.00001;    //2*(10^8);

float Px = P;
float Py = P/2;
float Ix = I;
float Iy = I/2;
float Dx = D;
float Dy = D/2;

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
  updateServos();

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

  switch (mode) {
    case PREADJUSTMENT:
      if (Z >= threshold)
        mode = ADJUSTMENT;
      if (Z < 40)
        updateServos();
      break;
      
    case ADJUSTMENT:
      updatePositions(X, Y);
      updateServos();
      mode = BACKTONORMAL;
      break;
      
    case BACKTONORMAL:
      pos1 = neutralPos;
      pos2 = neutralPos;      //we don't update servos in BACKTONORMAL
      mode = PREADJUSTMENT;
      break;
  }
  prevX = X;
  prevY = Y;
}

void updateServos() {
  myservo1.write(pos1 + offset1);
  myservo2.write(pos2 + offset2);
  myservo3.write(pos3 + offset3);
}

void updatePositions(float X, float Y){
 // Calculate deltaTime
 Serial.print("value: ");

 // Calculate error
 errorX = X - xOffsetOrigin;
 errorY = Y - yOffsetOrigin;
 
 if ((X != prevX) || (Y != prevY)) {
  currentTime = millis(); 
  deltaTime = currentTime - lastTime;

  if (errorX > maxError)  errorX = maxError;
  if (errorX < -maxError) errorX = -maxError;
  if (errorY > maxError)  errorY = maxError;
  if (errorY < -maxError) errorY = -maxError;

  // Update cumError
  cumErrorX += errorX; // * deltaTime;
  cumErrorY += errorY; // * deltaTime;

  if (cumErrorX > antiWindup)  cumErrorX = antiWindup;
  if (cumErrorX < -antiWindup) cumErrorX = -antiWindup;
  if (cumErrorY > antiWindup)  cumErrorY = antiWindup;
  if (cumErrorY < -antiWindup) cumErrorY = -antiWindup;

  // Calculate deltaError
  deltaErrorX = (errorX - lastErrorX); // / deltaTime;
  deltaErrorY = (errorY - lastErrorY); // / deltaTime;
  
  // Update lastTime and lastError
  lastTime = currentTime;
  lastErrorX = errorX;
  lastErrorY = errorY;
}
  // Update pos1 and pos2
  pos1 += Px*errorX - Py*errorY + (Ix*cumErrorX*deltaTime) - (Iy*cumErrorY*deltaTime) + (Dx*deltaErrorX/deltaTime) - (Dy*deltaErrorY/deltaTime);
  pos2 += Px*errorX + Py*errorY + (Ix*cumErrorX*deltaTime) + (Iy*cumErrorY*deltaTime) + (Dx*deltaErrorX/deltaTime) + (Dy*deltaErrorY/deltaTime);

  if (pos1 > neutralPos + maxPosDifference) pos1 = neutralPos + maxPosDifference;
  if (pos1 < neutralPos - maxPosDifference) pos1 = neutralPos - maxPosDifference;
  if (pos2 > neutralPos + maxPosDifference) pos2 = neutralPos + maxPosDifference;
  if (pos2 < neutralPos - maxPosDifference) pos2 = neutralPos - maxPosDifference;
 
  Serial.println(errorY);
}

float getFloat(unsigned char LV_CMD[],int pos) {
  // assume that you ask for a valid position!!!!
  int offset = (4*pos);
  unsigned char tmp[4] = { LV_CMD[3+offset],LV_CMD[2+offset],LV_CMD[1+offset],LV_CMD[0+offset]};
  float tmpF = *(float*)&tmp[0];
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

  int bytesInBuffer = Serial.available() ;
  if (bytesInBuffer >= LV_CMD_length) { // got a full CMD from LV

    for(int i = 0; i < LV_CMD_length; i++) {
      LV_CMD[i] = Serial.read();
    }

    if (LV_CMD[LV_CMD_length-1] == '\n') {
      //terminal char OK, we're clear to go
      doUpdateParameter = true;
    }
  }
}
