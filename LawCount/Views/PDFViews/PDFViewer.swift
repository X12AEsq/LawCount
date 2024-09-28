//
//  PDFViewer.swift
//  LawCount
//
//  Created by Morris Albers on 9/28/24.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var presentedAsModal: Bool
    var pdfData:Data
    var body: some View {
        VStack {
            PDFKitRepresentedView(pdfData)
            Spacer()
            HStack {
                Spacer()
                PDFShareView(activityItems: [pdfData])
                Spacer()
            }
            Spacer()
        }
    }
}
