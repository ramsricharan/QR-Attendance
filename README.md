# QR Attendance
**The Fastest attendance taking app. It uses QR Code Technology and Location Services to mark attendance fast
and accurate.**


## Project Setup
```
 Category: Academic Project
 Programming Language: Swift 4
 IDE: XCode
 Platform: iOS
 ```
 

## Motive
   My professor used to spend almost 5-6 mins during the class hours to take the attendance of the class. 
But then people used to walk out of the class as soon as the attendance has been marked. To avoid that,
my professor came up with a new idea i.e to take attendance in the beginning and also at the end of the class. 
So now we used to spend almost 15 mins in the entire 1 hr 30 mins class.
 
Coming from a generation where students pull out their phones to take a picture of the notes given by 
the teacher to save valuable time :wink:, I wanted to develop something by which students can sit right
in their seats and answer the attendance in the fastest way possible.

---

## Intent
   The main intention behind developing this app is to speed up the attendance taking process. 
   QR Codes can be scanned within a fraction of seconds. Why not use this technology to take the attendance
   for the entire class just under **1-2 mins**. This saves a lot of valuable time which can be used to 
   teach something productive.
   
---
   
## Working
   1. It all starts with the teacher when they are ready to take the attendance. They should generate the 
   QR Code for the given day by selecting a few options like the QR Code validity period and Size of Classroom. 
   
   2. They have two ways in which they can present the QR Code to the class. The fastest way is to display 
   that QR Code on the classroom projector using the public link provided by the app, or more time-consuming 
   way is to ask each individual student to scan that code directly from their phones.
   
   2. Now Students in the class should scan this code. The app marks the student present only if he/she is 
   within the class radius.
   
   3. Teachers can track the detailed attendance history of each individual student in their class and can
   make any changes if necessary. Students can track their personal attendance history.
   
---
   
## Technical Info
   * This app has been built entirely on **Firebase**. Firebase Authentication is used to handle Login and 
   Signup workflow of users. Firebase Database is used to store the attendance and other user information. 
   Firebase Storage is used to store the QRCodes and Profile Images.
   * Used **AVFoundation** library to generating QR Codes and providing camera view for scanning the code.
   * Used **CoreLocation Service** to get the users location which is used to validate their presence in the class.
   * Implemented basic animaitons using **Core Animation**.
   
---- 
   
## Demos
   
### Screenshots
   <p float="left">
    <img src="Screen%20shot/IMG_3994.png" width="200">
    <img src="Screen%20shot/IMG_3998.png" width="200">
    <img src="Screen%20shot/IMG_4002.png" width="200">
    <img src="Screen%20shot/IMG_4004.png" width="200">
    <img src="Screen%20shot/IMG_4005.png" width="200">
    <img src="Screen%20shot/IMG_4007.png" width="200">
    <img src="Screen%20shot/IMG_4011.png" width="200">
    <img src="Screen%20shot/IMG_4012.png" width="200">  
    <img src="Screen%20shot/IMG_4019.png" width="200">
  </p>
  
### Video
<div align="left">
  <a href="https://www.youtube.com/watch?v=ttO0YJeC_aI&feature=youtu.be"><img src="https://img.youtube.com/vi/ttO0YJeC_aI/0.jpg" alt="IMAGE ALT TEXT"></a>
</div>
  
  
  
---- 
   
## Links
   * **Screen Shots:**  [Click Here](https://github.com/ramsricharan/QR-Attendance/tree/master/Screen%20shot) 
   * **Demo Video:** [Youtube](https://www.youtube.com/watch?v=ttO0YJeC_aI&feature=youtu.be)
   * **Documentation:** [Download PDF](https://drive.google.com/open?id=1ceZpQ5zsIT0cVKSUYMflW-XmKAVDRHYX)
   
   
