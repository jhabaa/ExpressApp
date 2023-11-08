//
//  ServiceModifierView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 06/11/2023.
//

import SwiftUI
enum categoryOptions {
    case new, existing, none
}

struct ServiceModifierView: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var articles:Article
    @EnvironmentObject var appSettings:AppSettings
    @StateObject private var focusState = focusObjects()
    @FocusState private var focusedTextEditor: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var alerte:Alerte
    @State var service:Service
    @State var categorySelected:categoryOptions = .none
    @State var description:Bool = false
    @State var price:String=String()
    var body: some View {
        ScrollView{
            TextField(text: $service.name){}
                .font(.custom("BebasNeue", size: 40))
                .foregroundStyle(.blue)
            //CustomTextField(_text: $service.name, _element: "mot de passe",hideMode:false,type:.text, name:"Nom du service")
            Picker(selection: $categorySelected, label: Text("Picker")) {
                Text("Créer Catégorie").tag(categoryOptions.new)
                Text("Catégorie existante").tag(categoryOptions.existing)
            }
            .pickerStyle(.segmented)
            //MARK:Category choice
            switch categorySelected {
            case .new:
                Text("Pour créer et attribuer plusieurs catégories, séparer les catégories par ;")
                    .font(.caption2)
                TextField("Nouvelle catégorie", text: $service.categories, prompt: Text("Nom de la catégorie"))
                    .font(.custom("Ubuntu", size: 30))
                    .frame(maxWidth: .infinity, alignment:.center)
                    .multilineTextAlignment(.center)
            case .existing:
                //MARK: Choose one caterory in existing panel
                //all existing categories to simplify filling
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 20) {
                        ForEach(articles.GetCategories().sorted(by: <), id:\.self) {category in
                            Text(category)
                                .padding()
                                .background(service.categories == category ? .blue : .primary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .onTapGesture {
                                    //assing it
                                    service.categories = category
                                }
                        }
                    }
                }
                .frame(height: 100)
            case .none:
                Text("Choisir comment vous souhaiter attibuer une catégorie")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            VStack{
                Text("Prix de l'article et delai de traitement")
                    .font(.caption2)
                LazyVGrid(columns: [GridItem(),GridItem()]) {
                    TextField("Prix", text: .init(get: {
                        price
                    }, set: { Value in
                        price = Value.filter({$0.isNumber || $0 == "."})
                        if !price.isEmpty{
                            service.cost = Decimal(string: price)!
                        }
                    }))
                    .padding(20)
                    .keyboardType(.decimalPad)
                    .shadow(radius: 1)
                    .font(.custom("SadMachine", size: 50))
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.bar)
                    }
                    
                    //MARK: Days selector
                    Picker("Nombre de jours requis", selection: $service.time) {
                        ForEach(0..<100){day in
                            Text("\(day)")
                                .font(.custom("SadMachine", size: 30))
                        }
                    }
                    .font(.custom("SadMachine", size: 30))
                    .pickerStyle(.automatic)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.bar)
                    }
                }
                .frame(height: 100)
            }
            
                //message associé
                Toggle(isOn: $description) {
                    Text(description ? "Ajouter une description" : "Retirer la description")
                        .font(.custom("BebasNeue", size: 20))
                }
                .toggleStyle(ExpressToggleStyle())
                .onChange(of: description) { V in
                    if V{
                        service.description = "." // Reset description if the button is pressed after text
                    }
                }
                if !description{
                    
                    TextField("\(service.description)", text: .init(get: {
                        service.description
                    }, set: { v in
                        if (String(v).allSatisfy({$0.isASCII})){
                            service.description = v
                        }
                    }))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .font(.custom("Ubuntu", size: 20))
                    .frame(height: 100)
                    .background(.ultraThinMaterial)
                    .focused($focusedTextEditor)
                    .onReceive(service.description.publisher.last()) {
                                    if ($0 as Character).asciiValue == 10 { // ASCII 10 = newline
                                        focusedTextEditor = false // unfocus TextEditor to dismiss keyboard
                                        service.description.removeLast() // remove newline at end to prevent retriggering...
                                    }
                                }
                    .submitLabel(.done)
                }
            
            VStack(alignment:.leading){
                Button {
                    
                } label: {
                    Label("Choisir une nouvelle illustration", systemImage: "photo.badge.plus.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .buttonStyle(.borderedProminent)

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(articles.images.keys.sorted(by: <), id: \.self) { name in
                            Image(uiImage: articles.images[name]!)
                                .resizable()
                                .frame(width: 100, height:100)
                                .padding()
                                .onTapGesture {
                                    service.illustration = name
                                }
                                .scaleEffect(service.illustration == name ? 1.2: 1)
                                .shadow(color: Color("xpress"), radius: service.illustration == name ? 10: 0)
                        }
                    }
                }
            }
            .padding()
            
                Button("Supprimer l'article"){
                    Task{
                        let t = await service.Delete()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .tint(.red)
            .listStyle(.plain)
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
                Button {
                        Task{
                            let _ = await !service.Put_Service()
                            let _ = await articles.fetch()
                        }
                        //Show notification
                    #warning("look here")
                        /*alerte.this.text = "Article mis à jour"
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            alerte.this.text = String()
                        })*/
                        presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Mettre à jour")
                }
                .buttonStyle(.borderedProminent)
        })
    }
}

struct ExpressToggleStyle:ToggleStyle{
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            VStack{
                Image(systemName: configuration.isOn ? "checkmark.seal.fill" : "xmark.seal.fill")
                configuration.label
            }
            .tint(configuration.isOn ? .green : .red)
            .padding()
            .background{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.bar)
                    .shadow(color: configuration.isOn ? .green : .red, radius: 10)
            }
        }

    }
}

#Preview {
    ServiceModifierView(service:Service("Chemise"))
        .environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Article())
            .environmentObject(Alerte())
            .environmentObject(AppSettings())
}
