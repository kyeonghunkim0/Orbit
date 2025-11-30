//
//  AddCategoryView.swift
//  Orbit
//
//  Created by Orbit on 11/30/25.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColor: Color = .blue
    
    private let icons: [String] = [
        "star.fill", "heart.fill", "house.fill", "cart.fill", "car.fill",
        "bus.fill", "tram.fill", "airplane", "fork.knife", "cup.and.saucer.fill",
        "tshirt.fill", "bag.fill", "creditcard.fill", "banknote.fill", "wonsign.circle.fill",
        "book.fill", "graduationcap.fill", "gamecontroller.fill", "film.fill", "music.note",
        "cross.case.fill", "pills.fill", "pawprint.fill", "leaf.fill", "gift.fill"
    ]
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown, .gray, .black
    ]
    
    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("카테고리 이름", text: $name)
                
                Picker("유형", selection: $selectedType) {
                    Text("지출").tag(TransactionType.expense)
                    Text("수입").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
            }
            
            Section("아이콘") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 15) {
                    ForEach(icons, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(selectedIcon == icon ? selectedColor : .gray)
                            .frame(width: 44, height: 44)
                            .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedIcon = icon
                            }
                    }
                }
                .padding(.vertical, 10)
            }
            
            Section("색상") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("카테고리 추가")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    saveCategory()
                }
                .disabled(name.isEmpty)
            }
        }
    }
    
    private func saveCategory() {
        let newCategory = Category(
            name: name,
            iconName: selectedIcon,
            type: selectedType,
            color: selectedColor.toHex() ?? "#0000FF"
        )
        modelContext.insert(newCategory)
        dismiss()
    }
}

#Preview {
    NavigationView {
        AddCategoryView()
    }
}
