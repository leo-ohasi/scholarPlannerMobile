//
//  toDoListView.swift
//  scholarPlannerMobile
//
//  Created by Leonardo Ohasi on 25/05/23.
//

import SwiftUI

struct TodoListView: View {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(systemName: "arrow.backward"), transitionMaskImage: UIImage(systemName: "arrow.backward"))
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var searchText = ""
    @State private var isShowingDeleteItemsConfirmationDialog = false

    private var searchBinding: Binding<String> {
        Binding<String>(
            get: { return self.searchText },
            set: { newSearchText in
                withAnimation {
                    self.searchText = newSearchText
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.todoListIsEmpty {
                    Text("Adicione tarefas")
                        .font(.largeTitle)
                        .offset(y: Constants.onboardingHeaderYOffset)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredListOfTodosByTitle(searchText)) { todoItem in
                            ListItemView(todoItem: todoItem)
                        }
                        .onDelete {
                            viewModel.remove(indexSet: $0)
                        }
                    }
                    .searchable(text: searchBinding, prompt: "Procurar")
                }
            }
            .navigationTitle("Minhas Tarefas")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("Fundo de Prancheta 1 Removido 2")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(.leading, 16)
                        .position(CGPoint(x: 40, y: 35))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        isShowingDeleteItemsConfirmationDialog = true
                    } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                    .disabled(viewModel.todoListIsEmpty)
                    .confirmationDialog(
                        "Você tem certeza que deseja excluir essas tarefas?",
                        isPresented: $isShowingDeleteItemsConfirmationDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Excluir tarefas concluídas", role: .destructive) {
                            withAnimation {
                                viewModel.removeCompleted()
                            }
                        }
                        .disabled(viewModel.todoListHasNoCompletedItems)
                        
                        Button("Excluir todas as tarefas", role: .destructive) {
                            withAnimation {
                                viewModel.removeAll()
                            }
                        }
                        Button("Cancelar", role: .cancel) {} // Adicione este botão com o texto "Cancelar"
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditTodoView(todoItem: TodoListInfo.TodoItem())) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private struct Constants {
        static let onboardingHeaderYOffset: CGFloat = -50
    }
}

struct TodoListView_Previews: PreviewProvider {
static var previews: some View {
TodoListView().environmentObject(TodoListViewModel(testData: true))
}
}
