//
//  CategoryListView.swift
//  Orbit
//
//  Created by Orbit on 11/30/25.
//

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var showingAddCategory = false
    @State private var selectedType: TransactionType = .expense
    
    var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }
    
    var body: some View {
        List {
            ForEach(filteredCategories) { category in
                HStack {
                    Image(systemName: category.iconName)
                        .foregroundStyle(Color(hex: category.color) ?? .primary)
                        .frame(width: 30)
                    Text(category.name)
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("카테고리 관리")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Picker("Type", selection: $selectedType) {
                    Text("지출").tag(TransactionType.expense)
                    Text("수입").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            NavigationView {
                AddCategoryView()
            }
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredCategories[index])
            }
        }
    }
}

#Preview {
    NavigationView {
        CategoryListView()
            .modelContainer(for: Category.self, inMemory: true)
    }
}
