//
//  SettingsView.swift
//  Orbit
//
//  Created by 김경훈 on 9/11/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var categories: [Category]
    
    @AppStorage("appLanguage") private var appLanguage: String = "ko"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("관리") {
                    NavigationLink(destination: CategoryListView()) {
                        Label("카테고리 관리", systemImage: "list.bullet")
                    }
                }
                
                Section("일반") {
                    Picker("언어", selection: $appLanguage) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                    }
                    
                    Toggle("다크 모드", isOn: $isDarkMode)
                }
                
                Section("데이터") {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("데이터 초기화", systemImage: "trash")
                    }
                }
                
                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .alert("데이터 초기화", isPresented: $showingResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("모든 거래 내역과 카테고리가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    private func resetData() {
        do {
            try modelContext.delete(model: Transaction.self)
            try modelContext.delete(model: Category.self)
            
            // Re-add default categories
            for category in Category.defaultCategories {
                modelContext.insert(category)
            }
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}
