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
float lowA = 47;
float lowB = 47;
float lowC = 47;

float highA = 57;
float highB = 57;
float highC = 57;

int idTime = 20000;
int delayTime = 10;

void setup() {
  // initialize serial
  Serial.begin(115200);
  
  pinMode(LED_BUILTIN, OUTPUT);
  // positions initialization
  posA = lowA;
  posB = lowB;
  posC = lowC;

  // servos setup
  myservoA.attach(7);
  myservoB.attach(9);
  myservoC.attach(8);
  updateServos(posB, posC, posA);
  digitalWrite(LED_BUILTIN, LOW);

  delay(4000);
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
    posA = highA;
    posB = highB;
    posC = highC;
    updateServos(posB, posC, posA);
}

void updateServos(float posB, float posC, float posA) {
  myservoA.write(posA + offsetA);
  myservoB.write(posB + offsetB);
  myservoC.write(posC + offsetC);
}
