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

    /*
     /Users/thomas/.ssh
     id_rsa
     /Users/thomas
     /Users/thomas/.ssh/id_rsa
     /usr/bin/ssh-copy-id -i /Users/thomas/.ssh/id_rsa thomas@raspberrypi
     */

    /*
     let arg3 = await sshcreatekey.keypathonly
     print(arg3 ?? "")
     let arg4 = await sshcreatekey.identityfile
     print(arg4 ?? "")
     let arg5 = await sshcreatekey.userHomeDirectoryPath
     print(arg5 ?? "")
     let arg6 = await sshcreatekey.sshkeypathandidentityfile
     print(arg6 ?? "")
     let arg7 = await sshcreatekey.argumentssshcopyid(offsiteServer: "raspberrypi", offsiteUsername: "thomas")
     pri
     */
}
