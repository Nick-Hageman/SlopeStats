import SwiftUI
import Foundation

struct ResortView: View {
    // Example dictionary of ski resorts
    let skiResorts = [
        "Whistler Blackcomb": "whistler-blackcomb",
        "49 Degrees North": "49-degrees-north",
        "Alpine Meadows": "alpine-meadows",
        "Alta": "alta",
        "Alyeska": "alyeska",
        "Angel Fire": "angel-fire",
        "Arapahoe Basin": "arapahoe-basin",
        "Aspen Highlands": "aspen-highlands",
        "Aspen Mountain": "aspen-mountain",
        "Attitash": "attitash",
        "Beaver Creek": "beavercreek",
        "Big Sky": "big-sky",
        "Big White": "big-white",
        "Blue Mountain": "bluemountain",
        "Bolton Valley": "bolton-valley",
        "Boreal": "boreal",
        "Breckenridge": "breck",
        "Bretton Woods": "brettonwoods",
        "Brian Head": "brianhead",
        "Bridger Bowl": "bridger-bowl",
        "Brighton": "brighton",
        "Bromley Mountain": "bromley-mountain",
        "Burke Mountain": "burke-mountain",
        "Buttermilk": "buttermilk",
        "Caberfae Peaks": "caberfae-peaks",
        "Camelback Mountain": "camelback"
    ]

    // State variables for selected resort, slug, and API response data
    @State private var selectedResort: String = ""
    @State private var selectedSlug: String = ""
    @State private var resortName: String = ""
    @State private var liftsOpen: Int = 0
    @State private var liftsHold: Int = 0
    @State private var liftsScheduled: Int = 0
    @State private var liftsClosed: Int = 0
    @State private var tweets: [String] = []
    @State private var base: Int = 0
    @State private var season: Int = 0
    @State private var twelve_hours: Int = 0
    @State private var twentyfour_hours: Int = 0
    @State private var fortyeight_hours: Int = 0
    @State private var seven_days: Int = 0

    var body: some View {
        VStack {
            HStack {
                // Dropdown menu to select a resort
                Picker("Select a Resort", selection: $selectedResort) {
                    Text("Select a Resort").tag("") // Default value
                    ForEach(skiResorts.keys.sorted(), id: \ .self) { resort in
                        Text(resort).tag(resort)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // "Search" button
                Button(action: {
                    if let slug = skiResorts[selectedResort] {
                        selectedSlug = slug
                        //performAPICall(for: slug) // commented out since I hit API quota
                    }
                }) {
                    Text("Search")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(selectedResort.isEmpty) // Disable button if no selection
            }

            // Display API response
            if !resortName.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Resort: \(resortName) 🏔️")
                        .font(.title2)
                        .foregroundColor(Color.black)
                        .bold()

                    VStack {
                        Text("🚠 Lift Status:").font(.headline)
                        HStack {
                            Text("Lifts Open: \(liftsOpen)")
                            Spacer()
                            Text("Lifts Hold: \(liftsHold)")
                        }
                        .padding(.horizontal)
                        HStack {
                            Text("Lifts Scheduled: \(liftsScheduled)")
                            Spacer()
                            Text("Lifts Closed: \(liftsClosed)")
                        }
                        .padding(.horizontal)
                    }

                    VStack {
                        Text("❄️Conditions:").font(.headline)
                        HStack {
                            VStack {
                                Text("Base: \(base)")
                                Text("Season: \(season)")
                                Text("Twelve Hours: \(twelve_hours)")
                            }
                            .padding(.horizontal)
                            VStack {
                                Text("Twenty Four Hours: \(twentyfour_hours)")
                                Text("Forty Eight Hours: \(fortyeight_hours)")
                                Text("Seven Days: \(seven_days)")
                            }
                            .padding(.horizontal)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("📱Tweets:").font(.headline)
                        ForEach(tweets, id: \ .self) { tweet in
                            Text(tweet)
                                .padding()
                                .foregroundColor(Color.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green.opacity(0.1))
    }

    // API call function
    func performAPICall(for slug: String) {
        print("Calling API with slug: \(slug)")
        if let apiKey = ProcessInfo.processInfo.environment["SKIING_API_KEY"] {
            let headers = [
                "x-rapidapi-key": apiKey,
                "x-rapidapi-host": "ski-resorts-and-conditions.p.rapidapi.com"
            ]

            let urlString = "https://ski-resorts-and-conditions.p.rapidapi.com/v1/resort/\(slug)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    parseResponse(data: data)
                }
            }

            dataTask.resume()
        } else {
            print("API Key missing")
        }
    }

    // Parse the API response
    func parseResponse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let data = json["data"] as? [String: Any] {
                print("Response: \(data)")

                DispatchQueue.main.async {
                    self.resortName = data["name"] as? String ?? "Unknown Resort"

                    if let lifts = data["lifts"] as? [String: Any],
                       let stats = lifts["stats"] as? [String: Int] {
                        self.liftsOpen = stats["open"] ?? 0
                        self.liftsHold = stats["hold"] ?? 0
                        self.liftsScheduled = stats["scheduled"] ?? 0
                        self.liftsClosed = stats["closed"] ?? 0
                    }

                    if let conditions = data["conditions"] as? [String: Int] {
                        self.base = conditions["base"] ?? 0
                        self.season = conditions["season"] ?? 0
                        self.twelve_hours = conditions["twelve_hours"] ?? 0
                        self.twentyfour_hours = conditions["twentyfour_hours"] ?? 0
                        self.fortyeight_hours = conditions["fortyeight_hours"] ?? 0
                        self.seven_days = conditions["seven_days"] ?? 0
                    }

                    if let twitter = data["twitter"] as? [String: Any],
                       let tweetsArray = twitter["tweets"] as? [[String: Any]] {
                        self.tweets = tweetsArray.compactMap { $0["text"] as? String }
                    }
                }

            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}

struct ResortView_Previews: PreviewProvider {
    static var previews: some View {
        ResortView()
    }
}
