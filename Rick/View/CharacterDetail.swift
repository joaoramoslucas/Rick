import SwiftUI

struct CharacterDetail: View {
    var character: Character
    @State private var episodes: [Episode] = [] // Array para armazenar os episódios carregados
    @State private var isLoading = true // Indica se os episódios estão carregando
    @State private var errorMessage: String? = nil // Para mostrar erros, se necessário

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Detalhes do Personagem
                VStack {
                    if let imageUrl = character.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Color.gray.opacity(0.2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                Text("Sem imagem disponível")
                                    .foregroundColor(.gray)
                                    .padding()
                            )
                    }

                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 5)
                }

                // Informações adicionais do personagem
                VStack(alignment: .leading, spacing: 15) {
                    Text("Status: \(character.status ?? "Desconhecido")")
                    Text("Espécie: \(character.specie ?? "Desconhecido")")
                    Text("Gênero: \(character.gender)")
                    Text("Origem: \(character.origin.name)")
                }
                .font(.title3)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .shadow(radius: 5)

                // Seção de Episódios
                VStack(alignment: .leading, spacing: 15) {
                    Text("Episódios:")
                        .font(.headline)

                    if isLoading {
                        ProgressView("Carregando episódios...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if episodes.isEmpty {
                        Text("Nenhum episódio disponível.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Exibe os episódios
                        ForEach(episodes) { episode in
                            NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                HStack(alignment: .top, spacing: 15) {
                                    // Imagem pequena do personagem
                                    if let imageUrl = character.image, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 50, height: 50)
                                        }
                                    } else {
                                        Color.gray.opacity(0.2)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }

                                    // Detalhes do episódio
                                    VStack(alignment: .leading, spacing: 5) {
                                        if #available(iOS 16.0, *) {
                                            Text(episode.name)
                                                .font(.headline)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                        Text("Air Date: \(episode.air_date)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Episode: \(episode.episode)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                                .shadow(radius: 5)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)

                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Detalhes do Personagem")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadEpisodes()
        }
    }

    // Função para carregar os episódios dos URLs
    private func loadEpisodes() {
        let episodeURLs = character.episode

        loadEpisodesFromURLs(episodeURLs: episodeURLs) { episodes, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.episodes = episodes
            }
            self.isLoading = false
        }
    }

    // Função para carregar episódios de URLs
    private func loadEpisodesFromURLs(episodeURLs: [String], completion: @escaping ([Episode], Error?) -> Void) {
        var loadedEpisodes: [Episode] = []
        var encounteredError: Error? = nil

        let dispatchGroup = DispatchGroup()

        for urlString in episodeURLs {
            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()

            loadEpisode(from: url) { episode, error in
                if let episode = episode {
                    loadedEpisodes.append(episode)
                }
                if let error = error {
                    encounteredError = error
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(loadedEpisodes, encounteredError)
        }
    }

    // Função para carregar um único episódio de uma URL
    private func loadEpisode(from url: URL, completion: @escaping (Episode?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let episode = try JSONDecoder().decode(Episode.self, from: data)
                completion(episode, nil)
            } catch {
                print("Erro ao decodificar episódio: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
        .resume()
    }
}
