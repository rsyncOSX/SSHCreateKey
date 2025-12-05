import Foundation
@testable import SSHCreateKey
import Testing

@Suite final class TestCreateSSHkeys {
    var testconfigurations: [TestSynchronizeConfiguration]?

    @Test func LodaDataCreateSSHKeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations

        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        let arg3 = sshcreatekey.sshKeyPath
        #expect(ArgumentsCreatSSHKeys().keypathglobal == arg3)
        let arg4 = sshcreatekey.identityFileOnly
        #expect(ArgumentsCreatSSHKeys().identityfileglobl == arg4)
        let arg5 = sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathglobal == arg5)
        let arg6 = sshcreatekey.sshKeyPathAndIdentityFile
        #expect(ArgumentsCreatSSHKeys().sshkeypathandidentityfileglobal == arg6)
        do {
            let arg7 = try sshcreatekey.argumentsSSHCopyID(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
            #expect(ArgumentsCreatSSHKeys().argumentssshcopyidglobal == arg7)
        } catch {}
    }

    @Test func LodaDataCreateSSHKeysdefault() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations

        // Sett Shareddata to nil or default values
        let port = -1
        let identityfile: String? = nil
        let sshcreatekey = SSHCreateKey(sharedSSHPort: String(port),
                                        sharedSSHKeyPathAndIdentityFile: identityfile)
        let arg3 = sshcreatekey.sshKeyPath
        #expect(ArgumentsCreatSSHKeys().keypathdefault == arg3)
        let arg4 = sshcreatekey.identityFileOnly
        #expect(ArgumentsCreatSSHKeys().identityfiledefault == arg4)
        let arg5 = sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathdefault == arg5)
        let arg6 = sshcreatekey.sshKeyPathAndIdentityFile
        #expect(ArgumentsCreatSSHKeys().sshkeypathandidentityfiledefault == arg6)
        do {
            let arg7 = try sshcreatekey.argumentsSSHCopyID(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
            #expect(ArgumentsCreatSSHKeys().argumentssshcopyiddefault == arg7)
        } catch {}
    }

    @Test func createkeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        // Create keys
        do {
            let arguments = try sshcreatekey.argumentsCreateKey()
            #expect(ArgumentsCreatSSHKeys().sshcreateglobal == arguments)
        } catch {}
    }

    @Test func validatekeyfilespresent() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()

        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        print(sshcreatekey.validatePublicKeyPresent())
    }
}

@Suite final class TestCreateSSHkeysNOSSH {
    var testconfigurations: [TestSynchronizeConfiguration]?

    @Test func LodaDataCreateSSHKeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdatanossh()

        testconfigurations = loadtestdata.testconfigurations

        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        let arg3 = sshcreatekey.sshKeyPath
        #expect(ArgumentsCreatSSHKeys().defaultkeypath == arg3)
        let arg4 = sshcreatekey.identityFileOnly
        #expect(ArgumentsCreatSSHKeys().defaultidentityfileglobl == arg4)
        let arg5 = sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathglobal == arg5)
        let arg6 = sshcreatekey.sshKeyPathAndIdentityFile
        #expect(ArgumentsCreatSSHKeys().defaultsshkeypathandidentityfile == arg6)
        do {
            let arg7 = try sshcreatekey.argumentsSSHCopyID(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
            #expect(ArgumentsCreatSSHKeys().argumentssshcopyiddefault == arg7)
        } catch {}
    }

    @Test func LodaDataCreateSSHKeysdefault() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdatanossh()

        testconfigurations = loadtestdata.testconfigurations

        // Sett Shareddata to nil or default values
        let port = -1
        let identityfile: String? = nil
        let sshcreatekey = SSHCreateKey(sharedSSHPort: String(port),
                                        sharedSSHKeyPathAndIdentityFile: identityfile)
        let arg3 = sshcreatekey.sshKeyPath
        #expect(ArgumentsCreatSSHKeys().keypathdefault == arg3)
        let arg4 = sshcreatekey.identityFileOnly
        #expect(ArgumentsCreatSSHKeys().identityfiledefault == arg4)
        let arg5 = sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathdefault == arg5)
        let arg6 = sshcreatekey.sshKeyPathAndIdentityFile
        #expect(ArgumentsCreatSSHKeys().sshkeypathandidentityfiledefault == arg6)
        do {
            let arg7 = try sshcreatekey.argumentsSSHCopyID(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
            #expect(ArgumentsCreatSSHKeys().argumentssshcopyiddefault == arg7)
        } catch {}
    }

    @Test func createkeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdatanossh()

        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        // Create keys
        do {
            let arguments = try sshcreatekey.argumentsCreateKey()
            #expect(ArgumentsCreatSSHKeys().defaultsshcreate == arguments)
        } catch {}
    }

    @Test func validatekeyfilespresent() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdatanossh()

        let sshcreatekey = await SSHCreateKey(sharedSSHPort: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedSSHKeyPathAndIdentityFile: TestSharedReference.shared.sshkeypathandidentityfile)
        print(sshcreatekey.validatePublicKeyPresent())
    }
}
