//
//  EditBioView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct EditBioView: View {
    @StateObject var viewModel: EditBioViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s20) {
            
            // Drag Indicator
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.hint.opacity(0.5))
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.top, Spacing.s12)
            
            // Title
            Text("Edit Bio")
                .font(.title2)
                .bold()
                .foregroundColor(.primaryFont)
                .padding(.top, Spacing.s8)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    
                    // Specialization Field
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Specialization")
                            .font(.subheadline)
                            .foregroundColor(.primaryFont)
                        
                        TextField("", text: $viewModel.specialization)
                            .padding()
                            .foregroundColor(.primaryFont)
                            .background(Color.surfaceVariant)
                            .cornerRadius(Radius.r12)
                    }
                    
                    // Years of experience Field
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Years of experience")
                            .font(.subheadline)
                            .foregroundColor(.primaryFont)
                        
                        TextField("", text: $viewModel.yearsOfExperience)
                            .keyboardType(.numberPad)
                            .padding()
                            .foregroundColor(.primaryFont)
                            .background(Color.surfaceVariant)
                            .cornerRadius(Radius.r12)
                    }
                    
                    // Bio Field
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Bio")
                            .font(.subheadline)
                            .foregroundColor(.primaryFont)
                        
                        TextEditor(text: $viewModel.bio)
                            .padding(Spacing.s8)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.primaryFont)
                            .background(Color.surfaceVariant)
                            .cornerRadius(Radius.r12)
                            .frame(minHeight: 150)
                    }
                    
                    if let error = viewModel.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.error)
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: Spacing.s16) {
                // Cancel Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.s16)
                        .background(Color.surface)
                        .cornerRadius(Radius.r12)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.r12)
                                .stroke(Color.brandPrimary, lineWidth: 1)
                        )
                }
                
                // Save Button
                Button(action: {
                    viewModel.save()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .onPrimary))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.s16)
                    } else {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.onPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.s16)
                    }
                }
                .background(Color.brandPrimary)
                .cornerRadius(Radius.r12)
                .disabled(viewModel.isLoading)
            }
            .padding(.bottom, Spacing.s16)
            
        }
        .padding(.horizontal, Spacing.s24)
        .background(Color.surface.ignoresSafeArea())
        .presentationDetents([.fraction(0.75)])
    }
}
