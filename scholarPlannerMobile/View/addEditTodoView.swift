//
//  addEditTodoView.swift
//  scholarPlannerMobile
//
//  Created by Leonardo Ohasi on 25/05/23.
//

import SwiftUI
import UserNotifications

struct AddEditTodoView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var todoItem: TodoListInfo.TodoItem
    @State private var showNotificationExpiredDialog = false
    @State private var notificationIsNotAuthorized = false
    @State private var insertOrUpdateNotification = false

    var body: some View {
        Form {
            Section(header: Text("Título")) {
                TextField("Título", text: $todoItem.title)
            }
            Section(header: Text("Descrição")) {
                TextEditor(text: $todoItem.description)
            }
            Section(header: Text("Prioridade")) {
                PrioritySectionView(priority: $todoItem.priority)
            }
            Section(header: Text("Lembrete")) {
                ReminderSectionView(todoItem: $todoItem, insertOrUpdateNotification: $insertOrUpdateNotification)
            }.alert(isPresented: $notificationIsNotAuthorized) {
                Alert(title: Text("Você adicionou uma notificação, mas negou notificações para este aplicativo. Vá para as configurações para ativar as notificações."))
            }
        }
        .navigationTitle(Text("Editar tarefa"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Concluído") {
                    handleDonePressed()
                }
                .disabled(todoItem.title.isEmpty)
            }
        }
        .alert(isPresented: $showNotificationExpiredDialog) {
            Alert(title: Text("Remover lembrete ou definir uma data de lembrete válida"))
        }
    }

    private struct PrioritySectionView: View {
        @Binding var priority: Int

        var body: some View {
            Picker(selection: $priority, label: Text("Prioridade")) {
                Text(Priority.low.title).tag(Priority.low.rawValue)
                    .foregroundColor(Priority.low.color)
                Text(Priority.medium.title).tag(Priority.medium.rawValue)
                    .foregroundColor(Priority.medium.color)
                Text(Priority.high.title).tag(Priority.high.rawValue)
                    .foregroundColor(Priority.high.color)
            }
            .labelsHidden()
        }
    }

    private struct ReminderSectionView: View {
        @Binding var todoItem: TodoListInfo.TodoItem
        @Binding var insertOrUpdateNotification: Bool

        private var dateSelected: Binding<Date> {
            Binding<Date>(
                get: { return todoItem.dueDate.toSwiftDate() },
                set: { date in
                    todoItem.dueDate = todoItem.dueDate.fromSwiftDate(date)
                }
            )
        }

        var body: some View {
            if (todoItem.dueDateIsValid && todoItem.hasNotification) || insertOrUpdateNotification {
                DatePicker("Lembrete", selection: dateSelected, in: Date()...).labelsHidden()
            }

            Button((todoItem.dueDateIsValid && todoItem.hasNotification) || insertOrUpdateNotification ? "Remover" : "Definir Lembrete") {
                withAnimation(.easeInOut) {
                    if !todoItem.dueDateIsValid {
                        todoItem.dueDate = todoItem.dueDate.fromSwiftDate(Date())
                    }

                    if (todoItem.hasNotification) {
                        todoItem.hasNotification = false
                        insertOrUpdateNotification = false
                    } else {
                        insertOrUpdateNotification.toggle()
                    }
                }
            }
        }
    }

    private func handleDonePressed() {
        if insertOrUpdateNotification && !todoItem.dueDateIsValid {
            showNotificationExpiredDialog = true
        } else {
            if insertOrUpdateNotification && todoItem.dueDateIsValid {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                        upsertItemAndPopView()
                    } else if settings.authorizationStatus == .notDetermined {
                        requestNotificaitonAuthorization {
                            upsertItemAndPopView()
                        }
                    } else {
                        notificationIsNotAuthorized = true
                    }
                }
            } else {
                upsertItemAndPopView()
            }
        }
    }

    private func upsertItemAndPopView() {
        if !todoItem.dueDateIsValid {
            todoItem.hasNotification = false
        } else if insertOrUpdateNotification {
            todoItem.hasNotification = true
        }

        DispatchQueue.main.async {
            viewModel.upsert(editedItem: todoItem)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func requestNotificaitonAuthorization(successHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    successHandler()
                } else if let error = error {
                    print(error.localizedDescription)
                    notificationIsNotAuthorized = true
                }
            }
    }
}

struct AddEditTodoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditTodoView(
                todoItem: TodoListInfo.TodoItem(
                    title: "Tarefa de prioridade média",
                    description: "Descrição para uma tarefa de prioridade média",
                    priority: Priority.medium.rawValue
                )
            )
        }
    }
}
