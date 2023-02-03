//
//  Contacts.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 16/04/2023.
//

import SwiftUI

struct Contacts: View {
    var body: some View {
        GeometryReader { GeometryProxy in
            VStack{
                Image("logo120")
                    .clipShape(Circle())
                    .background{
                        Circle().fill(.thinMaterial).scaleEffect(1.02)
                            .shadow(color: .accentColor, radius: 20)
                    }
                Text("Leuvensesteenweg 526 1930 Zaventem").foregroundColor(.gray)
                    .padding()
                Text("+32 02 420 41 30")
                    .padding(.bottom,10)
                Text("info@expressdryclean.be")
                /*
                VStack{
                    Text("""
Vous souhaitez faire nettoyer à sec  votre chemisier en soie taché ? Vous avez besoin de faire nettoyer vos couettes ou vos couvertures avant le retour de l’hiver ?\nVous désirez faire décaper l’un de vos tapis avant de le remettre en place ?
    Vous recherchez une blanchisserie  près de Bruxelles ou dans le nord du Brabant-wallon pour lui confier votre linge de maison ou celui de votre famille ?
    Découvrez les services des experts du linge à Etterbeek, St-Josse, Zaventem et Moortebeek  – Ex-Press Dry Clean.

    Depuis plus de 20 ans, nous sommes à l’écoute des besoins de nos clients particuliers ou professionnels. N’hésitez pas à nous poser toutes vos questions
""")
                        .padding()
                        .textSelection(.enabled)
                        .multilineTextAlignment(.center)
                        
                }*/
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thinMaterial)
        }
        
        // The background should be the 3D express logo
    }
}

struct Contacts_Previews: PreviewProvider {
    static var previews: some View {
        Contacts()
    }
}
