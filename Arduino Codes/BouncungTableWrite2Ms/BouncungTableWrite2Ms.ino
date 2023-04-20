#include <Servo.h>

Servo myservoA;
Servo myservoB;
Servo myservoC;

float qA = 30; float qB = 30; float qC = 30;

int msA; int msB; int msC;

void setup() {
  Serial.begin(115200);
  myservoA.attach(7);
  myservoB.attach(9);
  myservoC.attach(8);
  angleToServos();
  // Serial.print("Print:"); Serial.print("\n");
}

void loop() {
  angleToServos(); 
  /*
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
  */
}

void angleToMs(){
  const int min_angle = 0; const int max_angle = 90;
  const int min_msA = 690; const int max_msA = 1600;
  const int min_msB = 680; const int max_msB = 1580;
  const int min_msC = 650; const int max_msC = 1550;
   
  msA = (((qA - min_angle)/(max_angle - min_angle)) * (max_msA - min_msA)) + min_msA;
  msB = (((qB - min_angle)/(max_angle - min_angle)) * (max_msB - min_msB)) + min_msB;
  msC = (((qC - min_angle)/(max_angle - min_angle)) * (max_msC - min_msC)) + min_msC;
}

void writeMsToServos(){
  myservoA.writeMicroseconds(msA);
  myservoB.writeMicroseconds(msB);
  myservoC.writeMicroseconds(msC);
}

void angleToServos(){
  angleToMs();
  writeMsToServos();
}

void printMs(){
  Serial.print(msA);
  Serial.print(" ");
  Serial.print(msB);
  Serial.print(" ");
  Serial.print(msC);
  Serial.print("\n");
}
