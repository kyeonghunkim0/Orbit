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
            Image(systemName: "plus")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
        }
    }
}

#Preview {
    TranscationAddButton()
}
