//
//  OneTransactionView.swift
//  LawCount
//
//  Created by Morris Albers on 8/24/24.
//

import SwiftUI

struct OneTransactionView: View {
    @EnvironmentObject var cvmInstance:CVM
    var itr:IJTrans
    @State var workTrans:IJTrans = IJTrans()
//    @State var workSegments:[IJTrans.IJTSegment] = [IJTrans.IJTSegment]()
    @State var workSeg:Int = -1
    @State var workTransNumberNumber:Int = 0
    @State var workTransactionNumber:String = ""
    @State var workTransactionName:String = ""
    @State var workTransactionDebitString:String = Money(moneyAmount: 0).rawMoney11
    @State var workTransactionCreditString:String = Money(moneyAmount: 0).rawMoney11
    @State var workTransactionDebitMoney:Money = Money()
    @State var workTransactionCreditMoney:Money = Money()
    @State var segmentsChanged:Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(cvmInstance.moduleTitle(mod: "Handle Transaction"))
                    .font(.system(size: 20))
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
/*
    Transaction base - contains the transaction date, other significant date
 */
            HStack {
                Text(String(itr.IJTSeqNr))
                Text(itr.IJTDate.exdFormatted)
                Text(itr.IJTType)
                Text(itr.IJTNum)
                Text(itr.IJTName)
            }
            .padding(.bottom, 10)
/*
    Segments - contain the various accounts to be impacted by this transaction
 */
            ForEach(itr.IJTSegments, id: \.self) { wseg in      // these are the transaction segments
                HStack {
/*
    This button is for each segment; if it's clicked, we want to try to update that segment
        That's why we transfer data from the segment to the working fields in the view
 */
                    Button {
                        print("above push")
                        for i in 0 ... itr.IJTSegments.count - 1 {
                            if itr.IJTSegments[i] == wseg {
                                workSeg = i
                                workTransNumberNumber = workTrans.IJTSegments[workSeg].IJTSAccountNr
                                workTransactionNumber = String(workTransNumberNumber)
                                workTransactionName = workTrans.IJTSegments[workSeg].IJTSAccountName
                                workTransactionDebitMoney = workTrans.IJTSegments[workSeg].IJTSDebit
                                workTransactionCreditMoney = workTrans.IJTSegments[workSeg].IJTSCredit
                                workTransactionDebitString = workTransactionDebitMoney.rawMoney11
                                workTransactionCreditString = workTransactionCreditMoney.rawMoney11
                                let status = cvmInstance.retrieveAccount(acctNr: workTransNumberNumber)
                                print(status)
                            }
                        }
                    } label: {
                        HStack {
                            Text(" ")
                            Text(String(wseg.IJTSAccountNr))
                            Text(wseg.IJTSAccountName)
                            Text(wseg.IJTSDebit.rawMoney11)
                            Text(wseg.IJTSCredit.rawMoney11)
                            Text(" ")
                        }
                    }
                    .buttonStyle(CustomButton3())
                    Spacer()
                }
                .padding(.bottom, 10)
            }
/*
    if the segments have changed, need to present the opportunity to save the changes - probably need to
        extend this to the entire transaction
 */
            if segmentsChanged {
                VStack(alignment: .leading) {
                    Button {
                        print("handle edit and save")
                    } label: {
                        Text(" Save Transaction ")
                    }
                    .buttonStyle(CustomButton3())
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    ForEach(workTrans.IJTSegments, id: \.self) { wseg in
                        HStack {
                            Text(" ")
                            Text(String(wseg.IJTSAccountNr))
                            Text(wseg.IJTSAccountName)
                            Text(wseg.IJTSDebit.rawMoney11)
                            Text(wseg.IJTSCredit.rawMoney11)
                            Text(" ")
                        }
                    }
                }
            }
            if workSeg >= 0 {
                VStack(alignment: .leading) {
                    Button {
                        print("above push")
// TODO: Update working transaction here
//  form takes data into workTransaction...
//  holding area for pending transaction update is workTrans
//  to save input, move it from workTransaction... to corresponding workTrans.IJTrans.IJTSegment[workSeg]...
                        
// TODO: Figure out why these simple assignments aren't happening; the right hand value just isn't replacing the left hand value; no indication of an error
                        workTrans.IJTSegments[workSeg].IJTSAccountNr = workTransNumberNumber
                        workTransactionNumber = String(workTrans.IJTSegments[workSeg].IJTSAccountNr)
                        workTrans.IJTSegments[workSeg].IJTSAccountName = workTransactionName
                        workSeg = -1
                    } label: {
                        Text(" done with segment ")
                    }
                    .buttonStyle(CustomButton3())
                    .padding(.top, 20)
                    
                    Form {
                        Section(header: Text("Transaction Segment").background(Color.teal).foregroundColor(.white)) {
                            HStack {
                                Text("Account number: ").foregroundColor(.mint)
                                TextField("Account number", text: $workTransactionNumber)
                                    .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
                                        handleChangedNumber(newNum: workTransactionNumber)
                                    }
                            }
                            HStack {
                                Text("Account name: ").foregroundColor(.mint)
                                TextField("Account name", text: $workTransactionName).disableAutocorrection(true)
                                    .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
                                        handleAccountNameChanged(newName: workTransactionName)
                                    }
                            }
                            HStack {
                                Text("Debit Amount: ").foregroundColor(.mint)
                                TextField("Only digits", text: $workTransactionDebitString).disableAutocorrection(true)
                                    .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
                                        let status = handleChangedMoney(newMoney: workTransactionDebitString)
                                        workTransactionDebitMoney = status.money
                                        workTransactionDebitString = status.str
                                    }
                            }
                            HStack {
                                Text("Credit Amount: ").foregroundColor(.mint)
                                TextField("Only digits", text: $workTransactionCreditString).disableAutocorrection(true)
                                    .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
                                        let status = handleChangedMoney(newMoney: workTransactionCreditString)
                                        workTransactionCreditMoney = status.money
                                        workTransactionCreditString = status.str
                                    }
                            }
                        }
                    }
