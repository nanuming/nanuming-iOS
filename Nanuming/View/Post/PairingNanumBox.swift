//
//  PairingNanumBox.swift
//  Nanuming
//
//  Created by byeoungjik on 2/12/24.
//

import SwiftUI

struct PairingNanumBox: View {
    @State private var identifyingNumber: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                //고유번호 입력
                Text("고유 번호를 입력해주세요.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.textBlack)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray300, lineWidth: 2.0)
                    .frame(width: screenWidth * 0.85, height: 43)
                    .overlay(alignment: .center, content: {
                        TextField(text: $identifyingNumber, label: {
                            Text("나누밍 상자 고유번호 입력 ")
                        })
                        .padding()
                    })
                    .padding()
                // 페어링 버튼
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: screenWidth * 0.85, height: 43)
                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 4)
                    .foregroundColor(.greenMain)
                    .overlay(content: {
                        Button(action: {
                            print("identifying number: \(identifyingNumber)")
                        }, label: {
                            Text("확인")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        })
                    })
                    .padding()
                    .offset(y: screenHeight * 0.27)
            }
            
        }
    }
}

#Preview {
    PairingNanumBox()
}
