#include <Servo.h>

Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a 
Servo myservo3;  // create servo object to control a servo
// twelve servo objects can be created on most boards

float offset1 = -4;   //  balck plexi at 30: -5   at 50: -5    at 70: -4   Hex Plexi -3
float offset2 = 10;    //  black plexi at 30: -5    at 50: -4     at 70: -4    Hex Plexi 10
float offset3 = 15;   //  black plexi at 30: 1    at 50: 1    at 70: 1    Hex Plexi 0

int pos = 30;
int pos1 = pos;    // variable to store the servo position
int pos2 = pos;    // variable to store the servo position
int pos3 = pos;    // variable to store the servo position

void setup() {
  myservo1.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo2.attach(8);
  myservo3.attach(7);
}

void loop() {
    myservo1.write(pos1 + offset1);              // tell servo to go to position in variable 'pos'
    myservo2.write(pos2 + offset2); 
    myservo3.write(pos3 + offset3);
}
