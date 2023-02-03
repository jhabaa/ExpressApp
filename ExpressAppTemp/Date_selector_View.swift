//
//  Date_selector_View.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI

//My Date PickerStyle
struct express_date_style:DatePickerStyle{
    func makeBody(configuration: Configuration) -> some View {
        var calendar = Calendar.current
        HStack{
            DatePicker("", selection: configuration.self.$selection, in: configuration.minimumDate! ... configuration.maximumDate!, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "fr"))
                .datePickerStyle(CompactDatePickerStyle())
                .onAppear{
                    //Sort dates
                    var days = configuration.selection.GetAllDates().compactMap { date -> DateValue
                        in
                        //getting Day
                        let day = calendar.component(.day, from: date)
                        //excluding weekends
                        let weekend = calendar.component(.weekday, from: date)
                        if weekend != 1 && weekend != 7 {
                            return DateValue(day: day, date: date)
                        }
                        return DateValue(day: -0, date: date)
                        
                    }
                    //On ajuiste le jour à la date
                    let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
                    print("first day week \(firstWeekDay)")
                    for _ in 1..<firstWeekDay - 1{
                        days.insert(DateValue(day: -1, date: Date()), at: 0)
                    }
                    //delete values with 0 which are week ends
                    days = days.filter{$0.day != 0}
                    calendar = Calendar(identifier: .gregorian)
                    calendar.locale = Locale(identifier: "fr")
                    var newRange = Date() ... Date.distantFuture
                    
                    var excludedComponents = DateComponents(weekday: 4)
                }
        }
    }
}

