import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("Logo")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color("MainColor"))
            
            Text("Inicio de Sesión")
                .font(.title)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 10) {
                TextField("Nombre de usuario", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("Iniciar sesión")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("MainColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
