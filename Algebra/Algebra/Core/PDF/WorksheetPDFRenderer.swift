import SwiftMath
import UIKit

@MainActor
protocol WorksheetPDFRenderer {
    func render(title: String, items: [WorksheetItem], includeSolutions: Bool) -> Data
}

@MainActor
final class SwiftMathWorksheetPDFRenderer: WorksheetPDFRenderer {

    private let pageSize = CGSize(width: 595.2, height: 841.8)
    private let margin: CGFloat = 40
    private let numberInset: CGFloat = 28
    private let itemSpacing: CGFloat = 14
    private let lineSpacing: CGFloat = 6

    // Ensambla la hoja pagina a pagina: dibuja titulo, cabecera y los enunciados de forma compacta, saltando de pagina cuando el siguiente no cabe, y anade la pagina de soluciones.
    func render(title: String, items: [WorksheetItem], includeSolutions: Bool) -> Data {
        let bounds = CGRect(origin: .zero, size: pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: UIGraphicsPDFRendererFormat())
        let usableWidth = pageSize.width - margin * 2
        let bottom = pageSize.height - margin

        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y = margin
            y = drawTitle(title, at: y)
            y = drawNameDateLine(at: y)

            for (index, item) in items.enumerated() {
                let images = item.statementLatexLines.map { image(for: $0, fontSize: 20) }
                let needed = statementHeight(images, usableWidth: usableWidth) + itemSpacing
                if y + needed > bottom {
                    ctx.beginPage()
                    y = margin
                }
                y = drawNumberedStatement(index + 1, images: images, at: y, usableWidth: usableWidth)
                y += itemSpacing
            }

            guard includeSolutions else { return }
            ctx.beginPage()
            y = margin
            y = drawTitle(String(localized: "Soluciones"), at: y)
            for (index, item) in items.enumerated() {
                let img = image(for: item.solutionLatex, fontSize: 15)
                let size = scaledSize(for: img, maxWidth: usableWidth - numberInset)
                if y + size.height + lineSpacing > bottom {
                    ctx.beginPage()
                    y = margin
                }
                y = drawNumberedStatement(index + 1, images: [img], at: y, usableWidth: usableWidth)
                y += lineSpacing
            }
        }
    }

    private func image(for latex: String, fontSize: CGFloat) -> UIImage? {
        let math = MTMathImage(latex: latex, fontSize: fontSize, textColor: .black,
                               labelMode: .display, textAlignment: .left)
        let (_, image) = math.asImage()
        return image
    }

    private func scaledSize(for image: UIImage?, maxWidth: CGFloat) -> CGSize {
        guard let image, image.size.width > 0 else { return .zero }
        guard image.size.width > maxWidth else { return image.size }
        let scale = maxWidth / image.size.width
        return CGSize(width: maxWidth, height: image.size.height * scale)
    }

    private func statementHeight(_ images: [UIImage?], usableWidth: CGFloat) -> CGFloat {
        let maxWidth = usableWidth - numberInset
        return images.reduce(0) { $0 + scaledSize(for: $1, maxWidth: maxWidth).height + lineSpacing }
    }

    @discardableResult
    private func drawNumberedStatement(_ index: Int, images: [UIImage?], at y: CGFloat, usableWidth: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        ("\(index))" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)

        var lineY = y
        let maxWidth = usableWidth - numberInset
        for image in images {
            let size = scaledSize(for: image, maxWidth: maxWidth)
            image?.draw(in: CGRect(x: margin + numberInset, y: lineY, width: size.width, height: size.height))
            lineY += size.height + lineSpacing
        }
        return lineY
    }

    @discardableResult
    private func drawTitle(_ title: String, at y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        let string = title as NSString
        let size = string.size(withAttributes: attrs)
        string.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        return y + size.height + 16
    }

    @discardableResult
    private func drawNameDateLine(at y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let string = String(localized: "Nombre: ________________     Fecha: __________") as NSString
        let size = string.size(withAttributes: attrs)
        string.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        return y + size.height + 20
    }
}
