// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public enum SSHKeyError: LocalizedError {
    case invalidPath
    case invalidPort
    case keyDirectoryCreationFailed
    case homeDirectoryNotFound
    case invalidServerAddress
    case invalidUsername
    
    public var errorDescription: String? {
        switch self {
        case .invalidPath:
            "Invalid SSH key path"
        case .invalidPort:
            "Invalid SSH port number"
        case .keyDirectoryCreationFailed:
            "Failed to create SSH key directory"
        case .homeDirectoryNotFound:
            "Could not determine user home directory"
        case .invalidServerAddress:
            "Invalid server address"
        case .invalidUsername:
            "Invalid username"
        }
    }
}

public final class SSHCreateKey {
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultIdentityFile = "id_rsa"
        static let defaultSSHDirectory = ".ssh"
        static let sshKeygenCommand = "/usr/bin/ssh-keygen"
        static let sshCopyIDCommand = "/usr/bin/ssh-copy-id"
        static let sshCommand = "/usr/bin/ssh"
        static let noPortValue = "-1"
    }
    
    // MARK: - Properties
    
    var sharedSSHPort: String?
    var sharedSSHKeyPathAndIdentityFile: String?
    
    public var createKeyCommand = Constants.sshKeygenCommand
    
    /// Lists all SSH key files in the SSH key directory
    public var allSSHKeyFiles: [String]? {
        let fileManager = FileManager.default
        guard let path = sshKeyPath else { return nil }
        
        do {
            return try fileManager.contentsOfDirectory(atPath: path)
        } catch {
            return nil
        }
    }
    
    /// Full path to SSH key including the identity file
    /// Example: /Users/username/.ssh/id_rsa
    public var sshKeyPathAndIdentityFile: String? {
        guard let userHome = userHomeDirectoryPath else { return nil }
        
        if let sharedPath = sharedSSHKeyPathAndIdentityFile, !sharedPath.isEmpty {
            return parseSSHKeyPath(sharedPath, userHome: userHome, includeIdentityFile: true)
        }
        
        return userHome + "/" + Constants.defaultSSHDirectory + "/" + Constants.defaultIdentityFile
    }
    
    /// Returns only the identity file name (e.g., "id_rsa" or custom name)
    public var identityFileOnly: String {
        guard let sharedPath = sharedSSHKeyPathAndIdentityFile,
              !sharedPath.isEmpty,
              sharedPath.first == "~" else {
            return Constants.defaultIdentityFile
        }
        
        let components = sharedPath.split(separator: "/")
        guard components.count > 2, let lastComponent = components.last else {
            return Constants.defaultIdentityFile
        }
        
        return String(lastComponent)
    }
    
    /// Path to SSH key directory (without identity file)
    /// Example: /Users/username/.ssh
    public var sshKeyPath: String? {
        guard let userHome = userHomeDirectoryPath else { return nil }
        
        if let sharedPath = sharedSSHKeyPathAndIdentityFile, !sharedPath.isEmpty {
            return parseSSHKeyPath(sharedPath, userHome: userHome, includeIdentityFile: false)
        }
        
        return userHome + "/" + Constants.defaultSSHDirectory
    }
    
    /// User's home directory path
    public var userHomeDirectoryPath: String? {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(
                withFileSystemRepresentation: home,
                length: Int(strlen(home))
            )
            return homePath
        }
        return nil
    }
    
    // MARK: - Initialization
    
    public init(sharedSSHPort: String?,
                sharedSSHKeyPathAndIdentityFile: String?) {
        self.sharedSSHPort = sharedSSHPort
        self.sharedSSHKeyPathAndIdentityFile = sharedSSHKeyPathAndIdentityFile
    }
    
    // MARK: - Public Methods
    
    /// Creates the SSH key root directory if it doesn't exist
    /// - Throws: SSHKeyError if directory creation fails
    public func createSSHKeyRootPath() throws {
        let fileManager = FileManager.default
        guard let keyPath = sshKeyPath else {
            throw SSHKeyError.invalidPath
        }
        
        // Return early if directory already exists
        guard !fileManager.locationExists(at: keyPath, kind: .folder) else {
            return
        }
        
        let keyPathURL = URL(fileURLWithPath: keyPath)
        
        do {
            try fileManager.createDirectory(
                at: keyPathURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw SSHKeyError.keyDirectoryCreationFailed
        }
    }
    
    /// Generates arguments for ssh-copy-id command to copy public key to remote server
    /// - Parameters:
    ///   - offsiteServer: Remote server address
    ///   - offsiteUsername: Username on remote server
    /// - Returns: Array of command arguments
    /// - Throws: SSHKeyError for invalid inputs
    public func argumentsSSHCopyID(offsiteServer: String,
                                   offsiteUsername: String) throws -> [String] {
        try validateServerAndUsername(server: offsiteServer, username: offsiteUsername)
        
        var args = [Constants.sshCopyIDCommand]
        args.append("-i")
        
        if let sharedPath = sharedSSHKeyPathAndIdentityFile,
           !sharedPath.isEmpty,
           let port = sharedSSHPort,
           port != Constants.noPortValue {
            try validatePort(port)
            args.append(sharedPath)
            args.append("-p")
            args.append(port)
        } else {
            guard let keyPath = sshKeyPathAndIdentityFile else {
                throw SSHKeyError.invalidPath
            }
            args.append(keyPath)
        }
        
        args.append("\(offsiteUsername)@\(offsiteServer)")
        return args
    }
    
    /// Generates arguments for SSH command to verify remote public key
    /// - Parameters:
    ///   - offsiteServer: Remote server address
    ///   - offsiteUsername: Username on remote server
    /// - Returns: Array of command arguments
    /// - Throws: SSHKeyError for invalid inputs
    public func argumentsVerifyRemotePublicSSHKey(offsiteServer: String,
                                                  offsiteUsername: String) throws -> [String] {
        try validateServerAndUsername(server: offsiteServer, username: offsiteUsername)
        
        var args = [Constants.sshCommand]
        
        if let port = sharedSSHPort, port != Constants.noPortValue {
            try validatePort(port)
            args.append("-p")
            args.append(port)
        }
        
        if let sharedPath = sharedSSHKeyPathAndIdentityFile, !sharedPath.isEmpty {
            args.append("-i")
            args.append(sharedPath)
        }
        
        args.append("\(offsiteUsername)@\(offsiteServer)")
        return args
    }
    
    /// Generates arguments for ssh-keygen to create a new RSA key pair
    /// - Returns: Array of command arguments for ssh-keygen
    /// - Throws: SSHKeyError if path is invalid
    public func argumentsCreateKey() throws -> [String] {
        var args = ["-t", "rsa", "-N", "", "-f"]
        
        if let sharedPath = sharedSSHKeyPathAndIdentityFile, !sharedPath.isEmpty {
            if sharedPath.first == "~" {
                guard let userHome = userHomeDirectoryPath else {
                    throw SSHKeyError.homeDirectoryNotFound
                }
                let expandedPath = sharedPath.replacingOccurrences(of: "~", with: userHome)
                args.append(expandedPath)
            } else {
                args.append(sharedPath)
            }
        } else {
            guard let keyPath = sshKeyPath else {
                throw SSHKeyError.invalidPath
            }
            args.append(keyPath + "/" + identityFileOnly)
        }
        
        return args
    }
    
    /// Checks if the public key file exists in the SSH key directory
    /// - Returns: true if public key exists, false otherwise
    public func validatePublicKeyPresent() -> Bool {
        guard let keyFiles = allSSHKeyFiles else { return false }
        let publicKeyName = identityFileOnly + ".pub"
        return keyFiles.contains(publicKeyName)
    }
    
    // MARK: - Private Helper Methods
    
    /// Parses SSH key path, handling tilde expansion and path extraction
    /// - Parameters:
    ///   - path: The path to parse (may start with ~)
    ///   - userHome: User's home directory
    ///   - includeIdentityFile: Whether to include the identity file in the result
    /// - Returns: Parsed path string
    private func parseSSHKeyPath(_ path: String,
                                 userHome: String,
                                 includeIdentityFile: Bool) -> String {
        guard path.first == "~" else {
            // Non-tilde path, return default
            let basePath = userHome + "/" + Constants.defaultSSHDirectory
            return includeIdentityFile ? basePath + "/" + Constants.defaultIdentityFile : basePath
        }
        
        var components = path.split(separator: "/")
        guard components.count > 2 else {
            // Invalid path structure, return default
            let basePath = userHome + "/" + Constants.defaultSSHDirectory
            return includeIdentityFile ? basePath + "/" + Constants.defaultIdentityFile : basePath
        }
        
        // Remove the identity file if we don't want it
        if !includeIdentityFile {
            components.removeLast()
        }
        
        // Remove the tilde and construct path
        let pathWithoutTilde = components.joined(separator: "/").dropFirst()
        return userHome + "/" + pathWithoutTilde
    }
    
    /// Validates server address and username for security
    /// - Parameters:
    ///   - server: Server address to validate
    ///   - username: Username to validate
    /// - Throws: SSHKeyError if inputs contain potentially malicious characters
    private func validateServerAndUsername(server: String, username: String) throws {
        let invalidCharacters = CharacterSet(charactersIn: ";|&$`\n\r")
        
        guard server.rangeOfCharacter(from: invalidCharacters) == nil else {
            throw SSHKeyError.invalidServerAddress
        }
        
        guard username.rangeOfCharacter(from: invalidCharacters) == nil else {
            throw SSHKeyError.invalidUsername
        }
        
        guard !server.isEmpty, !username.isEmpty else {
            throw SSHKeyError.invalidServerAddress
        }
    }
    
    /// Validates that port is a valid number
    /// - Parameter port: Port string to validate
    /// - Throws: SSHKeyError if port is invalid
    private func validatePort(_ port: String) throws {
        guard let portNumber = Int(port), portNumber > 0, portNumber <= 65535 else {
            throw SSHKeyError.invalidPort
        }
    }
}

// MARK: - FileManager Extension

extension FileManager {
    /// Checks if a location exists at the specified path and matches the expected kind
    /// - Parameters:
    ///   - path: File system path to check
    ///   - kind: Expected location kind (file or folder)
    /// - Returns: true if location exists and matches the kind
    func locationExists(at path: String, kind: LocationKind) -> Bool {
        var isFolder: ObjCBool = false
        
        guard fileExists(atPath: path, isDirectory: &isFolder) else {
            return false
        }
        
        switch kind {
        case .file: return !isFolder.boolValue
        case .folder: return isFolder.boolValue
        }
    }
}

// MARK: - Location Kind Enum

/// Describes the type of file system location
public enum LocationKind {
    /// A file can be found at the location
    case file
    /// A folder can be found at the location
    case folder
}
