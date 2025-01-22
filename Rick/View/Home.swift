import SwiftUI
import Kingfisher

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
            ZStack {
                VStack {
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
                        loadFavoriteCharacters()
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

                if showMenu {
                    VStack {
                        Spacer()
                        MenuView(isLoggedIn: .constant(false), navigateToOnboarding: $navigateToOnboarding)
                            .transition(.move(edge: .bottom)) // Animação de entrada
                    }
                    .background(Color.black.opacity(0.4).ignoresSafeArea()) // Fundo semi-transparente
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $navigateToOnboarding) {
                OnboardingView()
            }
        }
    }

    private func toggleFavorite(character: Character) {
        if let index = favoriteCharacters.firstIndex(where: { $0.id == character.id }) {
            favoriteCharacters.remove(at: index)
        } else {
            favoriteCharacters.append(character)
        }
        saveFavoriteCharacters()
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

// MARK: - MenuView

struct MenuView: View {
    @Binding var isLoggedIn: Bool
    @Binding var navigateToOnboarding: Bool

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                isLoggedIn = false
                navigateToOnboarding = true
            }) {
                Text("Sair para Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

// MARK: - CharactersListView

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

// MARK: - FavoritesListView

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
                Text("Nenhum personagem adicionado ao favoritos.")
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
