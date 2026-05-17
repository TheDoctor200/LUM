import SwiftUI

struct AsyncThumbnail: View {
  let url: URL?
  var aspectRatio: CGFloat = 16 / 9
  var cornerRadius: CGFloat = 12

  @State private var phase: AsyncImagePhase = .empty

  var body: some View {
    AsyncImage(url: url) { p in
      switch p {
      case .empty:
        ShimmerView()
          .aspectRatio(aspectRatio, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      case .success(let image):
        image
          .resizable()
          .aspectRatio(aspectRatio, contentMode: .fill)
          .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
          .transition(.opacity.animation(.easeIn(duration: 0.25)))
      case .failure:
        ZStack {
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.05))
          Image(systemName: "photo")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
      @unknown default:
        EmptyView()
      }
    }
  }
}

struct ShimmerView: View {
  @State private var phase: CGFloat = -1

  var body: some View {
    GeometryReader { geo in
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.white.opacity(0.06))
        LinearGradient(
          colors: [.clear, Color.white.opacity(0.1), .clear],
          startPoint: .leading,
          endPoint: .trailing
        )
        .frame(width: geo.size.width * 0.6)
        .offset(x: phase * geo.size.width)
      }
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .onAppear {
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
          phase = 1.6
        }
      }
    }
  }
}
