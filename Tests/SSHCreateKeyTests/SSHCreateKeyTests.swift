@testable import SSHCreateKey
import Testing

@Suite final class TestCreateSSHkeys {
    var testconfigurations: [TestSynchronizeConfiguration]?

    @Test func LodaDataCreateSSHKeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations
        if let testconfigurations {
            
            let sshcreatekey = await SSHCreateKey(sharedsshport: String(TestSharedReference.shared.sshport ?? -1),
                                                  sharedsshkeypathandidentityfile: TestSharedReference.shared.sshkeypathandidentityfile)

            let arg3 = await sshcreatekey.keypathonly
            print(arg3 ?? "")
            let arg4 = await sshcreatekey.identityfile
            print(arg4 ?? "")
            let arg5 = await sshcreatekey.userHomeDirectoryPath
            print(arg5 ?? "")
        }
    }
    
    @Test func LodaDataCreateSSHKeysdefault() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations
        if let testconfigurations {
            
            let port = -1
            let identityfile: String? = nil
            let sshcreatekey =  await SSHCreateKey(sharedsshport: String(port),
                                                  sharedsshkeypathandidentityfile: identityfile)

            let arg3 = await sshcreatekey.keypathonly
            print(arg3 ?? "")
            let arg4 = await sshcreatekey.identityfile
            print(arg4 ?? "")
            let arg5 = await sshcreatekey.userHomeDirectoryPath
            print(arg5 ?? "")
        }
    }


    @Test func createkeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations
        if let testconfigurations {

            do {
                let sshcreatekey = await SSHCreateKey(sharedsshport: String(TestSharedReference.shared.sshport ?? -1),
                                                      sharedsshkeypathandidentityfile: TestSharedReference.shared.sshkeypathandidentityfile)
                let present = try await sshcreatekey.islocalpublicrsakeypresent()
                if present == false {
                    // If new keypath is set create it
                    let sshrootpath = await sshcreatekey.testcreatesshkeyrootpath()
                    // Create keys
                    let arguments = await sshcreatekey.argumentscreatekey()
                    let command = "/usr/bin/ssh-keygen"
                    print(sshrootpath ?? "")
                    print(command)
                    print(arguments?.joined(separator: " ") ?? "")
                }
            } catch let e {
                let error = e
                print(error)
            }
        }
    }
    
    
    @Test func createkeysdefault() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations
        if let testconfigurations {
            
            do {
                
                let port = -1
                let identityfile: String? = nil
                
                let sshcreatekey =  await SSHCreateKey(sharedsshport: String(port),
                                                      sharedsshkeypathandidentityfile: identityfile)
                let present = try  await sshcreatekey.islocalpublicrsakeypresent()
                if present == false {
                    // If new keypath is set create it
                    let sshrootpath =  await sshcreatekey.testcreatesshkeyrootpath()
                    // Create keys
                    let arguments =  await sshcreatekey.argumentscreatekey()
                    let command = "/usr/bin/ssh-keygen"
                    print(sshrootpath ?? "")
                    print(command)
                    print(arguments?.joined(separator: " ") ?? "")
                }
            } catch let e {
                let error = e
                print(error)
            }
        }
    }
}


