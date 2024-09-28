//
//  PDFShareView.swift
//  LawCount
//
//  Created by Morris Albers on 9/28/24.
//

import SwiftUI
import UIKit

struct PDFShareView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFShareView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<PDFShareView>) {
        // empty
    }
}
