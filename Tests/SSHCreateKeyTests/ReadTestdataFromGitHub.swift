//
//  ReadTestdataFromGitHub.swift
//  RsyncArguments
//
//  Created by Thomas Evensen on 05/08/2024.
//

import Foundation

final class ReadTestdataFromGitHub {
    var testconfigurations = [TestSynchronizeConfiguration]()

    func getdata() async {
        let testdata = TestdataFromGitHub()
        // Load user configuration
        do {
            if let userconfig = try await testdata.getrsyncuiconfigbyURL() {
                await TestUserConfiguration(userconfig)
                print("ReadTestdataFromGitHub: loading userconfiguration COMPLETED)")
            }

        } catch {
            print("ReadTestdataFromGitHub: loading userconfiguration FAILED)")
        }
        // Load data
        do {
            if let testdata = try await testdata.gettestdatabyURL() {
                testconfigurations.removeAll()
                for i in 0 ..< testdata.count {
                    var configuration = TestSynchronizeConfiguration(testdata[i])
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
