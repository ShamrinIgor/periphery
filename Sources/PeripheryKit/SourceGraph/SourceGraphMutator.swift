import Foundation
import PeripheryShared

protocol SourceGraphMutator: AnyObject {
    init(graph: SourceGraph, configuration: Configuration)
    func mutate() throws
}
