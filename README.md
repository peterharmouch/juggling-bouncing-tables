# juggling-bouncing-tables

Welcome to the GitHub repository for the Juggling Bouncing Tables Project! This project focuses on creating a table that can be controlled using three servos to manipulate the roll, pitch, and height of a top plate. The primary goal of the project is to enable the table to interact with a bouncing ball or aim the ball towards a specific point in space.

## Repository Structure
The repository is organized into the following main folders:

### Arduino Codes
This folder contains the Arduino codes that are used to control the physical table. The Arduino microcontroller is responsible for interfacing with the servos and implementing the desired control algorithms. Within this folder, you can find subfolders that separate the codes based on specific functionalities or versions.

### Control Loop Simulation
The Control Loop Simulation folder houses mathematical models implemented in MATLAB and Simulink. These simulations are used to evaluate and fine-tune the control algorithms for tracking the height, roll, and pitch of the table.

### System Identification
The System Identification folder focuses on identifying the dynamics of the system. It involves collecting data by applying a pseudo-random binary signal (PRBS) to the servos and using an opti-track system to measure the position of the table. Subfolders within this directory contain scripts, data files, and analysis results related to system identification.

### Table Kinematics
The Table Kinematics folder contains the mathematical model that forms the core of the project. Here, you can find the equations and algorithms used to calculate the position and orientation of the table based on the servo inputs. Additionally, this folder includes an experimental validation section, where the accuracy of the mathematical model is tested using real-world measurements.

## Contact
If you have any questions or feedback regarding this project, please don't hesitate to reach out to me:
**email:** peter.harmouch@epfl.ch
