class Action {
  String actionId; // Уникальный идентификатор действия
  String actionType; // Тип действия
  String description; // Тип действия
  Map<String, dynamic> actionData; // Данные действия
  Action({
    required this.actionId,
    required this.actionType,
    required this.actionData,
    required this.description,
  });

}