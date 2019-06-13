//
//  Downloader.swift
//  FileDownloaderTest
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import Foundation

public protocol DownloaderDelegate: class {
    func didUpdateDownloadStatus(for identifier: String, progress: Float, status: DownloadStatus, error: Error?)
}

extension DownloaderDelegate {
    func didUpdateDownloadStatus(for identifier: String, progress: Float, status: DownloadStatus, error: Error?) {
        // Optional Function
    }
}

#warning("DO NOT USER ANY STATIC VARIABLES AND FUNCTIONS")
open class Downloader {
    weak var delegate: DownloaderDelegate?

    public init(with delegate: DownloaderDelegate? = nil) {
        
    }

    public func allDownloads(_ completion: @escaping ([DownloadModel]?) -> Void) {
        DispatchQueue.main.async {
            completion(nil)
        }
    }

    public func resumeDownload(for identifier: String, remotePath: String,
                        _ completion: @escaping (_ data: DownloadModel?, _ error: Error?) -> Void) {
        DispatchQueue.main.async {
            completion(nil, NSError(domain: "DOWNLOADER", code: -1, userInfo: nil))
        }
    }

    public func pauseDownload(for identifier: String, _ completion: @escaping (_ data: DownloadModel?, _ error: Error?) -> Void) {
        DispatchQueue.main.async {
            completion(nil, NSError(domain: "DOWNLOADER", code: -1, userInfo: nil))
        }
    }

    public func removeDownload(for identifier: String, _ completion: @escaping (_ error: Error?) -> Void) {
        DispatchQueue.main.async {
            completion(NSError(domain: "DOWNLOADER", code: -1, userInfo: nil))
        }
    }

    public func downloadData(for identifier: String, _ completion: @escaping (_ data: DownloadModel?) -> Void) {
        DispatchQueue.main.async {
            completion(nil)
        }
    }
}
