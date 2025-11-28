## Hi there 👋

This package is code for assisting users to create SSH identityfile and key in RsyncUI. The user can either let RsyncUI assist in creating SSH identityfile and key in RsyncUI, or create it by commandline.

# SSHCreateKey

A Swift package for managing SSH keys, including creation, validation, and deployment to remote servers. Provides a safe, type-safe interface for common SSH key operations.

## Features

- **SSH Key Generation**: Create RSA key pairs with ssh-keygen
- **Key Deployment**: Copy public keys to remote servers using ssh-copy-id
- **Key Validation**: Verify public key presence and remote key access
- **Path Management**: Handle custom SSH key paths with tilde expansion
- **Security Validation**: Input sanitization for server addresses and usernames
- **Port Configuration**: Support for custom SSH ports
- **Directory Management**: Automatic SSH directory creation
- **Key Discovery**: List all SSH keys in the key directory

## Requirements

- Swift 5.9+
- macOS 13.0+ / iOS 16.0+ (macOS recommended for full SSH functionality)
- Foundation framework
- SSH command-line tools (`ssh-keygen`, `ssh-copy-id`, `ssh`)

## Usage

### Basic Key Creation

```swift
import SSHCreateKey

// Initialize with default settings
let sshKey = SSHCreateKey(
    sharedSSHPort: nil,
    sharedSSHKeyPathAndIdentityFile: nil
)

// Create SSH directory if needed
try sshKey.createSSHKeyRootPath()

// Generate key creation arguments
let args = try sshKey.argumentsCreateKey()
// Returns: ["-t", "rsa", "-N", "", "-f", "/Users/username/.ssh/id_rsa"]

// Execute ssh-keygen (using your process execution framework)
// /usr/bin/ssh-keygen -t rsa -N "" -f /Users/username/.ssh/id_rsa
```

### Custom SSH Key Path

```swift
// Use custom key location
let sshKey = SSHCreateKey(
    sharedSSHPort: "2222",
    sharedSSHKeyPathAndIdentityFile: "~/.ssh/my_custom_key"
)

// Get full path
if let fullPath = sshKey.sshKeyPathAndIdentityFile {
    print("Key will be created at: \(fullPath)")
    // Output: /Users/username/.ssh/my_custom_key
}

// Get just the identity file name
print("Identity file: \(sshKey.identityFileOnly)")
// Output: my_custom_key

// Get directory path only
if let dirPath = sshKey.sshKeyPath {
    print("SSH directory: \(dirPath)")
    // Output: /Users/username/.ssh
}
```

### Deploy Key to Remote Server

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: "22",
    sharedSSHKeyPathAndIdentityFile: "~/.ssh/id_rsa"
)

// Generate ssh-copy-id arguments
let args = try sshKey.argumentsSSHCopyID(
    offsiteServer: "example.com",
    offsiteUsername: "john"
)
// Returns arguments for: ssh-copy-id -i ~/.ssh/id_rsa -p 22 john@example.com

// Execute ssh-copy-id with these arguments
```

### Verify Remote Key Access

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: "2222",
    sharedSSHKeyPathAndIdentityFile: "~/.ssh/id_rsa"
)

// Generate SSH verification arguments
let args = try sshKey.argumentsVerifyRemotePublicSSHKey(
    offsiteServer: "example.com",
    offsiteUsername: "john"
)
// Returns arguments for: ssh -p 2222 -i ~/.ssh/id_rsa john@example.com

// Test connection with these arguments
```

### Validate Key Presence

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: nil,
    sharedSSHKeyPathAndIdentityFile: "~/.ssh/id_rsa"
)

// Check if public key exists
if sshKey.validatePublicKeyPresent() {
    print("✓ Public key (id_rsa.pub) exists")
} else {
    print("✗ Public key not found - need to create it")
}
```

### List All SSH Keys

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: nil,
    sharedSSHKeyPathAndIdentityFile: nil
)

// Get all files in SSH directory
if let keyFiles = sshKey.allSSHKeyFiles {
    print("SSH Key Files:")
    for file in keyFiles {
        print("  - \(file)")
    }
}
// Example output:
//   - id_rsa
//   - id_rsa.pub
//   - known_hosts
//   - config
```

## Complete Workflow Example

### Creating and Deploying an SSH Key

