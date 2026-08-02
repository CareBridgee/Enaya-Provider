//
//  TabCustomHeader.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct TabCustomHeader: View {
    let title: String
    
    var body: some View {
        HStack(spacing: Spacing.s12) {
            Image("mock_avatar") 
                .resizable()
                .frame(width: Spacing.s40, height: Spacing.s40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.surfaceVariant, lineWidth: 1))
            
            Text(title)
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(.brandPrimary)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: IconSize.s20))
                    .foregroundColor(.primaryFont)
            }
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s8)
        .background(Color.backGround)
    }
}

