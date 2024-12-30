import SwiftUI
import UIKit

struct Chart: View {
    var data: [Double]
    var title: String
    var color: Color
    var icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon) // Add icon to the left of title
                    .foregroundColor(.white)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top)

            LineChart(data: data, lineColor: color)
                .frame(height: 200)
                .padding([.leading, .trailing], 10)
        }
        .padding([.top, .bottom], 20)
        .background(Color.black) // Dark mode background
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct LineChart: View {
    var data: [Double]
    var lineColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw the axes
                AxisLines(width: geometry.size.width, height: geometry.size.height, data: data)
                
                // Draw the data points as dots
                ForEach(0..<data.count, id: \.self) { index in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(data.count - 1)
                    let maxY = data.max() ?? 1
                    let minY = data.min() ?? 0
                    let scaleY = maxY - minY
                    
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat((data[index] - minY) / scaleY) * height
                    
                    Circle()
                        .fill(lineColor)
                        .frame(width: 6, height: 6)  // Make the dot size adjustable
                        .position(x: x, y: y)
                }
            }
        }
    }
}


struct AxisLines: View {
    var width: CGFloat
    var height: CGFloat
    var data: [Double]

    var body: some View {
        let maxY = data.max() ?? 1
        let minY = data.min() ?? 0
        let scaleY = maxY - minY

        let yTickCount = 5  // Number of Y ticks

        // Y-axis labels
        let yLabels: [String] = (0..<yTickCount).map { i in
            String(format: "%.0f", minY + (scaleY * (1.0 - CGFloat(i) / CGFloat(yTickCount - 1))))
        }

        // X-axis labels
        let xLabels: [String] = (0..<data.count).map { "\($0)" }

        return ZStack {
            // Y-axis line
            YAxisLine(height: height)

            // X-axis line
            XAxisLine(width: width, height: height)

            // Y-axis labels
            YAxisLabels(yLabels: yLabels, height: height)

            // X-axis labels
            XAxisLabels(xLabels: xLabels, width: width, height: height)
        }
    }
}

// Y-axis line
struct YAxisLine: View {
    var height: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
    }
}

// X-axis line
struct XAxisLine: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
        }
        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
    }
}

// Y-axis labels
struct YAxisLabels: View {
    var yLabels: [String]
    var height: CGFloat

    var body: some View {
        ForEach(0..<yLabels.count, id: \.self) { i in
            let yPos = CGFloat(i) * (height / CGFloat(yLabels.count - 1))
            Text(yLabels[i])
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: -20, y: yPos)
        }
    }
}

// X-axis labels
struct XAxisLabels: View {
    var xLabels: [String]
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ForEach(0..<xLabels.count, id: \.self) { i in
            let xPos = CGFloat(i) * (width / CGFloat(xLabels.count - 1))
            Text(xLabels[i])
                .font(.caption)
                .foregroundColor(.gray)
                .position(x: xPos, y: height + 10)
        }
    }
}
