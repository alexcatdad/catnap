import Foundation

private let git = "/usr/bin/git"

/// Discovers git repos in a directory and extracts status info from each.
enum GitScanner {
    /// Returns directories under `scanPath` that contain a `.git` folder.
    static func discoverRepos(in scanPath: String) async throws -> [String] {
        let fm = FileManager.default
        let expanded = NSString(string: scanPath).expandingTildeInPath
        guard let entries = try? fm.contentsOfDirectory(atPath: expanded) else { return [] }

        return entries.compactMap { entry in
            let full = (expanded as NSString).appendingPathComponent(entry)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: full, isDirectory: &isDir), isDir.boolValue else { return nil }
            let gitDir = (full as NSString).appendingPathComponent(".git")
            guard fm.fileExists(atPath: gitDir) else { return nil }
            return full
        }
        .sorted()
    }

    /// Scans a single repo for git metadata.
    static func scan(repoPath: String) async -> GitInfo? {
        async let lastCommit = lastCommitDate(in: repoPath)
        async let branch = currentBranch(in: repoPath)
        async let dirty = isDirty(in: repoPath)

        guard let date = await lastCommit else { return nil }
        return GitInfo(
            lastCommitDate: date,
            branch: await branch ?? "unknown",
            isDirty: await dirty
        )
    }

    private static func lastCommitDate(in path: String) async -> Date? {
        do {
            let output = try await ShellRunner.run(
                git, arguments: ["log", "-1", "--format=%aI"], workingDirectory: path
            )
            guard !output.isEmpty else { return nil }
            return ISO8601DateFormatter().date(from: output)
        } catch {
            print("[GitScanner] lastCommitDate failed for \(path): \(error)")
            return nil
        }
    }

    private static func currentBranch(in path: String) async -> String? {
        do {
            return try await ShellRunner.run(
                git, arguments: ["rev-parse", "--abbrev-ref", "HEAD"], workingDirectory: path
            )
        } catch {
            print("[GitScanner] currentBranch failed for \(path): \(error)")
            return nil
        }
    }

    private static func isDirty(in path: String) async -> Bool {
        do {
            let output = try await ShellRunner.run(
                git, arguments: ["status", "--porcelain"], workingDirectory: path
            )
            return !output.isEmpty
        } catch {
            print("[GitScanner] isDirty failed for \(path): \(error)")
            return false
        }
    }
}

struct GitInfo: Sendable {
    let lastCommitDate: Date
    let branch: String
    let isDirty: Bool
}
