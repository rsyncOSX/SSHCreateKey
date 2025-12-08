//
//  TestUserConfiguration.swift
//  RsyncArguments
//
//  Created by Thomas Evensen on 05/08/2024.
//

import Foundation

struct TestUserConfiguration: Codable {
    var rsyncversion3: Int = -1
    // Detailed logging
    var addsummarylogrecord: Int = 1
    // Logging to logfile
    var logtofile: Int = 1
    // Montor network connection
    var monitornetworkconnection: Int = -1
    // local path for rsync
    var localrsyncpath: String?
    // temporary path for restore
    var pathforrestore: String?
    // days for mark days since last synchronize
    var marknumberofdayssince: String = "5"
    // Global ssh keypath and port
    var sshkeypathandidentityfile: String?
    var sshport: Int?
    // Environment variable
    var environment: String?
    var environmentvalue: String?
    // Check for error in output from rsync
    var checkforerrorinrsyncoutput: Int = -1
    // Automatic execution
    var confirmexecute: Int?

    @MainActor private func setuserconfigdata() {
        setRsyncConfig()
        setLogConfig()
        setPathConfig()
        setSSHConfig()
        setEnvironmentConfig()
        setErrorConfig()
        setConfirmConfig()
    }

    @MainActor
    private func setRsyncConfig() {
        TestSharedReference.shared.rsyncversion3 = (rsyncversion3 == 1)
    }

    @MainActor
    private func setLogConfig() {
        TestSharedReference.shared.addsummarylogrecord = (addsummarylogrecord == 1)
        TestSharedReference.shared.logtofile = (logtofile == 1)
        TestSharedReference.shared.monitornetworkconnection = (monitornetworkconnection == 1)
    }

    @MainActor
    private func setPathConfig() {
        TestSharedReference.shared.localrsyncpath = localrsyncpath
        TestSharedReference.shared.pathforrestore = pathforrestore
        if Int(marknumberofdayssince) ?? 0 > 0 {
            TestSharedReference.shared.marknumberofdayssince = Int(marknumberofdayssince) ?? 0
        }
    }

    @MainActor
    private func setSSHConfig() {
        if sshkeypathandidentityfile != nil {
            TestSharedReference.shared.sshkeypathandidentityfile = sshkeypathandidentityfile
        }
        if sshport != nil {
            TestSharedReference.shared.sshport = sshport
        }
    }

    @MainActor
    private func setEnvironmentConfig() {
        if environment != nil {
            TestSharedReference.shared.environment = environment
        }
        if environmentvalue != nil {
            TestSharedReference.shared.environmentvalue = environmentvalue
        }
    }

    @MainActor
    private func setErrorConfig() {
        TestSharedReference.shared.checkforerrorinrsyncoutput = (checkforerrorinrsyncoutput == 1)
    }

    @MainActor
    private func setConfirmConfig() {
        TestSharedReference.shared.confirmexecute = (confirmexecute == 1)
    }

    // Used when reading JSON data from store
    @discardableResult
    @MainActor init(_ data: DecodeTestUserConfiguration) {
        rsyncversion3 = data.rsyncversion3 ?? -1
        addsummarylogrecord = data.addsummarylogrecord ?? 1
        logtofile = data.logtofile ?? 0
        monitornetworkconnection = data.monitornetworkconnection ?? -1
        localrsyncpath = data.localrsyncpath
        pathforrestore = data.pathforrestore
        marknumberofdayssince = data.marknumberofdayssince ?? "5"
        sshkeypathandidentityfile = data.sshkeypathandidentityfile
        sshport = data.sshport
        environment = data.environment
        environmentvalue = data.environmentvalue
        checkforerrorinrsyncoutput = data.checkforerrorinrsyncoutput ?? -1
        confirmexecute = data.confirmexecute ?? -1
        // Set user configdata read from permanent store
        setuserconfigdata()
    }

    // Default values user configuration
    @discardableResult
    @MainActor init() {
        rsyncversion3 = TestUserConfiguration.boolToInt(TestSharedReference.shared.rsyncversion3)
        addsummarylogrecord = TestUserConfiguration.boolToInt(TestSharedReference.shared.addsummarylogrecord)
        logtofile = TestUserConfiguration.boolToInt(TestSharedReference.shared.logtofile)
        monitornetworkconnection = TestUserConfiguration.boolToInt(TestSharedReference.shared.monitornetworkconnection)
        localrsyncpath = TestSharedReference.shared.localrsyncpath
        pathforrestore = TestSharedReference.shared.pathforrestore
        marknumberofdayssince = String(TestSharedReference.shared.marknumberofdayssince)
        sshkeypathandidentityfile = TestSharedReference.shared.sshkeypathandidentityfile
        sshport = TestSharedReference.shared.sshport
        environment = TestSharedReference.shared.environment
        environmentvalue = TestSharedReference.shared.environmentvalue
        checkforerrorinrsyncoutput = TestUserConfiguration.boolToInt(TestSharedReference.shared.checkforerrorinrsyncoutput)
        confirmexecute = TestUserConfiguration.boolToInt(TestSharedReference.shared.confirmexecute)
    }

    private static func boolToInt(_ value: Bool?) -> Int {
        return value == true ? 1 : -1
    }
}
