import SwiftUI

struct DotGridBackground: View {
    var dotSpacing: CGFloat = 24
    var dotRadius: CGFloat = 1.5

    var body: some View {
        Canvas { context, size in
            let color = Color.mapleT4.opacity(0.35)
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let rect = CGRect(
                        x: x - dotRadius,
                        y: y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    )
                    context.fill(Circle().path(in: rect), with: .color(color))
                    x += dotSpacing
                }
                y += dotSpacing
            }
        }
        .allowsHitTesting(false)
    }
}
