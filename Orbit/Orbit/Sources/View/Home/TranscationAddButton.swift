//
//  TranscationAddButton.swift
//  Orbit
//
//  Created by 김경훈 on 11/8/25.
//

import SwiftUI

struct TranscationAddButton: View {
    
    var body: some View {
        Menu {
            Button("수입 추가", action: {
                // TODO: 수입 추가 화면 이동
            })
            Button("지출 추가", action: {
                // TODO: 지출 추가 화면 이동
            })
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundColor(.accentColor) // 앱의 기본 강조색 사용
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    TranscationAddButton()
}
