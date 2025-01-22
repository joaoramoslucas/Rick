import SwiftUI

struct Home: View {
    @ObservedObject var viewModel = HomeViewModel()
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @AppStorage("favoriteCharacters") private var favoriteCharactersData: Data = Data()
    @State private var favoriteCharacters: [Character] = []

    @State private var isDarkMode: Bool = false
    @State private var showMenu = false
    @State private var navigateToOnboarding = false
    @State private var selectedTab: Tab = .characters

    enum Tab {
        case characters
        case favorites
    }

    var body: some View {
        NavigationView {
            VStack {
                if showMenu {
                    MenuView(isLoggedIn: .constant(false), navigateToOnboarding: $navigateToOnboarding)
                } else {
                    TabView(selection: $selectedTab) {
                        CharactersListView(
                            characters: viewModel.characters,
                            isLoading: viewModel.isLoading,
                            onError: viewModel.onErr,
                            toggleFavorite: toggleFavorite,
                            isFavorite: isFavorite
                        )
                        .tabItem {
                            Label("Personagens", systemImage: "person.3.fill")
                        }
                        .tag(Tab.characters)

                        FavoritesListView(
                            characters: favoriteCharacters,
                            removeFavorite: toggleFavorite
                        )
                        .tabItem {
                            Label("Favoritos", systemImage: "star.fill")
                        }
                        .tag(Tab.favorites)
                    }
                    .onAppear {
                        viewModel.getCharacters()
                        loadFavoriteCharacters() // Carregar favoritos quando a view aparecer
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showMenu.toggle() }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.blue)
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { isDarkMode.toggle() }) {
                                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .navigationTitle(selectedTab == .characters ? "Personagens" : "Favoritos")
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                }
            }
        }
    }

    private func toggleFavorite(character: Character) {
        if let index = favoriteCharacters.firstIndex(where: { $0.id == character.id }) {
            favoriteCharacters.remove(at: index)
        } else {
            favoriteCharacters.append(character)
        }
        saveFavoriteCharacters() // Salva os favoritos toda vez que mudar
    }

    private func isFavorite(character: Character) -> Bool {
        favoriteCharacters.contains(where: { $0.id == character.id })
    }

    private func loadFavoriteCharacters() {
        if let loadedFavorites = try? JSONDecoder().decode([Character].self, from: favoriteCharactersData) {
            favoriteCharacters = loadedFavorites
        }
    }

    private func saveFavoriteCharacters() {
        if let encoded = try? JSONEncoder().encode(favoriteCharacters) {
            favoriteCharactersData = encoded
        }
    }
}

// MARK: - Characters List View
struct CharactersListView: View {
    var characters: [Character]
    var isLoading: Bool
    var onError: Bool
    var toggleFavorite: (Character) -> Void
    var isFavorite: (Character) -> Bool

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Carregando personagens...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else if onError {
                Text("Erro ao carregar personagens.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(characters) { char in
                            VStack {
                                NavigationLink(destination: CharacterDetail(character: char)) {
                                    ImageLoader(url: char.image)
                                        .frame(width: 150, height: 150)
                                        .cornerRadius(10)
                                }

                                Text(char.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)

                                Button(action: {
                                    toggleFavorite(char)
                                }) {
                                    Image(systemName: isFavorite(char) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
// MARK: - Favorites List View
import SwiftUI
import Kingfisher

struct FavoritesListView: View {
    var characters: [Character]
    var removeFavorite: (Character) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if characters.isEmpty {
                Text("Nenhum personagem favorito.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(characters) { char in
                        VStack {
                            NavigationLink(destination: CharacterDetail(character: char)) {
                                KFImage(URL(string: char.image ?? ""))
                                    .placeholder {
                                        ProgressView()
                                            .frame(width: 150, height: 150)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(10)
                                    .clipped()
                            }

                            Text(char.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)

                            Button(action: {
                                removeFavorite(char)
                            }) {
                                Image(systemName: "star.slash")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
        }
    }
}

struct MenuView: View {
    @Binding var isLoggedIn: Bool // Estado de login
    @Binding var navigateToOnboarding: Bool // Controle da navegação para a tela de login

    var body: some View {
        VStack {
            Spacer() // Empurra o menu para o rodapé

            HStack {
                Button(action: {
                    // Ação para sair e redirecionar para a tela de login
                    isLoggedIn = false
                    navigateToOnboarding = true
                }) {
                    Text("Sair para Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Ocupa largura total do botão dentro do HStack
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.9)) // Fundo do menu
            .cornerRadius(12) // Bordas arredondadas do menu
            .shadow(radius: 5)
            .frame(maxWidth: .infinity) // Ocupa toda a largura da tela
        }
        .edgesIgnoringSafeArea(.bottom) // Faz o menu tocar o rodapé da tela
    }
}

// MARK: - ImageLoader
struct ImageLoader: View {
    let url: String?

    @State private var cachedImage: Image?

    var body: some View {
        Group {
            if let image = cachedImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipped()
            } else if let imageUrl = url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            } else {
                Color.gray
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
            }
        }
    }
}