```swift
import SSHCreateKey
import ProcessCommand  // Your process execution framework

func setupSSHKey(
    server: String,
    username: String,
    customKeyPath: String? = nil,
    port: String? = nil
) async throws {
    
    // 1. Initialize SSH key manager
    let sshKey = SSHCreateKey(
        sharedSSHPort: port,
        sharedSSHKeyPathAndIdentityFile: customKeyPath
    )
    
    // 2. Create SSH directory if needed
    print("Creating SSH directory...")
    try sshKey.createSSHKeyRootPath()
    
    // 3. Check if key already exists
    if sshKey.validatePublicKeyPresent() {
        print("✓ SSH key already exists")
    } else {
        print("Creating new SSH key...")
        
        // 4. Generate the key
        let keygenArgs = try sshKey.argumentsCreateKey()
        
        // Execute ssh-keygen (pseudo-code)
        let process = ProcessCommand(
            command: "/usr/bin/ssh-keygen",
            arguments: keygenArgs,
            handlers: createHandlers()
        )
        try await process.executeProcess()
        
        print("✓ SSH key created")
    }
    
    // 5. Copy key to remote server
    print("Deploying key to \(server)...")
    let copyArgs = try sshKey.argumentsSSHCopyID(
        offsiteServer: server,
        offsiteUsername: username
    )
    
    // Execute ssh-copy-id (pseudo-code)
    let copyProcess = ProcessCommand(
        command: "/usr/bin/ssh-copy-id",
        arguments: Array(copyArgs.dropFirst()), // Remove command itself
        handlers: createHandlers()
    )
    try await copyProcess.executeProcess()
    
    print("✓ Key deployed to server")
    
    // 6. Verify connection
    print("Verifying SSH connection...")
    let verifyArgs = try sshKey.argumentsVerifyRemotePublicSSHKey(
        offsiteServer: server,
        offsiteUsername: username
    )
    
    // Test SSH connection (pseudo-code)
    let verifyProcess = ProcessCommand(
        command: "/usr/bin/ssh",
        arguments: Array(verifyArgs.dropFirst()) + ["echo", "Connection successful"],
        handlers: createHandlers()
    )
    try await verifyProcess.executeProcess()
    
    print("✓ SSH setup complete!")
}

// Usage
try await setupSSHKey(
    server: "example.com",
    username: "john",
    customKeyPath: "~/.ssh/my_server_key",
    port: "2222"
)
```

## SwiftUI Integration

### SSH Key Setup View

```swift
import SwiftUI
import SSHCreateKey

struct SSHKeySetupView: View {
    @State private var server = ""
    @State private var username = ""
    @State private var port = "22"
    @State private var customKeyPath = ""
    @State private var useCustomPath = false
    
    @State private var isProcessing = false
    @State private var statusMessage = ""
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section("Server Details") {
                TextField("Server Address", text: $server)
                    .textContentType(.URL)
                
                TextField("Username", text: $username)
                    .textContentType(.username)
                
                TextField("Port", text: $port)
                    .keyboardType(.numberPad)
            }
            
            Section("SSH Key Configuration") {
                Toggle("Use Custom Key Path", isOn: $useCustomPath)
                
                if useCustomPath {
                    TextField("Key Path", text: $customKeyPath)
                        .font(.system(.body, design: .monospaced))
                    Text("Example: ~/.ssh/my_custom_key")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Button(action: setupKey) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Label("Setup SSH Key", systemImage: "key.fill")
                    }
                }
                .disabled(isProcessing || server.isEmpty || username.isEmpty)
            }
            
            if !statusMessage.isEmpty {
                Section("Status") {
                    Text(statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("SSH Key Setup")
    }
    
    func setupKey() {
        Task {
            isProcessing = true
            errorMessage = nil
            statusMessage = "Initializing..."
            
            do {
                let sshKey = SSHCreateKey(
                    sharedSSHPort: port,
                    sharedSSHKeyPathAndIdentityFile: useCustomPath ? customKeyPath : nil
                )
                
                // Create directory
                statusMessage = "Creating SSH directory..."
                try sshKey.createSSHKeyRootPath()
                
                // Check for existing key
                if sshKey.validatePublicKeyPresent() {
                    statusMessage = "✓ SSH key already exists"
                } else {
                    statusMessage = "Creating new SSH key..."
                    let args = try sshKey.argumentsCreateKey()
                    // Execute key creation here
                    statusMessage = "✓ SSH key created"
                }
                
                // Deploy key
                statusMessage = "Deploying key to server..."
                let copyArgs = try sshKey.argumentsSSHCopyID(
                    offsiteServer: server,
                    offsiteUsername: username
                )
                // Execute ssh-copy-id here
                
                statusMessage = "✓ Setup complete!"
                
            } catch let error as SSHKeyError {
                errorMessage = error.localizedDescription
                statusMessage = "Setup failed"
            } catch {
                errorMessage = error.localizedDescription
                statusMessage = "Setup failed"
            }
            
            isProcessing = false
        }
    }
}
```

## API Reference

### SSHCreateKey

Main class for SSH key management.

#### Initialization

```swift
public init(
    sharedSSHPort: String?,
    sharedSSHKeyPathAndIdentityFile: String?
)
```

#### Properties

- `createKeyCommand: String` - Path to ssh-keygen (default: "/usr/bin/ssh-keygen")
- `allSSHKeyFiles: [String]?` - List of all files in SSH directory
- `sshKeyPathAndIdentityFile: String?` - Full path including identity file
- `identityFileOnly: String` - Just the identity file name
- `sshKeyPath: String?` - Directory path without identity file
- `userHomeDirectoryPath: String?` - User's home directory

