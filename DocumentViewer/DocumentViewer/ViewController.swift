//
//  ViewController.swift
//  DocumentViewer
//
//  Created by Pawan Kumar on 29/08/19.
//  Copyright © 2019 com.pawanShivHari. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    var documentInteractionController = UIDocumentInteractionController()
    
    // MARK: - View lifecycle
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.documentInteractionController.delegate = self
    }
    
    // MARK: - IB Action
    // MARK: -
    
    @IBAction func openPDFView(_ sender: Any) {
        self.viewPdf(urlPath: "http://www.africau.edu/images/default/sample.pdf", screenTitle: "Tesing Document")
    }
    
    // MARK: - Helper methods
    // MARK: -
    
    func viewPdf(urlPath: String, screenTitle: String) {
        // open pdf for booking id
        guard let url = urlPath.toUrl else {
            print("Please pass valid url")
            return
        }
        
        self.downloadPdf(fileURL: url, screenTitle: screenTitle) { localPdf in
            if let url = localPdf {
                DispatchQueue.main.sync {
                    self.openDocument(atURL: url, screenTitle: screenTitle)
                }
            }
        }
    }
    
    // method  for download pdf file
    func downloadPdf(fileURL: URL, screenTitle: String, complition: @escaping ((URL?) -> Void)) {
        // Create destination URL
        if let documentsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationFileUrl = documentsUrl.appendingPathComponent("\(screenTitle).pdf")
            
            if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                try? FileManager.default.removeItem(at: destinationFileUrl)
            }
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url: fileURL)
            
            let task = session.downloadTask(with: request) { tempLocalUrl, response, error in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                    }
                    
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        complition(destinationFileUrl)
                    } catch let writeError {
                        print("Error creating a file \(destinationFileUrl) : \(writeError)")
                    }
                    
                } else {
                    print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "N/A")")
                }
            }
            task.resume()
        } else {
            complition(nil)
        }
    }
    
    func openDocument(atURL url: URL, screenTitle: String) {
        self.documentInteractionController.url = url
        self.documentInteractionController.name = screenTitle
        self.documentInteractionController.delegate = self
        self.documentInteractionController.presentPreview(animated: true)
    }
    
    // when a document interaction controller needs a view controller for presenting a document preview.
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController ?? UIViewController()
    }
}



// MARK: - String extension
// MARK: -

extension String {
    /// EZSE: Converts String to URL
    var toUrl: URL? {
        if self.hasPrefix("file://") || self.hasPrefix("https://") || self.hasPrefix("http://") {
            return URL(string: self)
        } else {
            return URL(fileURLWithPath: self)
        }
    }
}
