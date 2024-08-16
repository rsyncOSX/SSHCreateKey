//
//  ArgumentsCreatSSHKeys.swift
//  SSHCreateKey
//
//  Created by Thomas Evensen on 15/08/2024.
//

import Foundation

struct ArgumentsCreatSSHKeys {
    let keypathglobal = "/Users/thomas/.ssh_global"
    let identityfileglobl = "global"
    let userHomeDirectoryPathglobal = "/Users/thomas"
    let sshkeypathandidentityfileglobal = "/Users/thomas/.ssh_global/global"
    let argumentssshcopyidglobal = "/usr/bin/ssh-copy-id -i ~/.ssh_global/global -p 2222 thomas@raspberrypi"

    let keypathdefault = "/Users/thomas/.ssh"
    let identityfiledefault = "id_rsa"
    let userHomeDirectoryPathdefault = "/Users/thomas"
    let sshkeypathandidentityfiledefault = "/Users/thomas/.ssh/id_rsa"
    let argumentssshcopyiddefault = "/usr/bin/ssh-copy-id -i /Users/thomas/.ssh/id_rsa thomas@raspberrypi"
    
    
    let URLfilelocal: URL? = URL(fileURLWithPath: "/Users/thomas/.ssh/")
    let sshcreatelocal = ["-t", "rsa", "-N", "", "-f", "/Users/thomas/.ssh/id_rsa"]
    
    
    let URLfileglobal = URL(fileURLWithPath:"/Users/thomas/.ssh_global")
    let sshcreateglobal = ["-t", "rsa", "-N", "", "-f", "/Users/thomas/.ssh_global/global"]

}
