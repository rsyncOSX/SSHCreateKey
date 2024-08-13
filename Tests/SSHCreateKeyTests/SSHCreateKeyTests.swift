import Testing
@testable import SSHCreateKey

@Suite final class TestCreateSSHkeys {
    var testconfigurations: [TestSynchronizeConfiguration]?

    @Test func LodaDataCreateSSHKeys() async {
        let loadtestdata = ReadTestdataFromGitHub()
        await loadtestdata.getdata()
        testconfigurations = loadtestdata.testconfigurations
        if let testconfigurations {
            // Test for one configuration only, config nr 0
            guard testconfigurations.count > 0 else { return }
            let config = testconfigurations[0]
            let createsshkeys = await SSHCreateKey(sharedsshport: String(TestSharedReference.shared.sshport ?? -1),
                sharedsshkeypathandidentityfile: TestSharedReference.shared.sshkeypathandidentityfile
            )

            let arg3 = await createsshkeys.keypathonly
            print(arg3 ?? "")
            let arg4 = await createsshkeys.identityfile
            print(arg4 ?? "")
            let arg5 = await createsshkeys.userHomeDirectoryPath
            print(arg5 ?? "")
        }
    }
}
