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
      <details>
      <summary>Example API Response</summary>

  ```json
      {
      "request": {
          "type": "City",
          "query": "San Francisco, United States of America",
          "language": "en",
          "unit": "m"
      },
      "location": {
          "name": "San Francisco",
          "country": "United States of America",
          "region": "California",
          "lat": "37.775",
          "lon": "-122.418",
          "timezone_id": "America/Los_Angeles",
          "localtime": "2019-09-03 05:35",
          "localtime_epoch": 1567488900,
          "utc_offset": "-7.0"
      },
      "current": {
          "observation_time": "12:35 PM",
          "temparature": 16,
          "weather_code": 122,
          "weather_icons": [
              "https://assets.weatherstack.com/images/symbol.png"
          ],
          "weather_descriptions": [
              "Overcast"
          ],
      "wind_speed": 17,
      "wind_degree": 260,
      "wind_dir": "W",
      "pressure": 1016,
      "precip": 0,
      "humidity": 87,
      "cloudcover": 100,
      "feelslike": 16,
      "uv_index": 0,
      "visibility": 16
      }
    }
  ```
  </details>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/05cc56fd-58ac-454f-936b-8051a22e2cd6" alt="Image Description" width="200"/>
    </td>
    <td>
      <p>I used <img src="https://github.com/user-attachments/assets/58b9f10b-d276-417c-b77a-7c9b95d0a53a" height="20"> to get real-time updates on resort information. This API provided details on the lift status, weather, snow conditions, and even twitter feeds.</p>
            <details>
      <summary>Example API Response</summary>

  ```json
      {
      "data": {
        "slug": "whistler-blackcomb",
        "name": "Whistler Blackcomb",
        "country": "CA",
        "region": "BC",
        "href": "http://www.whistlerblackcomb.com/the-mountain/lifts-and-grooming/index.aspx",
        "units": "metric",
        "location": {
          "latitude": 50.10693,
          "longitude": -122.922073
        },
        "lifts": {
          "status": {
            "7th Heaven Express": "closed",
            "Blackcomb Gondola Lower": "closed",
            "Blackcomb Gondola Upper": "closed",
            "Bubly Tube Park": "closed",
            "Catskinner Express": "closed",
            "Crystal Ridge Express": "closed",
            "Excalibur Gondola Lower": "closed",
            "Excalibur Gondola Upper": "closed",
            "Excelerator Express": "closed",
            "Glacier Express": "closed",
            "Horstman T-Bar": "closed",
            "Jersey Cream Express": "closed",
            "Magic Chair": "closed",
            "Peak 2 Peak Gondola": "closed",
            "Showcase T-Bar": "closed",
            "Big Red Express": "closed",
            "Creekside Gondola": "closed",
            "Emerald 6 Express": "closed",
            "Fitzsimmons Express": "closed",
            "Franz's Chair": "closed",
            "Garbanzo Express": "closed",
            "Harmony 6 Express": "closed",
            "Olympic Chair": "closed",
            "Peak Express": "closed",
            "Symphony Express": "closed",
            "T-Bars": "closed",
            "Whistler Village Gondola Lower": "closed",
            "Whistler Village Gondola Upper": "closed"
          },
          "stats": {
            "open": 0,
            "hold": 0,
            "scheduled": 0,
            "closed": 28,
            "percentage": {
              "open": 0,
              "hold": 0,
              "scheduled": 0,
              "closed": 100
            }
          }
        },
        "conditions": {
          "base": 245,
          "season": 679,
          "twelve_hours": 0,
          "twentyfour_hours": 0,
          "fortyeight_hours": 3,
          "seven_days": 50
        },
        "twitter": {
          "user": "WhistlerBlckcmb",
          "tweets": [
            {
              "text": "Possible sunny breaks today and mild temperatures🌤️\n\nListen to the Snowphone daily for your weather and snow report. \n\nPowered by @TELUS \nhttps://t.co/fAoIiWWibr",
              "id_str": "1481652294202523657",
              "created_at": "Thu Jan 13 15:40:09 +0000 2022",
              "entities": {
                "hashtags": [],
                "symbols": [],
                "user_mentions": [
                  {
                    "screen_name": "TELUS",
                    "name": "TELUS",
                    "id": 6975832,
                    "id_str": "6975832",
                    "indices": [
                      130,
                      136
                    ]
                  }
                ],
                "urls": [
                  {
                    "url": "https://t.co/fAoIiWWibr",
                    "expanded_url": "https://soundcloud.com/whistler-blackcomb/snowphone-january-13th-730am-2022?si=0eba8e35cf0d46d5badc03cd2d95ecf9&utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing",
                    "display_url": "soundcloud.com/whistler-black…",
                    "indices": [
                      138,
                      161
                    ]
                  }
                ]
              }
            },
            {
              "text": "Periods of snow today with mild temperatures.\n\nListen to the Snowphone daily for your weather and snow report. \n\nPowered by @TELUS\nhttps://t.co/AasfPRETYp",
              "id_str": "1481292758627368960",
              "created_at": "Wed Jan 12 15:51:29 +0000 2022",
              "entities": {
                "hashtags": [],
                "symbols": [],
                "user_mentions": [
                  {
                    "screen_name": "TELUS",
                    "name": "TELUS",
                    "id": 6975832,
                    "id_str": "6975832",
                    "indices": [
                      124,
                      130
                    ]
                  }
                ],
                "urls": [
                  {
                    "url": "https://t.co/AasfPRETYp",
                    "expanded_url": "https://soundcloud.com/whistler-blackcomb/january-12b?si=45e67c285f674b4aa9066d0b481b04e5&utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing",
                    "display_url": "soundcloud.com/whistler-black…",
                    "indices": [
                      131,
                      154
                    ]
                  }
                ]
              }
            },
            {
              "text": "Enjoy the day at Whistler Blackcomb with 15cm of new snow!\n\nListen to the Snowphone daily for your weather and snow report. \n\nPowered by @TELUS\n\nhttps://t.co/XaOkpIC1zP",
              "id_str": "1480928679626784771",
              "created_at": "Tue Jan 11 15:44:46 +0000 2022",
              "entities": {
                "hashtags": [],
                "symbols": [],
                "user_mentions": [
                  {
                    "screen_name": "TELUS",
                    "name": "TELUS",
                    "id": 6975832,
                    "id_str": "6975832",
                    "indices": [
                      137,
                      143
                    ]
                  }
                ],
                "urls": [
                  {
                    "url": "https://t.co/XaOkpIC1zP",
                    "expanded_url": "https://soundcloud.com/whistler-blackcomb/january-11b?si=72e9539b4e1145f98f29ffc323d7b1bf&utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing",
                    "display_url": "soundcloud.com/whistler-black…",
                    "indices": [
                      145,
                      168
                    ]
                  }
                ]
              }
            }
          ]
        }
      }
    }
  ```
  </details>

  </td>
  </tr>
</table>
