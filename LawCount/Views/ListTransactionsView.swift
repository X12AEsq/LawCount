//
//  ListTransactionsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct ListTransactionsView: View {
    @EnvironmentObject var cvmInstance:CVM
    
    @State var transactionList:String = ""
    @State var reportAlpha:Bool = true
    @State var report:String = ""
    @State var rcdNr:Int = 0
    @State var lineNr:Int = 0
    @State var pdfTrxList:Data = Data()
    @State var trxListURL:URL?
    @State var trxListLocation:String = ""
    @State var trxListString:String = ""
    @State var trxListCompare:String = ""

    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "List Transactions"))
                        .font(.system(size: 20))
                    Spacer()
                    Button("  Print?  ") {
                        report = transactionList
                        let trxListResult = PDFService.savePDF(data: pdfTrxList, fileName: "TransactionList" + trxListCompare)
                        if trxListResult.successful {
                            trxListURL = trxListResult.location
                            trxListLocation = trxListURL?.absoluteString ?? ""
                        } else {
                            trxListLocation = ""
                        }
                    }
                    .buttonStyle(CustomButton1())
                    Spacer()
                    if report != "" {
                        Spacer()
                        ShareLink(item: report)
                    }
                    Spacer()
                    if trxListLocation != "" {
                        Text("Transaction List Location: ")
                        Text(trxListLocation)
                        Spacer()
                    }
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
//                if trxListLocation != "" {
//                Button("Save to disk") {
//                    let data = Data(transactionList.utf8)
//                    let url = URL.documentsDirectory.appending(path: "TransactionList.txt")
//
//                    do {
//                        try data.write(to: url, options: [.atomic, .completeFileProtection])
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
                ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(cvmInstance.cvmNewTrans, id: \.self) { ctr in
                            HStack {
                                Text(ctr.shortPrintLine)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
            }
            .onFirstAppear {
                transactionList = buildTransactionList()
                pdfTrxList = generatePDF() ?? Data()
            }
//            .onAppear(perform: {
//                transactionList = buildTransactionList()
//                trxAcctList = generatePDF() ?? Data()
//            })
        }
    }
    
    func buildTransactionList() -> String {
        var tl:String = ""
        for ctr in cvmInstance.cvmNewTrans {
            tl += ctr.shortPrintLine
            tl += "\n"
        }
        return tl
    }
    
    func generatePDF() -> Data? {
        /**
        W: 8.5 inches * 72 DPI = 612 points
        H: 11 inches * 72 DPI = 792 points
        A4 = [W x H] 595 x 842 points
        */

        let pdfParms = PDFParms.pdfParameters()
        var pageCount:Int = 0
        var currentY: CGFloat = pdfParms.currentY

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pdfParms.pageWidth, height: pdfParms.pageHeight))

        let data = pdfRenderer.pdfData { context in
            for ctr in cvmInstance.cvmNewTrans {
                let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))
                
                currentY = nextPageResult.currentY
                pageCount = nextPageResult.pageCount

                currentY = drawTransactionLine(NAT:ctr, at: CGPoint(x: pdfParms.margin, y: currentY), pageWidth: pdfParms.contentWidth + pdfParms.margin)
                
                let trsegs:[NewTransactionSegment] = cvmInstance.cvmNewSegments.filter({ $0.NTSParentTransaction == ctr.NATSeqNr })
                for trs in trsegs {
                    currentY = drawSegmentLine(NTS: trs, at: CGPoint(x: pdfParms.margin, y: currentY), pageWidth: pdfParms.contentWidth + pdfParms.margin)
                    let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))

                    currentY = nextPageResult.currentY
                    pageCount = nextPageResult.pageCount
                }
            }
            
            let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))

            currentY = nextPageResult.currentY
            pageCount = nextPageResult.pageCount
        }
        return data
    }
    
    func drawTransactionLine(NAT:NewAccountTransaction, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
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
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: numericStyle
        ]
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: alphaStyle
        ]
        
        let transNRWidth: CGFloat = 50
        let transNRRect = CGRect(x: nextX, y: rowStart, width: transNRWidth, height: rowHeight)
        let transNRString = NSAttributedString(string: FormattingService.rjf(base: String(NAT.NATSeqNr), len: 5, zeroFill: true), attributes: numericAttributes)
        transNRString.draw(in: transNRRect)
        nextX += transNRWidth + interField

        let transDateWidth: CGFloat = 70
        let transDateRect = CGRect(x: nextX, y: rowStart, width: transDateWidth, height: rowHeight)
        let transDateString = NSAttributedString(string: FormattingService.ljf(base: NAT.NATDate.exdFormatted, len: 11), attributes: alphaAttributes)
        transDateString.draw(in: transDateRect)
        nextX += transDateWidth + interField
        
        let transTypeWidth: CGFloat = 80
        let transTypeRect = CGRect(x: nextX, y: rowStart, width: transTypeWidth, height: rowHeight)
        let transTypeString = NSAttributedString(string: FormattingService.ljf(base: NAT.NATType, len: 20), attributes: alphaAttributes)
        transTypeString.draw(in: transTypeRect)
        nextX += transTypeWidth + interField
        
        let transNumWidth: CGFloat = 80
        let transNumRect = CGRect(x: nextX, y: rowStart, width: transNumWidth, height: rowHeight)
        let transNumString = NSAttributedString(string: FormattingService.ljf(base: NAT.NATNum, len: 15), attributes: alphaAttributes)
        transNumString.draw(in: transNumRect)
        nextX += transNumWidth + interField
        
        let transNameWidth: CGFloat = 120
        let transNameRect = CGRect(x: nextX, y: rowStart, width: transNameWidth, height: rowHeight)
        let transNameString = NSAttributedString(string: FormattingService.ljf(base: NAT.NATName, len: 25), attributes: alphaAttributes)
        transNameString.draw(in: transNameRect)
        nextX += transNameWidth + interField
        
        let transDoneWidth: CGFloat = 50
        let transDoneRect = CGRect(x: nextX, y: rowStart, width: transDoneWidth, height: rowHeight)
        let transDoneString = NSAttributedString(string: NAT.NATProcessed ? "done" : "ready", attributes: alphaAttributes)
        transDoneString.draw(in: transDoneRect)
        nextX += transDoneWidth + interField
        return origin.y + 15
    }

    func drawSegmentLine(NTS:NewTransactionSegment, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
        let rowHeight: CGFloat = 14
        let rowStart: CGFloat = origin.y + rowHeight
        let leftOffset: CGFloat = 30
        let numericStyle = NSMutableParagraphStyle()
        let alphaStyle = NSMutableParagraphStyle()
        numericStyle.alignment = .right
        alphaStyle.alignment = .left
        let interField:CGFloat = 5
        var nextX:CGFloat = origin.x + leftOffset
        
        let numericAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: numericStyle,
            .foregroundColor: UIColor.blue
        ]
        let alphaAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: alphaStyle,
            .foregroundColor: UIColor.blue
        ]
        
        let trSegNrWidth: CGFloat = 50
        let trSegNrRect = CGRect(x: nextX, y: rowStart, width: trSegNrWidth, height: rowHeight)
        let trSegNrString = NSAttributedString(string: FormattingService.rjf(base: String(NTS.NTSSeqNr), len: 5, zeroFill: true), attributes: numericAttributes)
        trSegNrString.draw(in: trSegNrRect)
        nextX += trSegNrWidth + interField
        
        let trSegAcctNrWidth: CGFloat = 50
        let trSegAcctNrRect = CGRect(x: nextX, y: rowStart, width: trSegAcctNrWidth, height: rowHeight)
        let trSegAcctNrString = NSAttributedString(string: FormattingService.rjf(base: String(NTS.NTSAccountNr), len: 5, zeroFill: true), attributes: numericAttributes)
        trSegAcctNrString.draw(in: trSegAcctNrRect)
        nextX += trSegAcctNrWidth + interField
        
        let trSegAcctNameWidth: CGFloat = 120
        let trSegAcctNameRect = CGRect(x: nextX, y: rowStart, width: trSegAcctNameWidth, height: rowHeight)
        let trSegAcctNameString = NSAttributedString(string: NTS.NTSAccountName, attributes: alphaAttributes)
        trSegAcctNameString.draw(in: trSegAcctNameRect)
        nextX += trSegAcctNameWidth + interField

        let trSegAcctDebitWidth: CGFloat = 100
        let trSegAcctDebitRect = CGRect(x: nextX, y: rowStart, width: trSegAcctDebitWidth, height: rowHeight)
        let trSegAcctDebitString = NSAttributedString(string: NTS.NTSDebit.rawMoney11, attributes: numericAttributes)
        trSegAcctDebitString.draw(in: trSegAcctDebitRect)
        nextX += trSegAcctDebitWidth + interField

        let trSegAcctCreditWidth: CGFloat = 100
        let trSegAcctCreditRect = CGRect(x: nextX, y: rowStart, width: trSegAcctCreditWidth, height: rowHeight)
        let trSegAcctCreditString = NSAttributedString(string: NTS.NTSCredit.rawMoney11, attributes: numericAttributes)
        trSegAcctCreditString.draw(in: trSegAcctCreditRect)
        nextX += trSegAcctCreditWidth + interField

        return origin.y + 15
/*
 var NTSAccountNr:Int = 0
 var NTSAccountName = ""
 var NTSDebit:Money = Money()
 var NTSCredit:Money = Money()

 */

    }

}

//#Preview {
//    ListTransactionsView()
//}
