# LazyJSON

*LazyJSON* is a library for extracting model objects out of JSON values in a fast, type-safe and extensible way.

## Use

### Basic Example

```swift
import LazyJSON

struct User {
  let name: String
  let age: Int?
}

struct Group {
  let users: [User]
  let attributes: [String: Int]
}

extension User: Decodable {
  static var decoder: Decoder<User>.Function {
    return { name in { age in User(name: name, age: age) } }
        <^> <~"name"
        <*> <~?"age"
  }
}

extension Group: Decodable {
  static var decoder: Decoder<Group>.Function {
    return { users in { attrs in Group(users: users, attributes: attrs) } }
        <^> <|"users"
        <*> <&"attributes"
  }
}

let json: AnyObject = ...

do {
  let allGroups: [Group] = try decode(json, root: "groups")
} catch {
  print("parsing failed with error", error)
}
```

### Explanation

To decode some value its type has to conform to the `Decodable` protocol. For this you have to provide a static gettable property named `decoder` which returns a function of the type `JSON throws -> DecodedType` or hiding the specific details `Decoder<DecodedType>.Function`.

Using the parsing operators and those used in functional applicative style (`<^>` and `<*>`) you can easily implement the decoder without having to touch the passed json object directly.

## About *LazyJSON's* speed

**It is fast because *LazyJSON* …**

  - never builds arrays or dictionaries using a `reduce`–`+` operation but sticks to `for...in` loops
  - parses only those objects it has to parse (e.g. when accessing the key-path `outer.nesting.inner` the object with the key *inner* is never parsed)
  - doesn't wrap every result into an enum which has to be unwrapped and rewrapped every time, but uses Swift error handling technique
  - doesn't cast whole arrays and dictionaries from `AnyObject` to `Array` or `Dictionary`

**The downside:**

  - *LazyJSON* assumes to operate on Foundation objects and thus saving time by not bridging whole arrays/dictionaries but accessing them internally as `NSArray` or `NSDictionary`.

    In other words, that means, passing a Swift object structure probably won't give you this much of an speed improvement in comparison to other parsing libraries.

## Reference

### Key-Paths

A key-path is way through a JSON structure by object keys and array indices to a specific value. There are two different representations of key-paths in *LazyJSON*:

  1. Key-Paths given by the user to retrieve a specific value:

     Those are of the type `[KeyPathElem]` because array literals are easy to be constructed, while they are as easily traversed in a forward direction when extracting values.

     `KeyPathElem` is both `StringLiteralConvertible` and `IntegerLiteralConvertible`. The former is used to extract values from JSON objects while the latter is beeing used to index into JSON arrays.

  2. Key-Paths returned by the library to locate errors and JSON values:

     Those are of the type `KeyPath`, an enum similar to a linked list. This structure was chosen because it saves some allocations while preserving easy appending.

     Any `KeyPath` can be turned into an array of `KeyPathElem`s by using the `keyPathArray` property.

#### Examples

```swift
key(["user"])               // Extract a decodable at the top level key "user"
key(["user", "friend", 0])  // Extract the first friend from the array of friends of the user object
```

### Parsing Operators

All these are prefix operators which you prepend either to a single key or an array of keys forming a key-path.

If you want to extract a type `A` where `A` is `Decodable`, then `A.DecodedType` must equal `A` because else the compiler has no chance to infer the type of `A`.

| Type       | Basic | Optional | Additional Constraints
|:-----------|:-----:|:--------:|:----------------------
| Decodable  | `<~`  | `<~?`    | *none*
| Array      | `<|`  | `<|?`    | `Element: Decodable`
| Dictionary | `<&`  | `<&?`    | `Key == String, Value: Decodable`


#### Examples

```swift
<|"users"               // Extract the array of users
<~?["users", 0, "age"]  // Optionally extract the age of the first user
<&"attributes"          // Extract the dictionary of attributes
```

## Contributing

As this project is in a very early stage, feel free to open issues and pull requestes for feature requests, improvements and bug-fixes.

### Things to be done:

  - Write a test suite
  - Document the code
  - Think about better extracting operators (`<~`, `<|` and `<&`)
