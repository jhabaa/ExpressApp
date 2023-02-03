//
//   SettingsView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 04/04/2023.
//
import Foundation
import SwiftUI

struct _SettingsView: View {
    //@StateObject var fetchModels = FetchModels()
    @EnvironmentObject var userdata : UserData
    @EnvironmentObject var appSettings:AppSettings
    var body: some View {
        List {
            VStack{
                Label("Annonce Publique", systemImage: "square.and.arrow.up.circle")
            }
            VStack{
                Label("Tarif Bruxelles", systemImage: "car.rear.road.lane")
            }
            VStack{
                Label("Tarif Brabant", systemImage: "car.rear.road.lane")
            }
            VStack{
                Label("Tarif au Kilomètre", systemImage: "car.rear.road.lane")
            }
            
            Section {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        appSettings.disconnect()
                    }
                    //User.disconnect()
                    //userdata.currentUser.LOGGED_USER = 0
                } label: {
                    VStack(alignment:.center){
                        Text("Deconnexion")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    
                }
            } footer: {
                Text("Fermer votre session")
            }

        }
        .onAppear{
            //fetchModels.fetchSettings()
        }
    }
}


struct Previews__SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        _SettingsView()
            .environmentObject(UserData())
    }
}
