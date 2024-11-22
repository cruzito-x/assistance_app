import SwiftUI
import FirebaseAuth

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Menú Principal")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(spacing: 15) {
                    // Navegación a Reportar Faltas
                    NavigationLink(destination: ReportAbsenceView()) {
                        MenuButton(icon: "bell.fill", text: "Ver casos de faltas justificadas")
                    }
                    
                    // Navegación a Registro de Asistencia por QR
                    NavigationLink(destination: QRScanView()) {
                        MenuButton(icon: "qrcode", text: "Registro de asistencia por QR")
                    }
                    
                    // Navegación a Registro de Asistencia Manual
                    NavigationLink(destination: ManualAttendanceView()) {
                        MenuButton(icon: "square.and.pencil", text: "Registro de asistencia manual")
                    }
                    
                    // Navegación a Añadir o Quitar Estudiantes
                    NavigationLink(destination: ManageStudentsView()) {
                        MenuButton(icon: "person.3.fill", text: "Añadir o quitar estudiantes de la nómina")
                    }
                    
                    // Navegación a Ver Registros de Asistencia
                    NavigationLink(destination: AttendanceListView()) {
                        MenuButton(icon: "doc.text.fill", text: "Ver registros de asistencia")
                    }
    
                    // Navegación a Ver Registros de Asistencia
                    NavigationLink(destination: LoginView()) {
                        MenuButton(icon: "arrow.right.circle.fill", text: "Salir")
                        .onTapGesture {
                            Logout()
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct MenuButton: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding()
        .background(Color("MainColor"))
        .cornerRadius(10)
    }
}


private func Logout() {
    do {
        try Auth.auth().signOut()
    } catch let signOutError as NSError {
        print("Error al cerrar sesión:")
    }
}
