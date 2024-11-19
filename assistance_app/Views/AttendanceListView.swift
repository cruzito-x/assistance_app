import SwiftUI

struct AttendanceListView: View {
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Registros de Asistencia")
            
            ScrollView {
                ForEach(0..<10, id: \.self) { _ in
                    HStack {
                        Text("Aguilar Cuellar, Andrés Gerardo")
                        Spacer()
                        Text("P").padding(.horizontal)
                        Text("F").padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Button(action: {}) {
                Text("Marcar asistencia")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("MainColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
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
