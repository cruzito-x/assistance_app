import SwiftUI
import Firebase

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

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

            VStack(alignment: .leading, spacing: 20) {
                TextField("Nombre de usuario", text: $username)
                    .padding(.bottom, 5)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    .padding(.horizontal)

                SecureField("Contraseña", text: $password)
                    .padding(.bottom, 5)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    .padding(.horizontal)
            }
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button(action: loginUser) {
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

    // Firebase Login Logic
    private func loginUser() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, rellena todos los campos."
            return
        }

        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                return
            }

            // Successful login
            errorMessage = ""
            // Navegar a otra vista si es necesario
        }
    }
}
