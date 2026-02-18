//
//  PetImageManager.swift
//  petmanager
//
//  Created by Sam Matthews on 18/02/2026.
//

import UIKit

class PetImageManager {
    static let shared = PetImageManager()

    private let fileManager = FileManager.default
    private let defaults = UserDefaults.standard

    private var imageDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("pet_images")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private init() {}

    // MARK: - Photo Storage

    func saveImage(_ image: UIImage, for petId: Int) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = imageDirectory.appendingPathComponent("pet_\(petId).jpg")
        try? data.write(to: url)
    }

    func loadImage(for petId: Int) -> UIImage? {
        let url = imageDirectory.appendingPathComponent("pet_\(petId).jpg")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    func deleteImage(for petId: Int) {
        let url = imageDirectory.appendingPathComponent("pet_\(petId).jpg")
        try? fileManager.removeItem(at: url)
        defaults.removeObject(forKey: "petImage_\(petId)")
    }

    // MARK: - Image Preference (SF Symbol name or "custom_photo")

    func saveImagePreference(_ name: String, for petId: Int) {
        defaults.set(name, forKey: "petImage_\(petId)")
    }

    func imagePreference(for petId: Int) -> String? {
        defaults.string(forKey: "petImage_\(petId)")
    }
}
