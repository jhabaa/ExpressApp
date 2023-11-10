//
//  Contacts.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/04/2023.
//

import SwiftUI

struct Contacts: View {
    var body: some View {
        HStack(alignment: .top, spacing:0){
            VStack(alignment:.leading){
                VStack(alignment:.leading){
                    Text("Ex-press Dry Clean")
                        .font(.custom("Bariol_Regular", size: 20))
                    Text("Leuvensesteenweg 526 1930 Zaventem")
                        .foregroundColor(.gray)
                    Link("+32024204130", destination: URL(string: "tel:+32024204130")!)
                        .padding(.bottom,10)
                    Link("info@expressdryclean.be", destination: URL(string: "mailto:info@expressdryclean.be")!)
                        .textSelection(EnabledTextSelectability.enabled)
                    Label("BE0460.715.554", systemImage: "newspaper.fill")
                }
               
                LazyVGrid(columns: [GridItem(.flexible()), GridItem()],alignment:.center, content: {
                    Label("Confidentialité", systemImage: "safari")
                        .foregroundStyle(.gray)
                        .font(.caption2)
                        .onTapGesture {
                            let url = URL.init(string: "https://expressdryclean.be/politique-de-confidentialite/")
                            UIApplication.shared.open((url ?? URL.init(string: "https://expressdryclean.be"))!)
                        }
                        
                    Label("Conditions générales de vente", systemImage: "safari")
                        .foregroundStyle(.gray)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            let url = URL.init(string: "https://expressdryclean.be/conditions-generales-de-vente/")
                            UIApplication.shared.open(url!)
                        }
                })
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .background(.bar)
        // The background should be the 3D express logo
    }
}

struct Contacts_Previews: PreviewProvider {
    static var previews: some View {
        Contacts()
    }
}
