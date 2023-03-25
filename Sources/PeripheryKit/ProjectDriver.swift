import Foundation
import Shared

public protocol ProjectDriver {
    static func build() throws -> Self

    func build() throws
    func index(graph: SourceGraph) throws
}
