import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    @State private var amount: Double = 0
    @State private var selectedCategory: String = "식비"
    @State private var selectedType: String = "지출"
    @State private var memo: String = ""
    @State private var showingAlert = false
    

    
    var body: some View {
        NavigationStack {
            Form {
                Section("금액") {
                    TextField("금액 입력", value: $amount, format: .number)
                }
                
                Section("유형") {
                    Picker("유형", selection: $selectedType) {
                        Text("지출").tag("지출")
                        Text("수입").tag("수입")
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("카테고리") {
                    Picker("카테고리", selection: $selectedCategory) {
                        if connectivityManager.watchCategories.isEmpty {
                            Text("카테고리 없음").tag("카테고리 없음")
                        } else {
                            let filteredCategories = connectivityManager.watchCategories.filter { $0.type == selectedType }
                            ForEach(filteredCategories) { category in
                                Text(category.name).tag(category.name)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("메모") {
                    TextField("메모 (선택)", text: $memo)
                }
                
                Section {
                    Button(action: saveTransaction) {
                        Text("추가하기")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Orbit")
            .alert("저장 완료", isPresented: $showingAlert) {
                Button("확인", role: .cancel) {
                    resetForm()
                }
            }
        }
    }
    
    private func saveTransaction() {
        connectivityManager.sendTransaction(
            amount: selectedType == "지출" ? -amount : amount,
            category: selectedCategory,
            type: selectedType,
            memo: memo,
            date: Date()
        )
        showingAlert = true
    }
    
    private func resetForm() {
        amount = 0
        memo = ""
        // Keep category and type as is for convenience
    }
}

#Preview {
    ContentView()
        .environmentObject(ConnectivityManager.shared)
}
