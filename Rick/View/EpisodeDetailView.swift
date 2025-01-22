import SwiftUI

struct Episode: Identifiable, Decodable {
    var id: Int
    var name: String
    var air_date: String
    var episode: String
}

struct EpisodeDetailView: View {
    var episode: Episode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    ZStack {
                        // Fundo do player (simulando a tela de vídeo)
                        Color.black
                            .frame(height: 250)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                                .opacity(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? 1 : 0)
                            )

                        // Ícone de Play (botão de reprodução)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.horizontal)

                    Text(episode.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    Text(
                        """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut \
                        labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco \
                        laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in \
                        voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat \
                        non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        """
                    )
                    .font(.title3)
                    .padding()

                    Text("Lançado: \(episode.air_date)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()

                    Text("Episódio: \(episode.episode)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Detalhes do Episódio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
