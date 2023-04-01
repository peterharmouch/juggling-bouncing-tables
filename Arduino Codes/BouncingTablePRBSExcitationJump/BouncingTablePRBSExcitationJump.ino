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
float pos1, pos2, pos3;

// Calibrate offsets
float offset1 = -4;
float offset2 = -1;
float offset3 = 4;

// Control parameters
float lowPos = 30;
float highPos = 40;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  pos1 = lowPos;
  pos2 = lowPos;
  pos3 = lowPos;

  // servos setup
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos(pos1, pos2, pos3);

  // mode initialization
  mode = DOWN;
  a = 1;
}

void loop() {
  PRBSGenerator prbs(millis());

  bool prbs_output = prbs();

  switch (mode) {
    case UP:
      pos1 = highPos;
      pos2 = highPos;
      pos3 = highPos;
      updateServos(pos1, pos2, pos3);
      if (!prbs_output) {
        mode = DOWN;
      }
      break;

    case DOWN:
      pos1 = lowPos;
      pos2 = lowPos;
      pos3 = lowPos;
      updateServos(pos1, pos2, pos3);
      if (prbs_output) {
        mode = UP;
      }
      break;

      }

      delay(100);
      
}

void updateServos(float pos1, float pos2, float pos3) {
  myservo1.write(pos1 + offset1);
  myservo2.write(pos2 + offset2);
  myservo3.write(pos3 + offset3);
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
