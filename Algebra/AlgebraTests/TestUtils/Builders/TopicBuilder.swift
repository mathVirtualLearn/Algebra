@testable import Algebra

struct TopicBuilder {
    private var id = "equations"
    private var title = "Ecuaciones"
    private var subtitle = "Primer y segundo grado"
    private var systemImage = "function"

    func with(id: String) -> Self { var c = self; c.id = id; return c }
    func with(title: String) -> Self { var c = self; c.title = title; return c }
    func with(subtitle: String) -> Self { var c = self; c.subtitle = subtitle; return c }
    func with(systemImage: String) -> Self { var c = self; c.systemImage = systemImage; return c }

    func build() -> Topic {
        Topic(id: id, title: title, subtitle: subtitle, systemImage: systemImage)
    }
}
