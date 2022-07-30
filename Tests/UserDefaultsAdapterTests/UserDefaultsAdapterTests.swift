import XCTest
@testable import UserDefaultsAdapter

final class UserDefaultsAdapterTests: XCTestCase {

    // MARK: - Properties

    private let defaults = UserDefaults(suiteName: "test")!
    private lazy var userDefaultsAdapter = UserDefaultsAdapter(defaults: defaults)

    // MARK: - Tests

    func testSavingAndReading() throws {
        let modelToStore = TestModel(id: 22)
        try userDefaultsAdapter.save(modelToStore)

        let loadedModel = try userDefaultsAdapter.load(type: TestModel.self)
        XCTAssertEqual(loadedModel.id, 22)
    }
}

// MARK: - Utilities

fileprivate struct TestModel: Codable {
    let id: Int
}
