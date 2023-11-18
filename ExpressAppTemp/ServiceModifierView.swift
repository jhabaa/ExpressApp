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

/// The mode used in the Service Modifier view.
enum ServiceAddMode{
    case update, new
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
    @State var checkCategories:Set<String>=[ ]
    @State var showingImagePicker = false
    @State var inputImage:UIImage?
    @State var mode:ServiceAddMode?
    var body: some View {
        Form{
            Section("Nom et catégorie") {
                TextField(text: $service.name,prompt:Text("Nom du service")){}
                //Category selection
                Picker(selection: $categorySelected, label: Text("Picker")) {
                    Text("Créer Catégorie").tag(categoryOptions.new)
                    Text("Catégorie existante").tag(categoryOptions.existing)
                }
                .pickerStyle(.segmented)
            }
            //MARK:Category choice
            switch categorySelected {
            case .new:
                Section {
                    HStack{
                        Text("Catégorie")
                        TextField("Nouvelle catégorie", text: $service.categories, prompt: Text("Nom de la catégorie"))
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment:.trailing)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                } header: {
                    Label("Nouvelle catégorie", systemImage: "rectangle.stack.badge.plus.fill")
                        .font(.caption)
                } footer: {
                    Text("Pour créer et attribuer plusieurs catégories, séparer les catégories par ;")
                        .font(.caption2)
                }
            case .existing:
                //MARK: Choose one caterory in existing panel
                //all existing categories to simplify filling
                Section {
                    List(articles.GetCategories().sorted(by: <), id: \.self, selection: $checkCategories) { c in
                        Label(c, systemImage: checkCategories.contains(c) ?  "checkmark.circle.fill" : "circle")
                            .tint(.white)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.2, blendDuration: 0.2)) {
                                    //Add category in the check categories array
                                    if checkCategories.contains(c){
                                        checkCategories.remove(c)
                                    }else{
                                        checkCategories.update(with: c)
                                    }
                                }
                                
                            }
                    }
                    .frame(maxHeight: 200)
                } header: {
                    Text("Selection de catégories")
                } footer: {
                    Text("Vous pouvez cocher les cercles pour attribuer plusieurs catégories à un article. Pour créer un nouvel article passer à l'onglet \(Text("Créer Catégorie").italic().underline(color: .blue))")
                }
                    
            case .none:
                Text("Choisir comment vous souhaiter attibuer une catégorie")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            
            Section("Prix de l'article et délai de traitement") {
                HStack{
                    Text("Prix : ")
                    Spacer(minLength: 100)
                    TextField("Prix", text: .init(get: {
                        price
                    }, set: { Value in
                        price = Value.filter({$0.isNumber || $0 == "."})
                        if !price.isEmpty{
                            service.cost = Decimal(string: price)!
                        }
                    }))
                    .keyboardType(.decimalPad)
                }
                .frame(maxWidth: .infinity)
                
                //MARK: Days selector
                Picker("Nombre de jours requis", selection: $service.time) {
                    ForEach(0..<100){day in
                        Text("\(day)")
                            .font(.caption)
                    }
                }
                .pickerStyle(.automatic)
            }
            Section {
                if description{
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
            } header: {
                //message associé
                Toggle(isOn: $description) {
                    Text("description ?")
                        .font(.custom("BebasNeue", size: 20))
                }
                
                .onChange(of: description) { V in
                    if V{
                        service.description = "." // Reset description if the button is pressed after text
                    }
                }
            } footer: {
                Text("La description est affichée sur la page d'un article. Elle permet de mieux comprendre le service.")
            }
            
            Section(){
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(articles.images.keys.sorted(by: <), id: \.self) { name in
                            Image(uiImage: articles.images[name]!)
                                .resizable()
                                .frame(width: 80, height:80*(16/9))
                                
                                .padding()
                                .onTapGesture {
                                    service.illustration = name
                                }
                                .scaleEffect(service.illustration == name ? 1.2: 1)
                                .grayscale(service.illustration == name ? 0 : 1)
                                .shadow(color: Color("xpress"), radius: service.illustration == name ? 10: 0)
                        }
                    }
                }
            }
        header:{
            Text("Illustration et affichage")
        }
            footer: {
                VStack(alignment:.leading){
                    Text("Vous pouvez sélectionner une image déjà présente dans l'application pour l'associer à un service")
                    Button {
                        withAnimation {
                            showingImagePicker = true
                        }
                    } label: {
                        Label("Choisir une nouvelle image", systemImage: "photo.badge.plus.fill")
                            .font(.caption)
                    }
                }
            }
            if mode == .update{
                Button("Supprimer l'article"){
                    Task{
                        let t = await service.Delete()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .listStyle(.automatic)
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.large)
        .submitLabel(.send)
        .onSubmit({
            SendArticle()
        })
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePickerView(selectedImage: $inputImage)
        })
        .toolbar(content: {
                Button {
                    SendArticle()
                } label: {
                    Text("Mettre à jour")
                }
                .buttonStyle(.borderedProminent)
        })
        .task{
            let _ = await articles.fetch()
        }
    }
    func SendArticle(){
        //MARK: This view is an update and an add view according to the selected mode
        appSettings.loading = true
        switch mode {
        case .update:
            Task{
                let response = await service.Put_Service()
                let _ = await articles.fetch()
                if response{
                    alerte.NewNotification(.amber, "Service \(service.name) correctement ajouté", UIImage(systemName: "plus.circle.fill"))
                }
            }
        case .new:
            Task{
               //Push the service with an image
                appSettings.connection_error = !(await articles.PushService(inputImage))
                if !appSettings.connection_error{
                    //Show notification
                    alerte.NewNotification(.amber, "Nouvel article ajouté", UIImage(systemName: "cart.badge.plus.fill"))
                    appSettings.connection_error = !(await articles.fetch())
                }
            }
        case nil:
            break
        }
        appSettings.loading = false
        presentationMode.wrappedValue.dismiss()
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
