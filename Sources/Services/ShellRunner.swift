import Foundation

enum ShellError: Error {
    case nonZeroExit(Int32, stderr: String)
}

/// Runs shell commands asynchronously using Foundation Process.
/// Uses absolute paths since .app bundles don't inherit shell PATH.
enum ShellRunner {
    static func run(
        _ executable: String,
        arguments: [String] = [],
        workingDirectory: String? = nil
    ) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
            if let dir = workingDirectory {
                process.currentDirectoryURL = URL(fileURLWithPath: dir)
            }

            let stdout = Pipe()
            let stderr = Pipe()
            process.standardOutput = stdout
            process.standardError = stderr

            process.terminationHandler = { proc in
                let outData = stdout.fileHandleForReading.readDataToEndOfFile()
                let errData = stderr.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let errOutput = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if proc.terminationStatus != 0 {
                    continuation.resume(throwing: ShellError.nonZeroExit(proc.terminationStatus, stderr: errOutput))
                } else {
                    continuation.resume(returning: output)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
