//
//  HomeViewModel.swift
//  Rick
//
//  Created by Jao on 21/08/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var onErr = false
    @Published var isLoading = true // Alterado para isLoading
    @Published var characters: [Character] = []
    
    private let netWorking: NetworkManager
    
    init() {
        netWorking = NetworkManager()
        getCharacters() // Inicia o carregamento dos personagens ao criar a ViewModel
    }
    
    func getCharacters() {
        isLoading = true // Define o estado de carregamento como verdadeiro
        netWorking.request(Routes.CHARACTERS.rawValue) { (result: Result<ConfigCharacters, ApiError>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.characters = response.results
                    self.isLoading = false // Define o estado de carregamento como falso quando os dados são carregados
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.onErr = true // Atualiza o estado de erro
                    self.isLoading = false // Define o estado de carregamento como falso se ocorrer um erro
                    print("Error fetching characters: \(err)")
                }
            }
        }
    }
}
