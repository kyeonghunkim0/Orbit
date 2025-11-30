//
//  HomeView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var calendarModel: CalendarViewModel
    @Query private var transactions: [Transaction]
    
    /// Sheet 표시 여부
    @State private var isShowingAddSheet = false
    @State private var isShowingScanner = false
    
    @State private var scannedAmount: Double = 0
    @State private var scannedDate: Date = Date()
    @State private var scannedMemo: String = ""
    
    var body: some View {
        NavigationView {
            // VStack으로 감싸서 캘린더와 거래 목록을 세로로 배치
            VStack {
                CalendarView(calendarModel: calendarModel)
                
                // 선택된 날짜가 있을 때만 DailyTransactionListView 표시
                if let selectedDate = calendarModel.selectedDate{
                    DailyTransactionListView(viewModel: calendarModel, selectedDate: selectedDate, transactions: transactions)
                } else {
                    Spacer()
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTransactionView(amount: scannedAmount, date: scannedDate, memo: scannedMemo)
                // 시트 뷰에서도 ViewModel에 접근할 수 있도록 environmentObject를 전달
                    .environmentObject(calendarModel)
            }
            .padding()
            .toolbar {
                Menu {
                    Button {
                        // Reset scanned data for manual add
                        scannedAmount = 0
                        scannedDate = Date()
                        scannedMemo = ""
                        isShowingAddSheet = true
                    } label: {
                        Label("직접 추가", systemImage: "pencil")
                    }
                    
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("영수증 촬영", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            .sheet(isPresented: $isShowingScanner, onDismiss: {
                // 스캔이 완료되면(시트가 닫히면) 추가 화면 표시
                // 단, 스캔이 취소되었을 때도 열리는 것을 방지하려면 
                // scannedMemo 등이 비어있는지 체크할 수도 있지만, 
                // 여기서는 일단 스캔 시트가 닫히면 무조건 추가 화면으로 이동하도록 함 (사용성 고려)
                // 필요하다면 ReceiptScannerView에서 완료 여부를 반환받아야 함.
                // 일단은 간단하게 구현.
                isShowingAddSheet = true
            }) {
                ReceiptScannerView(recognizedText: $scannedMemo, scannedDate: $scannedDate, scannedAmount: $scannedAmount)
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
