# Техническое задание системы LMS «ЦУМ: Корпоративный университет» (v2.2.0)

Дата: 2025-07-25
Ответственный: Архитектор/Тимлид
Связанные документы: `.cursor/rules/productmanager.mdc`, `technical_requirements/TDD_MANDATORY_GUIDE.md`, `docs/ARCHITECTURE_V3.md`, `ARCHITECTURE_MODERNIZATION_TECHNICAL_SPEC.md`, `SPRINT_54_PLAN_ARCHITECTURE_MODERNIZATION.md`

## 1. Цель и контекст

- Обеспечить максимально быстрый и простой цикл разработки, деплоя и отладки для LMS.
- Гибридная архитектура: iOS (SwiftUI) + Веб‑клиент (Next.js) + Бэкенд (Supabase PostgreSQL/Auth/Realtime/Edge Functions).
- Модульный подход: каждый спринт — production‑ready модуль. В текущем спринте — модуль «Лента» (Telegram‑стиль) + фундамент веб‑приложения.
- Совместимость с текущим PHP‑микросервисным бэкендом, постепенная миграция на Supabase.

## 2. Область работ (Scope)

- Веб‑приложение: Next.js 14 App Router, TypeScript, Tailwind, shadcn/ui, React Query.
- Модуль «Лента» (Feed) — только Telegram‑стиль UI на старте.
- База данных в Supabase: схемы `profiles`, `feed_channels`, `feed_posts` (+ расширение при необходимости: `feed_comments`, `feed_reactions`).
- RLS политики для безопасного доступа. Начальная модель — публичное чтение ленты, запись только аутентифицированным.
- CI/CD: GitHub Actions → Railway (веб), Supabase (БД), альтернативно Vercel (веб).
- Мониторинг: Sentry, базовые health‑эндпоинты.
- Интеграция iOS: WebView для веб‑модулей, Deep Link, логирование через ComprehensiveLogger.

Не входит: полнофункциональная админ‑панель (будет в отдельном спринте), миграция всех доменов с PHP.

## 3. Глобальные требования к процессу

- Методология: TDD строго обязательна, тесты пишутся первыми, все тесты должны проходить.
- Логирование: все ключевые действия логируются, тесты проверяют наличие логов.
- Feature Registry (iOS): каждый модуль регистрируется и покрывается интеграционными тестами доступности.
- Вертикальный срез: функциональность от UI до БД готова и проверена.

## 4. Архитектура (высокий уровень)

Компоненты:
- iOS клиент (SwiftUI) — нативные экраны + WebView для веб‑модулей; навигация, логирование, Deep Links.
- Веб‑клиент (Next.js 14) — UI, взаимодействие с Supabase (SSR/CSR, Realtime для ленты), API routes для служебных задач.
- Supabase — PostgreSQL, Auth, Realtime, Edge Functions, Storage (медиа в перспективе), RLS.
- CI/CD — GitHub Actions: тесты → сборка → деплой на Railway.

Потоки данных:
- Публичное чтение ленты: Next.js (Edge/Node) → PostgREST (Supabase) → `feed_*` таблицы.
- Публикация постов: клиент (аутентифицированный) → Supabase (RLS) → `feed_posts` + триггеры обновления счетчиков.

## 5. Модуль «Лента» (Telegram‑стиль)

### 5.1 UI/UX
- Список постов: карточки в Telegram‑стиле (аватар канала, заголовок, краткое содержимое, медиа превью, реакции/счетчики).
- Деталь поста: полный контент, медиа, счетчики.
- Создание поста: `PostEditor` (заголовок, контент, выбор канала, прикрепление медиа позже).
- Состояния: загрузка, пусто, ошибка; skeleton‑плейсхолдеры.
- Локализация: ru‑RU (по умолчанию), готовность к i18n.

### 5.2 Компоненты фронтенда
- `PostCard` — Telegram‑стиль карточки поста (реакции — emoji‑кнопки, hover‑эффекты).
- `PostEditor` — форма создания поста (пока без TipTap, затем подключение).
- `ChannelSelector`, `MediaUploader`, `CommentThread` — в следующих итерациях.
- `useFeed` — хук загрузки/создания постов через Supabase (обработка ошибок, логирование).

## 6. Модель данных (Supabase PostgreSQL)

Базовые таблицы (минимально совместимые с текущим кодом):

- `profiles`
  - `id uuid primary key` — совпадает с `auth.users.id` (в проде FK включён; в dev допускается временно отключать для seed).
  - `full_name text not null`
  - `role text not null default 'student'` — значения: `admin`, `moderator`, `student`, `employee`, `instructor`, `staff`.
  - `department text`, `position text`
  - `avatar_url text`
  - `created_at timestamptz default now()`, `updated_at timestamptz default now()`
  - Индекс: `idx_profiles_role` по `role`.

