import Foundation
import Shared

final class UnusedImportMarker: SourceGraphMutator {
    private let graph: SourceGraph

    required init(graph: SourceGraph, configuration: Configuration) {
        self.graph = graph
    }

    func mutate() {
        var referencedModulesByFile = [SourceFile: Set<String>]()

        for ref in graph.allReferences {
            guard let decl = graph.explicitDeclaration(withUsr: ref.usr) else { continue }
            referencedModulesByFile[ref.location.file, default: []].formUnion(decl.location.file.modules)
        }

        for (file, referencedModules) in referencedModulesByFile {
            let imports = file.importStatements
                .filter { !$0.isExported && graph.indexedModules.contains($0.module) }

            let unusedImports = imports
                .filter { !referencedModules.contains($0.module) }

//            let missingImports = referencedModules
//                .filter { refMod in
//                    !imports.contains(where: { $0.module == refMod })
//                }
//                .filter { !file.modules.contains($0) }
//
//            for x in missingImports {
//                print("!\(file.path.string): '\(x)'")
//            }

            for unusedImport in unusedImports {
                let exportedModule = referencedModules.first {
                    graph.isModule($0, exportedBy: unusedImport.module)
                }

                if let exportedModule {
                    // Import is unused if the exported referenced module is imported directly.
                    if imports.contains(where: { $0.module == exportedModule }) {
                        graph.markUnusedModuleImport(unusedImport)
                    }
                } else {
                    graph.markUnusedModuleImport(unusedImport)
                }
            }
        }
    }
}
