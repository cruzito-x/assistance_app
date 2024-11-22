import SwiftUI
import FirebaseFirestore

struct AttendanceListView: View {
    @State private var attendanceRecords: [AttendanceRecord] = []
    @State private var tutors: [String: String] = [:] // tutor_id -> tutor_name
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Registros de Asistencia")
            
            if isLoading {
                ProgressView("Cargando registros...")
            } else {
                ScrollView {
                    ForEach(attendanceRecords) { record in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(record.studentName) - \(record.courseID)")
                                    .font(.headline)
                                Text("Docente: \(tutors[record.tutorID] ?? "Sin Docente")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if record.isPresent {
                                Text("P")
                                    .padding(.horizontal)
                                    .foregroundColor(.green)
                            } else {
                                Text("F")
                                    .padding(.horizontal)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
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
        .onAppear(perform: fetchAttendanceData)
        .padding()
    }
    
    private func fetchAttendanceData() {
        isLoading = true
        let db = Firestore.firestore()
        
        // Fetch tutors first
        db.collection("tutors").getDocuments { tutorsSnapshot, error in
            guard let tutorsSnapshot = tutorsSnapshot, error == nil else {
                print("Error al cargar los tutores: \(error?.localizedDescription ?? "")")
                isLoading = false
                return
            }
            
            // Map tutor_id to tutor_name
            for document in tutorsSnapshot.documents {
                let data = document.data()
                if let tutorID = data["id"] as? String, let tutorName = data["name"] as? String {
                    tutors[tutorID] = tutorName
                }
            }
            
            // Fetch attendance records
            db.collection("QR_assistance").getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error al cargar los registros de asistencia: \(error?.localizedDescription ?? "")")
                    isLoading = false
                    return
                }
                
                var records: [AttendanceRecord] = []
                for document in snapshot.documents {
                    let data = document.data()
                    let record = AttendanceRecord(
                        id: document.documentID,
                        studentName: data["name"] as? String ?? "Desconocido",
                        courseID: data["course_id"] as? String ?? "Sin curso",
                        tutorID: data["tutor_id"] as? String ?? "",
                        isPresent: data["is_present"] as? Bool ?? false
                    )
                    records.append(record)
                }
                
                attendanceRecords = records
                isLoading = false
            }
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

// AttendanceRecord model to represent each record
struct AttendanceRecord: Identifiable {
    var id: String
    var studentName: String
    var courseID: String
    var tutorID: String
    var isPresent: Bool
}

