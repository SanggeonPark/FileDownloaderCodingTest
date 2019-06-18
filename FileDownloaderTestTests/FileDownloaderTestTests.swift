//
//  FileDownloaderTestTests.swift
//  FileDownloaderTestTests
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import XCTest
import FileDownloaderTest

class FileDownloaderTestTests: XCTestCase {
    let identifier = "E77F55F7-B304-41EF-83FF-958A2F9986E2"

    #warning("YOU CAN ALSO CHANGE URL ;)")
    let remoteFilePath = "http://bit.ly/2WHqcG2"

    func test0SimpleDownload() {
        let downloader = Downloader()
        let resumeExpectation = self.expectation(description: "resumeExpectation")

        downloader.resumeDownload(for: identifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.identifier == self.identifier)
            XCTAssert(model?.remoteFilePath == self.remoteFilePath)
            XCTAssert(model?.status == DownloadStatus.DOWNLOADING)
            resumeExpectation.fulfill()
        }
        self.wait(for: [resumeExpectation], timeout: 1)

        let downloadedExpectation = self.expectation(description: "downloadedExpectation")
        let checkTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            downloader.allDownloads({ (downloads) in
                if let download = downloads?.filter({ (data) -> Bool in
                    data.identifier == self.identifier &&
                        data.status == .DOWNLOADED &&
                        data.progress == 100 &&
                        data.remoteFilePath == self.remoteFilePath
                }).first {
                    XCTAssertNotNil(download.localFilePath, "Downloaded file path is nil")
                    XCTAssert(FileManager.default.isReadableFile(atPath: download.localFilePath!))
                    downloadedExpectation.fulfill()
                } else if downloads?.isEmpty == true {
                    XCTAssert(false, "No downloads found")
                    downloadedExpectation.fulfill()
                }
            })
        })

        self.wait(for: [downloadedExpectation], timeout: 30)
        checkTimer.invalidate()
        // NOW, WE HAVE 1 DOWNLOADED ITEM
    }

    func test1RemoveDownload() {
        let downloader = Downloader()
        let removeExpectation = self.expectation(description: "removeExpectation")
        downloader.allDownloads({ (downloads) in
            if let download = downloads?.filter({ (data) -> Bool in
                data.identifier == self.identifier &&
                    data.status == .DOWNLOADED &&
                    data.progress == 100 &&
                    data.remoteFilePath == self.remoteFilePath
            }).first {
                XCTAssertNotNil(download.localFilePath)
                XCTAssert(FileManager.default.isReadableFile(atPath: download.localFilePath!))
                let localFilePath = download.localFilePath ?? ""
                downloader.removeDownload(for: download.identifier, { (error) in
                    XCTAssertNil(error)
                    XCTAssertFalse(FileManager.default.isReadableFile(atPath: localFilePath))
                    removeExpectation.fulfill()
                })
            } else {
                XCTAssert(false, "No downloads found")
                removeExpectation.fulfill()
            }
        })
        self.wait(for: [removeExpectation], timeout: 1)
        // WE REMOVED ALL ITEMS.
    }

    func test2PauseDownload() {
        let downloader = Downloader()
        let resumeExpectation = self.expectation(description: "resumeExpectation")

        downloader.resumeDownload(for: identifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.identifier == self.identifier)
            XCTAssert(model?.remoteFilePath == self.remoteFilePath)
            XCTAssert(model?.status == .DOWNLOADING)
            resumeExpectation.fulfill()
        }
        self.wait(for: [resumeExpectation], timeout: 1)

        let pauseExpectation = self.expectation(description: "pauseExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            downloader.pauseDownload(for: self.identifier, { (model, error) in
                XCTAssertNil(error)
                XCTAssertNotNil(model)
                XCTAssert(model?.status == .PAUSED)
                pauseExpectation.fulfill()
            })
        }

        self.wait(for: [pauseExpectation], timeout: 5)
        // NOW, WE HAVE 1 PAUSED ITEM
    }

    func test3DuplicatedDownloads() {
        let downloader = Downloader()
        let resumeExpectation = self.expectation(description: "resumeExpectation")
        downloader.resumeDownload(for: identifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.status == .DOWNLOADING)
            resumeExpectation.fulfill()
        }
        self.wait(for: [resumeExpectation], timeout: 1)

        let pauseExpectation = self.expectation(description: "pauseExpectation")
        downloader.pauseDownload(for: identifier, { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.status == .PAUSED)
            pauseExpectation.fulfill()
        })

        self.wait(for: [pauseExpectation], timeout: 1)
        // Check All Downloads
        let checkExpectation = self.expectation(description: "checkExpectation")
        downloader.allDownloads({ (downloads) in
            XCTAssertNotNil(downloads)
            XCTAssert(downloads?.count == 1)
            if downloads?.filter({ (data) -> Bool in
                data.identifier == self.identifier &&
                    data.status == .PAUSED
            }).first != nil {
                checkExpectation.fulfill()
            } else {
                XCTAssert(false, "No downloads found")
                checkExpectation.fulfill()
            }
        })
        self.wait(for: [checkExpectation], timeout: 1)
        // WE STILL HAVE 1 PAUSED ITEM
    }

    func test4PauseInvalidDownload() {
        let downloader = Downloader()
        let pauseExpectation = self.expectation(description: "pauseExpectation")
        downloader.pauseDownload(for: "THIS_IS_WORNG_IDENTIFIER", { (model, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(model)
            pauseExpectation.fulfill()
        })
        self.wait(for: [pauseExpectation], timeout: 1)

        // Check All Downloads
        let checkExpectation = self.expectation(description: "checkExpectation")
        downloader.allDownloads({ (downloads) in
            XCTAssertNotNil(downloads)
            XCTAssert(downloads?.count == 1)
            if downloads?.filter({ (data) -> Bool in
                data.identifier == self.identifier &&
                    data.status == .PAUSED
            }).first != nil {
                checkExpectation.fulfill()
            } else {
                XCTAssert(false, "No downloads found")
                checkExpectation.fulfill()
            }
        })
        self.wait(for: [checkExpectation], timeout: 1)
        // WE STILL HAVE 1 PAUSED ITEM
    }

    func test5RemoveInvalidDownload() {
        let downloader = Downloader()
        let removeExpecation = self.expectation(description: "removeExpecation")
        downloader.removeDownload(for: "THIS_IS_WORNG_IDENTIFIER", { (error) in
            XCTAssertNotNil(error)
            removeExpecation.fulfill()
        })
        self.wait(for: [removeExpecation], timeout: 1)
        // Check All Downloads
        let checkExpectation = self.expectation(description: "checkExpectation")
        downloader.allDownloads({ (downloads) in
            XCTAssertNotNil(downloads)
            XCTAssert(downloads?.count == 1)
            if downloads?.filter({ (data) -> Bool in
                data.identifier == self.identifier &&
                    data.status == .PAUSED
            }).first != nil {
                checkExpectation.fulfill()
            } else {
                XCTAssert(false, "No downloads found")
                checkExpectation.fulfill()
            }
        })
        self.wait(for: [checkExpectation], timeout: 1)
        // WE STILL HAVE 1 PAUSED ITEM
    }

    func test6DownloadFiles() {
        let downloader = Downloader()
        let otherIdentifier = "38C002AC-A3C5-49DB-BC16-8BE61C439F36"
        downloader.resumeDownload(for: identifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.identifier == self.identifier)
            XCTAssert(model?.remoteFilePath == self.remoteFilePath)
            XCTAssert(model?.status == DownloadStatus.DOWNLOADING)
        }
        downloader.resumeDownload(for: otherIdentifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssert(model?.identifier == otherIdentifier)
            XCTAssert(model?.remoteFilePath == self.remoteFilePath)
            XCTAssert(model?.status == DownloadStatus.DOWNLOADING)
        }

        let downloadedExpectation = self.expectation(description: "donwloadWithIdentifierDownloadedExpectation")
        let checkTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            downloader.allDownloads({ (downloads) in
                XCTAssert(downloads?.count == 2)
                if downloads?.filter({ (data) -> Bool in
                        data.status == .DOWNLOADED &&
                        data.progress == 100 &&
                        data.remoteFilePath == self.remoteFilePath
                }).count == 2 {
                    downloadedExpectation.fulfill()
                } else if downloads?.isEmpty == true {
                    XCTAssert(false, "No downloads found")
                    downloadedExpectation.fulfill()
                }
            })
        })

        self.wait(for: [downloadedExpectation], timeout: 30)
        checkTimer.invalidate()

        // NOW, WE HAVE 2 DOWNLOADED ITEMS
    }

    func test7RemoveAllDownloads() {
        let downloader = Downloader()
        let otherIdentifier = "48C002AC-A3C5-49DB-BC16-8BE61C439F36"
        let resumeExpectation = self.expectation(description: "resumeExpectation")
        downloader.resumeDownload(for: otherIdentifier, remotePath: remoteFilePath) { (model, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(model)
            resumeExpectation.fulfill()
        }

        self.wait(for: [resumeExpectation], timeout: 2)

        // NOW, WE HAVE 1 DOWNLOADING ITEM AND 2 DOWNLOADED ITEMS

        let removeExpecation = self.expectation(description: "removeExpecation")
        downloader.allDownloads({ (downloads) in
            XCTAssertNotNil(downloads)
            let downloadsCount = downloads?.count
            var counter: Int = 0
            if let array = downloads, array.isEmpty == false {
                for download in array {
                    downloader.removeDownload(for: download.identifier, { (error) in
                        XCTAssertNil(error)
                        counter += 1
                        if counter == downloadsCount {
                            removeExpecation.fulfill()
                        }
                    })
                }
            } else {
                XCTAssert(false, "No downloads found")
                removeExpecation.fulfill()
            }
        })

        self.wait(for: [removeExpecation], timeout: 3)

        let statusCheckExpectation = self.expectation(description: "statusCheckExpectation")
        downloader.allDownloads({ (downloads) in
            XCTAssert((downloads == nil || downloads!.isEmpty))
            statusCheckExpectation.fulfill()
        })

        self.wait(for: [statusCheckExpectation], timeout: 3)
    }
}
