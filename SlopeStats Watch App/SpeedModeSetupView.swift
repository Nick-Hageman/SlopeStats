//
//  SpeedModeSetupView.swift
//  SlopeStats
//
//  Created by Alex Hageman on 12/23/24.
//

import SwiftUI

struct SpeedModeSetupView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isConfirmActive = false

    var body: some View {
        VStack {
            Text("Time to beat")
                .font(.headline)
                .padding()

            HStack {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24) { Text("\($0)h") }
                }
                .frame(width: 50)
                .clipped()

                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { Text("\($0)m") }
                }
                .frame(width: 50)
                .clipped()

                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60) { Text("\($0)s") }
                }
                .frame(width: 50)
                .clipped()
            }
            .pickerStyle(WheelPickerStyle())

            NavigationLink(destination: SpeedModeCountdownView(hours: hours, minutes: minutes, seconds: seconds), isActive: $isConfirmActive) {
                Button(action: {
                    isConfirmActive = true
                }) {
                    Text("Confirm")
                        .font(.subheadline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}
