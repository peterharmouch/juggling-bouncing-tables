#include <Servo.h>

Servo myservo1;
Servo myservo2;
Servo myservo3; 

float offset1 = -4;
float offset2 = -1;
float offset3 = 4;
float firstPos = 30;
float lastPos = 60;
float myDelay = 200;

void setup() {
  myservo1.attach(9);
  myservo2.attach(8);
  myservo3.attach(7);
  updateServos(firstPos);
}

void loop() {
  updateServos(firstPos);
  delay(myDelay);
  updateServos(lastPos);
  delay(myDelay);
}

void updateServos(float pos) {
  myservo1.write(pos + offset1);
  myservo2.write(pos + offset2);
  myservo3.write(pos + offset3);
}
