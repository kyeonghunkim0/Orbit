import SwiftUI
import Charts
import SwiftData

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                periodPicker
                typePicker
                
                ScrollView {
                    VStack(spacing: 20) {
                        totalAmountView
                        chartView
                        categoryListView
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("통계")
            .onAppear {
                viewModel.updateData(with: transactions)
            }
            .onChange(of: transactions) { oldValue, newValue in
                viewModel.updateData(with: newValue)
            }
            .onChange(of: viewModel.selectedPeriod) { oldValue, newValue in
                viewModel.focusedDate = Date()
                viewModel.filterAndAggregateData()
            }
            .onChange(of: viewModel.selectedType) { oldValue, newValue in
                viewModel.filterAndAggregateData()
            }
        }
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(StatisticsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var typePicker: some View {
        Picker("Type", selection: $viewModel.selectedType) {
            Text("지출").tag(TransactionType.expense)
            Text("수입").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var totalAmountView: some View {
        VStack(spacing: 5) {
            Text(dateString(for: viewModel.focusedDate) + " " + (viewModel.selectedType == .expense ? "지출" : "수입"))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(viewModel.totalAmount, format: .currency(code: "KRW"))
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        switch viewModel.selectedPeriod {
        case .week:
            formatter.dateFormat = "M월 d일"
        case .month:
            formatter.dateFormat = "M월"
        case .year:
            formatter.dateFormat = "yyyy년"
        }
        return formatter.string(from: date)
    }
    
    private var chartView: some View {
        Group {
            if !viewModel.chartData.isEmpty {
                TransactionChart(viewModel: viewModel)
                    .frame(height: 200)
                    .padding()
            } else {
                ContentUnavailableView("데이터가 없습니다", systemImage: "chart.bar.xaxis")
                    .frame(height: 200)
            }
        }
    }
    
    private var categoryListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("카테고리별 현황")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.categoryStatistics.isEmpty {
                Text("데이터가 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.categoryStatistics) { stat in
                    HStack {
                        Image(systemName: stat.category.iconName)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(viewModel.selectedType == .expense ? Color.red : Color.blue)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(stat.category.name)
                                .font(.subheadline)
                            ProgressView(value: stat.percentage)
                                .tint(viewModel.selectedType == .expense ? .red : .blue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(stat.amount, format: .currency(code: "KRW"))
                                .font(.subheadline)
                                .bold()
                            Text(stat.percentage, format: .percent.precision(.fractionLength(1)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct TransactionChart: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        Chart(viewModel.chartData) { dataPoint in
            BarMark(
                x: .value("Date", dataPoint.date),
                y: .value("Amount", dataPoint.amount),
                width: .fixed(20)
            )
            .foregroundStyle(by: .value("Category", dataPoint.category?.name ?? "기타"))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: unit)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: format)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .currency(code: "KRW").presentation(.narrow))
            }
        }
        .chartForegroundStyleScale { categoryName in
            if let category = viewModel.categoryStatistics.first(where: { $0.category.name == categoryName })?.category {
                return Color(hex: category.color) ?? .gray
            }
            return .gray
        }
        .chartXScale(domain: viewModel.chartStartDate...viewModel.chartEndDate)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onTapGesture { location in
                        if let date: Date = proxy.value(atX: location.x) {
                            viewModel.focusedDate = date
                            viewModel.updateStatistics(for: date)
                        }
                    }
            }
        }
    }
    
    private var unit: Calendar.Component {
        switch viewModel.selectedPeriod {
        case .week: return .day
        case .month: return .month
        case .year: return .year
        }
    }
    
    private var format: Date.FormatStyle {
        switch viewModel.selectedPeriod {
        case .week: return .dateTime.day()
        case .month: return .dateTime.month(.abbreviated)
        case .year: return .dateTime.year()
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
