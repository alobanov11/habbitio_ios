# Habbitio iOS App

Приложение для отслеживания привычек на iOS с использованием SwiftUI и SwiftData.

## Функциональность

- ✅ Создание и редактирование привычек с категориями
- ✅ Настройка дней недели для каждой привычки
- ✅ Система напоминаний с локальными уведомлениями
- ✅ Архивирование привычек с возможностью восстановления
- ✅ Статистика выполнения с графиками
- ✅ Виджет для экрана блокировки с тепловой картой активности
- ✅ Поддержка App Groups для совместного доступа к данным

## Технологии

- **SwiftUI** - пользовательский интерфейс
- **SwiftData** - хранение данных (iOS 17.0+)
- **UserNotifications** - система напоминаний
- **WidgetKit** - виджеты для главного экрана
- **Swift Charts** - графики статистики

## Минимальные требования

- iOS 17.0+
- Xcode 15.0+

## Установка

1. Склонируйте репозиторий
2. Откройте `Habbitio.xcodeproj` в Xcode
3. Запустите проект на симуляторе или устройстве

## Архитектура

Приложение следует паттерну MVVM с использованием:
- SwiftData модели для данных
- SwiftUI Views для интерфейса
- Singleton DataManager для управления данными
- NotificationCenter для координации между экранами

## Миграция с Core Data

В версии 2.0 приложение было мигрировано с Core Data на SwiftData для упрощения кода и лучшей интеграции со SwiftUI. Все пользовательские данные совместимы между версиями.

Смотрите подробную документацию в `doc.md` для изучения технических деталей.

## Features

- Pure SwiftUI
- No third party libraries
- WidgetKit
- Core Data

## Requirements

- iOS 16+
- Swift 5.7

## History and Plans

- [x] Create and upload to AppStore
- [ ] Create onboarding screen
- [ ] Integrate fastlane / firebase
- [ ] Add analytics
- [ ] Add unit tests

## Links

- [AppStore](https://apps.apple.com/us/app/habbitio/id6444619357)
- [Site](https://alobanov11.ru/)