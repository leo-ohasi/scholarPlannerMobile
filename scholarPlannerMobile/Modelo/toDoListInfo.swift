//
//  toDoListInfo.swift
//  scholarPlannerMobile
//
//  Created by Leonardo Ohasi on 25/05/23.
//

import Foundation

struct TodoListInfo: Codable {
    var todos = [TodoItem]()

    struct TodoItem: Codable, Identifiable, Equatable {
        private(set) var id = UUID().uuidString
        var title = ""
        var description = ""
        var priority = Priority.medium.rawValue
        var isCompleted = false
        var dueDate = DueDate(year: 0, month: 0, day: 0, hour: 0, minute: 0)
        private(set) var notificationId = UUID().uuidString
        var hasNotification = false

        var dueDateIsValid: Bool {
            dueDate.toSwiftDate().timeIntervalSinceNow.sign != .minus
        }

        mutating func generateNewId() {
            id = UUID().uuidString
        }

        struct DueDate: Codable, Equatable {
            var year: Int
            var month: Int
            var day: Int
            var hour: Int
            var minute: Int

            func toSwiftDate() -> Date {
                Calendar.current.date(
                    from: DateComponents(
                        year: year,
                        month: month,
                        day: day,
                        hour: hour,
                        minute: minute
                    )
                )!
            }

            func fromSwiftDate(_ date: Date) -> TodoListInfo.TodoItem.DueDate {
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                return TodoListInfo.TodoItem.DueDate(
                    year: dateComponents.year!,
                    month: dateComponents.month!,
                    day: dateComponents.day!,
                    hour: dateComponents.hour!,
                    minute: dateComponents.minute!
                )
            }

            func formattedDateString() -> String {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                formatter.timeZone = .current
                return formatter.string(from: toSwiftDate())
            }
        }
    }

    func index(of item: TodoItem) -> Int? {
        todos.firstIndex { $0.id == item.id }
    }

    var json: Data? {
        try? JSONEncoder().encode(self)
    }

    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(TodoListInfo.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }

    init(testData: Bool) {
        if !testData {
            loadPersistedJsonData()
        } else {
            loadTestData()
        }
    }

    mutating private func loadPersistedJsonData() {
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            if let jsonData = try? Data(contentsOf: url), let savedTodoListInfo = TodoListInfo(json: jsonData) {
                self.todos = savedTodoListInfo.todos
            }
        }
    }

    static func persistTodoList(_ todoListInfo: TodoListInfo) {
        if let json = todoListInfo.json, let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            do {
                try json.write(to: url)
            } catch let error {
                print("Não foi possível salvar, erro: \(error)")
            }
        }
    }

    mutating private func loadTestData() {
        self.todos = [
            TodoItem(title: "Tarefa de prioridade média",
                     description: "Descrição para uma tarefa de prioridade média",
                     priority: Priority.medium.rawValue,
                     isCompleted: false),
            TodoItem(title: "Tarefa de prioridade alta",
                     description: "Descrição para uma tarefa de prioridade alta",
                     priority: Priority.high.rawValue,
                     isCompleted: false),
            TodoItem(title: "Tarefa de prioridade baixa",
                     description: "Descrição para uma tarefa de prioridade baixa",
                     priority: Priority.low.rawValue,
                     isCompleted: false),
            TodoItem(title: "Prioridade alta completa",
                     description: "Descrição para uma tarefa de prioridade alta completada",
                     priority: Priority.high.rawValue,
                     isCompleted: true),
            TodoItem(title: "Tarefa com notificação",
                     description: "Descrição para uma tarefa com lembrete",
                     priority: Priority.medium.rawValue,
                     isCompleted: false,
                     dueDate: TodoItem.DueDate(year: 2021, month: 05, day: 25, hour: 14, minute: 15)),
            TodoItem(title: "Tarefa com descrição longa",
                     description: "Descrição para uma tarefa longa. Essa descrição ocupará várias linhas na tela do iPhone",
                     priority: Priority.medium.rawValue,
                     isCompleted: true),
            TodoItem(title: "Prioridade média completa",
                     description: "Descrição para uma tarefa de prioridade média completada",
                     priority: Priority.medium.rawValue,
                     isCompleted: true),
            TodoItem(title: "Prioridade baixa completa",
                     description: "Descrição para uma tarefa de prioridade baixa completada",
                     priority: Priority.low.rawValue,
                     isCompleted: true)
        ]
    }
}