#### Methods

**Directory Management:**
```swift
func createSSHKeyRootPath() throws
```
Creates SSH directory if it doesn't exist.

**Key Generation:**
```swift
func argumentsCreateKey() throws -> [String]
```
Returns arguments for ssh-keygen to create RSA key pair.

**Key Deployment:**
```swift
func argumentsSSHCopyID(
    offsiteServer: String,
    offsiteUsername: String
) throws -> [String]
```
Returns arguments for ssh-copy-id to deploy public key.

**Key Verification:**
```swift
func argumentsVerifyRemotePublicSSHKey(
    offsiteServer: String,
    offsiteUsername: String
) throws -> [String]
```
Returns arguments for SSH connection test.

**Validation:**
```swift
func validatePublicKeyPresent() -> Bool
```
Checks if public key file exists.

### Error Types

```swift
public enum SSHKeyError: LocalizedError {
    case invalidPath                    // Invalid SSH key path
    case invalidPort                    // Invalid port number
    case keyDirectoryCreationFailed     // Cannot create directory
    case homeDirectoryNotFound          // Cannot find home directory
    case invalidServerAddress           // Invalid server address
    case invalidUsername                // Invalid username
}
```

### LocationKind

Helper enum for file system checks:

```swift
public enum LocationKind {
    case file      // Location is a file
    case folder    // Location is a folder
}
```

## Security Features

### Input Validation

SSHCreateKey validates all inputs to prevent command injection:

```swift
// These characters are blocked in server addresses and usernames
let invalidCharacters = ";|&$`\n\r"

try sshKey.argumentsSSHCopyID(
    offsiteServer: "example.com; rm -rf /",  // ❌ Throws SSHKeyError.invalidServerAddress
    offsiteUsername: "user"
)
```

### Port Validation

```swift
// Port must be between 1 and 65535
let sshKey = SSHCreateKey(
    sharedSSHPort: "99999",  // ❌ Will throw SSHKeyError.invalidPort
    sharedSSHKeyPathAndIdentityFile: nil
)
```

## Path Handling

### Tilde Expansion

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: nil,
    sharedSSHKeyPathAndIdentityFile: "~/.ssh/custom_key"
)

// Automatically expands ~ to user home directory
if let fullPath = sshKey.sshKeyPathAndIdentityFile {
    print(fullPath)
    // Output: /Users/john/.ssh/custom_key (not ~/.ssh/custom_key)
}
```

### Default Paths

If no custom path is provided, defaults are used:

- **Key directory**: `~/.ssh`
- **Identity file**: `id_rsa`
- **Full default path**: `~/.ssh/id_rsa`

## Best Practices

1. **Always validate key presence** before attempting to create a new one
2. **Use custom key paths** for server-specific keys (e.g., `~/.ssh/production_key`)
3. **Handle errors appropriately** - all methods throw typed errors
4. **Create directory first** using `createSSHKeyRootPath()` before key generation
5. **Validate input** - the class handles validation, but check return values
6. **Use specific ports** when servers don't use default SSH port (22)
7. **Test connections** after deployment using `argumentsVerifyRemotePublicSSHKey()`

## Common Patterns

### Multi-Server Setup

```swift
struct ServerConfig {
    let name: String
    let address: String
    let username: String
    let port: String
    let keyPath: String
}

let servers = [
    ServerConfig(name: "Production", address: "prod.example.com", 
                 username: "deploy", port: "22", keyPath: "~/.ssh/prod_key"),
    ServerConfig(name: "Staging", address: "staging.example.com", 
                 username: "deploy", port: "2222", keyPath: "~/.ssh/staging_key")
]

for server in servers {
    let sshKey = SSHCreateKey(
        sharedSSHPort: server.port,
        sharedSSHKeyPathAndIdentityFile: server.keyPath
    )
    
    // Setup key for this server
    try sshKey.createSSHKeyRootPath()
    
    if !sshKey.validatePublicKeyPresent() {
        let args = try sshKey.argumentsCreateKey()
        // Execute key creation
    }
    
    // Deploy to server
    let copyArgs = try sshKey.argumentsSSHCopyID(
        offsiteServer: server.address,
        offsiteUsername: server.username
    )
    // Execute deployment
}
```

## Troubleshooting

### Key Already Exists Error

```swift
// Check before creating
if sshKey.validatePublicKeyPresent() {
    print("Key already exists - skipping creation")
} else {
    let args = try sshKey.argumentsCreateKey()
    // Create key
}
```

### Permission Denied

Ensure the SSH directory has correct permissions (700):

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Connection Refused

Verify the port and server address:

```swift
let sshKey = SSHCreateKey(
    sharedSSHPort: "22",  // Verify correct port
    sharedSSHKeyPathAndIdentityFile: nil
)
```

## License

MIT

## Author

Thomas Evensen