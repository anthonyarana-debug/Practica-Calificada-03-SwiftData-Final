import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: [SortDescriptor(\Docente.nombre), SortDescriptor(\Docente.apellido),
                  SortDescriptor(\Docente.correo)]) private var docentes: [Docente]
    @State private var busqueda = ""
    @State private var creando = false
    @State private var seleccionado: Docente?
    @State private var errorBorrado: String?

    private var resultados: [Docente] {
        let texto = busqueda.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return docentes }
        return docentes.filter { docente in
            ["\(docente.nombre) \(docente.apellido)", docente.especialidad, docente.correo]
                .contains { $0.localizedStandardContains(texto) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search teachers...", text: $busqueda)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    if !busqueda.isEmpty {
                        Button { busqueda = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                List(resultados) { docente in
                    Button {
                        seleccionado = docente
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(docente.nombre) \(docente.apellido)").font(.headline)
                            Text(docente.especialidad).font(.subheadline).foregroundStyle(.blue)
                            Text(docente.correo).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("teacher-\(docente.correo)")
                    .swipeActions {
                        Button("Delete", role: .destructive) { eliminar(docente) }
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Teachers")
            .toolbar {
                Button { creando = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Teacher")
            }
            .sheet(isPresented: $creando) { FormularioDocente() }
            .sheet(item: $seleccionado) { docente in FormularioDocente(docente: docente) }
            .alert("Could not delete teacher", isPresented: Binding(
                get: { errorBorrado != nil }, set: { if !$0 { errorBorrado = nil } }
            )) {
                Button("OK") {}
            } message: { Text(errorBorrado ?? "") }
        }
    }

    private func eliminar(_ docente: Docente) {
        do {
            try contexto.transaction { contexto.delete(docente) }
        } catch {
            contexto.rollback()
            errorBorrado = error.localizedDescription
        }
    }
}
