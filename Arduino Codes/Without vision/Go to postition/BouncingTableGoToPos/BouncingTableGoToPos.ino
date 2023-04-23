#include <Servo.h>

Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a 
Servo myservo3;  // create servo object to control a servo
// twelve servo objects can be created on most boards

float offsetA = 4;   //  black plexi at 30: 1    at 50: 1    at 70: 1    Hex Plexi 0
float offsetB = -3;   //  balck plexi at 30: -5   at 50: -5   at 70: -4   Hex Plexi -3
float offsetC = -1;   //  black plexi at 30: -5   at 50: -4   at 70: -4    Hex Plexi 10

int pos = 77;
int qA = 58;    // variable to store the servo position //qA  
int qB = 64;    // variable to store the servo position //qB
int qC = 60;    // variable to store the servo position //qC

void setup() {
  myservo1.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo2.attach(8);
  myservo3.attach(7);
}

void loop() {
    myservo3.write(qA + offsetA);
    myservo1.write(qB + offsetB);              // tell servo to go to position in variable 'pos'
    myservo2.write(qC + offsetC); 
}
