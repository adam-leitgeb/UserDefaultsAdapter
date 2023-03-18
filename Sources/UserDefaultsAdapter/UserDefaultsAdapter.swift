//
//  UserDefaultsAdapter.swift
//  Approver
//
//  Created by Adam Leitgeb on 09.05.2021.
//

import Combine
import Foundation

public struct UserDefaultsAdapter {
        
    // MARK: - Properties
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Object Lifecycle

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Read
    
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
    
    // MARK: - Write
    
    public func save<T: Codable>(_ object: T?, customKey: String = "") throws {
        guard let object = object else {
            return try remove(T.self, customKey: customKey)
        }
        let key = generateKey(for: T.self, customKey: customKey)
        let encoded = try encoder.encode(object)
        defaults.set(encoded, forKey: key)
    }
    
    public func remove<T: Codable>(_ objectType: T.Type, customKey: String = "") throws {
        let key = generateKey(for: objectType, customKey: customKey)
        defaults.set(nil, forKey: key)
    }

    public func removeAll<T: Codable>(ofType: T.Type) {
        let typeToBeRemoved = String(describing: ofType)
        let dictionaryRepresentation = defaults.dictionaryRepresentation()
        var keys = dictionaryRepresentation.keys.map { $0 as String }
        keys = keys.filter { $0.contains(typeToBeRemoved) }
        keys.forEach(defaults.removeObject)
    }
    
    // MARK: - Utilities
    
    private func generateKey<T>(for objectType: T.Type, customKey: String) -> String {
        guard customKey.isEmpty else {
            return customKey
        }
        
        var key = String(describing: type(of: self))
        key += "." + String(describing: objectType)
        key += customKey.isEmpty ? "" : ".\(customKey)"
        
        return key
    }
}

// MARK: - Combine

extension UserDefaultsAdapter {

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