//                    .onAppear{
//                        workTransNumberNumber = workTrans.IJTSegments[workSeg].IJTSAccountNr
//                        workTransactionNumber = String(workTransNumberNumber)
//                        workTransactionName = workTrans.IJTSegments[workSeg].IJTSAccountName
//                        workTransactionDebitMoney = workTrans.IJTSegments[workSeg].IJTSDebit
//                        workTransactionCreditMoney = workTrans.IJTSegments[workSeg].IJTSCredit
//                        workTransactionDebitString = workTransactionDebitMoney.rawMoney11
//                        workTransactionCreditString = workTransactionCreditMoney.rawMoney11
//                        let status = cvmInstance.retrieveAccount(acctNr: workTransNumberNumber)
//                        print(status)
//                    }
                }

            }
            Spacer()
        }
        .padding(.leading, 20)
        .onFirstAppear {
            initWorkArea()
        }
    }
    
    func handleAccountNumberChanged(newNum:String) {
        if workTransactionNumber != newNum {
            segmentsChanged = true
            handleChangedNumber(newNum: newNum)
        }
    }
    
    func handleAccountNameChanged(newName:String) {
        workTransactionName = workTrans.IJTSegments[workSeg].IJTSAccountName
    }
    
    func handleChangedNumber(newNum:String) {
        workTransactionNumber = newNum
        workTransNumberNumber = Int(newNum) ?? -1
        workTransactionNumber = String(workTransNumberNumber)
        let status = cvmInstance.retrieveAccount(acctNr: workTransNumberNumber)
        if status.status == 0 {
            workTransactionName = status.acct.ICAAAccountName
        } else {
            workTransactionName = ""
        }
        if workTransactionName != itr.IJTSegments[workSeg].IJTSAccountName  {
            segmentsChanged = true
        }
        print("here")
    }
    
    func handleChangedMoney(newMoney:String) -> (money:Money, str:String) {
        var workMoney:Money = Money()
        var workString:String = workMoney.rawMoney11
        var workMoneyAmount:Int = Int(newMoney) ?? 0
        workMoney = Money(moneyAmount: workMoneyAmount)
        workString = workMoney.rawMoney11
        return(workMoney, workString)
    }
                                                        
    func initWorkArea() {
        workTrans = IJTrans()
        workTrans.IJTSeqNr = itr.IJTSeqNr
        workTrans.IJTDate = itr.IJTDate
        workTrans.IJTType = itr.IJTType
        workTrans.IJTNum = itr.IJTNum
        workTrans.IJTName = itr.IJTName
        workTrans.IJTSegments = itr.IJTSegments
        segmentsChanged = false
    }
}

//#Preview {
//    OneTransactionView(, itr: IJTrans()
//}
