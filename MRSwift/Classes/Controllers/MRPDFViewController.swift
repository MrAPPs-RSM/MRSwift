//
//  MRPdfViewController.swift
//  Alamofire
//
//  Created by Nicola Innocenti on 28/02/18.
//

import UIKit

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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapPDF(notification:)), name: NSNotification.Name(rawValue: "didTapPDF"), object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didTapPDF"), object: nil)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pdfViewController?.view.frame = view.frame
    }
    
    // MARK: - Other Methods
    
    private func showPDF(with url: URL) {
        
        let document = PDFDocument(url: url)!
        let viewController = PDFViewController.createNew(with: document)
        pdfViewController = viewController
        view.addSubview(viewController.view)
        addChildViewController(viewController)
    }
    
    @objc func didTapPDF(notification: Notification) {
        delegate?.mediaDidTapView()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
