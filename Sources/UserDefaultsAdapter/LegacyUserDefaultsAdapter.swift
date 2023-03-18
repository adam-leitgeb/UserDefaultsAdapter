import Combine
import Foundation

public struct LegacyUserDefaultsAdapter {

    // MARK: - Properties

    private let defaults: UserDefaults = .standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Actions

    public func loadIfPresent<T: Codable>(type: T.Type, customKey: String = "") -> T? {
        try? load(type: type, customKey: customKey)
    }
    
    public func load<T: Codable>(type: T.Type, customKey: String = "") throws -> T {
        let key = generateKey(for: type.self, customKey: customKey)

        guard let data = defaults.object(forKey: key) as? Data else {
            throw UserDefaultsAdapterError.notFound
        }
        return try decoder.decode(T.self, from: data)
    }

    public func save<T: Codable>(_ object: T?, customKey: String = "") throws {
        guard let object = object else {
            return try remove(T.self, customKey: customKey)
        }
        let key = generateKey(for: T.self, customKey: customKey)
        let encoded = try encoder.encode(object)
        defaults.set(encoded, forKey: key)
    }

    // Could be moved in utilities (+ become private)
    public func remove<T: Codable>(_ objectType: T.Type, customKey: String = "") throws {
        let key = generateKey(for: objectType, customKey: customKey)
        defaults.set(nil, forKey: key)
    }

    @available(*, deprecated, message: "Use method with explicit type instead")
    public func load<T: Codable>(customKey: String = "") throws -> T {
        let key = generateKey(for: T.self, customKey: customKey)

        guard let data = defaults.object(forKey: key) as? Data else {
            throw UserDefaultsAdapterError.notFound
        }
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Utilities

    private func generateKey<T>(for objectType: T.Type, customKey: String) -> String {
        var key = String(describing: type(of: self))
        key += "." + String(describing: objectType)
        key += customKey.isEmpty ? "" : ".\(customKey)"

        return key
    }
}

// MARK: - Combine

extension LegacyUserDefaultsAdapter {

    // Read

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    public func loadIfPresentPublisher<T: Codable>(type: T.Type, customKey: String = "") -> AnyPublisher<T?, Never> {
        Future { promise in
            let object: T? = loadIfPresent(type: type, customKey: customKey)
            promise(.success(object))
        }
        .eraseToAnyPublisher()
    }

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    public func loadPublisher<T: Codable>(type: T.Type, customKey: String = "") -> AnyPublisher<T, Error> {
        Future { promise in
            do {
                let object: T = try load(type: type, customKey: customKey)
                promise(.success(object))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
