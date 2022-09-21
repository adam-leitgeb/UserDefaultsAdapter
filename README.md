# UserDefaultsAdapter

A lightweight generic wrapper around UserDefaults. 

## Usage

### Model you'd like to store has to conform to `Codable` protocol

```
struct TestModel: Codable {
    let id: Int
}
```

### Save
```
let testModel = TestModel(id: 22)
try userDefaultsAdapter.save(testModel)
```

### Load
```
// Use default key (default key is name of the struct, "TestModel")

let loadedModel = try userDefaultsAdapter.load(type: TestModel.self)
XCTAssertEqual(loadedModel.id, 22)

// Use custom key

let modelWithCustomKeyToStore = TestModel(id: 22)
try userDefaultsAdapter.save(modelWithCustomKeyToStore, customKey: "custom-key")
```

### Delete
```
// Remove all stored objects of selected type

userDefaultsAdapter.removeAll(ofType: TestModel.self)

// Remove particular object

userDefaultsAdapter.remove(TestModel.self, customKey: "custom-key")
```
