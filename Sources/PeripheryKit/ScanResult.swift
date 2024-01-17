import Foundation

public struct ScanResult {
    public enum Annotation {
        case unused
        case assignOnlyProperty
        case redundantProtocol(references: Set<Reference>, inherited: Set<String>)
        case redundantPublicAccessibility(modules: Set<String>)
    }

    public let declaration: Declaration
    public let annotation: Annotation
}
