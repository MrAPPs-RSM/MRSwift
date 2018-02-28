//
//  MRPdfViewController.swift
//  Alamofire
//
//  Created by Nicola Innocenti on 28/02/18.
//

import UIKit
import PDFReader

open class MRPDFViewController: MRMediaViewController {

    // MARK: - Constants & Variables
    
    var pdfViewController: PDFViewController?
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        if let localUrl = media.localUrl, localUrl.fileExists {
            self.showPDF(with: localUrl)
        } else if let remoteUrl = media.remoteUrl {
            self.showPDF(with: remoteUrl)
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pdfViewController?.frame = view.frame
    }
    
    // MARK: - Other Methods
    
    private func showPDF(with url: URL) {
        
        let document = PDFDocument(url: documentRemoteURL)!
        guard let viewController = PDFViewController.createNew(with: document) else { return }
        
        pdfViewController = viewController
        view.addSubview(viewController.view)
        addChildViewController(viewController)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
