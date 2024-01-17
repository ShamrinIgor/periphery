import Foundation

public class SourceLocation {
    public let file: SourceFile
    public let line: Int
    public let column: Int

    private let hashValueCache: Int

    public init(file: SourceFile, line: Int, column: Int) {
        self.file = file
        self.line = line
        self.column = column
        self.hashValueCache = [file.hashValue, line, column].hashValue
    }

    // MARK: - Private

    private func buildDescription(path: String) -> String {
        [path, line.description, column.description].joined(separator: ":")
    }

    private lazy var descriptionInternal: String = {
        buildDescription(path: file.path.string)
    }()

    private lazy var shortDescriptionInternal: String = {
        buildDescription(path: file.path.lastComponent?.string ?? "")
    }()
}

extension SourceLocation: Equatable {
    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        lhs.file == rhs.file && lhs.line == rhs.line && lhs.column == rhs.column
    }
}

extension SourceLocation: Hashable {
    public func hash(into hasher: inout Hasher) {

        hasher.combine(hashValueCache)
    }
}

extension SourceLocation: CustomStringConvertible {
    public var description: String {
        return descriptionInternal
    }

    public var shortDescription: String {
        return shortDescriptionInternal
    }
}

extension SourceLocation: Comparable {
    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        if lhs.file == rhs.file {
            if lhs.line == rhs.line {
                return lhs.column < rhs.column
            }

            return lhs.line < rhs.line
        }

        return lhs.file < rhs.file
    }
}
