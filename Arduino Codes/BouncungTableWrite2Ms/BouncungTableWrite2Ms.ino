#include <Servo.h>

Servo myservoA;
Servo myservoB;
Servo myservoC;

float qA = 30; float qB = 30; float qC = 30;

int msA; int msB; int msC;

void setup() {
  Serial.begin(115200);
  myservoA.attach(9);
  myservoB.attach(7);
  myservoC.attach(8);
  angleToMs();
  writeMsToServos();
  Serial.print("Print:"); Serial.print("\n");
}

void loop() {
  qA = 30; qB = 30; qC = 30;
  angleToMs();
  writeMsToServos();
  printMs();
  delay(500);

  qA = 60; qB = 30; qC = 30;
  angleToMs();
  writeMsToServos();
  printMs();
  delay(500);
}

void angleToMs(){
  const int min_angle = 0; const int max_angle = 90;
  const int min_msA = 500; const int max_msA = 1500;
  const int min_msB = 500; const int max_msB = 1500;
  const int min_msC = 500; const int max_msC = 1500;
   
  msA = (((qA - min_angle)/(max_angle - min_angle)) * (max_msA - min_msA)) + min_msA;
  msB = (((qB - min_angle)/(max_angle - min_angle)) * (max_msB - min_msB)) + min_msB;
  msC = (((qC - min_angle)/(max_angle - min_angle)) * (max_msC - min_msC)) + min_msC;
}

void writeMsToServos(){
  myservoA.writeMicroseconds(msA);
  myservoB.writeMicroseconds(msB);
  myservoC.writeMicroseconds(msC);
}

void printMs(){
  Serial.print(msA);
  Serial.print(" ");
  Serial.print(msB);
  Serial.print(" ");
  Serial.print(msC);
  Serial.print("\n");
}
