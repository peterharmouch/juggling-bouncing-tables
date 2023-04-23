#include <Servo.h>

Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a 
Servo myservo3;  // create servo object to control a servo
// twelve servo objects can be created on most boards

float offset1 = -4;   //  balck plexi at 30: -7  at 70: -5   Hex Plexi -3
float offset2 = -4;    //  black plexi at 30: 8   at 70: 5    Hex Plexi 10
float offset3 = 1;   //  black plexi at 30: 0   at 70: -5    Hex Plexi 0

int pos1 = 30;    // variable to store the servo position
int pos2 = 30;    // variable to store the servo position
int pos3 = 30;    // variable to store the servo position

float kx = 10;
float ky = 20;
float Px = 1/kx;
float Py = 1/ky;

float errorX = 0;
float errorY = 100;

void setup() {
  myservo1.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo2.attach(8);
  myservo3.attach(7);
  pos1 += Px*errorX - Py*errorY;
  pos2 += Px*errorX + Py*errorY;
}

void loop() {
    myservo1.write(pos1 + offset1);              // tell servo to go to position in variable 'pos'
    myservo2.write(pos2 + offset2); 
    myservo3.write(pos3 + offset3);
}
