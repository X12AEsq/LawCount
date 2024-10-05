//
//  TransJournalView.swift
//  LawCount
//
//  Created by Morris Albers on 9/2/24.
//

import SwiftUI

struct TransJournalView: View {
    @EnvironmentObject var cvmInstance:CVM
//    @State var transactionList:String = ""
    @State var workAccount:[NewAccountRecord] = []
    @State var workTRX:FullTransaction = FullTransaction()
    @State var journalReport:String = ""
    @State var journalStartDate:Date = Date()
    @State var journalEndDate:Date = Date()
    @State var journalStartCompare:ExtDate = ExtDate()
    @State var journalEndCompare:ExtDate = ExtDate()
    @State var trxListURL:URL?
    @State var trxListLocation:String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment:.top) {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text(cvmInstance.moduleTitle(mod: "Journal"))
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                    HStack {
                        DatePicker("Start Date", selection: $journalStartDate, displayedComponents: [.date])
                            .onChange(of: journalStartDate, {
                                journalStartCompare = ExtDate(appleDate: journalStartDate)
                            })
                            .frame(width: 200, alignment:.leading)
                            .datePickerStyle(.wheel)
                        Spacer()
                        DatePicker("End Date", selection: $journalEndDate, displayedComponents: [.date])
                            .onChange(of: journalEndDate, {
                                journalEndCompare = ExtDate(appleDate: journalEndDate)
                            })
                            .frame(width: 200, alignment:.leading)
                            .datePickerStyle(.wheel)
                        Spacer()
                        Button(" Execute ") {
                            trxListLocation = ""
                            if let pdfJournal:Data = generatePDF() {
                                let trxListResult = PDFService.savePDF(data: pdfJournal, fileName: "TransactionJournal" + journalStartCompare.exdDateRaw + "-" + journalEndCompare.exdDateRaw)
                                if trxListResult.successful {
                                    let trxListURL:URL? = trxListResult.location
                                    trxListLocation = trxListURL?.absoluteString ?? ""
                                }
                            }
                        }
                        .buttonStyle(CustomButton1())
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                    .frame(alignment:.leading)
                    if trxListLocation != "" {
                        HStack {
                            Text("Transaction List Location: ")
                            Text(trxListLocation)
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        .frame(alignment:.leading)
                    }

                    ScrollView {
                        VStack (alignment: .leading) {
//                        ForEach(cvmInstance.cvmNewGroup, id: \.self) { NTG in
//                            OneGroupView(NTG: NTG)
//                        }
                            HStack {
                                Text("Totals")
//                            Text("Credits: ")
//                            Text(creditTotal)
//                            Text("Debits: ")
//                            Text(debitTotal)
                                Spacer()
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    prepareWorkArea()
                    print("xxx")
                })
            }
        }
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
        var totalCredit:Money = Money()
        var totalDebit:Money = Money()
        
        if journalStartCompare.dateValue == 0 { journalStartCompare = ExtDate(appleDate: Date()) }
        if journalEndCompare.dateValue == 0 { journalEndCompare = ExtDate(appleDate: Date()) }

        let filteredTrans:[NewAccountTransaction] = cvmInstance.cvmNewTrans.filter( { $0.NATDate >= journalStartCompare && $0.NATDate <= journalEndCompare } )
        let reportTrans:[NewAccountTransaction] = filteredTrans.sorted(by: { $0.NATSeqNr < $1.NATSeqNr } )

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pdfParms.pageWidth, height: pdfParms.pageHeight))

        let data = pdfRenderer.pdfData { context in
            for trx in reportTrans {
                let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))
                
                currentY = nextPageResult.currentY
                pageCount = nextPageResult.pageCount

                currentY = drawTransactionLine(NAT:trx, at: CGPoint(x: pdfParms.margin, y: currentY), pageWidth: pdfParms.contentWidth + pdfParms.margin)
                
                let trsegs:[NewTransactionSegment] = cvmInstance.cvmNewSegments.filter({ $0.NTSParentTransaction == trx.NATSeqNr })
                for trs in trsegs {
                    totalDebit = totalDebit + trs.NTSDebit
                    totalCredit = totalCredit + trs.NTSCredit
                    
                    currentY = drawSegmentLine(NTS: trs, at: CGPoint(x: pdfParms.margin, y: currentY), pageWidth: pdfParms.contentWidth + pdfParms.margin)
                    let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))
                    currentY = nextPageResult.currentY
                    pageCount = nextPageResult.pageCount
                }
            }
            let nextPageResult = PDFService.checkNewPage(pageWidth: pdfParms.pageWidth, pageHeight: pdfParms.pageHeight, margin: pdfParms.margin, pageCount: pageCount, currentY: currentY, context: context, header: cvmInstance.shortModuleTitle(), header2: "List Transactions " + DateService.dateDate2String(inDate: Date(), short: false))
            
            currentY = nextPageResult.currentY
            pageCount = nextPageResult.pageCount

            currentY = drawTotalsLine(Debit: totalDebit, Credit: totalCredit, at: CGPoint(x: pdfParms.margin, y: currentY), pageWidth: pdfParms.contentWidth + pdfParms.margin)
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
    
    func drawTotalsLine(Debit: Money, Credit: Money, at origin: CGPoint, pageWidth: CGFloat) -> CGFloat {
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
        
        return origin.y + 15
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

    func prepareWorkArea() {
        journalReport = ""
        workAccount = [NewAccountRecord]()
        for acct in cvmInstance.cvmNewAccount {
//            let workAcct: NewAccountRecord = NewAccountRecord(NARAAccountNr: acct.NARAAccountNr, NARAAccountName: acct.NARAAccountName, NARAAccountGroup: acct.NARAAccountGroup, NARADebit: Money(), NARACredit: Money())
            workAccount.append(acct)
        }
        for trx in cvmInstance.cvmNewTrans.filter( { $0.NATProcessed } ) {
            workTRX.ftxTrans = trx
            workTRX.ftxSegs = cvmInstance.cvmNewSegments.filter({$0.NTSParentTransaction == trx.NATSeqNr}).sorted(by: { $0.NTSSeqNr < $1.NTSSeqNr } )
            var pl:String = FormattingService.rjf(base: String(workTRX.ftxTrans.NATSeqNr), len: 5, zeroFill: false)
            pl = pl + " "
            pl = pl + workTRX.ftxTrans.NATDate.exdFormatted
            pl = pl + " "
            pl += " "
            pl += FormattingService.ljf(base: workTRX.ftxTrans.NATNum, len: 15)
            pl += " "
            pl += FormattingService.ljf(base: workTRX.ftxTrans.NATName, len: 25)
            pl += "\n"
            journalReport += pl
        }
   }
}
//
//#Preview {
//    TransJournalView()
//}
