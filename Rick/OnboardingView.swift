import SwiftUI

struct OnboardingView: View {
    @State private var isOnboardingFinished = false // Controla a navegação para a Home

    var body: some View {
        if isOnboardingFinished {
            Home() // Quando o onboarding termina, exibe a Home
        } else {
            TabView {
                OnboardingPageView(
                    title: "Bem-vindo ao RickMovies",
                    description: "Explore os personagens incríveis e mergulhe no universo de Rick and Morty.",
                    imageName: "onboarding1"
                )

                OnboardingPageView(
                    title: "Descubra seus favoritos",
                    description: "Veja detalhes de cada personagem, salve os seus favoritos e assista todos episódios do seu personagem preferido.",
                    imageName: "onboarding2"
                )

                OnboardingPageView(
                    title: "Pronto para começar?",
                    description: "Clique e comece agora!",
                    imageName: "onboarding3",
                    showStartButton: true,
                    onButtonTap: {
                        isOnboardingFinished = true // Finaliza o onboarding
                    }
                )
            }
            .tabViewStyle(PageTabViewStyle()) // Estilo de página com rolagem horizontal
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Mostra os indicadores de página
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct OnboardingPageView: View {
    var title: String
    var description: String
    var imageName: String
    var showStartButton: Bool = false
    var onButtonTap: (() -> Void)? = nil // Callback para o botão "Começar"

    var body: some View {
        VStack(spacing: 30) {
            // Ajuste na exibição da imagem
            Image(imageName)
                .resizable()
                .scaledToFill() // Ajuste para a imagem preencher completamente o círculo
                .frame(width: 200, height: 200) // Definindo o tamanho do círculo
                .clipShape(Circle()) // Garante o formato circular
                .overlay(Circle().stroke(Color.white, lineWidth: 4)) // Adiciona uma borda branca
                .shadow(radius: 10) // Sombra ao redor da imagem
                .padding()

            // Título
            Text(title)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.orange)
                .multilineTextAlignment(.center)

            // Descrição
            Text(description)
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            // Botão para iniciar, caso seja o último slide
            if showStartButton {
                Button(action: {
                    onButtonTap?() // Chama a ação de finalizar o onboarding
                }) {
                    Text("Começar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
            }
        }
        .padding()
    }
}
