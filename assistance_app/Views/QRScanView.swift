import SwiftUI
import AVFoundation
import FirebaseFirestore

struct QRScanView: View {
    @State private var isShowingScanner = false
    @State private var scannedStudent: (id: String, name: String)? = nil
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Registro por QR")
            
            Text("Para marcar su asistencia, acerque el código QR que se le ha asignado")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                isShowingScanner = true
            }) {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(Color("MainColor"))
            }
            
            if let student = scannedStudent {
                Text("Marcado Exitoso!")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text("Datos del estudiante:")
                    .font(.subheadline)
                Text("Nombre: \(student.name)")
                Text("ID: \(student.id)")
            }
        }
        .padding()
        .sheet(isPresented: $isShowingScanner) {
            QRCodeScannerView { result in
                self.isShowingScanner = false
                switch result {
                case .success(let scannedData):
                    handleScannedData(scannedData)
                case .failure(let error):
                    print("Error al escanear: \(error)")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Asistencia registrada"),
                  message: Text("El estudiante \(scannedStudent?.name ?? "") ha sido registrado exitosamente."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleScannedData(_ scannedData: String) {
        // Simulamos que el código QR contiene el ID y nombre del estudiante
        let components = scannedData.split(separator: "|")
        guard components.count == 2 else {
            print("Formato de QR inválido")
            return
        }
        
        let studentID = String(components[0])
        let studentName = String(components[1])
        scannedStudent = (id: studentID, name: studentName)
        saveAttendanceToFirestore(studentID: studentID, studentName: studentName)
        showAlert = true
    }
    
    private func saveAttendanceToFirestore(studentID: String, studentName: String) {
        let db = Firestore.firestore()
        let attendanceData: [String: Any] = [
            "student_id": studentID,
            "name": studentName,
            "timestamp": Timestamp(date: Date())
        ]
        db.collection("QR_assistance").addDocument(data: attendanceData) { error in
            if let error = error {
                print("Error al guardar la asistencia: \(error)")
            } else {
                print("Asistencia registrada correctamente en Firestore.")
            }
        }
    }
}

struct QRCodeScannerView: UIViewControllerRepresentable {
    var onResult: (Result<String, Error>) -> Void
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.onResult(.success(stringValue))
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            context.coordinator.parent.onResult(.failure(NSError(domain: "No camera found", code: -1, userInfo: nil)))
            return viewController
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            context.coordinator.parent.onResult(.failure(error))
            return viewController
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            context.coordinator.parent.onResult(.failure(NSError(domain: "Can't add camera input", code: -1, userInfo: nil)))
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            context.coordinator.parent.onResult(.failure(NSError(domain: "Can't add metadata output", code: -1, userInfo: nil)))
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
