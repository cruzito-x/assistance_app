import SwiftUI

struct ManualAttendanceView: View {
    @State private var selectedStudent: String = ""
    @State private var students = [
        "Aguilar Cuellar, Andrés Gerardo",
        "Ramírez López, Josué Alexander",
        "López Méndez, Camila Sofía",
        "Martínez Ruiz, Alejandro David",
        "Pérez Gómez, Valeria Isabel"
    ]
    @State private var markedStudents: [String: Bool] = [:] // Seguimiento de asistencia
    
    var body: some View {
        VStack {
            HeaderView(title: "Registro de asistencia manual")
            .padding()
            
            Divider()
            
            // Lista de estudiantes + Botón de check
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(students, id: \.self) { student in
                        HStack {
                            Text(student)
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle(isOn: Binding<Bool>(
                                get: { markedStudents[student] ?? false },
                                set: { markedStudents[student] = $0 }
                            )) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Submit
            Button(action: {
                // Lógica 
            }) {
                Text("Marcar Asistencia")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("MainColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
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
