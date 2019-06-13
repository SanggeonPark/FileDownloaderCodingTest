//
//  ViewModel.swift
//  FileDownloaderTest
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import Foundation

class DownloadViewModel {
    var identifier: String
    var downloadStatus: DownloadStatus = .NONE
    var progress: Float = 0
    var remoteFilePath: String

    init(with id: String, remotePath: String) {
        identifier = id
        remoteFilePath = remotePath
    }
}
