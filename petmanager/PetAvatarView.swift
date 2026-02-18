//
//  PetAvatarView.swift
//  petmanager
//
//  Created by Sam Matthews on 18/02/2026.
//

import SwiftUI

struct PetAvatarView: View {
    let pet: Pet
    let size: CGFloat

    var body: some View {
        Group {
            if let customImage = PetImageManager.shared.loadImage(for: pet.id) {
                Image(uiImage: customImage)
                    .resizable()
                    .scaledToFill()
            } else if UIImage(named: pet.imageName) != nil {
                Image(pet.imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.white.opacity(0.8)
                    Image(systemName: pet.imageName.isEmpty ? "pawprint.circle.fill" : pet.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(size * 0.2)
                        .foregroundColor(.purple)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
