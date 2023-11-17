//
//  AdminCommandView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/11/2023.
//

import SwiftUI

struct AdminCommandView: View {
    @State var panier:Panier
    var body: some View {
        NavigationView(content: {
            //MARK: Command fixed infos
            ScrollView {
                VStack(alignment: .leading, content: {
                    Text("Id:457454")
                    Text("Passée le 478/2122/54")
                    Text("Utilisateur: John Doe")
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.uppercase)
                .foregroundStyle(.gray)
                .font(.caption)
                //MARK: Current Cart
                Section {
                    
                }
            }
        })
        .navigationTitle("Commande:\(panier.command.id)")
    }
}

#Preview {
    AdminCommandView(panier: Panier())
        
}
