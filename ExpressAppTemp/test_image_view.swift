//
//  test_image_view.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 28/05/2023.
//

import SwiftUI

struct test_image_view: View {
    var body: some View {
        
            VStack{
                Image("back")
                    .resizable()
                    .scaledToFill()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
    }
}

struct test_image_view_Previews: PreviewProvider {
    static var previews: some View {
        test_image_view()
    }
}
