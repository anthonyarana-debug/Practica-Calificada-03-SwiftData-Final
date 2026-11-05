import SwiftUI
import SwiftData

@main
struct LaboratorioDocentesApp: App {
    private let almacenamiento = Result {
        try ModelContainer(for: Docente.self, configurations: ModelConfiguration("Docentes"))
    }

    var body: some Scene {
        WindowGroup {
            switch almacenamiento {
            case .success(let contenedor):
                ContentView()
                    .modelContainer(contenedor)
            case .failure(let error):
                ContentUnavailableView("Teachers could not be loaded",
                                       systemImage: "externaldrive.badge.exclamationmark",
                                       description: Text(error.localizedDescription))
            }
        }
    }
}
