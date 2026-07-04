import Foundation

enum BuildInfo {
    static var gitRevision: String {
        if let value = Bundle.main.infoDictionary?["LabWordGitRevision"] as? String,
           !value.isEmpty {
            return value
        }
        return "dev"
    }

    static var shortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    static var fullVersion: String {
        "\(shortVersion) (\(gitRevision))"
    }
}
