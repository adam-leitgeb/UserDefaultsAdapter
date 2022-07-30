//
//  UserDefaultsAdapterError.swift
//  Approver
//
//  Created by Adam Leitgeb on 09.05.2021.
//

import Foundation

enum UserDefaultsAdapterError: Error {
    case notFound
    case decodingError(Error)
}
