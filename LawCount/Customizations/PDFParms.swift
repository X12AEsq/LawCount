//
//  PDFParms.swift
//  LawCount
//
//  Created by Morris Albers on 9/29/24.
//
import Foundation
import SwiftUI

struct PDFParms {
    
    public static func pdfParameters() -> (pageWidth:CGFloat, pageHeight:CGFloat, margin:CGFloat, contentWidth:CGFloat, currentY: CGFloat) {
        
        let pw: CGFloat = 612
        let ph: CGFloat = 792
        let margin: CGFloat = 50
        let cw = pw - 2 * margin
        let cy: CGFloat = ph
        
        return(pw, ph, margin, cw, cy)
    }
}
