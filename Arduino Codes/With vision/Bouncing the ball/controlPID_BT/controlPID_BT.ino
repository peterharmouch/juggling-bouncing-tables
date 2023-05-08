#define LV_CMD_length 17 // MUST BE the same as in LabVIEW

#define PREADJUSTMENT 0
#define ADJUSTMENT 1
#define UP 2
#define DOWN 3
#define BACKTONORMAL 4

#include <Servo.h>

// Servos definition
Servo myservo1;
Servo myservo2;
Servo myservo3;

// Serial event
unsigned char LV_CMD[LV_CMD_length];
bool doUpdateParameter = false;       // need to update params, i.e. when all the params are received (3 x int16)

// Mode definition
int mode;

// Positions
float X, Y, Z=0, prevZ=0;
float dx = 0;
float dy = 0;
float pos1, pos2, pos3;

// PID variables
float lastErrorX = 0, lastErrorY = 0;
float cumErrorX = 0, cumErrorY = 0;
float errorX = 0, errorY = 0;
float deltaErrorX =0, deltaErrorY =0;
unsigned long currentTime, deltaTime, lastTime = 0;

// PID parameters
float Px, Py, Ix, Iy, Dx, Dy;

// PID constants
float maxPosDifference = 15;
float maxError = 60;
float antiWindup = 6000;

// Calibrate origin
float xOffsetOrigin = 160;    //middle of the table in x coordinates
float yOffsetOrigin = 120;    //middle of the table in y coordinates

// Calibrate offsets          //determined with the help of the calibration code
float offset1 = 20;
float offset2 = 20;
float offset3 = 25;

// Control parameters
float neutralPos = 35;        // The neutral position is the angle associated to the height of the table before the table reaches the threshold
float threshold = 48;         // The threshold is a height reached by the ball where the table adjusts its position
float jumpHeight = 45;        // The jump height is angle associated to the difference of height between the neutral position and the maximum position
float increment = 0.075;      // The increment controls the speed at which the table does the jump
float P = 0.1;               
float I = 0;                  
float D = 0.00001;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // servos setup
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos();

  // positions initialization
  pos1 = neutralPos;
  pos2 = neutralPos;
  pos3 = neutralPos;

  // mode initialization
  mode = PREADJUSTMENT;

  // Control parameters in the y direction must be half of those in the x direction
  Px = P;
  Py = P/2;
  Ix = I;
  Iy = I/2;
  Dx = D;
  Dy = D/2;
}

void loop() {  
  // update and ack params if any, note: async. arrival!
  if (doUpdateParameter) {
    X = getFloat(LV_CMD, 0);
    Y = getFloat(LV_CMD, 1);
    Z = getFloat(LV_CMD, 2); 
  }

  switch (mode) {
    case PREADJUSTMENT:
      if (Z >= threshold && ((Z - prevZ) > 0))    // Change mode when the ball reaches the threshold in the descending direction
        mode = ADJUSTMENT;
      break;

    case ADJUSTMENT:
      updatePositionsPID();
      updateServos();
      mode = UP;
      break;

    case UP:
      pos1 += increment;
      pos2 += increment;
      pos3 += increment;
      updateServos();
      if (pos3 >= (neutralPos + jumpHeight))  //The table reaches the desired jump height
        mode = DOWN;
      break;

    case DOWN:     
      pos1 -= increment;
      pos2 -= increment;
      pos3 -= increment;
      updateServos();
      if (pos3 <= neutralPos)   //The table returns to the adjusted position
        mode = BACKTONORMAL;
      break;

    case BACKTONORMAL:
      pos1 = neutralPos;
      pos2 = neutralPos;
      pos3 = neutralPos;
      updateServos();
      mode = PREADJUSTMENT;
      break;
  }

  prevZ = Z;    //saving the previous value of Z to know the direction of the ball
}

void updateServos() {
  myservo1.write(pos1 + offset1);
  myservo2.write(pos2 + offset2);
  myservo3.write(pos3 + offset3);
}

void updatePositionsPID() {
  // Calculate error
  errorX = X - xOffsetOrigin;
  errorY = Y - yOffsetOrigin;

  // Calculate deltaTime
  currentTime = millis(); 
  deltaTime = currentTime - lastTime;

  if (errorX > maxError)  errorX = maxError;
  if (errorX < -maxError) errorX = -maxError;
  if (errorY > maxError)  errorY = maxError;
  if (errorY < -maxError) errorY = -maxError;

  // Update cumError
  cumErrorX += errorX * deltaTime;
  cumErrorY += errorY * deltaTime;

  // anti-windup reset
  if (cumErrorX > antiWindup)  cumErrorX = antiWindup;
  if (cumErrorX < -antiWindup) cumErrorX = -antiWindup;
  if (cumErrorY > antiWindup)  cumErrorY = antiWindup;
  if (cumErrorY < -antiWindup) cumErrorY = -antiWindup;

  // Calculate deltaError
  if (deltaTime > 0) {
    deltaErrorX = (errorX - lastErrorX) / deltaTime;
    deltaErrorY = (errorY - lastErrorY) / deltaTime;
  }

  // Update lastTime and lastError
  lastTime = currentTime;
  lastErrorX = errorX;
  lastErrorY = errorY;

  // Update pos1 and pos2
  pos1 += Px*errorX - Py*errorY + Ix*cumErrorX - Iy*cumErrorY + Dx*deltaErrorX - Dy*deltaErrorY;
  pos2 += Px*errorX + Py*errorY + Ix*cumErrorX + Iy*cumErrorY + Dx*deltaErrorY + Dy*deltaErrorY;

  // Limit pos1 and pos2
  if (pos1 > neutralPos + maxPosDifference) pos1 = neutralPos + maxPosDifference;
  if (pos1 < neutralPos - maxPosDifference) pos1 = neutralPos - maxPosDifference;
  if (pos2 > neutralPos + maxPosDifference) pos2 = neutralPos + maxPosDifference;
  if (pos2 < neutralPos - maxPosDifference) pos2 = neutralPos - maxPosDifference;

  Serial.print("value: ");
  Serial.println(pos1-neutralPos);
}

float getFloat(unsigned char LV_CMD[],int pos) {      // assume that you ask for a valid position!!!!
  int offset = (4*pos);
  unsigned char tmp[4] = {LV_CMD[3+offset], LV_CMD[2+offset], LV_CMD[1+offset], LV_CMD[0+offset]};
  float tmpF = *(float*)&tmp[0];
  return tmpF;
}

/*
  SerialEvent occurs whenever a new data comes in the hardware serial RX. This
  routine is run between each time loop() runs, so using delay inside loop can
  delay response. Multiple bytes of data may be available.
*/

void serialEvent() {      // assume fixed size command, assume last char should be '\n'
  int bytesInBuffer= Serial.available() ;
  if (bytesInBuffer >= LV_CMD_length) {     // got a full CMD from LV
     for(int i=0; i<LV_CMD_length; i++) LV_CMD[i] = Serial.read();
     if (LV_CMD[LV_CMD_length-1] == '\n') doUpdateParameter = true;     //terminal char OK, we're clear to go
  }
}
