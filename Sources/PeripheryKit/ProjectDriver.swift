import Foundation

public protocol ProjectDriver {
    static func build(currentDir: URL?) throws -> Self

    func build() throws
    func index(graph: SourceGraph) throws
}
