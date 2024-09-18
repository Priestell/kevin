enum CommandeStatut {
  enAttente,
  enCours,
  termine,
  annule,
}

extension CommandeStatutExtension on CommandeStatut {
  String get value {
    switch (this) {
      case CommandeStatut.enAttente:
        return 'En attente';
      case CommandeStatut.enCours:
        return 'En cours';
      case CommandeStatut.termine:
        return 'Terminé';
      case CommandeStatut.annule:
        return 'Annulé';
    }
  }

  static CommandeStatut fromString(String statut) {
    switch (statut) {
      case 'En attente':
        return CommandeStatut.enAttente;
      case 'En cours':
        return CommandeStatut.enCours;
      case 'Terminé':
        return CommandeStatut.termine;
      case 'Annulé':
        return CommandeStatut.annule;
      default:
        throw Exception('Statut inconnu: $statut');
    }
  }
}
