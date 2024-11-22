import SwiftUI
import FirebaseFirestore

struct ManageStudentsView: View {
    @State private var studentName: String = ""
    @State private var studentID: String = ""
    @State private var tutorID: String = ""
    @State private var tutors: [(id: String, name: String)] = []
    @State private var selectedTutor: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Gestionar Estudiantes")
            
            GroupBox(label: Text("Estudiante")) {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Carnet", text: $studentID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
    
                    TextField("Nombre del Estudiante", text: $studentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Tutor", selection: $selectedTutor) {
                        ForEach(tutors, id: \.id) { tutor in
                            Text(tutor.name).tag(tutor.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
            }
            
            HStack {
                Button(action: saveStudentData) {
                    Text("Añadir a la nómina")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Acciones para quitar de la nómina, si se requieren
                }) {
                    Text("Quitar de la nómina")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear(perform: fetchTutors)
        .padding()
    }
    
    private func fetchTutors() {
        let db = Firestore.firestore()
        db.collection("tutors").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching tutors: \(error)")
                return
            }
            if let snapshot = snapshot {
                self.tutors = snapshot.documents.map { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let name = data["name"] as? String ?? ""
                    return (id: id, name: name)
                }
                if let firstTutor = tutors.first {
                    self.selectedTutor = firstTutor.id
                }
            }
        }
    }

    private func saveStudentData() {
        guard !studentName.isEmpty, !studentID.isEmpty, !selectedTutor.isEmpty else {
            print("All fields must be filled")
            return
        }

        let db = Firestore.firestore()
        let studentData: [String: Any] = [
            "course_id": selectedTutor,
            "id": studentID,
            "name": studentName,
            "tutor_id": selectedTutor
        ]

        db.collection("students").document(studentID).setData(studentData) { error in
            if let error = error {
                print("Error saving student data: \(error)")
            } else {
                print("Student data saved successfully!")
                clearFields()
            }
        }
    }
    
    private func clearFields() {
        studentName = ""
        studentID = ""
        selectedTutor = tutors.first?.id ?? ""
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