struct Date_selector_View: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchmodel:FetchModels
    @State var dateIn:Date = Date()
    @State var dateOut:Date = Date()
    @Binding var show:Bool
    @State var currentMonth:Int = 0
    @State var currentMonth_2:Int = 0
    @State var fill_date_in:Bool = false
    @State var fill_date_out:Bool = false
    @Namespace var selected_date:Namespace.ID
    @State var time_to_wait:Int = 1
    @State var date_limit:Date=Date()
    @State var adress_modifier:Bool = false
    @State var adress_is_valid:Bool = false
    @State var sure_to_command:Bool = false
    @Binding var command_id:Int
    //@Binding var command_passed:Bool
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack (spacing:0) {
                VStack(alignment:.center, spacing:0){
                    Text("Total")
                        .offset(y:10)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(userdata.Get_Cost_command().formatted(.currency(code: "EUR")))")
                        .font(.custom("Ubuntu", size: 40))
                    
                }
                .frame(width: size.width,height: 100, alignment:.bottom)
                .background(.ultraThinMaterial)
                List {
                    Section("Récupération") {
                        CalendarPart()
                    }
                    Section("Livraison") {
                        CalendarPart_2()
                    }
                    
                    Section {
                        
                    }header: {
                        VStack{
                            Text("Adresse")
                                .font(.callout)
                                .bold()
                            Text(userdata.currentUser.adress)
                                .font(.custom("Ubuntu", size: 15))
                                .multilineTextAlignment(.leading)
                        }
                    } footer: {
                        Text("Tapez pour modifer votre adresse")
                    }
                    .onTapGesture {
                        // sheet view to modify user adress
                        adress_modifier.toggle()
                    }
                }
                .listStyle(.sidebar)
                /*
                ScrollView() {
                    Text("Reception et Livraison")
                        .bold()
                    CalendarPart()
                    //Dates selection
                    CalendarPart_2()
                    //Addres check
                    HStack(alignment:.top){
                        Image(systemName: "location.fill")
                        //Adress
                        VStack{
                            Text("Adresse")
                                .font(.callout)
                                .bold()
                            Text(userdata.currentUser.ADDRESS_USER)
                                .font(.custom("Ubuntu", size: 15))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "pencil.line")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 20).stroke()
                    }
                    .onTapGesture {
                        // sheet view to modify user adress
                        adress_modifier.toggle()
                    }
                    //total again
                    HStack(alignment: .center) {
                        Text("Total")
                        Spacer()
                        Text(userdata.Get_Cost_command().formatted(.currency(code: "EUR")))
                            .bold()
                    }
                    .bold()
                    .padding(.horizontal)
                    
                    Divider()
                    
                    //Button to validate the command
                    
                        
                        .onTapGesture {
                            
                        }
                }*/
                .navigationTitle("Récupération & livraison")
            }
            .frame(maxWidth: size.width)
            .ignoresSafeArea(edges: .all)
            //Valid button in overlay like every others command
            .overlay(alignment: .bottom) {
                HStack{
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.frame(width: 50)
                        .frame(width: 50)
                        .onTapGesture {
                            withAnimation(.priceJump()){
                                show.toggle()
                            }
                        }
                    Text("Continuer")
                        .bold()
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            withAnimation(.priceJump()){
                                sure_to_command.toggle()
                            }
                        }
                        .disabled(!userdata.currentCommand.isValid)
                       
                        
                }
                .background(.thickMaterial)
                .clipShape(Capsule())
                .shadow(radius: 5)
                .padding(.bottom, 50)
            }
            
            //on appear, get the max treatment time
            .onAppear{
                time_to_wait = userdata.MaxDaysForCard(Command.current_cart)
            }
            //view to modify adress
            if adress_modifier{
                AdressEditView(_show: $adress_modifier)
            }
            
            // Are you sure that you want to validate this command ?
            if sure_to_command{
                Sure_to_command()
            }
            
               
        }
        .clipped()
        .edgesIgnoringSafeArea(.all)
    }
    @State var days:[String]=["lun","mar","mer","jeu","ven"]
    @ViewBuilder
    public func CalendarPart() -> some View{
        //let size = $0.size
        VStack(alignment: .center, spacing: 20) {
            //Mois et année
            
            LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]){
                //Bouton du mois précédent
                HStack(spacing:0){
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth-1))[1])")
                        .font(.caption2)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        currentMonth -= 1
                    }
                }
                .disabled(getCurrentMonth(currentMonth: currentMonth ) <= Date())
                //Month and year
                Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth))[1])")
                    .bold()
                    .overlay(alignment: .topTrailing) {
                        Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth))[0])")
                            .offset(y:-10)
                            .font(.caption2)
                    }
                
                HStack(spacing:0){
                    Text("\(extraData(a:getNextMonth(currentMonth: currentMonth))[1])")
                        .font(.caption2)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                }
                
                    .onTapGesture {
                        withAnimation(.spring()) {
                            currentMonth += 1
                            //getCurrentMonth(currentMonth: currentMonth)
                        }
                    }
                
            }.frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.center)
                .padding(.horizontal)
            //
            ScrollView(.horizontal){
                let cols = Array(repeating: GridItem(.flexible()), count: 1)
                //Calendar
                HStack{
                    Section {
                        ForEach(extractDates(currentMonth: currentMonth)){value in
                            //CadView(value: value)
                            if !(value.day == -1 || value.date < Date()){
                                VStack{
                                    Text("\(extraData(a:value.date)[2])")
                                    Text("\(value.day)")
                                        .monospacedDigit()
                                        .padding(5)
                                        .frame(width:50)
                                }
                                .background(value.date == dateIn ? .green : .primary.opacity(0.1))
                                // Lets set a fixed size
                                .foregroundColor(value.date == dateIn ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    dateIn = value.date
                                }
                            }
                        }
                    }
                    .onChange(of: dateIn) { _ in
                        Task{
                            await fetchmodel.FetchTimes(day:dateIn.mySQLFormat(), type: "in")
                            userdata.currentCommand.enter_date = dateIn.mySQLFormat()
                            userdata.currentCommand.return_date = fetchmodel.AddDaysToDate(date: dateIn, daysToAdd: userdata.MaxDaysForCard(userdata.cart)).mySQLFormat()
                            date_limit = dateIn.set_limit(time_to_wait)
                        }
                    }
                }
                
                
            }
            .cornerRadius(2)
            
            HStack {
                Picker(selection: $userdata.currentCommand.enter_time, label: Text("Creneaux")) {
                    ForEach(fetchmodel.TIMES_IN_AVAILABLES, id: \.self) { value in
                        Text("\(value)h à \(value + 1)h")
                            .tag("\(value)")
                    }
                }
                .foregroundColor(Color.primary)
                .labelsHidden()
            }
            .padding(2)
            .background()
            .clipShape(Capsule())
        }
        //.padding(.vertical, 10)
        //.background(.red)
    }
    
    @ViewBuilder
    public func Sure_to_command()->some View{
        GeometryReader { GeometryProxy in
            let size = GeometryProxy.size
            VStack{
                // I change my mind
                Button {
                    withAnimation(.priceJump()){
                        sure_to_command.toggle()
                    }
                } label: {
                    Text("Annuler")
                        .underline()
                        .foregroundColor(.gray)
                }

                // Recap card
                LazyVGrid(columns: [GridItem(),GridItem()]) {
                    // On the left side, we have the shipping adress
                    VStack{
                        Text("Adresse:")
                        Text(userdata.currentUser.adress)
                            .multilineTextAlignment(.leading)
                            
                    }
                    VStack(alignment:.trailing){
                        HStack(alignment:.center, spacing:0){
                            Text("Sous-total: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(userdata.Get_Cost_command().formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Livraison: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(userdata.currentCommand.delivery.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Reduction: -")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(userdata.currentCommand.discount.formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                        HStack(alignment:.center, spacing:0){
                            Text("Total: ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(userdata.Get_Cost_command().formatted(.currency(code: "EUR")))")
                                .font(.caption)
                                .bold()
                        }
                    }
                    
                    
                }
                .padding(.vertical, 20)
                .frame(width: size.width-30)
                .background(.thinMaterial)
                .cornerRadius(20, antialiased: true)
                .shadow(radius: 20)
                .overlay(alignment: .trailing) {
                    ZStack(alignment:.trailing){
                        ZStack(alignment:.trailing){
                            Rectangle().fill(Color("xpress")).frame(width: 10, height: 50)
                                .blur(radius: 2)
                            Rectangle().fill(RadialGradient(colors: [Color("xpress").opacity(0.6),Color("xpress").opacity(0.0)], center: .trailing, startRadius: 0, endRadius: 100)).frame(width: 100, height: 200)
                        }
                        ZStack(alignment: .topTrailing) {
                            Image("logo120")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                                .clipShape(Circle())
                                .offset(y:-100)
                            
                        }
                    }
                   
                    
                    
                        
                        
                }
                .padding()
                
                HStack {
                    Group{
                        Image(systemName: "arrow.right.circle.fill")
                            .padding(.trailing,5)
                            .animation(.logoAnimation(),value: sure_to_command)
                        Text("Valider")
                    }
                    .font(.system(size: 35))
                    .padding(.trailing,5)
                    
                }
                .background(Color("xpress"))
                .clipShape(Capsule())
                .shadow(radius: 5)
                .onTapGesture {
                    Task{
                        //Now validation of the command
                        userdata.currentCommand.sub_total = userdata.currentCommand.get_sub_total
                        userdata.currentCommand.cost = userdata.CommandCost()
                        userdata.currentCommand.user = userdata.currentUser.id
                        userdata.currentCommand.services_quantity = userdata.cartToString(Command.current_cart)
                        let r = await fetchmodel.PushCommand(commande: userdata.currentCommand)
                        DispatchQueue.main.async {
                            command_id = r
                            sure_to_command.toggle()
                            show.toggle()
                            userdata.command_confirmation = r == 0 ? false : true
                        }
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
            
                
        }
        .frame(alignment: .center)
        .background(.ultraThinMaterial)
    }
    //Shipping dates
    @ViewBuilder
    public func CalendarPart_2() -> some View{
        //let size = $0.size
        VStack(alignment: .center, spacing: 20) {
            //Mois et année
            LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]){
                //Bouton du mois précédent
                HStack(spacing:0){
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFit()
                        .clipped()
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2-1))[1])")
                        .font(.caption2)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        currentMonth_2 -= 1
                    }
                }
                .disabled(getCurrentMonth(currentMonth: currentMonth_2 ) <= date_limit)
                //Month and year
                Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2))[1])")
                    .bold()
                    .overlay(alignment: .topTrailing) {
                        Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2))[0])")
                            .offset(y:-10)
                            .font(.caption2)
                    }
                HStack{
                    Text("\(extraData(a:getCurrentMonth(currentMonth: currentMonth_2+1))[1])")
                        .font(.caption2)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width:30)
                        .scaledToFill()
                        .clipped()
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        currentMonth_2 += 1
                        getCurrentMonth(currentMonth: currentMonth_2)
                    }
                    }
                
            }.frame(maxWidth: .infinity, alignment: SwiftUI.Alignment.center)
                .padding(.horizontal)
            //
            ScrollView(.horizontal){
                let cols = Array(repeating: GridItem(.flexible()), count: 1)
                //Calendar
                HStack{
                    Section {
                        ForEach(extractDates(currentMonth: currentMonth_2)){value in
                            //CadView(value: value)
                            if (value.day == -1){
                                VStack{
                                    
                                }
                            }
                            if(value.date > date_limit && value.day != -1){
                                VStack{
                                    Text("\(extraData(a:value.date)[2])")
                                    Text("\(value.day)")
                                        .monospacedDigit()
                                        .padding(5)
                                        .frame(width:50)
                                }
                                .background(value.date == dateOut ? .green : .black.opacity(0.1))
                                // Lets set a fixed size
                                .foregroundColor(value.date == dateOut ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                .onTapGesture {
                                    dateOut = value.date
                                }
                            }
                            //   }
                        }
                    }
                    
                }
                
                
            }
            .cornerRadius(2)
            .onChange(of: dateOut) { _ in
                Task{
                    await fetchmodel.FetchTimes(day:dateIn.mySQLFormat(), type: "out")
                    userdata.currentCommand.return_date = dateOut.mySQLFormat()
                }
            }
            //.padding(.horizontal, 10)
            
            HStack {
                Picker(selection: $userdata.currentCommand.return_time, label: Text("Creneaux")) {
                    ForEach(fetchmodel.TIMES_OUT_AVAILABLES, id: \.self) { value in
                        Text("\(value)h à \(value + 1)h")
                            .tag("\(value)")
                    }
                }
                .foregroundColor(Color.primary)
                .labelsHidden()
            }
            .padding(2)
            .background()
            .clipShape(Capsule())
        }
        //.padding(.vertical, 10)
        //.background(.red)
    }
}

struct Date_selector_View_Previews: PreviewProvider {
    static var previews: some View {
        Date_selector_View(show: Binding.constant(true), command_id: .constant(124547))
            .environmentObject(FetchModels())
            .environmentObject(UserData())
    }
}
