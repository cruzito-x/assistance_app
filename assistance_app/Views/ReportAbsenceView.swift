import SwiftUI

struct ReportAbsenceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedStudent = "José Miguel Mejía Acevedo"
    @State private var reason = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Reportar Faltas")
            
            Picker("Selecciona un estudiante", selection: $selectedStudent) {
                Text("José Miguel Mejía Acevedo").tag("José Miguel Mejía Acevedo")
                // Agrega más opciones aquí
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("Describa el motivo de la inasistencia", text: $reason)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    Label("Adjuntar constancia", systemImage: "plus.circle")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: {}) {
                    Text("Reportar Asistencia")
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color("MainColor"))
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
