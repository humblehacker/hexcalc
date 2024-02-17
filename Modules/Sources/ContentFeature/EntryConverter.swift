import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct EntryConverter {
    var text: (_ integer: Int, _ kind: EntryKind) throws -> String = { _, _ in "" }
    var integer: (_ text: String, _ kind: EntryKind) throws -> Int? = { _, _ in 0 }
}
enum EntryConverterError: Error {
    case invalidConversion
}

extension EntryConverter: DependencyKey {
    static let liveValue = Self(
        text: { integer, kind in
            String(integer, radix: kind.base, uppercase: true)
        },
        integer: { text, kind in
            if kind == .exp {
                guard text.isNotEmpty else { return nil }
                @Dependency(\.expressionEvaluator.evaluate) var evaluateExpression
                return try evaluateExpression(text)
            } else {
                guard let value = Int(text, radix: kind.base) else { throw EntryConverterError.invalidConversion }
                return value
            }
        }
    )
}

extension DependencyValues {
    var entryConverter: EntryConverter {
        get { self[EntryConverter.self] }
        set { self[EntryConverter.self] = newValue }
    }
}
