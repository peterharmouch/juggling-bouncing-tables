#define UP 1
#define DOWN 2
#define BACKTONORMAL 3

#include <Servo.h>

// Servos definition
Servo myservo1;
Servo myservo2;
Servo myservo3;

// Mode definition
int mode;
float qA; float qB; float qC; float qBBeforeJump;
int cpt; int maxCpt;

float highA = 87;
float highB = 47;
float highC = 47;

float lowA = 57;
float lowB = 17;
float lowC = 17;

// Calibrate offsets          //determined with the help of the calibration code
float offsetA = 4;
float offsetB = -4;
float offsetC = 0;

// Control parameters
float jumpHeight = 40;
float incrementA = 0.06;
float incrementB;
float incrementC;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  qA = 47;
  qB = 17;
  qC = 17;

  // servos setup
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos(qB, qC, qA);

  // mode initialization
  mode = BACKTONORMAL;
  cpt = 0;

  // Useful computations
  maxCpt = (highA - lowA) / incrementA;
  incrementB = (highB - lowB) / maxCpt;
  incrementC = (highC - lowC) / maxCpt;
  
}

void loop() {  

  switch (mode) {
    case UP:
      cpt++;
      qA += incrementA;
      qB += incrementB;
      qC += incrementC;
      updateServos(qB, qC, qA);
      if (cpt > maxCpt) //when the table reaches the desired jump height
        mode = DOWN;
      break;
      
    case DOWN:
      cpt--;
      qA -= incrementA;
      qB -= incrementB;
      qC -= incrementC;
      updateServos(qB, qC, qA);
      if (cpt < 1)      //when the table returns to the adjusted position
        mode = BACKTONORMAL;
      break;

    case BACKTONORMAL:
      qA = 47;
      qB = 17;
      qC = 17;
      qBBeforeJump = qB;
      cpt = 0;
      updateServos(qB, qC, qA);
      mode = UP;
      delay(100);
      break;
  }
}

void updateServos(float qB, float qC, float qA) {
  myservo3.write(qA + offsetA);
  myservo1.write(qB + offsetB);
  myservo2.write(qC + offsetC);
}
