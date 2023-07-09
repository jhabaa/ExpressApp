//
//  CommandAllView.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 02/05/2022.
//  Vue du Calendrier avec selection des tâches associées aux jours.
//  Disponible uniquement en mode Administrateur
//

/**
            Un click sur une tâche affiche un menu détaillé de la tâche. Une récupération est orange et un retour en vert.
    La page ManageCommand est alors ouverte.
 */

import SwiftUI

struct CommandAllView: View {
    @State var selectedDate:Date = Date.init()
    @Namespace var namespace:Namespace.ID
    @EnvironmentObject var fetchModel : FetchModels
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var article:Article
    @State var commandList:[GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @State var selectedCommand:Command = Command.init()
    @State var showDetailCommand:Bool = false
    @State var details_command:Bool = false
    @EnvironmentObject var userdata:UserData
    @State  var currentDate : Date = Date()
    @State var currentMonth:Int = 0
    @State var days = ["lun","mar","mer","jeu","ven"]
    @State var commands_per_hour:[Int:[Command]]=[:]
    var body: some View {
        GeometryReader { GeometryProxy in
            let size = GeometryProxy.size
            let minY = GeometryProxy.frame(in: .named("calendar")).minY
            List {
                /*
                    CalendarPart(size)
                        
                        
                        .padding(0)
                        .listRowSeparator(Visibility.hidden)
                */
                Section() {
                    ForEach(commands_per_hour.keys.sorted(by: {$0 < $1}), id: \.self) { hour in
                        
                        Section {
                            VStack {
                                ForEach(commands_per_hour[hour]!, id: \.self) { com in
                                    //Guess if it's get day or not
                                    let state:Bool = com.enter_date == selectedDate.mySQLFormat() ? true : false
                                    
                                    //command card
                                    VStack(alignment:.leading ,spacing:5){
                                        HStack {
                                            HStack{
                                                Text("\(utilisateur.userWithId(com.user!).surname)")
                                                    .monospacedDigit()
                                                    .font(.title3.bold())
                                                Text("\(utilisateur.userWithId(com.user!).name)")
                                                    .monospacedDigit()
                                                    .font(.title2)
                                            }
                                            .padding(.horizontal)
                                            Spacer()
                                            
                                        }
                                        .padding(.vertical, 5)
                                        
                                        Text("\(state ? "Récupérer":"Déposer") commande # \(com.id)")
                                            .font(.caption)
                                            .opacity(0.7)
                                        
                                        HStack{
                                            VStack{
                                                Text("\(com.infos.isEmpty ? utilisateur.userWithId(com.user!).adress : com.infos)")
                                                    .font(.caption2)
                                            }
                                            Spacer()
                                            //Prix
                                            Text(com.cost.formatted(.currency(code:"eur")))
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(height:100)
                                    .background(state ? Color.blue.opacity(0.2).gradient : Color.red.opacity(0.2).gradient)
                                    //.shadow(radius: 1)
                                    //.ignoresSafeArea(.horizontal)
                                    .padding(.horizontal)
                                    
                                    .onTapGesture {
                                        //To the trick : lets open the command interface
                                        //selectedCommand = com
                                        commande.services = commande.ReadCommand_List(list: com.services_quantity, article: article).services
                                        commande.editMode(com)
                                    }
                                }
                            }
                            
                            
                            .ignoresSafeArea(edges: .horizontal)
                        } header: {
                            if !commands_per_hour[hour]!.isEmpty{
                                Text("\(hour)h")
                            }
                            
                        }
                    }
                }header:{
                    CalendarPart(size)
                    Text(
                        "Programme du \(selectedDate.dateUserfriendly())"
                    )
                    .padding(.top, 50)
                }
                
                
            }
           .listStyle(.plain)
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .background(LinearGradient(colors: [Color("xpress").opacity(1),Color("fond").opacity(0.0)], startPoint: .top, endPoint: .center))
            .onChange(of: currentMonth) { newValue in
                //Mise à jour du mois
                withAnimation(.spring()) {
                    currentDate = getCurrentMonth(currentMonth: currentMonth)
                }
                
            }
            .onChange(of: minY) { V in
                print(minY)
            }
            if commande.edit{
                CommandDetailView(userdata: _userdata)
            }
            
        }
        
        .background(.ultraThinMaterial)
        .onAppear{
            Task{
                commande.fetch()
                utilisateur.fetch()
                commands_per_hour = commande.Commands_Hours_Dict(date: selectedDate)
            }
           
            
        }
        
    }
    @ViewBuilder
    public func CalendarPart(_ size:CGSize) -> some View{
            //let size = $0.size
       
        
        VStack(){
            let cols = [GridItem(.fixed(50)), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

                
                //Calendar
                LazyVGrid(columns:cols, pinnedViews:PinnedScrollableViews.sectionHeaders) {
                    
                    Section {
                        
                        ForEach(days, id: \.self) { day in
                            Text(day)
                        }
                        
                        ForEach(extractDates(currentMonth: currentMonth)){value in
                                //CadView(value: value)
                            if (value.day == -1){
                                    Text("")
                                   // .disabled(false)
                            }else{
                                VStack{
                                    Text("\(value.day)")
                                        .monospacedDigit()
                                        .padding(5)
                                        .frame(width:50)
                                        .background(value.date == selectedDate ? .black : .blue.opacity(0))
                                        // Lets set a fixed size
                                        
                                        
                                        .foregroundColor(value.date == selectedDate ? .white : .primary)
                                        .clipShape(Circle())
                                        .overlay(alignment: .center) {
                                            ZStack{
                                                if (commande.getToday(value.date)){
                                                    Circle().stroke(LinearGradient(colors: [.blue, .clear], startPoint:.leading, endPoint: .trailing))
                                                }
                                                if (commande.returnToday(value.date)){
                                                    Circle().stroke(LinearGradient(colors: [.red, .clear], startPoint:.trailing, endPoint: .leading))
                                                }
                                            }
                                        }
                                }
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedDate = value.date
                                        
                                            commands_per_hour = commande.Commands_Hours_Dict(date: selectedDate)
                                        }
                                        
                                        print(selectedDate)
                                    }
                            }
                     //   }
                        }
                    } header: {
                        //Mois et année
                        
                            HStack{
                                //Bouton du mois précédent
                                
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .frame(width:30)
                                    .scaledToFit()
                                    .clipped()
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                        currentMonth -= 1
                                    }
                                }
                                Spacer()
                                //Month and year
                                HStack(alignment:.center){
                                   
                                    Text(extraData(a: currentDate)[1]).font(.title2.bold())
                                    Text(extraData(a: currentDate)[0])
                                        .fontWeight(.semibold)
                                }.padding(.horizontal)
                                    
                                    .containerShape(RoundedRectangle(cornerRadius: 30))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                                    .frame(width:30)
                                    .scaledToFill()
                                    .clipped()
                                    .onTapGesture {
                                    withAnimation(.spring()) {
                                        currentMonth += 1
                                        getCurrentMonth(currentMonth: currentMonth)
                                    }
                                }
                                
                            }.frame(maxWidth: size.width, alignment: SwiftUI.Alignment.center)
                            .padding(.horizontal)
                        //
                        
                    }
                }
                //.padding(.vertical)
                .ignoresSafeArea(.all)
                .frame(width:size.width, alignment: SwiftUI.Alignment.top)
                .padding(.top, 50)
            }
            
    }
    
