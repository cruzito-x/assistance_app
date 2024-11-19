import SwiftUI

struct ManageStudentsView: View {
    @State private var studentName: String = ""
    @State private var studentID: String = ""
    @State private var tutorName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Gestionar Estudiantes")
            
            GroupBox(label: Text("Estudiante")) {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Nombre del Estudiante", text: $studentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Carnet", text: $studentID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Tutor", text: $tutorName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
            }
            
            HStack {
                Button(action: {}) {
                    Text("Añadir a la nómina")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {}) {
                    Text("Quitar de la nómina")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    struct HeaderView: View {
        var title: String
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding()
        }
    }
}
