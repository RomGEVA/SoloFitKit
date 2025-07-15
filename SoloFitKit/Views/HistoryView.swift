import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    // Группировка по дням для графика
    private var dailyStats: [DailyStat] {
        let grouped = Dictionary(grouping: workoutViewModel.settings.completedWorkouts) { session in
            Calendar.current.startOfDay(for: session.startDate)
        }
        return grouped.map { (date, sessions) in
            DailyStat(date: date, totalMinutes: sessions.reduce(0) { $0 + $1.duration } / 60)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // График активности
                if #available(iOS 16.0, *) {
                    ChartSection(dailyStats: dailyStats)
                } else {
                    Text("Charts require iOS 16+")
                        .foregroundColor(.secondary)
                }
                
                // История тренировок
                List {
                    ForEach(workoutViewModel.settings.completedWorkouts.sorted(by: { $0.startDate > $1.startDate })) { session in
                        HistoryRow(session: session)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("History & Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let totalMinutes: Int
}

@available(iOS 16.0, *)
struct ChartSection: View {
    let dailyStats: [DailyStat]
    @State private var animateBars = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Activity")
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))
                .padding(.leading, 8)
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("CardBackgroundColor"))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                Chart {
                    ForEach(Array(dailyStats.enumerated()), id: \ .element.id) { idx, stat in
                        BarMark(
                            x: .value("Day", stat.date, unit: .day),
                            y: .value("Minutes", animateBars ? stat.totalMinutes : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("AccentColor").opacity(0.85), Color("AccentColor").opacity(0.6)]),
                                startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(8)
                        .annotation(position: .top, alignment: .center) {
                            if stat.totalMinutes > 0 {
                                Text("\(stat.totalMinutes)m")
                                    .font(.caption2)
                                    .foregroundColor(Color("PrimaryTextColor").opacity(0.7))
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                            .foregroundStyle(Color("SecondaryTextColor").opacity(0.2))
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .foregroundStyle(Color("SecondaryTextColor"))
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                            .foregroundStyle(Color("SecondaryTextColor").opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(Color("SecondaryTextColor"))
                            .font(.caption2)
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: animateBars)
                .onAppear { animateBars = true }
            }
        }
        .padding(.horizontal, 0)
        .padding(.top, 8)
    }
}

struct HistoryRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.workout.category.icon)
                .foregroundColor(Color(session.workout.category.color))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.workout.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("\(session.duration / 60)m  |  \(session.workout.difficulty.rawValue)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(session.startDate, style: .date)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView(workoutViewModel: WorkoutViewModel())
} 