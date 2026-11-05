import Foundation
import SwiftData

@Model
final class Docente {
    var nombre: String
    var apellido: String
    @Attribute(.unique) var correo: String
    var telefono: String
    var nacimiento: Date
    var especialidad: String
    var contratacion: Date
    var activo: Bool

    init(nombre: String, apellido: String, correo: String, telefono: String,
         nacimiento: Date, especialidad: String, contratacion: Date, activo: Bool) {
        self.nombre = nombre
        self.apellido = apellido
        self.correo = correo
        self.telefono = telefono
        self.nacimiento = nacimiento
        self.especialidad = especialidad
        self.contratacion = contratacion
        self.activo = activo
    }
}
