import SwiftUI
import FirebaseFirestore

struct ManualAttendanceView: View {
    @State private var students: [Students] = [] // Lista de estudiantes desde Firestore
    @State private var markedStudents: [String: Bool] = [:] // Seguimiento de asistencia
    @State private var alreadyMarkedStudents: Set<String> = [] // IDs de estudiantes ya registrados
    @State private var isLoading = true // Indicador de carga
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            HeaderView(title: "Registro de asistencia manual")
                .padding()

            Divider()

            if isLoading {
                ProgressView("Cargando estudiantes...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                // Lista de estudiantes con curso y toggle
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(students) { student in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(student.name)
                                        .foregroundColor(.primary)
                                    Text(student.courseName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle(isOn: Binding<Bool>(
                                    get: { markedStudents[student.id] ?? false },
                                    set: { newValue in
                                        if !alreadyMarkedStudents.contains(student.id) {
                                            markedStudents[student.id] = newValue
                                        }
                                    }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .disabled(alreadyMarkedStudents.contains(student.id)) // Deshabilitar si ya está marcado
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Botón para marcar asistencia
                Button(action: saveAttendance) {
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
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            fetchStudents()
            setupMidnightReset()
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

    // Función para cargar estudiantes desde Firestore
    private func fetchStudents() {
        let db = Firestore.firestore()
        isLoading = true
        errorMessage = nil

        db.collection("students").getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Error al cargar estudiantes: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let documents = snapshot?.documents else {
                self.errorMessage = "No se encontraron estudiantes."
                self.isLoading = false
                return
            }

            var fetchedStudents: [Students] = []
            let dispatchGroup = DispatchGroup()

            for document in documents {
                let data = document.data()
                guard let id = document.documentID as String?,
                      let name = data["name"] as? String,
                      let courseId = data["course_id"] as? String else {
                    continue
                }

                dispatchGroup.enter()
                // Obtener el nombre del curso
                db.collection("courses").document(courseId).getDocument { courseSnapshot, _ in
                    let courseName = courseSnapshot?.data()?["name"] as? String ?? "Curso no especificado"
                    fetchedStudents.append(Students(id: id, name: name, courseName: courseName))
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.students = fetchedStudents.sorted(by: { $0.name < $1.name })
                self.loadAttendanceStatus()
                self.isLoading = false
            }
        }
    }

    // Función para cargar el estado de asistencia
    private func loadAttendanceStatus() {
        let db = Firestore.firestore()

        db.collection("QR_assistance").getDocuments { snapshot, error in
            if let error = error {
                print("Error al cargar asistencia: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                if let studentId = data["student_id"] as? String {
                    self.alreadyMarkedStudents.insert(studentId)
                    self.markedStudents[studentId] = true
                }
            }
        }
    }

    // Función para guardar asistencia
    private func saveAttendance() {
        let db = Firestore.firestore()
        let timestamp = Date()

        for student in students {
            let isPresent = markedStudents[student.id] ?? false

            // Solo guardar asistencia si no está previamente registrada
            if isPresent && !alreadyMarkedStudents.contains(student.id) {
                let attendanceData: [String: Any] = [
                    "name": student.name,
                    "student_id": student.id,
                    "timestamp": timestamp
                ]

                db.collection("QR_assistance").addDocument(data: attendanceData) { error in
                    if let error = error {
                        print("Error al guardar asistencia para \(student.name): \(error.localizedDescription)")
                    } else {
                        alreadyMarkedStudents.insert(student.id) // Actualizar estado de marcado
                    }
                }
            }
        }
    }

    // Función para configurar el reinicio de asistencia a medianoche
    private func setupMidnightReset() {
        // Obtén la fecha y hora de la próxima medianoche
        if let midnightTime = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .strict) {
            // Calcula la diferencia de tiempo hasta la medianoche
            let timeInterval = midnightTime.timeIntervalSinceNow
            
            // Crea el temporizador para ejecutar la acción en la medianoche
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                self.resetAttendance() // Llama a la función directamente en el bloque
            }
        }
    }

    private func resetAttendance() {
        // Resetear estado de asistencia al llegar a medianoche
        for student in students {
            if !alreadyMarkedStudents.contains(student.id) {
                markedStudents[student.id] = false
            }
        }
    }
}

// Modelo de estudiante
struct Students: Identifiable {
    let id: String
    let name: String
    let courseName: String
}
