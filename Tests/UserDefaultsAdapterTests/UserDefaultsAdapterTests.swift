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

    func testSavingAndReadingWithCustomKey() throws {
        let modelToStore = TestModel(id: 22)
        try userDefaultsAdapter.save(modelToStore, customKey: "custom-key")

        let loadedModel = try userDefaultsAdapter.load(type: TestModel.self, customKey: "custom-key")
        XCTAssertEqual(loadedModel.id, 22)
    }

    func testOverridingCustomKeyWithDefault() throws {
        let modelWithCustomKeyToStore = TestModel(id: 22)
        try userDefaultsAdapter.save(modelWithCustomKeyToStore, customKey: "UserDefaultsAdapter.TestModel")

        let modelWithDefaultKeyToStore = TestModel(id: 23)
        try userDefaultsAdapter.save(modelWithDefaultKeyToStore)

        let loadedModel = try userDefaultsAdapter.load(type: TestModel.self)
        XCTAssertEqual(loadedModel, modelWithDefaultKeyToStore)
        XCTAssertNotEqual(loadedModel, modelWithCustomKeyToStore )
    }
}

// MARK: - Utilities

fileprivate struct TestModel: Codable, Equatable {
    let id: Int

    static func == (lhs: TestModel, rhs: TestModel) -> Bool {
        lhs.id == rhs.id
    }
}
