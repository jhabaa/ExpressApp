//
//  Date_selector_View.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 18/04/2023.
//

import SwiftUI

enum stages {
case step1, step2, step3, step4, step5
}

/// Receiving Embeded UIScrollView from the swiftui Scriollview
struct SnapCarouselHelper:UIViewRepresentable{
    var pageWidth:CGFloat
    var pageCount:Int
    @Binding var index:Int
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let scrollview = uiView.superview?.superview?.superview  as? UIScrollView{
                scrollview.decelerationRate = .fast
                scrollview.delegate = context.coordinator
                context.coordinator.pageCount = pageCount
                context.coordinator.pageWidth = pageWidth
            }
        }
    }
    
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent:SnapCarouselHelper
        var pageCount:Int = 0
        var pageWidth:CGFloat = 0
        init(parent: SnapCarouselHelper) {
            self.parent = parent
        }
        func scrollViewDidScroll(_ scrollView : UIScrollView){
            
        }
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            /// Adding velocity too, this will make a perfect scroll anaimation
            let targetEnd = scrollView.contentOffset.x + (velocity.x * 60)
            let targetIndex = (targetEnd / pageWidth).rounded()
            //Updartin index
            let index = min(max(Int(targetIndex), 0), pageCount - 1)
            parent.index = index
            targetContentOffset.pointee.x = targetIndex * pageWidth
        }
    }
}

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
                    
                    for _ in 1..<firstWeekDay - 1{
                        days.insert(DateValue(day: -1, date: Date()), at: 0)
                    }
                    //delete values with 0 which are week ends
                    days = days.filter{$0.day != 0}
                    calendar = Calendar(identifier: .gregorian)
                    calendar.locale = Locale(identifier: "fr")
                    _ = Date() ... Date.distantFuture
                    
                    _ = DateComponents(weekday: 4)
                }
        }
    }
}

