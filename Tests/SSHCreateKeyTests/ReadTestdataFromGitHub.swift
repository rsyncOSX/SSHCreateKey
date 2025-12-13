//
//  ReadTestdataFromGitHub.swift
//  RsyncArguments
//
//  Created by Thomas Evensen on 05/08/2024.
//
// swiftlint:disable line_length
import Foundation

final class ReadTestdataFromGitHub {
    var testconfigurations = [TestSynchronizeConfiguration]()
    private var urlJSONuiconfig: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncArguments/master/Testdata/rsyncuiconfig.json"
    private var urlJSONuiconfignossh: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncArguments/master/Testdata/rsyncuiconfignossh.json"
    private var urlJSON: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncArguments/master/Testdata/configurations.json"

    func getdata() async {
        let testdata = TestdataFromGitHub()
        // Load user configuration
        do {
            if let userconfig = try await
                testdata.loadanddecodestringdata(DecodeTestUserConfiguration.self, fromwhere: urlJSONuiconfig) {
                await TestUserConfiguration(userconfig)
                print("ReadTestdataFromGitHub: loading userconfiguration COMPLETED)")
            }

        } catch {
            print("ReadTestdataFromGitHub: loading userconfiguration FAILED)")
        }
        // Load data
        do {
            if let testdata = try await testdata.loadanddecodearraydata(DecodeTestdata.self, fromwhere: urlJSON) {
                testconfigurations.removeAll()
                for index in 0 ..< testdata.count {
                    var configuration = TestSynchronizeConfiguration(testdata[index])
                    configuration.profile = "test"
                    testconfigurations.append(configuration)
                }
                print("ReadTestdataFromGitHub: loading data COMPLETED)")
            }
        } catch {
            print("ReadTestdataFromGitHub: loading data FAILED)")
        }
    }

    func getdatanossh() async {
        let testdata = TestdataFromGitHub()
        // Load user configuration
        do {
            if let userconfig = try await
                testdata.loadanddecodestringdata(DecodeTestUserConfiguration.self, fromwhere: urlJSONuiconfignossh) {
                await TestUserConfiguration(userconfig)
                print("ReadTestdataFromGitHub: loading userconfiguration NOSSH COMPLETED)")
            }

        } catch {
            print("ReadTestdataFromGitHub: loading userconfiguration FAILED)")
        }
        // Load data
        do {
            if let testdata = try await testdata.loadanddecodearraydata(DecodeTestdata.self, fromwhere: urlJSON) {
                testconfigurations.removeAll()
                for index in 0 ..< testdata.count {
                    var configuration = TestSynchronizeConfiguration(testdata[index])
                    configuration.profile = "test"
                    testconfigurations.append(configuration)
                }
                print("ReadTestdataFromGitHub: loading data COMPLETED)")
            }
        } catch {
            print("ReadTestdataFromGitHub: loading data FAILED)")
        }
    }
}
// swiftlint:enable line_length
