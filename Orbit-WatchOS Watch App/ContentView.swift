import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let summary = connectivityManager.receivedSummary {
                    VStack(spacing: 12) {
                        SummaryCard(title: "오늘", expense: summary.todayExpense, income: summary.todayIncome)
                        SummaryCard(title: "이번 주", expense: summary.weekExpense, income: summary.weekIncome)
                        SummaryCard(title: "이번 달", expense: summary.monthExpense, income: summary.monthIncome)
                        SummaryCard(title: "올해", expense: summary.yearExpense, income: summary.yearIncome)
                    }
                    .padding()
                } else {
                    VStack {
                        if connectivityManager.isSessionActivated {
                            Text("데이터를 기다리는 중...")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("iPhone과 연결 중...")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .navigationTitle("Orbit")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let expense: Double
    let income: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("지출")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(abs(expense)))원")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("수입")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(income))원")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConnectivityManager.shared)
}
