![SlopeStats](https://github.com/user-attachments/assets/b98bcfee-b19b-4d68-bb07-fddfa40e4163)

INSERT DEMO VIDEO

⛷️ Track skiing/snowboarding activity on the go with SlopeStats

## Table of Contents
- [About](#-about)
- [Wireless Connectivity](#-wireless-connectivity)
- [Database](#-database)
- [Activity Tracking](#-activity-tracking)
- [Resort & Weather information](#-resort-and-weather-tracking)

## 🏂 About
**SlopeStats** is a watchOS + iOS app which has multiple modes of tracking activity for skiing & snowboarding. It offers the following features:

| Feature        | Demo                                                                                                      | Description | Technologies |
| :------------- | :------------------------------------------------------------------------------------------------------- | :---------- | :----------- |
| Run Tracking   | <img src="https://github.com/user-attachments/assets/c3ee6ea4-7592-4869-800b-3033c9a6216e" width="120">  | "Run tracking" stores the altitude, heart rate, speed, top speed, and duration of an entire slope run. This data is then sent to the iOS companion app, stored locally on the iPhone, and displayed where you can view the history of your previous runs. Discover insights and visualize your data in charts to see how your performance varies from run to run. | HealthKit, CoreMotion, Core Data, WatchConnectivity |
| Speed Mode     | <img src="https://github.com/user-attachments/assets/60f24e16-a884-4d08-a946-a0acdac836bf" width="120">  | "Speed Mode" allows users to to "ghost racing" where they can select a time to beat. During the run, they get more insights on their speed (rather than altitude, heart rate, etc). If they don't end the run before the "time to beat" expires, they are notified that the time has expired. | CoreMotion, Core Data, watchConnectivity |
| Resort Info    | <img src="https://github.com/user-attachments/assets/f2442522-a50f-4bbe-ac02-465bf11dd71c" width="120">  | x           | x            |
| Weather Info   | <img src="https://github.com/user-attachments/assets/b98cbac5-369a-4846-83ab-68bb3bd88197" width="120">  | x           | x            |

## 🌐 Wireless Connectivity
Since I wanted to store the data for each run locally on the iPhone, I used **Watch Connectivity** to send the data from the Apple watch. This proved to be the most difficult part of the project. I ran into a lot of issues with connecting the iPhone & Watch simulators, but eventually got it to work.

## 📦 Database
Rather than using a Realm database, I chose to go with the Apple native **Core Data** persistence framework. This was pretty easy to implement into the project. I just had to create a persistance controller (singleton pattern) and a custom transformer to store the data.

## ️‍🔥 Activity Tracking
Used Apple built-in frameworks to monitor altitude, heart rate, and speed/acceleration.
- <img src="https://github.com/user-attachments/assets/1fec60c9-b73a-4416-ae21-8cd36b409c46" width="30"> **Core Motion**
  - Used the Altimeter to periodically store the altitude
  - Used the Accelerometer to record speed (also tracking the top speed for the run)

- <img src="https://github.com/user-attachments/assets/7f7a3ca0-653e-49d9-a771-1c7264b72f6f" width="30"> **HealthKit**
  - Periodically stored heart rate measurements in an array to be sent to the iPhone and visualized in a graph.

## 🌦️ Weather & Resort Info 🌲
