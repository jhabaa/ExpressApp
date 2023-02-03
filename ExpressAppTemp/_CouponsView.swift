//
//  _CouponsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/04/2023.
//

import SwiftUI

struct CouponsView: View {
    @EnvironmentObject var fetchmodel:FetchModels
    @State var _coupon:Coupon=Coupon()
    var body: some View {
        VStack{
            List {
                Section {
                    HStack{
                        TextField(text: $_coupon.code) {
                            Text("Code")
                                
                        }
                        
                        .textCase(.uppercase)
                        .padding()
                        .frame(maxWidth: 150)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        
                        //Coupon value
                        TextField(value: $_coupon.discount, format: .currency(code: "")) {
                            Text("Valeur")
                        }
                        .keyboardType(.decimalPad)
                        
                        .padding()
                        .frame(maxWidth: 100)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        
                        Button("OK")
                        {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            //Add coupon
                            Task{
                                if await (fetchmodel.Add_Coupon(_coupon)){
                                    _coupon = Coupon()
                                }
                                try await fetchmodel.Retrieve_Coupons()
                            }
                            
                            
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                    }
                } header: {
                    VStack{
                        Text("Vous pouvez ajouter un nouveau coupon ici. Il suffit de mentionner le montant et le code et de valider. Les coupons ne peuvent pas être modifiés une fois créés")
                        
                    }
                    
                }
                
                Section {
                    ForEach(fetchmodel.all_coupons, id: \.self) { coupon in
                        HStack{
                            Text("\(coupon.code)")
                        }
                        .frame(height: 50)
                        .badge("\(coupon.discount.formatted(.currency(code: "EUR")))")
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                
                                Button(role:.destructive) {
                                    //Delete coupon
                                    Task{
                                        await fetchmodel.Delete_Coupon(coupon)
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                                .tint(.red)

                            }
                        
                    }
                } header: {
                    Text("Coupons en cours")
                }

                
                
            }
        }
        .onAppear{
            Task{
                try await fetchmodel.Retrieve_Coupons()
            }
        }
        
        
    }
}

struct CouponsView_Previews: PreviewProvider {
    static var previews: some View {
        CouponsView()
            .environmentObject(FetchModels())
    }
}
