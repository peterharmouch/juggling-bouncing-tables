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
Servo myservoB;
Servo myservoC;
Servo myservoA;

// Mode definition
int mode;
int a;

// Positions
float posB, posC, posA;

// Calibrate offsets
float offsetB = -3;
float offsetC = -1;
float offsetA = 4;

// Control parameters
float lowPos = 47;
float highPos = 57;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  posA = lowPos;
  posB = lowPos;
  posC = lowPos;

  // servos setup
  myservoA.attach(7);
  myservoB.attach(9);
  myservoC.attach(8);
  updateServos(posB, posC, posA);

  delay(4000);
  // mode initialization
  mode = DOWN;
  a = 1;
}

void loop() {
  PRBSGenerator prbs(millis());

  bool prbs_output = prbs();

  switch (mode) {
    case UP:
      posA = highPos;
      posB = highPos;
      posC = highPos;
      updateServos(posB, posC, posA);
      if (!prbs_output) {
        mode = DOWN;
      }
      break;

    case DOWN:
      posA = lowPos;
      posB = lowPos;
      posC = lowPos;
      updateServos(posB, posC, posA);
      if (prbs_output) {
        mode = UP;
      }
      break;

      }

      delay(100);
      
}

void updateServos(float posB, float posC, float posA) {
  myservoA.write(posA + offsetA);
  myservoB.write(posB + offsetB);
  myservoC.write(posC + offsetC);
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
