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
Servo myservoA;
Servo myservoB;
Servo myservoC;

// Mode definition
int mode;
int a;

// Positions
float posB, posC, posA;

// Calibrate offsets
float offsetA = 4;
float offsetB = -3;
float offsetC = -1;

// Control parameters
float lowA = 49;
float lowB = 56;
float lowC = 50;

float highA = 58;
float highB = 64;
float highC = 60;

int idTime = 20000;
int delayTime = 10;

void setup() {
  // initialize serial
  Serial.begin(115200);

  // positions initialization
  posA = lowA;
  posB = lowB;
  posC = lowC;

  // servos setup
  myservoA.attach(7);
  myservoB.attach(9);
  myservoC.attach(8);
  updateServos(posB, posC, posA);

  delay(4000);

  // mode initialization
  mode = DOWN;
  a = 1;
  Serial.println("Printing PRBS values to Serial Monitor");
}

void loop() {
  PRBSGenerator prbs(millis());
  bool prbs_output = prbs();
  static unsigned long startTime = millis();

  Serial.println(prbs_output);

  // Store PRBS values for 20 seconds
  if (millis() - startTime > 20000) {
    posA = lowA;
    posB = lowB;
    posC = lowC;
    updateServos(posB, posC, posA);
    while (true);  // Stop program execution
  }

  switch (mode) {
    case UP:
      posA = highA;
      posB = highB;
      posC = highC;
      updateServos(posB, posC, posA);
      if (!prbs_output) {
        mode = DOWN;
      }
      break;

    case DOWN:
      posA = lowA;
      posB = lowB;
      posC = lowC;
      updateServos(posB, posC, posA);
      if (prbs_output) {
        mode = UP;
      }
      break;
  }
  delay(delayTime);
}

void updateServos(float posB, float posC, float posA) {
  myservoA.write(posA + offsetA);
  myservoB.write(posB + offsetB);
  myservoC.write(posC + offsetC);
}
