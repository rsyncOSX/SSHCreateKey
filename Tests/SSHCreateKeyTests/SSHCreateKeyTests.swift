@testable import SSHCreateKey
import Testing
import Foundation

@Suite final class TestCreateSSHkeys {
    var testconfigurations: [TestSynchronizeConfiguration]?

    @Test func LodaDataCreateSSHKeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations

        let sshcreatekey = await SSHCreateKey(sharedsshport: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedsshkeypathandidentityfile: TestSharedReference.shared.sshkeypathandidentityfile)
        let arg3 = await sshcreatekey.keypathonly
        #expect(ArgumentsCreatSSHKeys().keypathglobal == arg3)
        let arg4 = await sshcreatekey.identityfile
        #expect(ArgumentsCreatSSHKeys().identityfileglobl == arg4)
        let arg5 = await sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathglobal == arg5)
        let arg6 = await sshcreatekey.sshkeypathandidentityfile
        #expect(ArgumentsCreatSSHKeys().sshkeypathandidentityfileglobal == arg6)
        let arg7 = await sshcreatekey.argumentssshcopyid(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
        #expect(ArgumentsCreatSSHKeys().argumentssshcopyidglobal == arg7)
    }

    @Test func LodaDataCreateSSHKeysdefault() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations

        // Sett Shareddata to nil or default values
        let port = -1
        let identityfile: String? = nil
        let sshcreatekey = await SSHCreateKey(sharedsshport: String(port),
                                              sharedsshkeypathandidentityfile: identityfile)
        let arg3 = await sshcreatekey.keypathonly
        #expect(ArgumentsCreatSSHKeys().keypathdefault == arg3)
        let arg4 = await sshcreatekey.identityfile
        #expect(ArgumentsCreatSSHKeys().identityfiledefault == arg4)
        let arg5 = await sshcreatekey.userHomeDirectoryPath
        #expect(ArgumentsCreatSSHKeys().userHomeDirectoryPathdefault == arg5)
        let arg6 = await sshcreatekey.sshkeypathandidentityfile
        #expect(ArgumentsCreatSSHKeys().sshkeypathandidentityfiledefault == arg6)
        let arg7 = await sshcreatekey.argumentssshcopyid(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
        #expect(ArgumentsCreatSSHKeys().argumentssshcopyiddefault == arg7)
    }

    @Test func createkeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
    
        let sshcreatekey = await SSHCreateKey(sharedsshport: String(TestSharedReference.shared.sshport ?? -1),
                                              sharedsshkeypathandidentityfile: TestSharedReference.shared.sshkeypathandidentityfile)
        // If new keypath is set create it
        let sshrootpath = await sshcreatekey.testcreatesshkeyrootpath()
        #expect(ArgumentsCreatSSHKeys().URLfileglobal == sshrootpath)
        // Create keys
        let arguments = await sshcreatekey.argumentscreatekey()
        #expect(ArgumentsCreatSSHKeys().sshcreateglobal == arguments)
    }

    @Test func createkeysdefault() async {
    
        let port = -1
        let identityfile: String? = nil

        let sshcreatekey = await SSHCreateKey(sharedsshport: String(port),
                                              sharedsshkeypathandidentityfile: identityfile)

        let sshrootpath = await sshcreatekey.testcreatesshkeyrootpath()
        #expect(ArgumentsCreatSSHKeys().URLfilelocal == sshrootpath)
        let arguments = await sshcreatekey.argumentscreatekey()
        #expect(ArgumentsCreatSSHKeys().sshcreatelocal == arguments)
    }
}