struct Date_selector_View: View {
    @EnvironmentObject var userdata:UserData
    @EnvironmentObject var fetchmodel:FetchModels
    @EnvironmentObject var commande:Commande
    @Environment(\.colorScheme) var colorscheme
    @EnvironmentObject var utilisateur:Utilisateur
    @EnvironmentObject var daysOff : Days
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
    @State var selectionPhase:Bool = true
    @State var stage:stages = .step1
    @EnvironmentObject var panier:Panier
    @State var slideValue=Int()
    @State var finalAmount = Int()
    @State var inTimes:[Int] = []
    //@Binding var command_passed:Bool
    @State var possibleTimesIn:[Int]=[]
    @State var possibleTimesOut:[Int]=[]
    @State var alertInfos:Bool = false
    var body: some View {
        GeometryReader {
            let size = $0.size

                ScrollView {
                    if stage == .step1 || stage == .step2{
                        Text("Selectionnez une date \npour la \(selectionPhase ? "récupération":"livraison") du linge")
                            .font(.custom("Ubuntu", size: 40))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment:.leading)
                            .padding(.top, 100)
                            .animation(.priceJump(), value: selectionPhase)
                    }else{
                        Divider()
                            .padding(.bottom, 80)
                    }
                        //MARK: Here we'll put 2 views to be able to slide between them
                    
                    if stage != .step4 && stage != .step5{
                        CalendarPart()
                            .frame(width: size.width)
                            .offset(y:CGFloat(slideValue))
                            .clipped()
                    }
                    if stage == .step4{
                        TimesPart(size)
                            .onChange(of: indexIn) { V in
                                //MARK: Assign values
                                commande.this.enter_time = String(V)
                            }
                            .onChange(of: indexOut) { V in
                                //MARK: Assign values
                                commande.this.return_time = String(V)
                            }
                    }
                    if stage == .step5{
                        Recap()
                        //MARK: Get sup infos here
                        VStack(spacing:0){
                            ZStack(alignment:.top){
                                Text("Informations supplémentaires")
                                    .font(.custom("BebasNeue", size: 20))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .offset(y:-20)
                                TextEditor(text: $commande.this.infos)
                                    .font(.custom("Ubuntu", size: 15))
                                    .padding()
                                    .background(.bar)
                                    .foregroundStyle(.gray)
                                    .frame(height:100)
                            }
                            .overlay(alignment:.bottomLeading) {
                                Text("Caractères restants : \(150 - commande.this.infos.count)")
                                    .font(.caption2)
                                    .foregroundStyle((150 - commande.this.infos.count) < 0 ? .red : .gray)
                            }
                        }
                        
                    }
            }
            
            //on appear, get the max treatment time
            .onAppear{
                time_to_wait = commande.daysNeeded()
                Task{
                   await daysOff.Retrieve_daysOff()
                }
            }
            //MARK: Header buttons
            HStack{
                Group{
                    Image(systemName: "chevron.backward")
                        .onTapGesture {
                            withAnimation(.priceJump()){
                                show.toggle()
                            }
                        }
                    Spacer()
                        
                    Image(systemName:"info.circle")
                        .onTapGesture {
                            withAnimation(.priceJump()){
                                alertInfos.toggle()
                            }
                        }
                }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .alert("Informations", isPresented: $alertInfos) {
                        Button {
                            //
                        } label: {
                            Text("ok")
                        }

                    } message: {

                            Text("Les dates de récupérations et de livraisons permettent une meilleure organisation. Si en plus vous êtes disponibles à d'autres moments, vous pouvez mentionner vos disponibilités dans les informations supplémentaires")
                    }

            }
            .offset(y:70)
            .padding(.horizontal)
            .frame(height: 0)
            
            //MARK: Actions buttons
            VStack(alignment: HorizontalAlignment.center, spacing: 2){
                Button(action: {
                    //Move to step 3 to choose hours
                    switch stage {
                    case .step1:
                        break
                    case .step2:
                        break
                    case .step3:
                        //MARK: Dates are ok. Move to the next step to choose times
                        Task{
                            possibleTimesIn = await fetchmodel.FetchTimes(day:dateIn.mySQLFormat())
                            possibleTimesOut = await fetchmodel.FetchTimes(day:dateOut.mySQLFormat())
                            //Assign firsts values of arrays ad default values
                            commande.this.enter_time = String(possibleTimesIn.first ?? 0)
                            commande.this.return_time = String(possibleTimesOut.first ?? 0)
                        }
                        stage = .step4
                        
                    case .step4:
                        //MARK: All is ok. Print the recap
                        stage = .step5
                    case .step5:
                        //Validate the command
                        Task{
                            await commande.validate(utilisateur)
                            let _ = await commande.PushCommand()
                        }
                    }
                }, label: {
                    Text("Continuer")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                })
                .padding()
                //.buttonBorderShape(RoundedRectangle(cornerRadius: 10))
                .buttonStyle(.borderedProminent)
                .offset(x:stage == .step3 || stage == .step4 || stage == .step5 ? 0 : 500)
                .disabled(commande.this.infos.count > 150)
                
                Button(action: {
                    //MARK: Reset the process
                    if stage == .step5{
                        //Cancel the current command
                        show = commande.erase()
                    }else{
                        dateIn = Date()
                        dateOut = Date()
                        stage = .step1
                    }
                    
                }, label: {
                    Label(stage == .step5 ? "Annuler la commande":"Réessayer", systemImage: stage == .step5 ? "xmark":"arrow.clockwise.circle" )
                        .foregroundStyle(.gray)
                })
                .padding(.bottom, 40)
           
            }
            .frame(maxHeight:.infinity,alignment: .bottom)
            
        }
        .clipped()
        .background{
            LinearGradient(colors: [
                colorscheme == .dark ? .black.opacity(1) : .white.opacity(1),
                colorscheme == .dark ? .black.opacity(0) : .white.opacity(0)
            ], startPoint: .top, endPoint: .bottom)
        }
        .background{
            RadialGradient(colors: [
                colorscheme == .dark ? Color("xpress") : Color("xpress"),
                colorscheme == .dark ? Color("xpress").opacity(0) : Color("xpress").opacity(0)
            ], center: .bottom, startRadius: 50, endRadius: 300)
        }
        .background(.bar)
        .edgesIgnoringSafeArea(.all)
        
    }
    @State private var indexIn = 0
    @State private var indexOut = 0
    @ViewBuilder
    public func TimesPart(_ screen:CGSize) -> some View{
        let _ = fetchmodel.TIMES_OUT_AVAILABLES
        let size = screen
        let pageWidth:CGFloat = size.width/3
        let timeWidth:CGFloat = 100
        let outCount = possibleTimesOut.count
        let inCount = possibleTimesIn.count
        Text("Quelle créneau \npour la \nrécupération ?")
            .font(.custom("Ubuntu", size: 30))
            .lineLimit(4, reservesSpace: false)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment:.leading)
            .padding(.leading)
            //MARK: Date selection for the enter date
            ScrollView(.horizontal,showsIndicators: false){
                HStack{
                    ForEach(possibleTimesIn, id: \.self) { v in
                            HStack(alignment:.center){
                                //MARK: Time in the best style
                                VStack(spacing:0){
                                    Text("de \(v)h")
                                        .font(.system(size: 20, weight: v == (indexIn+inCount) ? .bold : .thin))
                                        .animation(.easeInOut(duration: 0.4), value: indexIn)
                                    Text("à \(v+1)h")
                                }
                                .frame(width: timeWidth,height:100, alignment: .center)
                                .foregroundStyle(v == (indexIn+inCount) ? .blue : .gray)
                                .scaleEffect(v == (indexIn+inCount) ? 1.3 : 1)
                                .animation(.easeInOut(duration: 0.4), value: indexIn)
                            }
                            .frame(width: pageWidth, alignment: .center)
                        }
                }
                //Start from the center
                .padding(.horizontal, (size.width - pageWidth) / 2)
                .background{
                    SnapCarouselHelper(pageWidth: pageWidth, pageCount: inCount, index: $indexIn)
                }
            }
        //MARK: Scroll indice
        HStack{
            Group{
                Text("Scroll")
                Image(systemName: "arrowshape.left.arrowshape.right")
            }
                .foregroundStyle(.gray)
                .animation(.pulse(),value: show)
        }
        Text("Et \npour la \nlivraison ?")
            .font(.custom("Ubuntu", size: 30))
            .lineLimit(4, reservesSpace: false)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment:.leading)
            .padding(.leading)
        
        //MARK: Date selection for the return date
        ScrollView(.horizontal,showsIndicators: false){
            HStack{
                ForEach(possibleTimesOut, id: \.self) { v in
                        HStack(alignment:.center){
                            //MARK: Time in the best style
                            VStack(spacing:0){
                                Text("de \(v)h")
                                    .font(.system(size: 20, weight: v == (indexOut+outCount) ? .bold : .thin))
                                    .animation(.easeInOut(duration: 0.4), value: indexOut)
                                Text("à \(v+1)h")
                            }
                            .frame(width: timeWidth,height:100, alignment: .center)
                            .foregroundStyle(v == (indexOut+outCount) ? .blue : .gray)
                            .scaleEffect(v == (indexOut+outCount) ? 1.3 : 1)
                            .animation(.easeInOut(duration: 0.4), value: indexOut)
                        }
                        .frame(width: pageWidth, alignment: .center)
                    }
            }
            //Start from the center
            .padding(.horizontal, (size.width - pageWidth) / 2)
            .background{
                SnapCarouselHelper(pageWidth: pageWidth, pageCount: outCount, index: $indexOut)
            }
        }
        .onAppear(perform: {
            inTimes = fetchmodel.TIMES_IN_AVAILABLES
            
        })
    }
    
    @State var days:[String]=["lun","mar","mer","jeu","ven"]
    @ViewBuilder
    public func CalendarPart() -> some View{
        //let size = $0.size
        VStack(alignment: .leading, spacing:0) {
            //MARK: Header
            //Current Month and Year - important
            let thisMonth:Date = getCurrentMonth(currentMonth: currentMonth ) //Get Current Month
            let prevMonth:Date = getCurrentMonth(currentMonth: currentMonth - 1 )
            let nextMonth1:Date = getCurrentMonth(currentMonth: currentMonth + 1)
            let nextMonth2:Date = getCurrentMonth(currentMonth: currentMonth + 2)
            let _ = extraData(a:thisMonth)[0]
            let dark = colorscheme == .dark ? true : false
                VStack(alignment:.leading,spacing:0){
                    Text("\(extraData(a:thisMonth)[0])")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text(extraData(a:thisMonth)[1])
                        .font(.largeTitle)
                }
                .frame(width: .infinity, alignment: .leading)
                //MARK: Change dates cursors
                //Print One month before this one if possible
                HStack{
                    Group{
                        Button("\(Text(extraData(a:prevMonth)[1]))") {
                            withAnimation {
                                currentMonth -= 1
                            }
                        }
                        .scaleEffect(y: thisMonth <= Date() ? 0 : 1)
                        .disabled(thisMonth <= Date())
                        
                        Spacer()
                        Button("\(Text(extraData(a:nextMonth1)[1]))") {
                            withAnimation(.spring) {
                                currentMonth += 1
                            }
                        }
                        Button("\(Text(extraData(a:nextMonth2)[1]))") {
                            withAnimation(.spring) {
                                currentMonth += 2
                            }
                        }
                    }
                    .foregroundStyle(.gray)
                    .onAppear{
                        print(getWeekDays())
                    }
                }
            
                //MARK: Calendar
                LazyVGrid(columns: [GridItem(),GridItem(),GridItem(),GridItem(),GridItem()], alignment: .center) {
                    ForEach(getWeekDays(), id:\.self) { d in
                        Text(d)
                            .font(.title3)
                    }
                    //MARK: Here we set days with open circle down
                    ForEach(extractDates(currentMonth: currentMonth)){value in
                        //CadView(value: value)
                        if !(value.day == -1){
                            Button {
                                //MARK: Logic -> Id dateIn si default, I set the value to the dateIn variable. Else to the dateOut
                                switch stage {
                                case .step1:
                                    print("Test")
                                    dateIn = value.date
                                    selectionPhase.toggle()
                                    commande.setDateIn(value.date)
                                    stage = .step2
                                case .step2:
                                    dateOut = value.date
                                    commande.setDateOut(value.date)
                                    stage = .step3
                                case .step3: break // Nothing to do because button is disabled
                                    
                                case .step4:
                                    break
                                case .step5:
                                    break
                                }
                            } label: {
                                VStack{
                                    Group{
                                        Text("\(value.day)")
                                            .monospacedDigit()
                                            .padding(.horizontal,5)
                                            .frame(width:50)
                                            .bold()
                                            .foregroundStyle(value.date == dateIn || value.date == dateOut ? dark ? .black : .white : dark ? .white : .black)
                                            
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle((value.date == dateIn || value.date == dateOut) ? .blue : .clear)
                                    }
                                    .foregroundStyle(colorscheme == .dark ? .white : .black)
                                    .opacity(value.date < Date() || daysOff.isNoWorkDay(value.date)  || (value.date < date_limit ) ? 0.4 : 1)
                                    
                                    .animation(.spring, value: dateIn)
                                }
                                .padding(.vertical,4)
                                .background{
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(value.date == dateIn || value.date == dateOut ? colorscheme == .dark ? .white : .black : .clear)
                                }
                            }
                            .disabled(value.date < Date())
                            .disabled(daysOff.isNoWorkDay(value.date))
                            .disabled(value.date < date_limit)
                            .disabled(stage == .step3)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background{
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 40)
                .fill(.bar)
                .shadow(color: .gray, radius: 2)
        }
        .padding()
        .onChange(of: dateIn) { _ in
            Task{
                date_limit = dateIn.set_limit(time_to_wait)
                print(dateIn)
                print(dateOut)
            }
        }
    }
    
    @ViewBuilder
    public func Recap()->some View{
        ZStack(alignment:.top){
                //MARK: Header of recap
                Text("Recap")
                    .font(.custom("BebasNeue", size: 50))
                    .offset(y:-20)
            VStack(alignment:.leading){
                LazyVGrid(columns: [GridItem(.fixed(20)), GridItem(.flexible()),GridItem(.fixed(80)),GridItem(.fixed(80))], alignment: .leading, content: {

                    Group{
                        Text("Qté")
                        Text("Description")
                        Text("Prix")
                        Text("Total")
                    }
                    .font(.caption2)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    ForEach(commande.services.sorted(by: {$0.service.id < $1.service.id}), id: \.self){ achat in
                        Group{
                            
                            Text("\(achat.quantity)")
                            Text(achat.service.name)
                                
                            Text(achat.service.cost.formatted(.currency(code:"EUR")))
                            Text((achat.service.cost * Decimal(achat.quantity)).formatted(.currency(code:"EUR")))
                        }
                        .font(.caption2)
                    }
                    })
                .frame(maxWidth: .infinity)
                .padding()
                Text("Adresse")
                    .font(.caption)
                    .bold()
                Text(utilisateur.this.adress)
                    .font(.caption)
                    .foregroundStyle(.gray)
                LazyVGrid(columns: [GridItem(),GridItem()], alignment: .leading) {
                    Text("Sous-total: ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(commande.getCost.formatted(.currency(code: "EUR")))")
                        .font(.caption)
                        .bold()
                    Text("Livraison: ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(commande.this.delivery.formatted(.currency(code: "EUR")))")
                        .font(.caption)
                        .bold()
                    
                    Text("Reduction: ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("-\(commande.this.discount.formatted(.currency(code: "EUR")))")
                        .font(.caption)
                        .bold()
                    Divider()
                    VStack{
                        Text("Total à payer: ")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("\(commande.TotalCost.formatted(.currency(code: "EUR")))")
                            .font(.title)
                            .bold()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment:.leading)
            .background{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.bar)
            }
            .padding()
            
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
            .background{
                RoundedRectangle(cornerRadius: 25, style: RoundedCornerStyle.continuous)
                    .fill(Color("fond"))
            }
            .shadow(radius: 10)
            .padding()
    }
}

struct Date_selector_View_Previews: PreviewProvider {
    static var previews: some View {
        Date_selector_View(show: Binding.constant(true))
            .environmentObject(FetchModels())
            .environmentObject(UserData())
            .environmentObject(Panier())
            .environmentObject(Commande())
            .environmentObject(Utilisateur())
            .environmentObject(Coupons())
            .environmentObject(Days())
    }
}
