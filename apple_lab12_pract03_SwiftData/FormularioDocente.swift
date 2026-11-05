import SwiftUI
import SwiftData

struct FormularioDocente: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var cerrar
    private let docente: Docente?

    @State private var nombre: String
    @State private var apellido: String
    @State private var correo: String
    @State private var telefono: String
    @State private var nacimiento: Date
    @State private var especialidad: String
    @State private var contratacion: Date
    @State private var activo: Bool
    @State private var mensaje: String?

    init(docente: Docente? = nil) {
        self.docente = docente
        _nombre = State(initialValue: docente?.nombre ?? "")
        _apellido = State(initialValue: docente?.apellido ?? "")
        _correo = State(initialValue: docente?.correo ?? "")
        _telefono = State(initialValue: docente?.telefono ?? "")
        _nacimiento = State(initialValue: docente?.nacimiento ?? .now)
        _especialidad = State(initialValue: docente?.especialidad ?? "")
        _contratacion = State(initialValue: docente?.contratacion ?? .now)
        _activo = State(initialValue: docente?.activo ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $nombre)
                    TextField("Last Name", text: $apellido)
                    TextField("Email", text: $correo)
                        .keyboardType(.emailAddress).textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone", text: $telefono).keyboardType(.phonePad)
                    DatePicker("Date of Birth", selection: $nacimiento, in: ...Date.now,
                               displayedComponents: .date)
                }
                Section("Professional Information") {
                    TextField("Specialty", text: $especialidad)
                    DatePicker("Hire Date", selection: $contratacion, displayedComponents: .date)
                    Toggle("Active", isOn: $activo)
                }
                if let docente {
                    Section {
                        Button("Delete Teacher", role: .destructive) {
                            do {
                                try contexto.transaction { contexto.delete(docente) }
                                cerrar()
                            } catch {
                                contexto.rollback()
                                mensaje = error.localizedDescription
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(docente == nil ? "Add Teacher" : "Edit Teacher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { cerrar() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: guardar)
                }
            }
            .alert("Teacher information", isPresented: Binding(
                get: { mensaje != nil }, set: { if !$0 { mensaje = nil } }
            )) {
                Button("OK") {}
            } message: { Text(mensaje ?? "") }
        }
    }

    private func guardar() {
        let nombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let apellido = apellido.trimmingCharacters(in: .whitespacesAndNewlines)
        let especialidad = especialidad.trimmingCharacters(in: .whitespacesAndNewlines)
        let correo = correo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let telefono = telefono.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nombre.isEmpty, !apellido.isEmpty, !especialidad.isEmpty else {
            mensaje = "Enter the first name, last name and specialty."
            return
        }
        guard correo.range(of: #"^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$"#, options: .regularExpression) != nil else {
            mensaje = "Enter a valid email address."
            return
        }
        guard (7...15).contains(telefono.filter(\.isNumber).count),
              telefono.allSatisfy({ $0.isNumber || "+-() ".contains($0) }) else {
            mensaje = "Enter a phone number with 7 to 15 digits."
            return
        }
        guard Calendar.current.compare(nacimiento, to: contratacion, toGranularity: .day) != .orderedDescending else {
            mensaje = "Hire date must be on or after the date of birth."
            return
        }

        do {
            let filtro = FetchDescriptor<Docente>(predicate: #Predicate { $0.correo == correo })
            if let existente = try contexto.fetch(filtro).first,
               existente.persistentModelID != docente?.persistentModelID {
                mensaje = "A teacher with this email already exists."
                return
            }
            try contexto.transaction {
                if let docente {
                    docente.nombre = nombre
                    docente.apellido = apellido
                    docente.correo = correo
                    docente.telefono = telefono
                    docente.nacimiento = nacimiento
                    docente.especialidad = especialidad
                    docente.contratacion = contratacion
                    docente.activo = activo
                } else {
                    contexto.insert(Docente(nombre: nombre, apellido: apellido, correo: correo,
                                           telefono: telefono, nacimiento: nacimiento, especialidad: especialidad,
                                           contratacion: contratacion, activo: activo))
                }
            }
            cerrar()
        } catch {
            contexto.rollback()
            mensaje = error.localizedDescription
        }
    }
}
