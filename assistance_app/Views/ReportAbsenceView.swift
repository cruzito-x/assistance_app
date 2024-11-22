import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ReportAbsenceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var students: [Student] = [] // Lista de estudiantes desde Firestore
    @State private var selectedStudent: String = ""
    @State private var reason: String = ""
    @State private var showImagePicker = false
    @State private var imageData: Data? = nil // Imagen seleccionada
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Reportar Faltas")
            
            // Picker para seleccionar al estudiante
            Picker("Selecciona un estudiante", selection: $selectedStudent) {
                ForEach(students, id: \.id) { student in
                    Text(student.name).tag(student.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // TextField para descripción de la falta
            TextField("Describa el motivo de la inasistencia", text: $reason)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack(spacing: 20) {
                // Botón para adjuntar constancia
                Button(action: {
                    showImagePicker = true
                }) {
                    Label("Adjuntar constancia", systemImage: "plus.circle")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                // Botón para reportar la falta
                Button(action: reportAbsence) {
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
        .onAppear(perform: fetchStudents) // Cargar estudiantes al inicio
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Información"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(imageData: $imageData)
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
    
    // Función para obtener estudiantes desde Firestore
    private func fetchStudents() {
        let db = Firestore.firestore()
        db.collection("students").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error al cargar estudiantes: \(error?.localizedDescription ?? "")")
                return
            }
            
            var fetchedStudents: [Student] = []
            for document in snapshot.documents {
                let data = document.data()
                if let id = document.documentID as String?,
                   let name = data["name"] as? String {
                    fetchedStudents.append(Student(id: id, name: name))
                }
            }
            students = fetchedStudents
            if let firstStudent = students.first {
                selectedStudent = firstStudent.id
            }
        }
    }
    
    // Función para reportar la falta
    private func reportAbsence() {
        guard !selectedStudent.isEmpty, !reason.isEmpty else {
            alertMessage = "Por favor, completa todos los campos."
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        var absenceData: [String: Any] = [
            "student_id": selectedStudent,
            "description": reason,
            "timestamp": Date()
        ]
        
        // Subir imagen a Firebase Storage si existe
        if let imageData = imageData {
            let storageRef = Storage.storage().reference()
            let imagePath = "absence_images/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(imagePath)
            
            fileRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error al subir la imagen: \(error.localizedDescription)")
                    alertMessage = "Error al subir la constancia."
                    showAlert = true
                    return
                }
                
                // Añadir ruta de la imagen al registro en Firestore
                fileRef.downloadURL { url, error in
                    guard let url = url, error == nil else {
                        print("Error al obtener URL de la imagen: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    absenceData["path"] = url.absoluteString
                    saveAbsenceData(absenceData: absenceData, db: db)
                }
            }
        } else {
            saveAbsenceData(absenceData: absenceData, db: db)
        }
    }
    
    // Guardar los datos de la falta en Firestore
    private func saveAbsenceData(absenceData: [String: Any], db: Firestore) {
        db.collection("absences").addDocument(data: absenceData) { error in
            if let error = error {
                print("Error al guardar la falta: \(error.localizedDescription)")
                alertMessage = "Hubo un problema al registrar la falta."
            } else {
                alertMessage = "Falta justificada registrada satisfactoriamente!"
            }
            showAlert = true
        }
    }
}

// Modelo de estudiante
struct Student: Identifiable {
    let id: String
    let name: String
}

// ImagePicker para seleccionar imágenes
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                parent.imageData = imageData
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
