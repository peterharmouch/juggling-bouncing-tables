#define UP 1
#define DOWN 2

#include <Servo.h>

// PRBS generator based on Galois LFSR algorithm
class PRBSGenerator {
public:
    PRBSGenerator(unsigned int seed) : state(seed) {}

    bool operator()() {
        bool feedback = (state & 0x1) ^ ((state & 0x2) >> 1);
        state = (state >> 1) | (feedback ? 0x80000000 : 0);
        return feedback;
    }

private:
    unsigned int state;
};

// Servos definition
Servo myservo1;
Servo myservo2;
Servo myservo3;

// Mode definition
int mode;
int a;

// Positions
float qB, qC, qA;

// Calibrate offsets
float offset1 = -4;
float offset2 = 0;
float offset3 = 4;

// Control parameters
float lowPos = 47;
float highPos = 57;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  qA = lowPos;
  qB = lowPos;
  qC = lowPos;

  // servos setup
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos(qB, qC, qA);

  // mode initialization
  mode = DOWN;
  a = 1;
}

void loop() {
  PRBSGenerator prbs(millis());

  bool prbs_output = prbs();

  switch (mode) {
    case UP:
      qA = highPos;
      qB = lowPos;
      qC = lowPos;
      updateServos(qB, qC, qA);
      if (!prbs_output) {
        mode = DOWN;
      }
      break;

    case DOWN:
      qA = lowPos;
      qB = lowPos;
      qC = lowPos;
      updateServos(qB, qC, qA);
      if (prbs_output) {
        mode = UP;
      }
      break;

      }

      delay(100);
      
}

void updateServos(float qB, float qC, float qA) {
  myservo1.write(qB + offset1);
  myservo2.write(qC + offset2);
  myservo3.write(qA + offset3);
}

void delayMix() {
  if (a == 1) {
    delay(50);
   a = 2;
  }
  else if (a == 2) {
    delay(75);
    a = 3;
  }
  else {
    delay(100);
    a = 1;
  }
}
