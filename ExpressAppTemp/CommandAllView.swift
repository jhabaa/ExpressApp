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

enum DateSelectionMode {
case unique, range
}

struct CommandAllView: View {
    @State var selectedDate:Date = Date.init()
    @Namespace var namespace:Namespace.ID
    @Environment(\.colorScheme) var colorsheme
    @EnvironmentObject var fetchModel : FetchModels
    @EnvironmentObject var commande:Commande
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var article:Article
    @EnvironmentObject var daysOff:Days
    @EnvironmentObject var alerte:Alerte
    @State var commandList:[GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @State var selectedCommand:Command = Command()
    @State var showDetailCommand:Bool = false
    @State var details_command:Bool = false
    @EnvironmentObject var userdata:UserData
    @State  var currentDate : Date = Date()
    @State var currentMonth:Int = 0
    @State var days = ["lun","mar","mer","jeu","ven"]
    @State var commands_per_hour:[Int:[Command]]=[:]
    @State var WorkToday:Bool=true
    //Variables to add date as unavailable
    @State var startDate:Date = "2000/01/01".toDate()
    @State var endDate:Date = "2000/01/01".toDate()
    @State var selectDaysOff:Bool = false
    @State private var dates: Set<DateComponents> = []
    @State var daysSelectorView:Bool = false
    @State var DateUniqueSelector:Bool = false
    @State var datesBis:Set<DateComponents>=[]
    @State var commandeEditor:Bool = false
    var body: some View {
        GeometryReader { GeometryProxy in
            let size = GeometryProxy.size
            let minY = GeometryProxy.frame(in: .named("calendar")).minY
            List {
                Section() {
                    if WorkToday{
                        if (selectDaysOff){
                            // If no commands I can show the menu to add or del days off
                            Section{
                                HStack{
                                    if (!startDate.isEqualTo("2000/01/01")){
                                        Text("\(!endDate.isEqualTo("2000/01/01") ? "DU" : "LE")")
                                        VStack{
                                            Text("\(startDate.month)")
                                                .font(.custom("Gotham-Black", size: 20))
                                                .bold()
                                            Text("\(startDate.day)")
                                                .font(.custom("Ubuntu", size: 20))
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                    }
                                    
                                    
                                    if (!endDate.isEqualTo("2000/01/01")){
                                        Text("AU")
                                        VStack{
                                            Text("\(endDate.month)")
                                                .font(.custom("Gotham-Black", size: 20))
                                                .bold()
                                            Text("\(endDate.day)")
                                                .font(.custom("Ubuntu", size: 20))
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                    }
                                }
                                .padding()
                                
                                //Validate Button
                                if (!startDate.isEqualTo("2000/01/01") && endDate.isEqualTo("2000/01/01")){
                                    Button("Valider"){
                                        Task{
                                            let r = await daysOff.push(startDate)
                                            if r{
                                                startDate = "2000/01/01".toDate()
                                                endDate = "2000/01/01".toDate()
                                            }
                                            alerte.NewNotification(.amber, "\(startDate) ajouté aux jours fériés", UIImage(systemName: "calendar.badge.plus"))
                                            //update
                                            _ = await daysOff.Retrieve_daysOff()
                                        }
                                        selectDaysOff = false
                                    }
                                }
                                
                                if (startDate < endDate){
                                    Button("Valider"){
                                        Task{
                                            for d in startDate.datesTil(endDate){
                                                let r = await daysOff.push(d)
                                            }
                                            //update
                                            await daysOff.Retrieve_daysOff()
                                        }
                                        alerte.NewNotification(.amber, "Du \(startDate) au \(endDate) sont à présent fériés", UIImage(systemName: "calendar.badge.checkmark"))
                                        selectDaysOff = false
                                    }
                                }
                            }
                        }else{
                            
                            ForEach(commands_per_hour.keys.sorted(by: {$0 < $1}), id: \.self) { hour in
                                Section {
                                    VStack {
                                        ForEach(commands_per_hour[hour]!, id: \.self) { com in
                                            //Guess if it's get day or not
                                            let state:Bool = com.enter_date == selectedDate.mySQLFormat() ? true : false
                                            
                                            //command card
                                            
                                            HStack{
                                                //marker
                                                Rectangle().fill(!state ? .red : .blue)
                                                    .frame(maxWidth:5, maxHeight:.infinity)
                                                // Month and adress
                                                VStack{
                                                    Text("\(selectedDate.month)")
                                                        .font(.custom("Gotham-Black", size: 20))
                                                        .bold()
                                                    Text("\(selectedDate.day)")
                                                        .font(.custom("Ubuntu", size: 20))
                                                }
                                                .padding()
                                                .frame(height: 80)
                                                .background(.ultraThinMaterial)
                                                .padding(.trailing, 10)
                                                
                                                
                                                HStack{
                                                    //icons
                                                        Image(systemName: state ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                                    VStack(alignment:.leading){
                                                        Text("\(utilisateur.userWithId(com.user!).surname) \(utilisateur.userWithId(com.user!).name)")
                                                            .font(.custom("Gotham-Black", size: 20))
                                                        Text("\(utilisateur.userWithId(com.user!).adress)")
                                                            .font(.custom("Gotham-Black", size: 15))
                                                        Text("\(!state ? "Livrer" : "Récupérer")")
                                                            .font(.custom("Gotham-Black", size: 10))
                                                            .padding(3)
                                                            .background(!state ? .red : .blue)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                                .padding()
                                                .frame(height: 80)
                                                .background(.thinMaterial)
                                            }
                                            .onTapGesture {
                                                //To the trick : lets open the command interface
                                                selectedCommand = com
                                                //commande.editMode(com)
                                                commandeEditor = true
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
                        }
                        
                    }else{
                        VStack{
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .foregroundStyle(.red)
                            
                            Text("Ce jour est férié")
                                .font(.caption)
                            
                        }
                        
                        .frame(maxWidth: .infinity, alignment:.center)
                        .padding()
                        .background(.bar)
                    }
                    
                }header:{
                    //Calendrier
                    CalendarPart(size)
                    Text(
                        "Programme du \(selectedDate.dateUserfriendly())"
                    )
                    .padding(.top, 50)
                }
            }
            .listStyle(.inset)
            .listRowBackground(Rectangle().fill(.red))
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            
            
            .onChange(of: currentMonth) { newValue in
                //Mise à jour du mois
                withAnimation(.spring()) {
                    currentDate = getCurrentMonth(currentMonth: currentMonth)
                }
            }
            .onChange(of: minY) { V in
                print(minY)
            }
            if commandeEditor{
                CommandDetailView( commande: selectedCommand, show: $commandeEditor)
                    .background()
            }
            
            
            //MARK: Days selector View
            //Days off add sheet
            VStack{
                Toggle(DateUniqueSelector ? "Selection individuelles" : "Plage de dates", systemImage: "finger", isOn: $DateUniqueSelector)
                    .toggleStyle(.button)
                    .tint(.clear)
                    .foregroundStyle(.gray)
                MultiDatePicker("", selection: $dates )
                
                Button {
                    //MARK: Set dates as daysoff
                    if DateUniqueSelector{
                        dates.forEach { DateComponents in
                            Task{
                                await daysOff.push(DateComponents.date!)
                            }
                        }
                    }
                    else{
                        //Valid all between the min and the max selected date
                        let d1 = dates.min(by: {$0.date! < $1.date!})!.date //Find the minimum date
                        let d2 = dates.max(by: {$0.date! < $1.date!})!.date //Find the maximum date
                        for d in d1!.datesTil(d2!){
                            Task{
                                _ = await daysOff.push(d) //Foreach date between min and max, push it
                            }
                            
                        }
                        alerte.NewNotification(.amber, "Dates ajoutées aux jours fériés", UIImage(systemName: "calendar.badge.plus"))
                    }
                    //update
                    Task{
                        await daysOff.Retrieve_daysOff()
                    }
                    
                    
                } label: {
                    Text("Ajouter ces dates")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight:550, alignment:.leading)
            .background(.bar)
            .overlay(alignment: .topTrailing) {
                //MARK: Button to hide the days selector view
                Button {
                    withAnimation {
                        daysSelectorView.toggle()
                    }
                } label: {
                    Image(systemName: "xmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.horizontal)
                }

            }
            .offset(y: daysSelectorView ? 0 : -1000)
            .animation(.spring, value: daysSelectorView)
        }
        
        .background(.ultraThinMaterial)
        .onAppear{
            Task{
                commande.fetch()
                utilisateur.fetch()
                commands_per_hour = commande.Commands_Hours_Dict(date: selectedDate)
                _ = await daysOff.Retrieve_daysOff()
            }
            
            
        }
        
        
    }
    @State var deleteDayOff:Bool = false
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
                            ZStack{
                                Text("\(value.day)")
                                    .monospacedDigit()
                                    .padding(5)
                                    .frame(width:50)
                                    .background(value.date == selectedDate ? .blue : .blue.opacity(0))
                                // Lets set a fixed size
                                
                                
                                //.foregroundColor(value.date == selectedDate ? .white : .primary)
                                    .foregroundColor(daysOff.isNoWorkDay(value.date) ? .red : value.date == selectedDate ? .white : .primary)
                                    .clipShape(Circle())
                                    .onTapGesture(count: 2, perform: {
                                        Task{
                                            let _=await daysOff.remove(value.date)
                                            let _ = await daysOff.Retrieve_daysOff()
                                        }
                                        
                                    })
                                    .overlay(alignment: .center) {
                                        ZStack{
                                            if (commande.getToday(value.date)){
                                                Circle().stroke(LinearGradient(colors: [.blue, .clear], startPoint:.leading, endPoint: .trailing))
                                            }
                                            if (commande.returnToday(value.date)){
                                                Circle().stroke(LinearGradient(colors: [.red, .clear], startPoint:.trailing, endPoint: .leading))
                                            }
                                            if(value.date >= startDate && value.date <= endDate && selectDaysOff){
                                                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.blue.opacity(0.1))
                                            }
                                            
                                        }
                                    }
                                
                                
                            }
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    
                                    if (!selectDaysOff){
                                        WorkToday = !daysOff.isNoWorkDay(value.date)
                                        selectedDate = value.date
                                        
                                        commands_per_hour = commande.Commands_Hours_Dict(date: selectedDate)
                                    }else{
                                        // If the selected option is enable, just fill the first date. if another date is pressed fille the second one
                                        if (value.date < endDate || startDate.isEqualTo("2000/01/01")){
                                            //add to start date
                                            startDate = value.date
                                        }
                                        else{
                                            endDate = value.date
                                        }
                                    }
                                    
                                }
                                
                                print(selectedDate)
                            }
                        }
                    }
                } header: {
                    //Mois et année
                    HStack{
                        
                        Spacer()
                        Button("Ajouter congés"){
                            withAnimation (.easeInOut){
                                daysSelectorView.toggle()
                            }
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        
                    }
                    .padding(.horizontal)
                    .frame(maxWidth:.infinity,alignment: .leading)
                    .overlay(alignment: .bottomLeading) {
                        Text(extraData(a: currentDate)[0])
                            .font(.title)
                            .padding(.leading)
                            .foregroundStyle(colorsheme == .dark ? .white : .black, Color("xpress"))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    
                    
                    HStack{
                        //Bouton du mois précédent
                        
                        Text(getCurrentMonth(currentMonth: currentMonth-1).monthfull
                        )
                        .font(.title2)
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                currentMonth -= 1
                            }
                        }
                        Spacer()
                        //Month and year
                        HStack(alignment:.center){
                            
                            Text(extraData(a: currentDate)[1]).font(.title.bold())
                                .foregroundStyle(colorsheme == .dark ? .white : .black, Color("xpress"))
                                .opacity(1)
                                .minimumScaleFactor(0.4)
                                .lineLimit(1)
                            
                        }.padding(.horizontal)
                        
                            .containerShape(RoundedRectangle(cornerRadius: 30))
                        Spacer()
                        Text(getCurrentMonth(currentMonth: currentMonth+1).monthfull)
                            .font(.title2)
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    currentMonth += 1
                                    getCurrentMonth(currentMonth: currentMonth)
                                }
                            }
                        
                    }.frame(maxWidth: size.width, alignment: SwiftUI.Alignment.center)
                        .padding()
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
            .environmentObject(Days())
            .environmentObject(Alerte())
    }
}
