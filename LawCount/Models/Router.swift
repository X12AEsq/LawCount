//
//  Router.swift
//  aPractice
//
//  Created by Morris Albers on 4/29/24.
//

import Foundation
final class Router<T: Hashable>: ObservableObject {
    @Published var paths: [T] = []
    func push(_ path: T) {
        paths.append(path)
    }
    func pop() {
        paths.removeLast(1)
    }
}

enum Path {
    case DocumentMenu
    case EditPractice
    case Cause
    case SelectCause
    case AddCause
    case EditCauses
    case Client
    case SelectClient // ("select only")
    case AddClient
    case EditClients
    case Representations
    case AddRepresentation
    case EditRepresentations
    case AddAppearance
    case EditAppearances
    case AddNote
    case EditNotes
    case LawPractice
    case Documents
    case ClientList
    case CauseList
    case AppearanceList
    case NoteList
}
