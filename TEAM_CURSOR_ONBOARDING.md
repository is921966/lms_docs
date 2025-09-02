# Шпаргалка для команды: запуск проекта в Cursor

## 1) Клонирование и открытие в Cursor
```bash
# Вариант SSH
git clone git@github.com:is921966/lms_docs.git
cd lms_docs

# Веб‑клиент (отдельный репозиторий)
git clone git@github.com:is921966/lms-web-nextjs.git
```
В Cursor: File → Open Folder → выберите нужный репозиторий.

## 2) Подготовка окружения (web)
```bash
cd lms-web
cp .env.local.example .env.local
# вставьте значения Supabase из LastPass / у тимлида
npm ci
npm run test:run
npm run dev
```
Проверка: http://localhost:3000 и /api/health.

## 3) Быстрый dev‑seed БД (Supabase)
- Откройте `supabase/seed_simple.sql`
- Скопируйте SQL и выполните в Supabase SQL Editor
- Откройте /feed — должны появиться 2–3 поста

## 4) Полезные команды
```bash
# Проверка статуса прод БД
curl https://lms-web-nextjs-production.up.railway.app/api/check-db | jq

# Автозаполнение БД (dev)
node scripts/auto-populate-db.js
```

## 5) TDD и pre-commit
- Тест всегда пишется первым, коммиты с красными тестами блокируются.
- Перед пушем: `npm run test:run` (web) и `xcodebuild ... build` (iOS).

## 6) CI/CD и деплой
- GitHub Actions: тесты → билд → деплой в Railway.
- Секреты уже настроены (Supabase URL/Keys).

## 7) iOS проект (по требованию)
```bash
cd LMS_App/LMS
xcodebuild -scheme LMS -destination 'generic/platform=iOS' -configuration Release clean build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
```

## 8) Где читать спецификацию
- `technical_requirements/SYSTEM_TECHNICAL_SPEC_v2.2.0.md`
- `technical_requirements/REQUIREMENTS_CATALOG_v2.2.0.md`
- `technical_requirements/org_structure_module_tech_spec.md`

Если что‑то не запускается, создайте issue в GitHub с логами и скриншотами.
