# QR-Attendance
**The Fastest attendance taking app. It uses QR Code Technology to mark attendance of the class.**


### Project Setup
```
 Category: Academic Project
 Programming Language: Swift 4
 IDE: XCode
 Platform: iOS
 ```
 
 ## Back Story
   My professor used to spend almost 5-6 mins during the class hours to the attendance of the class. 
But then people used to walk out of the class as soon as the attendance has been marked. To avoid that,
my professor came up with a new idea i.e to take attendance in the beginning and end of the class. 
So now we used to spend almost 15 mins in the entire 1 hr 30 mins class.
 
Coming from a generation where students pull out their phones to take a picture of the notes given by 
the teacher, I wanted to develop something students can sit right in their seats and answer the attendance
in the fastest way possible.


## Idea
   The main intention behind developing this app is to speed up the attendance taking process. 
   QR Codes can be scanned within a fraction of seconds. With my app, the attendance for the entire class 
   can be taken within**1-2 mins**. This saves a lot of valuable time which can be used to teach something else.
   
   
## Working
   1. It all starts with the teacher when they are ready to take the attendance. They should generate the 
   QR Code for the given day by selecting a few options like the QR Code validity period and Size of Classroom. 
   
   2. They have two ways in which they can present the QR Code to the class. The fastest way is to display 
   that QR Code on the classroom projector using the public link provided by the app or more time-consuming 
   way is to ask each individual student to scan that code directly from their phones.
   
   2. Now Students in the class should scan this code. The app marks the student present only if he/she is 
   within the class radius.
   
   3. Teachers can track the detailed attendance history of each individual student in their class and can
   make any changes if necessary. Students can track their personal attendance history.
   
   
   ## Technical Info
   * This app has been built entirely on **Firebase**. Firebase Authentication is used to handle Login and 
   Signup workflow of users. Firebase Database is used to store the attendance and other user information. 
   Firebase Storage is used to store the QRCodes and Profile Images.
   * Used **AVFoundation** library to generating QR Codes and providing camera view for scanning the code.
   * Used **CoreLocation Service** to get the users location which is used to validate their presence in the class.
   * Implemented basic animaitons using **Core Animation**.
   
   
   
   ## Demos
   **Demo Video:** [Youtube](https://www.youtube.com/watch?v=ttO0YJeC_aI&feature=youtu.be)
   
   **Documentation:** [Download PDF](https://drive.google.com/open?id=1ceZpQ5zsIT0cVKSUYMflW-XmKAVDRHYX)
   
   
   