- `feed_channels`
  - `id uuid primary key`
  - `name text not null`, `slug text unique not null`
  - `description text`, `icon text`, `color text`, `is_official boolean default true`
  - `creator_id uuid not null references profiles(id)`
  - `posts_count int default 0`, `subscribers_count int default 0`
  - `created_at timestamptz default now()`, `updated_at timestamptz default now()`
  - Индексы: `idx_feed_channels_slug`, `idx_feed_channels_creator`.

- `feed_posts`
  - `id uuid primary key default gen_random_uuid()`
  - `channel_id uuid not null references feed_channels(id)`
  - `author_id uuid not null references profiles(id)`
  - `title text not null`, `content text not null`, `excerpt text`
  - `media_urls text[]` — массив URL изображений/видео (опционально)
  - `published_at timestamptz`, `created_at timestamptz default now()`, `updated_at timestamptz default now()`
  - `likes_count int default 0`, `comments_count int default 0`
  - Индексы: `idx_feed_posts_channel`, `idx_feed_posts_published`.

Примечание: поля `media_type`, `tags` не обязательны; добавляются миграцией после согласования (в текущей базе отсутствуют).

### 6.1 Триггеры/функции
- Триггер post‑insert/update/delete для пересчета `feed_channels.posts_count`.
- Опционально: триггер обрезки excerpt из content, если не задан.

### 6.2 Политики RLS (минимальный безопасный старт)
Включить RLS для всех таблиц. Примеры политик:

- `profiles`:
  - SELECT: только свой профиль или роли `admin/moderator`.
  - UPDATE: только владелец (auth.uid() = id) или `admin`.
  - INSERT/DELETE: через сервис‑ключ (серверные операции).

- `feed_channels`:
  - SELECT: разрешено всем (`using (true)`).
  - INSERT: только аутентифицированным с ролью `admin` или `moderator`:

```sql
create policy feed_channels_insert_auth
on public.feed_channels for insert
to authenticated
with check (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin','moderator')
  )
  and creator_id = auth.uid()
);
```

  - UPDATE: создатель или `admin/moderator`:

```sql
create policy feed_channels_update_owner_or_admin
on public.feed_channels for update
to authenticated
using (
  creator_id = auth.uid() or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin','moderator')
  )
)
with check (
  creator_id = auth.uid() or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin','moderator')
  )
);
```

- `feed_posts`:
  - SELECT: разрешено всем (`using (true)`), для приватных каналов политика будет уточнена позже.
  - INSERT: только аутентифицированным; автор — текущий пользователь, канал существует:

```sql
create policy feed_posts_insert_auth
on public.feed_posts for insert
to authenticated
with check (
  exists (select 1 from public.feed_channels c where c.id = channel_id)
  and author_id = auth.uid()
);
```

  - UPDATE/DELETE: автор поста или `admin/moderator` по аналогии с каналами.

## 7. Миграции и данные

- Прод: нормальные FK и RLS включены.
- Dev/Seed: допускается временное отключение FK для первичного заселения (см. `supabase/seed_simple.sql`).
- Файлы:
  - `supabase/migrations/*.sql` — эволюция схемы.
  - `supabase/seed_simple.sql` — быстрый seed без зависимостей (dev).
  - `supabase/seed_no_auth.sql` — seed без Supabase Auth (dev), только если RLS/ FK мешают.

## 8. API и контракты

Источники API:
- Supabase PostgREST (табличные операции)
- Next.js API routes для служебных задач/прокси

Базовые маршруты Next.js API:
- `GET /api/health` → `{ status: 'ok', timestamp, service, version }`
- `GET /api/check-db` → `{ profiles: N, channels: N, posts: N } | ошибки`
- `POST /api/feed/publish` (опционально) → валидирует вход, вызывает вставку в `feed_posts` от имени пользователя (SSR/Server Actions). Формат ошибок: `{ error: { code, message, details? } }`.

Ошибки:
- Стандартизованный формат: HTTP 4xx/5xx + `{ error: { code, message, details } }`.
- Логирование ошибок на сервере (Sentry) + клиентские уведомления.

OpenAPI: на старте — lightweight‑описание в `docs/api/`, расширение по мере появления серверных маршрутов.

## 9. Фронтенд (Next.js 14)

