import SwiftUI

struct QRScanView: View {
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Registro por QR")
            
            Text("Para marcar su asistencia, acerque el código QR que se le ha asignado")
                .multilineTextAlignment(.center)
                .padding()
            
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .frame(width: 200, height: 200)
                .foregroundColor(Color("MainColor"))
            
            Text("¡Marcado Exitoso!")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Datos del estudiante:")
                .font(.subheadline)
            Text("Marco: Josué Alexander Ramírez López")
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