    @ViewBuilder
    public func CadView(value:DateValue) -> some View{
        VStack{
            if value.day != -1{
                //Current date c'est la date du jour
                //Selected Date la date souhaitée par l'utilisateur
                if isSameDay(date1: selectedDate, date2: value.date){
                    VStack{
                        Text(value.day.formatted()).bold().scaledToFit()
                            .padding()
                            .background(.white)
                            .clipShape(Circle())
                            .padding(10)
                            .foregroundColor(.blue)
                        Text(value.date.formatted(date: Foundation.Date.FormatStyle.DateStyle.complete, time: .omitted).prefix(3)).foregroundColor(.white).padding([.bottom])
                            .animation(.easeInOut, value: value.date)
                    }
                    .background(.blue)
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                }
                else{
                    
                    
                    VStack{
                        Text(value.day.formatted()).scaledToFit()
                            .padding()
                            .background(.white)
                            .clipShape(Circle())
                            .animation(.easeInOut, value: value.date)
                            //.padding(10)
                        
                        Text(value.date.formatted(date: Foundation.Date.FormatStyle.DateStyle.complete, time: .omitted).prefix(3)).foregroundColor(.blue).padding([.bottom])
                            .animation(.easeInOut, value: value.date)
                    }
                    .fixedSize()
                    .shadow(radius: 3)
                    .foregroundColor(.blue)
                }
                //introduire le code pour vérifier si la date est libre dans la DB
            }
        }
    }
}
///fonction qui recupère le jour en lettre d'une date
func getDay(date:Date) -> String{
    var result:String = ""
    result = String(date.formatted(date: .complete, time: .omitted).split(separator: ",")[0])
    return result
}

struct Previews_CommandAllView_Previews: PreviewProvider {
    static var previews: some View {
        CommandAllView()
            .environmentObject(UserData())
            .environmentObject(FetchModels())
            .environmentObject(Utilisateur())
            .environmentObject(Commande())
            .environmentObject(Article())
    }
}
