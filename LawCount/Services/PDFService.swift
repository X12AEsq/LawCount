//
//  PDFService.swift
//  LawCount
//
//  Created by Morris Albers on 9/28/24.
//
import Foundation
import UIKit
import SwiftUI

struct PDFService {
    public static func addImage(pageRect: CGRect, image:UIImage) {
        let aspectWidth = (pageRect.width - 100) / image.size.width
        let aspectHeight = (pageRect.height - 100) / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        
        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageY = (pageRect.height - scaledHeight) / 2.0
        let imageRect = CGRect(x: imageX, y: imageY, width: scaledWidth, height: scaledHeight)
        
        image.draw(in: imageRect)
    }
        
    public static func drawPageHeader(at origin: CGPoint, pageWidth: CGFloat, header: String, header2: String) -> CGFloat {
        let headerRowHeight:CGFloat = 25
//        let header = selectedPractice().name ?? "Unidentified Practice"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ]
        
        let headerRect = CGRect(x: origin.x, y: origin.y, width: pageWidth, height: headerRowHeight)
        let attributedString = NSAttributedString(string: header, attributes: attributes)
        attributedString.draw(in: headerRect)

//        let header = selectedPractice().name ?? "Unidentified Practice"
//        let header2 = "Docket for " + docketString
        let header2Rect = CGRect(x: origin.x, y: origin.y + headerRowHeight, width: pageWidth, height: headerRowHeight)
        let attributedString2 = NSAttributedString(string: header2, attributes: attributes)
        attributedString2.draw(in: header2Rect)
        
        return origin.y + 60
    }

    public static func savePDF(data: Data, fileName: String) -> (successful: Bool, location: URL?) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return (false, nil)
        }
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).pdf")
        
        do {
            try data.write(to: fileURL)
//            docketReady = true
            return (true, fileURL)
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
//            docketReady = false
            return (false, nil)
        }
    }
    
    public static func checkNewPage(pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, pageCount: Int, currentY: CGFloat, context: UIGraphicsPDFRendererContext, header:String, header2:String) -> (pageCount:Int, currentY: CGFloat) {
        var workPageCount = pageCount
        var workCurrentY = currentY
        let nextY = currentY + 100
        if nextY > pageHeight {
            workPageCount += 1
            context.beginPage()
            
            if let watermark = UIImage(named: "AlbersMorrisLOGO copy") {
                PDFService.addImage(pageRect: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), image: watermark)
            }
            
            // Draw table headers
            workCurrentY = PDFService.drawPageHeader(at: CGPoint(x: margin, y: margin), pageWidth: pageWidth, header: header, header2: header2)
        }
        return(workPageCount, workCurrentY)
    }


}

