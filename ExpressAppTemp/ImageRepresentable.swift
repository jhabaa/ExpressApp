//
//  ImageRepresentable.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 03/04/2023.
//
import SwiftUI
import Foundation

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                if let imageData = uiImage.jpegData(compressionQuality: 0.5) {
                    uploadImage(imageData)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func uploadImage(_ imageData: Data) {
            let url = URL(string: "http://\(urlServer):\(urlPort)/uploadimage")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let params: [String: Any] = ["image": imageData.base64EncodedString()]
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                }
            }.resume()
        }
    }
}
