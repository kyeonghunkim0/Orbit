import SwiftUI
import Charts
import SwiftData

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Period Picker
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(StatisticsPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Type Picker (Income/Expense)
                Picker("Type", selection: $viewModel.selectedType) {
                    Text("지출").tag(TransactionType.expense)
                    Text("수입").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Total Amount
                        VStack(spacing: 5) {
                            Text(viewModel.selectedPeriod.rawValue + " " + (viewModel.selectedType == .expense ? "지출" : "수입"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.totalAmount, format: .currency(code: "KRW"))
                                .font(.title2)
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Chart (Time Trend)
                        if !viewModel.chartData.isEmpty {
                            Chart(viewModel.chartData) { dataPoint in
                                BarMark(
                                    x: .value("Date", dataPoint.date, unit: viewModel.selectedPeriod == .year ? .year : (viewModel.selectedPeriod == .month ? .month : .day)),
                                    y: .value("Amount", dataPoint.amount),
                                    width: .fixed(20)
                                )
                                .foregroundStyle(viewModel.selectedType == .expense ? Color.red.gradient : Color.blue.gradient)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: viewModel.selectedPeriod == .year ? .year : (viewModel.selectedPeriod == .month ? .month : .day))) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel(format: viewModel.selectedPeriod == .year ? .dateTime.year() : (viewModel.selectedPeriod == .month ? .dateTime.month(.abbreviated) : .dateTime.day()))
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel(format: .currency(code: "KRW").presentation(.narrow))
                                }
                            }
                            .frame(height: 200)
                            .padding()
                        } else {
                            ContentUnavailableView("데이터가 없습니다", systemImage: "chart.bar.xaxis")
                                .frame(height: 200)
                        }
                        
                        // Category Breakdown List
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
                viewModel.filterAndAggregateData()
            }
            .onChange(of: viewModel.selectedType) { oldValue, newValue in
                viewModel.filterAndAggregateData()
            }
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
