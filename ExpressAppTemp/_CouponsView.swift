//
//  _CouponsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/04/2023.
//

import SwiftUI

struct CouponsView: View {
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var coupon:Coupons
   
    var body: some View {
        VStack{
            List {
                Section {
                    HStack{
                        TextField(text: .init(get: {
                            coupon.this.code
                        }, set: { new in
                            coupon.this.code = new.uppercased()
                        })) {
                            Text("Code")
                        }
                        .textCase(.uppercase)
                        .padding()
                        .frame(maxWidth: 150)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        
                        //Coupon value
                        TextField(value: $coupon.this.discount, format: .currency(code: "")) {
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
                                if await (coupon.this.Add_Coupon()){
                                    coupon.clean()
                                }
                                try await coupon.Retrieve_Coupons()
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
                    ForEach(coupon.all, id: \.self) { c in
                        HStack{
                            Text("\(c.code)")
                        }
                        .frame(height: 50)
                        .badge("\(c.discount.formatted(.currency(code: "EUR")))")
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role:.destructive) {
                                    //Delete coupon
                                    Task{
                                        await c.Delete_Coupon()
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
                try await coupon.Retrieve_Coupons()
            }
        }
    }
}

struct CouponsView_Previews: PreviewProvider {
    static var previews: some View {
        CouponsView()
            .environmentObject(FetchModels())
            .environmentObject(Coupons())
    }
}
