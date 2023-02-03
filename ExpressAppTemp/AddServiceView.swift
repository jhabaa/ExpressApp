//
//  AddServiceView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 11/04/2022.
//

import SwiftUI

// A supprimer
struct AddServiceView: View {
    @EnvironmentObject var fetchModel:FetchModels
    @EnvironmentObject var userdata:UserData
    @State var saveResult:Bool = false
    @State var serviceName = ""
    @State var test:Decimal = Decimal(10)
    @State var serviceCost:Decimal = Decimal()
    @State var category = ""
    @State var message = ""
    @Binding var showThisView:Bool
    @State var service:Service = Service.init()
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack{
                //Fond bleui et transparent flou
                VStack{
                }.frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height).background(.blue.opacity(0.3)).blur(radius: 20)
                //Formulaire et bouton d'action
                VStack{
                    //header
                    HStack{
                        Text("Informations du service").font(.caption)
                        Spacer()
                    }
                    //Informations du service
                    VStack{
                        TextField("Nom du Service", text: $serviceName).textFieldStyle(.roundedBorder).cornerRadius(10).padding()
                        Text("Coût du Service").font(.caption)
                        TextField("Cout du service", value: $serviceCost, format: .currency(code: "EUR")).textFieldStyle(.roundedBorder).keyboardType(.decimalPad).cornerRadius(10).padding().textCase(.none)
                        TextField("Category", text: $category).textFieldStyle(.roundedBorder).cornerRadius(10).padding()
                        Text("Message d'aide associé au service pour guider les clients").multilineTextAlignment(.center)
                        TextEditor(text: $message).textFieldStyle(.roundedBorder).frame(height: 200, alignment: Alignment.topLeading)
                    }.shadow(radius: 3)
                    Text("Le prix est : \(NSDecimalNumber(decimal: serviceCost))")
                    Button {
                        //Code d'enregistrement dans la BD

                            service.name = serviceName
                            //service.COST_SERVICE = serviceCost
                            service.categories = category
                            service.description = message
                            // On lance le code d'enregistrement
                            //fetchModel.PushService(service: service, state: &saveResult)
                            print("saved")
                        Task{
                            await fetchModel.FetchServices()
                        }
                        
                        
                    } label: {
                        Text("Enregistrer")
                    }.buttonStyle(.borderedProminent).padding()
  
                }.padding().background(.ultraThinMaterial)
                    .cornerRadius(20)
                VStack(alignment: HorizontalAlignment.center, spacing: 20) {
                    Spacer()
                    Button {
                        //Exit Code
                        withAnimation {
                            showThisView.toggle()
                        }
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill").resizable().frame(width: 50, height: 50)
                    }.tint(.red)

                }
                
            }
            
        }.edgesIgnoringSafeArea(.all).padding()
        
        
        
    }
}