Технологии:
- Next.js 14 App Router, TypeScript
- Tailwind CSS, shadcn/ui
- React Query для данных, Zustand — локальные состояния по необходимости
- Vitest + React Testing Library, Playwright (Е2Е)

Структура:
- `src/app/page.tsx` — домашняя
- `src/app/(dashboard)/layout.tsx` — каркас
- `src/app/(dashboard)/feed/page.tsx` — лента
- `src/components/features/feed/PostCard.tsx` — карточка (Telegram‑стиль)
- `src/components/features/feed/PostEditor.tsx` — редактор поста
- `src/lib/hooks/useFeed.ts` — загрузка/создание постов через Supabase
- `src/lib/supabase/client.ts` — клиент Supabase

Состояния и UX:
- Загрузка, пусто, ошибка — обязательны.
- Реакции: emoji‑кнопки, hover эффекты (UI), без серверной записи на стартовом этапе.
- Accessibility: семантические элементы, aria‑атрибуты, focus‑стили.

Тесты (минимальный набор):
- Unit: `PostCard`, `PostEditor`, `useFeed`, домашняя страница, `/feed` страница
- Е2Е: открытие `/feed`, отображение списка постов после seed

## 10. Интеграция iOS

- Встраивание веб‑модулей через WebView (WKWebView, iOS 17+), единый стек навигации.
- Deep Linking: `lms://feed`, `lms://course/<id>` — маршрутизация в приложении.
- Логирование: `ComprehensiveLogger` (UI, network, data, navigation, error); тесты проверяют логи.
- Feature Registry: модуль Ленты зарегистрирован, интеграционный тест доступности в меню «Ещё».

## 11. CI/CD и деплой

- GitHub Actions: Джобы `test` (Node 20, npm ci, `npm run test:run`, `npm run build`) и `deploy` (Railway).
- Railway: `railway.toml` (NIXPACKS, health‑check `/api/health`, рестарт‑политика).
- Секреты: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SENTRY_DSN`.
- Pre‑commit hook: блокирует коммит с красными тестами (см. `cursor_tdd_methodology/git-hooks/pre-commit`).

## 12. Мониторинг и наблюдаемость

- `GET /api/health` + `GET /api/check-db` — проверки живости и статуса данных.
- Sentry (клиент/сервер), включение по переменной окружения.
- Railway Logs — оперативный просмотр логов.

## 13. Безопасность

- Все таблицы под RLS, запись — только аутентифицированным.
- Секреты — только в Secret Store (GitHub/ Railway), не в репозитории.
- CORS — ограничить доменами деплоя (этап продакшн).
- Ограничение скоростей (rate‑limit) для POST API (на уровне Next.js/Edge Function) — по мере появления серверных маршрутов.

## 14. Критерии приемки (DoD)

Функциональные:
- Страница `/feed` отображает реальные посты из Supabase после выполнения seed.
- `PostCard` — Telegram‑стиль, реакции визуально работают.
- `PostEditor` позволяет создать пост (dev/QA окружение), пост появляется в ленте.

Технические:
- Все unit тесты и сборка проходят локально и в CI.
- RLS включён, публичное чтение ленты работает, запись — только аутентифицированным.
- Health‑эндпоинты возвращают корректные ответы.

Документация:
- Обновлены разделы в `docs/` и `technical_requirements/` (данный документ актуален).

## 15. План запуска и вводные данные

- Dev seed: выполнить SQL из `supabase/seed_simple.sql` в Supabase SQL Editor.
- Проверка: `GET /api/check-db` должен показать непустые таблицы; страница `/feed` — карточки постов.
- Продакшн: настроить Supabase Auth и роли, включить FK на `profiles.id`, миграциями создать политики RLS.

## 16. Риски и допущения

- Несовпадение схемы таблиц и кода (устраняется миграциями; избежать полей, которых нет в базе).
- Ограничения RLS могут блокировать операции (в dev использовать сервис‑ключ/seed‑скрипты, в прод — корректные политики и аутентификация).
- Медиа‑хранилище — в первой итерации только URL, интеграция со Storage позже.

## 17. Приложения

- SQL seed (упрощённый): см. `supabase/seed_simple.sql` — создаёт 3 профиля, 3 канала, 3 поста.
- Проверка статуса: `CHECK_FEED_STATUS.md` — быстрые шаги валидации.
- Примеры RLS политик — в разделе 6.2; окончательное включение/отладка в Supabase UI.

---

Это ТЗ отражает текущую целевую архитектуру и минимально необходимый функционал для production‑ready модуля «Лента» в Telegram‑стиле, с упором на простоту деплоя и скорость итераций. Все изменения должны соответствовать методологии TDD и правилам проекта.
