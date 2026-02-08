//
//  PetService.swift
//  petmanager
//
//  Created by Sam Matthews on 25/01/2026.
//

import Foundation
import Combine

class PetService {
    static let shared = PetService()

    private let baseURL = URL(string: "http://localhost:8000")!

    // Date formatter for YYYY-MM-DD format (Python date type)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    // Date formatter for Python datetime format (with microseconds)
    private static let pythonDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // Fallback formatter without microseconds
    private static let pythonDateTimeFormatterNoMicro: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // Encoder for appointments (ISO8601 for sending to API)
    private let appointmentEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // Decoder for appointments (handles Python datetime response format)
    private let appointmentDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try Python format with microseconds first
            if let date = pythonDateTimeFormatter.date(from: dateString) {
                return date
            }
            // Try without microseconds
            if let date = pythonDateTimeFormatterNoMicro.date(from: dateString) {
                return date
            }
            // Try ISO8601 with Z suffix
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()
    
    // FETCH PET by ID
    func fetchPet(id: Int) -> AnyPublisher<Pet, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(id)")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Pet.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // CREATE PET
    func createPet(petRequest: PetCreationRequest, userId: Int? = nil) -> AnyPublisher<Pet, Error> {
        let url: URL
        if let userId = userId {
            url = baseURL.appendingPathComponent("users").appendingPathComponent("\(userId)").appendingPathComponent("pets")
        } else {
            url = baseURL.appendingPathComponent("pets")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try encoder.encode(petRequest)
            request.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Pet.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // FETCH PETS by USER ID
    func fetchPets(forUserId userId: Int) -> AnyPublisher<[Pet], Error> {
        let url = baseURL.appendingPathComponent("users").appendingPathComponent("\(userId)").appendingPathComponent("pets")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Pet].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // DELETE PET
    func deletePet(id: Int) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // UPDATE PET
    func updatePet(id: Int, petRequest: PetCreationRequest) -> AnyPublisher<Pet, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try encoder.encode(petRequest)
            request.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Pet.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // FETCH APPOINTMENTS for a pet
    func fetchAppointments(forPetId petId: Int) -> AnyPublisher<[Appointment], Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("appointments")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Appointment].self, decoder: appointmentDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // DELETE APPOINTMENT
    func deleteAppointment(id: Int) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("appointments").appendingPathComponent("\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // UPDATE APPOINTMENT
    func updateAppointment(id: Int, request: AppointmentUpdateRequest) -> AnyPublisher<Appointment, Error> {
        let url = baseURL.appendingPathComponent("appointments").appendingPathComponent("\(id)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try appointmentEncoder.encode(request)
            urlRequest.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: Appointment.self, decoder: appointmentDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // CREATE APPOINTMENT for a pet
    func createAppointment(forPetId petId: Int, request: AppointmentRequest) -> AnyPublisher<Appointment, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("appointments")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try appointmentEncoder.encode(request)
            urlRequest.httpBody = data
            // Debug: print what we're sending
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📤 Sending appointment request: \(jsonString)")
            }
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                // Debug: print raw response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Raw response: \(responseString)")
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                print("📥 Status code: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                return data
            }
            .decode(type: Appointment.self, decoder: appointmentDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Vaccines

    // FETCH VACCINES for a pet
    func fetchVaccines(forPetId petId: Int) -> AnyPublisher<[Vaccine], Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("vaccines")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Vaccine].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // CREATE VACCINE for a pet
    func createVaccine(forPetId petId: Int, request: VaccineCreateRequest) -> AnyPublisher<Vaccine, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("vaccines")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try encoder.encode(request)
            urlRequest.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: Vaccine.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // UPDATE VACCINE
    func updateVaccine(id: Int, request: VaccineUpdateRequest) -> AnyPublisher<Vaccine, Error> {
        let url = baseURL.appendingPathComponent("vaccines").appendingPathComponent("\(id)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try encoder.encode(request)
            urlRequest.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: Vaccine.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // DELETE VACCINE
    func deleteVaccine(id: Int) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("vaccines").appendingPathComponent("\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Records

    // Decoder for records (handles mixed date formats)
    private let recordsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try date-only format first (for vaccines)
            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
            dateOnlyFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateOnlyFormatter.date(from: dateString) {
                return date
            }

            // Try Python datetime format with microseconds
            if let date = pythonDateTimeFormatter.date(from: dateString) {
                return date
            }
            // Try without microseconds
            if let date = pythonDateTimeFormatterNoMicro.date(from: dateString) {
                return date
            }
            // Try ISO8601 with Z suffix
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()

    // FETCH RECORDS for a user (all pets)
    func fetchUserRecords(userId: Int) -> AnyPublisher<RecordsResponse, Error> {
        let url = baseURL.appendingPathComponent("users").appendingPathComponent("\(userId)").appendingPathComponent("records")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: RecordsResponse.self, decoder: recordsDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // FETCH RECORDS for a specific pet
    func fetchPetRecords(petId: Int) -> AnyPublisher<RecordsResponse, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("records")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: RecordsResponse.self, decoder: recordsDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Tablets

    // FETCH TABLETS for a pet
    func fetchTablets(forPetId petId: Int) -> AnyPublisher<[Tablet], Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("tablets")

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Tablet].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // CREATE TABLET for a pet
    func createTablet(forPetId petId: Int, request: TabletCreateRequest) -> AnyPublisher<Tablet, Error> {
        let url = baseURL.appendingPathComponent("pets").appendingPathComponent("\(petId)").appendingPathComponent("tablets")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try encoder.encode(request)
            urlRequest.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: Tablet.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // UPDATE TABLET
    func updateTablet(id: Int, request: TabletUpdateRequest) -> AnyPublisher<Tablet, Error> {
        let url = baseURL.appendingPathComponent("tablets").appendingPathComponent("\(id)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try encoder.encode(request)
            urlRequest.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: Tablet.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // DELETE TABLET
    func deleteTablet(id: Int) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("tablets").appendingPathComponent("\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
