// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

@MainActor
public final class SSHCreateKey {

    var sharedsshport: String?
    var sharedsshkeypathandidentityfile: String?
    
    public var createkeycommand = "/usr/bin/ssh-keygen"
    public var rsaStringPath: String?
    
    // Arrays all sshkey files
    public var allsshkeyfiles: [String]? {
        let fm = FileManager.default
        if let atpath = sshkeypath {
            var array = [String]()
            do {
                for files in try fm.contentsOfDirectory(atPath: atpath) {
                    array.append(files)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Path to ssh keypath including identityfile
    public var sshkeypathandidentityfile: String? {
        if let sharedsshkeypathandidentityfile,
           let userHomeDirectoryPath
        {
            if sharedsshkeypathandidentityfile.first == "~" {
                // must drop identityfile and then set rootpath
                // also drop the "~" character
                let sshkeypathandidentityfilesplit = sharedsshkeypathandidentityfile.split(separator: "/")
                guard sshkeypathandidentityfilesplit.count > 2 else {
                    // If anything goes wrong set to default global values
                    return userHomeDirectoryPath + "/.ssh/" + "/" + identityfileonly
                }
                return userHomeDirectoryPath + sshkeypathandidentityfilesplit.joined(separator: "/").dropFirst()

            } else {
                // If anything goes wrong set to default global values
                return userHomeDirectoryPath + "/.ssh" + "/" + identityfileonly
            }
        } else if let userHomeDirectoryPath {
            return userHomeDirectoryPath  + "/.ssh" + "/" + identityfileonly
        }
        return nil
    }

    // SSH identityfile with full keypath if NOT default is used
    // If default, only return defalt value
    public var identityfileonly: String {
        if let sharedsshkeypathandidentityfile {
            if sharedsshkeypathandidentityfile.first == "~" {
                // must drop identityfile and then set rootpath
                // also drop the "~" character
                let sshkeypathandidentityfilesplit = sharedsshkeypathandidentityfile.split(separator: "/")
                guard sshkeypathandidentityfilesplit.count > 2 else {
                    // If anything goes wrong set to default global values
                    return "id_rsa"
                }
                return String(sshkeypathandidentityfilesplit[sshkeypathandidentityfilesplit.count - 1])
            } else {
                // If anything goes wrong set to default global values
                return "id_rsa"
            }
        } else {
            return "id_rsa"
        }
    }

    // Used when creating ssh keypath
    // default keypath - Users/thomas/ssh
    // user set keypath - Users/thomas/.ssh_global
    // If not created return nil
    // NO trailing "/"
    
    public var sshkeypath: String? {
        if let sharedsshkeypathandidentityfile,
           let userHomeDirectoryPath
        {
            if sharedsshkeypathandidentityfile.first == "~" {
                // must drop identityfile and then set rootpath
                // also drop the "~" character
                var sshkeypathandidentityfilesplit = sharedsshkeypathandidentityfile.split(separator: "/")
                guard sshkeypathandidentityfilesplit.count > 2 else {
                    // If anything goes wrong set to default global values
                    return userHomeDirectoryPath
                }
                sshkeypathandidentityfilesplit.remove(at: sshkeypathandidentityfilesplit.count - 1)
                return userHomeDirectoryPath +
                    String(sshkeypathandidentityfilesplit.joined(separator: "/").dropFirst())

            } else {
                // If anything goes wrong set to default global values
                return userHomeDirectoryPath + "/.ssh"
            }
        } else if let userHomeDirectoryPath {
            return userHomeDirectoryPath + "/.ssh"
        }
        return nil
    }

    public var userHomeDirectoryPath: String? {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
            return homePath
        } else {
            return nil
        }
    }

    // Create SSH catalog
    // If ssh catalog exists - bail out, no need to create
    public func createsshkeyrootpath() {
        let fm = FileManager.default
        if let sshkeypath {
            guard fm.keypathlocationExists(at: sshkeypath, kind: .folder) == false else {
                return
            }
            let sshkeypathlURL = URL(fileURLWithPath: sshkeypath)

            do {
                try fm.createDirectory(at: sshkeypathlURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // catch let e
                // _ = e
                // propogateerror(error: error)
                return
            }
        }
    }

    // Set parameters for ssh-copy-id for copy public ssh key to server
    // ssh-address = "backup@server.com"
    // ssh-copy-id -i $ssh-keypath -p port $ssh-address
    public func argumentssshcopyid(offsiteServer: String,
                                   offsiteUsername: String) -> String
    {
        var args = [String]()
        let command = "/usr/bin/ssh-copy-id"
        args.append(command)
        args.append("-i")
        if let sharedsshkeypathandidentityfile,
           let sharedsshport,
           sharedsshkeypathandidentityfile.isEmpty == false,
           sharedsshport != "-1"
        {
            args.append(sharedsshkeypathandidentityfile)
            args.append("-p")
            args.append(sharedsshport)
        } else {
            args.append(sshkeypathandidentityfile ?? "")
        }
        args.append(offsiteUsername + "@" + offsiteServer)
        return args.joined(separator: " ")
    }

    // Check if pub key exists on remote server
    // ssh -p port -i $ssh-keypath $ssh-address
    public func argumentsverifyremotepublicsshkey(offsiteServer: String,
                                           offsiteUsername: String) -> String
    {
        var args = [String]()
        let command = "/usr/bin/ssh"
        args.append(command)
        
        if let sharedsshport, sharedsshport != "-1" {
            args.append("-p")
            args.append(sharedsshport)
        }
        if let sharedsshkeypathandidentityfile,
           sharedsshkeypathandidentityfile.isEmpty == false
        {
            args.append("-i")
            args.append(sharedsshkeypathandidentityfile)
        }
        args.append(offsiteUsername + "@" + offsiteServer)
        return args.joined(separator: " ")
    }

    // Create local key with ssh-keygen
    // Generate a passwordless RSA keyfile -N sets password, "" makes it blank
    // ssh-keygen -t rsa -N "" -f $ssh-keypath
    public func argumentscreatekey() -> [String]? {
        var args = [String]()
        args.append("-t")
        args.append("rsa")
        args.append("-N")
        args.append("")
        args.append("-f")
        if let sharedsshkeypathandidentityfile,
           sharedsshkeypathandidentityfile.isEmpty == false
        {
            if sharedsshkeypathandidentityfile.first == "~" {
                //replace the tilde with full Homecatalog
                // The Process object does not expand the tilde character when using ssh-keygen
                if let userHomeDirectoryPath {
                    let tempsharedsshkeypathandidentityfile = sharedsshkeypathandidentityfile.replacingOccurrences(of: "~", with: userHomeDirectoryPath)
                    args.append(tempsharedsshkeypathandidentityfile)
                }
            } else {
                args.append(sharedsshkeypathandidentityfile)
            }
            
        } else {
            if let sshkeypath {
                args.append(sshkeypath + "/" + identityfileonly)
            }
        }
        return args
    }

    public func validatepublickeypresent() -> Bool {
        if let allsshkeyfiles {
            let publickey = identityfileonly.appending(".pub")
            return allsshkeyfiles.contains(publickey)
        }
        return false
    }

    public init(sharedsshport: String?,
                sharedsshkeypathandidentityfile: String?)
    {
        self.sharedsshport = sharedsshport
        self.sharedsshkeypathandidentityfile = sharedsshkeypathandidentityfile
    }
    
    // Verify SSH keypathidentityfile
    public func verifysshkeypath(_ keypath: String) throws -> Bool {
        if keypath.first != "~" { throw SshError.noslash }
        let tempsshkeypath = keypath
        let sshkeypathandidentityfilesplit = tempsshkeypath.split(separator: "/")
        guard sshkeypathandidentityfilesplit.count == 3 else { throw SshError.noslash }
        guard sshkeypathandidentityfilesplit[1].count > 1 else { throw SshError.notvalidpath }
        guard sshkeypathandidentityfilesplit[2].count > 1 else { throw SshError.notvalidpath }
        return true
    }
    
    // Verify SSH port is a valid INT
    public func verifysshport(_ port: String) throws -> Bool {
        guard port.isEmpty == false else { return false }
        if Int(port) != nil {
            return true
        } else {
            throw SSHportnumberError.notvalidInt
        }
    }
    
    // For test only
    public func testcreatesshkeyrootpath() -> URL? {
            if let sshkeypath {
                let sshkeypathlURL = URL(fileURLWithPath: sshkeypath)
                return sshkeypathlURL
            }
            return nil
        }
}

extension FileManager {
    func keypathlocationExists(at path: String, kind: LocationKind) -> Bool {
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

/// Enum describing various kinds of locations that can be found on a file system.
public enum LocationKind {
    /// A file can be found at the location.
    case file
    /// A folder can be found at the location.
    case folder
}

public enum SshError: LocalizedError {
    case notvalidpath
    case sshkeys
    case noslash

    public var errorDescription: String? {
        switch self {
        case .notvalidpath:
            "SSH keypath is not valid"
        case .sshkeys:
            "SSH RSA keys exist, cannot create"
        case .noslash:
            "SSH keypath must be like ~/.ssh_keypath/identityfile"
        }
    }
}

public enum SSHportnumberError: LocalizedError {
    case notvalidDouble
    case notvalidInt

    public var errorDescription: String? {
        switch self {
        case .notvalidDouble:
            "Not a valid number (Double)"
        case .notvalidInt:
            "Not a valid number (Int)"
        }
    }
}

