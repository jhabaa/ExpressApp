//
//  UserCard.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 27/10/2023.
//

import SwiftUI

struct UserCard: View {
    @State var user:User
    @State var width:CGFloat
    var body: some View {
        VStack{
            //MARK: Logo at the top
            HStack{
                Spacer()
                Text("Ex-PRESS")
                    .bold()
            }
            Spacer()
            //MARK: Phone number & mail
            VStack(alignment: .leading, spacing:0){
                //Phone number
                Text(user.phone)
                    .font(.custom("SadMachine", size: 40))
                
                Text(user.mail)
                    .font(.caption)
                    .foregroundStyle(.gray.gradient)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            
            //MARK: Adress
            Spacer()
            VStack(alignment:.leading){
                Text(user.adress)
                    .font(.caption)
                Text("Tapez pour modifier")
                    .font(.custom("Ubuntu", size: 10))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment:.leading)
            
        }
        .padding()
        .frame(maxWidth: width, minHeight:250, maxHeight: 250, alignment: .topLeading)
        .background{
            RoundedRectangle(cornerRadius: 20)
                .fill(.bar)
                .shadow(color: Color("xpress"), radius: 10)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("xpress").gradient.colorSpace(Gradient.ColorSpace.perceptual))
        }
        .padding()
        
    }
}

#Preview {
    UserCard(user: User(name: "John"), width: .infinity)
}
