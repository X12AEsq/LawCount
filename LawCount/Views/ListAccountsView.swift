//
//  ListAccountsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import SwiftUI

struct ListAccountsView: View {
    @EnvironmentObject var cvmInstance:CVM
    
    @State var accountList:String = ""
    @State var creditTotal:String = ""
    @State var debitTotal:String = ""
    @State var reportAlpha:Bool = true
    @State var report:String = ""
    @State var rcdNr:Int = 0
    @State var lineNr:Int = 0
    @State var pdfAcctList:Data = Data()
    @State var acctListURL:URL?
    @State var acctListLocation:String = ""
    @State var acctListString:String = ""
    @State var acctListCompare:String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment:.top) {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text(cvmInstance.moduleTitle(mod: "List Accounts"))
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                    if acctListLocation != "" {
                        HStack {
                            Text("Account List Location: ")
                            Text(acctListLocation)
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                    }
//                    Button("Save to disk") {
//                        let data = Data(accountList.utf8)
//                        let url = URL.documentsDirectory.appending(path: "AccountList.txt")
//                        
//                        do {
//                            try data.write(to: url, options: [.atomic, .completeFileProtection])
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
                    ScrollView {
                        VStack (alignment: .leading) {
                            ForEach(cvmInstance.cvmNewGroup, id: \.self) { NTG in
                                OneGroupView(NTG: NTG)
                            }
                            HStack {
                                Text("Totals")
                                Text("Credits: ")
                                Text(creditTotal)
                                Text("Debits: ")
                                Text(debitTotal)
                                Spacer()
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button("  Print?  ") {
                            report = accountList
                            report += "\n Totals - Credits: \(creditTotal)  Debits: \(debitTotal)"
                            let acctListResult = PDFService.savePDF(data: pdfAcctList, fileName: "AccountList" + acctListCompare)
                            if acctListResult.successful {
                                acctListURL = acctListResult.location
                                acctListLocation = acctListURL?.absoluteString ?? ""
                            } else {
                                acctListLocation = ""
                            }
                        }
                        .buttonStyle(CustomButton1())
                        .padding()
                        if report != "" {
                            Spacer()
                            ShareLink(item: report)
                        }
                        Spacer()
                    }
                }
                .onAppear(perform: {
                    let acctList = buildAccountsList()
                    accountList = acctList.accounts
                    creditTotal = acctList.creditAmount
                    debitTotal = acctList.debitAmount
                    pdfAcctList = generatePDF() ?? Data()
                    print("xxx")
                })
            }
        }
    }
        
    func buildAccountsList() -> (accounts:String, creditAmount:String, debitAmount:String) {
        var tl:String = ""
        var totalCredit:Money = Money()
        var totalDebit:Money = Money()
        for NTG in cvmInstance.cvmNewGroup {
            tl += NTG.printLine
            tl += "\n"
            let accts:[NewAccountRecord] = cvmInstance.cvmNewAccount.filter( {$0.NARAAccountGroup == NTG.NAGroupNr } )
            for NAR in accts {
                tl += "  " + NAR.printLine + "\n"
                totalDebit = totalDebit + NAR.NARADebit
                totalCredit = totalCredit + NAR.NARACredit
            }
        }
        tl += "\n" + "    Credits: " + totalCredit.rawMoney11 + "; " + "Debits: " + totalDebit.rawMoney11  + "\n"
        return (tl, totalCredit.rawMoney11, totalDebit.rawMoney11)
    }
    
    func generatePDF() -> Data? {
        /**
        W: 8.5 inches * 72 DPI = 612 points
        H: 11 inches * 72 DPI = 792 points
        A4 = [W x H] 595 x 842 points
        */

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - 2 * margin
        var pageCount:Int = 0
        var currentY: CGFloat = pageHeight
        var totalCredit:Money = Money()
        var totalDebit:Money = Money()

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = pdfRenderer.pdfData { context in
            for NAG in cvmInstance.cvmNewGroup {
                let nextPageResult = checkNewPage(pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, pageCount: pageCount, currentY: currentY, context: context)
                currentY = nextPageResult.currentY
                pageCount = nextPageResult.pageCount
                currentY = drawGroupLine(NAG:NAG, at: CGPoint(x: margin, y: currentY), pageWidth: contentWidth + margin, contentWidth: contentWidth, margin: margin)
                let accts:[NewAccountRecord] = cvmInstance.cvmNewAccount.filter( {$0.NARAAccountGroup == NAG.NAGroupNr } )
                for NAR in accts {
                    let nextPageResult = checkNewPage(pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, pageCount: pageCount, currentY: currentY, context: context)
                    currentY = nextPageResult.currentY
                    pageCount = nextPageResult.pageCount
                    currentY = drawAccountLine(NAR:NAR, at: CGPoint(x: margin, y: currentY), pageWidth: contentWidth + margin)
                    totalDebit = totalDebit + NAR.NARADebit
                    totalCredit = totalCredit + NAR.NARACredit
                }
            }
            
            let nextPageResult = checkNewPage(pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, pageCount: pageCount, currentY: currentY, context: context)
            currentY = nextPageResult.currentY
            pageCount = nextPageResult.pageCount
            drawTotalsLine(Debit: totalDebit, Credit: totalCredit, at: CGPoint(x: margin, y: currentY), pageWidth: contentWidth + margin)

        }
        return data
    }
    
    func checkNewPage(pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, pageCount: Int, currentY: CGFloat, context: UIGraphicsPDFRendererContext) -> (pageCount:Int, currentY: CGFloat) {
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
            workCurrentY = PDFService.drawPageHeader(at: CGPoint(x: margin, y: margin), pageWidth: pageWidth, header: cvmInstance.shortModuleTitle(), header2: "List Accounts " + DateService.dateDate2String(inDate: Date(), short: false))
        }
        return(workPageCount, workCurrentY)
    }
    
    func drawGroupLine(NAG:NewAccountGroup, at origin: CGPoint, pageWidth: CGFloat, contentWidth: CGFloat, margin: CGFloat)  -> CGFloat {
        let rowHeight: CGFloat = 14
        let rowStart: CGFloat = origin.y + rowHeight + 5
        let numericStyle = NSMutableParagraphStyle()
        let alphaStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let leftOffset: CGFloat = 15
        let interField:CGFloat = 5
        let DebitX:CGFloat = origin.x + leftOffset + 50 + interField + 200 + interField
        let CreditX:CGFloat = DebitX + 100 + interField
        var nextX:CGFloat = origin.x
        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: numericStyle
        ]
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: alphaStyle
        ]
        let acctNRWidth: CGFloat = 50
        let acctNRRect = CGRect(x: nextX, y: rowStart, width: acctNRWidth, height: rowHeight)
        let acctNRString = NSAttributedString(string: String(FormattingService.rjf(base: String(NAG.NAGroupNr), len: 5, zeroFill: true)), attributes: numericAttributes)
        acctNRString.draw(in: acctNRRect)
        nextX += acctNRWidth + interField
        
        let acctGrpNameWidth: CGFloat = 200
        let acctGrpNameRect = CGRect(x: nextX, y: rowStart, width: acctGrpNameWidth, height: rowHeight)
        let acctGrpNameString = NSAttributedString(string: NAG.NAGroupName, attributes: alphaAttributes)
        acctGrpNameString.draw(in: acctGrpNameRect)

        let acctDebitWidth: CGFloat = 100
        let acctDebitRect = CGRect(x: DebitX, y: rowStart, width: acctDebitWidth, height: rowHeight)
        let acctDebitString = NSAttributedString(string: "Debits", attributes: numericAttributes)
        acctDebitString.draw(in: acctDebitRect)
        
        let acctCreditWidth: CGFloat = 100
        let acctCreditRect = CGRect(x: CreditX, y: rowStart, width: acctCreditWidth, height: rowHeight)
        let acctCreditString = NSAttributedString(string: "Credits", attributes: numericAttributes)
        acctCreditString.draw(in: acctCreditRect)

        return origin.y + 25
    }
    
    func drawAccountLine(NAR:NewAccountRecord, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let rowHeight: CGFloat = 14
        let rowStart: CGFloat = origin.y + rowHeight
        let leftOffset: CGFloat = 15
        let numericStyle = NSMutableParagraphStyle()
        let alphaStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let interField:CGFloat = 5
        var nextX:CGFloat = origin.x + leftOffset
        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: numericStyle
        ]
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: alphaStyle
        ]
        
        let acctNRWidth: CGFloat = 50
        let acctNRRect = CGRect(x: nextX, y: rowStart, width: acctNRWidth, height: rowHeight)
        let acctNRString = NSAttributedString(string: String(FormattingService.rjf(base: String(NAR.NARAAccountNr), len: 5, zeroFill: true)), attributes: numericAttributes)
        acctNRString.draw(in: acctNRRect)
        nextX += acctNRWidth + interField
        
        let acctNameWidth: CGFloat = 200
        let acctNameRect = CGRect(x: nextX, y: rowStart, width: acctNameWidth, height: rowHeight)
        let acctNameString = NSAttributedString(string: NAR.NARAAccountName, attributes: alphaAttributes)
        acctNameString.draw(in: acctNameRect)
        nextX += acctNameWidth + interField
        
        let acctDebitWidth: CGFloat = 100
        let acctDebitRect = CGRect(x: nextX, y: rowStart, width: acctDebitWidth, height: rowHeight)
        let acctDebitString = NSAttributedString(string: NAR.NARADebit.rawMoney11, attributes: numericAttributes)
        acctDebitString.draw(in: acctDebitRect)
        nextX += acctDebitWidth + interField
        
        let acctCreditWidth: CGFloat = 100
        let acctCreditRect = CGRect(x: nextX, y: rowStart, width: acctCreditWidth, height: rowHeight)
        let acctCreditString = NSAttributedString(string: NAR.NARACredit.rawMoney11, attributes: numericAttributes)
        acctCreditString.draw(in: acctCreditRect)
        nextX += acctCreditWidth + interField

        return origin.y + 15
    }
    
    func drawTotalsLine(Debit: Money, Credit: Money, at origin: CGPoint, pageWidth: CGFloat) {
        let rowHeight: CGFloat = 14
        let rowStart: CGFloat = origin.y + rowHeight + 30
        let leftOffset: CGFloat = 15
        let numericStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        let interField:CGFloat = 5
        let DebitX:CGFloat = origin.x + leftOffset + 50 + interField + 200 + interField
        let CreditX:CGFloat = DebitX + 100 + interField
        
        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: numericStyle
        ]
                
        let acctDebitWidth: CGFloat = 100
        let acctDebitRect = CGRect(x: DebitX, y: rowStart, width: acctDebitWidth, height: rowHeight)
        let acctDebitString = NSAttributedString(string: Debit.rawMoney11, attributes: numericAttributes)
        acctDebitString.draw(in: acctDebitRect)
        
        let acctCreditWidth: CGFloat = 100
        let acctCreditRect = CGRect(x: CreditX, y: rowStart, width: acctCreditWidth, height: rowHeight)
        let acctCreditString = NSAttributedString(string: Credit.rawMoney11, attributes: numericAttributes)
        acctCreditString.draw(in: acctCreditRect)
    }

}


//#Preview {
//    ListAccountsView()
//}
