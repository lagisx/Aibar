# AI Hairstyle — тестовая версия (MVP)

Чат-приложение (Flutter, Android + iOS): пользователь отправляет фото + текстовый
запрос, приложение генерирует варианты новой причёски/бороды и присылает их в чат
как ответ ассистента. Подписка Free/Pro/Max на этом этапе — мок в БД, без реального
биллинга. Полный план — см. корневой файл техплана в репозитории.

## Стек

- Flutter (Dart) + Riverpod
- Supabase: Postgres, Auth, Storage, Edge Functions, Realtime
- AI-генерация: Replicate (модель типа InstantID/IP-Adapter), вызывается только
  из Edge Function — ключ никогда не попадает в клиент

## Структура

```
lib/
  core/            # config (--dart-define), theme, utils
  data/            # models, repositories, services (Supabase, AI, image picker)
  features/
    auth/          # login/register, Supabase Auth + Google Sign-In
    consent/       # экран согласия на обработку фото (первый запуск)
    chat/          # экран чата, отправка фото+промпта, приём результата
    subscription/  # paywall free/pro/max (мок-апгрейд)
    profile/       # профиль, выход
  shared_widgets/
  routes/
supabase/
  migrations/      # SQL: таблицы + RLS + storage bucket + автоудаление фото
  functions/
    generate-hairstyle/  # Edge Function (Deno): лимиты + вызов AI + запись в чат
```

## Настройка Supabase

1. Создать проект на supabase.com (бесплатный tier).
2. Выполнить миграции из `supabase/migrations/` (SQL Editor или `supabase db push`).
   `0001_init.sql` создаёт таблицы, RLS-политики и публичный bucket `source-photos`.
   `0002_photo_retention.sql` включает автоудаление фото старше 7 дней через pg_cron.
3. В Authentication → Providers включить Email и Google.
4. Задеплоить Edge Function:
   ```
   supabase functions deploy generate-hairstyle
   supabase secrets set REPLICATE_API_TOKEN=... REPLICATE_MODEL_VERSION=...
   ```

## Запуск приложения

```
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
```

См. `.env.example` для полного списка переменных (реальные ключи не коммитить).

iOS-сборка требует Xcode на macOS (для подписи и Sign in with Apple) — на этапе
теста можно ограничиться Android-сборкой через Android Studio.

## Что сознательно не сделано на этом этапе

- Реальный биллинг (RevenueCat/App Store/Google Play) — тариф меняется напрямую в БД.
- Собственная ML-инфраструктура — используется готовый внешний API.
- Полная GDPR/BIPA-документация — только экран согласия и автоудаление фото.
- Оптимизация под масштаб — рассчитано на 20-30 тестовых пользователей.
