//
//  DownloadStatusUpdateModel.swift
//  FileDownloaderTest
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import Foundation

struct DownloadStatusUpdateModel {
    public let identifier: String
    public let status: DownloadStatus
    public let progress: Float
    public let error: Error?
}
