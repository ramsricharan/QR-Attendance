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
But then people used to walk out of the class as soon as the attendance has been marked. To avoid 
that, my professor came up with new idea i.e to take attendance in the beginning and ending of the 
class. So now we used to spend almost 15 mins in the entire 1 hr 30 mins class.
 
Coming from a generation where students pull out their phones to take a picture of the notes given by 
the teacher, I wanted to develop something students can sit right in their seats and answer the attendance
in the fastest way possible.


## Idea
   The main intention behind develping this app is to speed up the attendance taking process. QR Codes can 
   be scanned within fraction of seconds. With my app, the attendance for the entire class can be taken 
   within 1-2 mins. This saves a lot of valuble time which can be used to teach something else.
   
   
## Working
   1. It all starts when teacher creates a new attendance QR Code for the day. The QR Code is displayed on 
   their phones, so they can ask each individual student to come and scan their phone to get the attendance. 
   Or they can project the QR Code on to the Class Room projector using the public link provided by the app.
   
   2. Now Students in the class should scan this code. The app marks the student present only if he/she is 
   within the class radius.
   
   
   
   ## Technical Info
   * Used Firebase database for User Authentication, Database and Storage.
   * Used **AVFoundation** library to generating and providing camera view for scanning the code.
   * Used **CoreLocation Service** to get the users location which is used to validate their presence in the class.
   
   
   
   
   
