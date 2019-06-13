//
//  ViewController.swift
//  FileDownloaderTest
//
//  Created by Sanggeon Park on 13.06.19.
//  Copyright © 2019 Sanggeon Park. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let viewModels = [DownloadViewModel(with: "Video 1", remotePath: "http://bit.ly/2WHqcG2"),
                      DownloadViewModel(with: "Video 2", remotePath: "http://bit.ly/2WHqcG2")]

    var downloader = Downloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        downloader.delegate = self
    }
}

extension ViewController: DownloaderDelegate {
    func didUpdateDownloadStatus(for identifier: String, progress: Float, status: DownloadStatus, error: Error?) {
        // TODO: Please implement
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewModels[indexPath.row].identifier
        let status = viewModels[indexPath.row].downloadStatus
        switch status {
        case .DOWNLOADING:
            #warning("UPDATE DOWNLOADING PROGRESS")
            cell.detailTextLabel?.text = "\(viewModels[indexPath.row].progress)%"
        default:
            cell.detailTextLabel?.text = viewModels[indexPath.row].downloadStatus.rawValue
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let status = viewModels[indexPath.row].downloadStatus
        switch status {
        case .NONE,
             .PAUSED:
            #warning("RESUME DOWNLOAD")
            break
        case .DOWNLOADING:
            #warning("PAUSE DOWNLOAD")
            break
        case .DOWNLOADED:
            #warning("PLAY DOWNLOADED VIDEO")
            break
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            #warning("REMOVE ONLY DOWNLOAD & REFRESH ROW")
        }
    }
}

