![SlopeStats](https://github.com/user-attachments/assets/b98bcfee-b19b-4d68-bb07-fddfa40e4163)

<h2><img src="https://github.com/user-attachments/assets/3d4b925e-26bb-48b7-9775-020f5ce95f9d" width="30"> Track skiing/snowboarding activity on the go with SlopeStats</h2>

## Table of Contents
- [About](#-about)
- [Wireless Connectivity](#-wireless-connectivity)
- [Database](#-database)
- [Activity Tracking](#%EF%B8%8F-activity-tracking)
- [Resort & Weather information](#%EF%B8%8F-weather--resort-info-)

## 🏂 About
**SlopeStats** is a watchOS + iOS app which has multiple modes of tracking activity for skiing & snowboarding. It offers the following features:

| Feature        | Demo                                                                                                      | Description | Technologies |
| :------------- | :------------------------------------------------------------------------------------------------------- | :---------- | :----------- |
| Run Tracking   | <img src="https://github.com/user-attachments/assets/c3ee6ea4-7592-4869-800b-3033c9a6216e" width="120">  | "Run tracking" stores the altitude, heart rate, speed, top speed, and duration of an entire slope run. This data is then sent to the iOS companion app, stored locally on the iPhone, and displayed where you can view the history of your previous runs. Discover insights and visualize your data in charts to see how your performance varies from run to run. | HealthKit, CoreMotion, Core Data, WatchConnectivity |
| Speed Mode     | <img src="https://github.com/user-attachments/assets/60f24e16-a884-4d08-a946-a0acdac836bf" width="120">  | "Speed Mode" allows users to to "ghost racing" where they can select a time to beat. During the run, they get more insights on their speed (rather than altitude, heart rate, etc). If they don't end the run before the "time to beat" expires, they are notified that the time has expired. | CoreMotion, Core Data, watchConnectivity |
| Resort Info    | <img src="https://github.com/user-attachments/assets/f2442522-a50f-4bbe-ac02-465bf11dd71c" width="120">  | Users can select a resort from a dropdown list of options provided by a public ski resort API. When the user confirms the action, we hit the API to get information about the status of lifts, snow conditions, and even tweets. | Ski API (Rapid API) |
| Weather Info   | <img src="https://github.com/user-attachments/assets/b98cbac5-369a-4846-83ab-68bb3bd88197" width="120">  | Using Core Location, we can send the iPhone's latitude and longitude to a weather API and get a response for skiers to get insights on the skiing conditions. The watch app doesn't directly hit the API, instead, it uses WCSesssion to communicate with the iPhone. The iPhone then hits the API and sends the data back to the watch. | Core Location, WeatherStack API |

## 🌐 Wireless Connectivity

![wcsession](https://github.com/user-attachments/assets/8fd567c2-e7cc-47fd-a30a-ad88bb033db9)

Since I wanted to store the data for each run locally on the iPhone, I used **Watch Connectivity** to send the data from the Apple watch. This proved to be the most difficult part of the project. I ran into a lot of issues with connecting the iPhone & Watch simulators, but eventually got it to work.

## 📦 Database

<img width="267" alt="Screenshot 2024-12-29 at 11 05 16 PM" src="https://github.com/user-attachments/assets/59927ac1-77db-4568-8333-1f169f6b7214" />

Rather than using a Realm database, I chose to go with the Apple native **Core Data** persistence framework. This was pretty easy to implement into the project. I just had to create a persistance controller (singleton pattern) and a custom transformer to store the data.
<br>
<br>
Pros of using Core Data:
- Synchronization with iCloud (if I continued development on this app)
- Optimized performance for Apple products
- Full support for SwiftUI & UIKit

## ⛷️ Activity Tracking
<p>*Note that the data sent from watch to iPhone is a predefined array of values since it's in the xCode simulator. Real data is collected periodically and sent when running on the actual devices.</p><br>
<img src="https://github.com/user-attachments/assets/672f425a-f764-4e1e-bcc4-ff21b5dfd92f" width="500"><br>
Used Apple built-in frameworks to monitor altitude, heart rate, and speed/acceleration.<br>

- <img src="https://github.com/user-attachments/assets/1fec60c9-b73a-4416-ae21-8cd36b409c46" width="30"> **Core Motion**
  - Used the Altimeter to periodically store the altitude
  - Used the Accelerometer to record speed (also tracking the top speed for the run)

- <img src="https://github.com/user-attachments/assets/7f7a3ca0-653e-49d9-a771-1c7264b72f6f" width="30"> **HealthKit**
  - Periodically stored heart rate measurements in an array to be sent to the iPhone and visualized in a graph.

## 🌦️ Weather & Resort Info 🌲

<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/6ee3e2e8-e4dc-41a7-9ba0-b8ece20832ae" alt="Image Description" width="200"/>
    </td>
    <td>
      <p>I used the <img src="https://github.com/user-attachments/assets/6a460540-01f2-4b19-9f1b-bd31e01a31fc" width="120"> API to get real-time updates on skiing conditions. I only included the skiing-relevant measurements like temperture, wind conditions, etc from the json response.</p>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/05cc56fd-58ac-454f-936b-8051a22e2cd6" alt="Image Description" width="200"/>
    </td>
    <td>
      <p>I used <img src="https://github.com/user-attachments/assets/58b9f10b-d276-417c-b77a-7c9b95d0a53a" height="20"> to get real-time updates on resort information. This API provided details on the lift status, weather, snow conditions, and even twitter feeds.</p>
    </td>
  </tr>
</table>
