//
//  DownloadModel.swift
//  FileDownloaderTest
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import Foundation

public enum DownloadStatus: String, Codable {
    case NONE
    case WAITING
    case DOWNLOADING
    case PAUSED
    case DOWNLOADED
}

public struct DownloadModel: Codable {
    public let identifier: String
    public let status: DownloadStatus
    public let progress: Float // from 0.0% to 100.0%
    public let remoteFilePath: String
    public let localFilePath: String?
}
