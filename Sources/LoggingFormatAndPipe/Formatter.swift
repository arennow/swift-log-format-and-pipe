//
//  Formatter.swift
//  LoggingFormatAndPipe
//
//  Created by Ian Grossberg on 7/22/19.
//

import Logging
import Foundation

/// Possible log format components
public enum LogComponent {
    /// Timestamp of log
    /// Specifying your timestamp format can be done by providing a DateFormatter through `Formatter.timestampFormatter`
    case timestamp

    /// Logger label
    case label
    /// Log level
    case level
    /// The actual message
    case message
    /// Log metadata
    case metadata
    /// Log source
    case source
    /// The log's originating file
    case file
    /// The log's originating function
    case function
    /// The log's originating line number
    case line

    /// Literal text
    case text(String)
    /// A group of `LogComponents`, not using the specified `separator`
    case group([LogComponent])

    /// All basic log format component types
    public static var allNonmetaComponents: [LogComponent] {
        return [
            .timestamp,
            .level,
            .label,
            .message,
            .metadata,
            .source,
            .file,
            .function,
            .line
        ]
    }
}

/// Log Formatter
public protocol Formatter {
    /// Timestamp formatter
    var timestampFormatter: DateFormatter { get }

    /// Formatter's chance to format the log
    /// - Parameter level: log level
    /// - Parameter label: logger label
    /// - Parameter message: actual message
    /// - Parameter prettyMetadata: optional metadata that has already been "prettified"
    /// - Parameter file: log's originating file
    /// - Parameter function: log's originating function
    /// - Parameter line: log's originating line
    /// - Returns: Result of formatting the log
    func processLog(level: Logger.Level,
                    label: String,
                    message: Logger.Message,
                    prettyMetadata: String?,
                    source: String,
                    file: String, function: String, line: UInt) -> String

}

extension Formatter {
    /// Common usage component formatter
    /// - Parameter _: component to format
    /// - Parameter now: log's Date
    /// - Parameter level: log level
    /// - Parameter message: actual message
    /// - Parameter prettyMetadata: optional metadata that has already been "prettified"
    /// - Parameter file: log's originating file
    /// - Parameter function: log's originating function
    /// - Parameter line: log's originating line
    /// - Returns: Result of formatting the component
    public func processComponent(_ component: LogComponent, now: Date, level: Logger.Level,
                                  label: String,
                                  message: Logger.Message,
                                  prettyMetadata: String?,
                                  source: String,
                                  file: String, function: String, line: UInt) -> String {
        switch component {
        case .timestamp:
            return self.timestampFormatter.string(from: now)
        case .label:
            return "\(label)"
        case .level:
            return "\(level)"
        case .message:
            return "\(message)"
        case .metadata:
            return "\(prettyMetadata.map { "\($0)" } ?? "")"
        case .source:
            return "\(source)"
        case .file:
            return "\(file)"
        case .function:
            return "\(function)"
        case .line:
            return "\(line)"
        case .text(let string):
            return string
        case .group(let logComponents):
            return logComponents.map({ (component) -> String in
                self.processComponent(component, now: now, level: level, label: label, message: message, prettyMetadata: prettyMetadata, source: source, file: file, function: function, line: line)
            }).joined()
        }
    }
}
