# Sprint 54: Модернизация архитектуры - Rapid Development Platform

**Даты**: 24-31 июля 2025 (Дни 179-186)  
**Цель**: Создать платформу для сверхбыстрого прототипирования и развертывания новых модулей LMS  
**Подход**: Веб-first архитектура с мгновенным деплоем

## 🎯 Бизнес-цели спринта

1. **Ускорение разработки** - от идеи до production за часы, не дни
2. **Упрощение отладки** - все в браузере, без сложной настройки
3. **Быстрое тестирование гипотез** - A/B тесты новых функций
4. **Снижение порога входа** - junior разработчики могут вносить вклад

## 🏗️ Архитектурная трансформация

### Текущая архитектура:
- iOS Native (SwiftUI) + PHP Backend
- Долгий цикл разработки и деплоя
- Сложная настройка окружения

### Новая гибридная архитектура:
```
┌─────────────────────────────────────────────────┐
│              Production LMS                      │
├─────────────────────────────────────────────────┤
│  iOS App        │    Web App     │   Admin Panel│
│  (SwiftUI)      │  (React/Next)  │  (React/Bolt)│
├─────────────────────────────────────────────────┤
│             Unified API Layer                    │
├─────────────────┤                 │─────────────┤
│  Microservices  │                 │  Supabase   │
│  (PHP/K8s)      │                 │  Backend    │
└─────────────────┘                 └─────────────┘
```

## 📋 Детальный план реализации

### День 1-2: Инфраструктура и окружение

#### Задачи:
1. **Настройка Supabase проекта**
   - [ ] Создать Supabase проект для LMS
   - [ ] Настроить схему БД (миграция из PostgreSQL)
   - [ ] Настроить Row Level Security (RLS)
   - [ ] Настроить Auth providers (Email, OAuth)
   - [ ] Создать Edge Functions для бизнес-логики

2. **Настройка Railway**
   - [ ] Создать Railway проект
   - [ ] Настроить автодеплой из GitHub
   - [ ] Настроить переменные окружения
   - [ ] Настроить custom domains
   - [ ] Настроить monitoring и alerts

3. **WebContainer окружение**
   - [ ] Создать базовый template проекта
   - [ ] Настроить StackBlitz интеграцию
   - [ ] Подготовить dev environment config
   - [ ] Создать starter kit с компонентами

### День 3-4: Web App Foundation + Feed Module

#### Задачи:
1. **Next.js приложение**
   ```typescript
   // Структура проекта
   lms-web/
   ├── app/                    # App Router
   │   ├── (auth)/            # Auth группа
   │   ├── (dashboard)/       # Dashboard группа
   │   │   ├── feed/          # 🆕 Feed модуль
   │   │   │   ├── page.tsx   # Основная лента
   │   │   │   ├── [postId]/  # Детальный пост
   │   │   │   └── layout.tsx # Feed layout
   │   ├── courses/           # Курсы
   │   └── api/               # API routes
   │       ├── feed/          # 🆕 Feed API
   │       └── courses/
   ├── components/            # UI компоненты
   │   ├── ui/               # Базовые компоненты
   │   └── features/         # Feature компоненты
   │       ├── feed/         # 🆕 Feed компоненты
   │       │   ├── PostCard.tsx
   │       │   ├── PostEditor.tsx
   │       │   ├── ChannelSelector.tsx
   │       │   └── FeedFilters.tsx
   └── lib/                  # Утилиты
   ```

2. **UI Component Library**
   - [ ] Интегрировать shadcn/ui для базовых компонентов
   - [ ] Создать LMS-специфичные компоненты:
     - CourseCard
     - LessonPlayer
     - ProgressTracker
     - TestRunner
     - CertificateViewer
   - [ ] 🆕 Создать Feed компоненты:
     - PostCard (Classic и Telegram стили)
     - PostEditor с rich text
     - ChannelSelector
     - MediaUploader
     - CommentThread
   - [ ] Настроить Storybook для компонентов

3. **Feed Database Schema**
   ```sql
   -- Каналы ленты
   CREATE TABLE feed_channels (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     name TEXT NOT NULL,
     slug TEXT UNIQUE NOT NULL,
     description TEXT,
     icon TEXT,
     color TEXT,
     is_official BOOLEAN DEFAULT false,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Посты
   CREATE TABLE feed_posts (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     channel_id UUID REFERENCES feed_channels(id),
     author_id UUID REFERENCES profiles(id),
     title TEXT NOT NULL,
     content TEXT NOT NULL,
     excerpt TEXT,
     media_urls JSONB DEFAULT '[]',
     is_pinned BOOLEAN DEFAULT false,
     published_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Комментарии
   CREATE TABLE feed_comments (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     post_id UUID REFERENCES feed_posts(id),
     author_id UUID REFERENCES profiles(id),
     content TEXT NOT NULL,
     parent_id UUID REFERENCES feed_comments(id),
     created_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Реакции
   CREATE TABLE feed_reactions (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     post_id UUID REFERENCES feed_posts(id),
     user_id UUID REFERENCES profiles(id),
     type TEXT CHECK (type IN ('like', 'celebrate', 'support')),
     UNIQUE(post_id, user_id)
   );
   ```

### День 5: Rapid Development Tools + Feed Features

#### Задачи:
1. **Bolt.new-style команды для Feed**
   ```typescript
   // Команды для быстрого создания
   /component PostCard style="telegram" features="reactions,comments"
   /component FeedFilter type="channel,date,author"
   /page feed layout="infinite-scroll" filters="true"
   /api feed/posts methods="GET,POST" realtime="true"
   ```

2. **Realtime Feed с Supabase**
   ```typescript
   // hooks/useFeedRealtime.ts
   export function useFeedRealtime() {
     const [posts, setPosts] = useState<Post[]>([])
     
     useEffect(() => {
       // Подписка на новые посты
       const channel = supabase
         .channel('feed-posts')
         .on('postgres_changes', {
           event: 'INSERT',
           schema: 'public',
           table: 'feed_posts'
         }, (payload) => {
           setPosts(prev => [payload.new as Post, ...prev])
         })
         .subscribe()
       
       return () => {
         supabase.removeChannel(channel)
       }
     }, [])
     
     return { posts }
   }
   ```

3. **Feed Design System**
   - [ ] Classic режим (карточки)
   - [ ] Telegram режим (чат-стиль)
   - [ ] Переключение между режимами
   - [ ] Темная/светлая темы

### День 6: Миграция Course Catalog

#### Пилотный модуль #1: Course Catalog
1. **Функциональность**:
   - Список курсов с фильтрацией
   - Детальная страница курса
   - Запись на курс
   - Отслеживание прогресса

2. **Реализация**:
   ```typescript
   // app/courses/page.tsx
   export default async function CoursesPage() {
     const { data: courses } = await supabase
       .from('courses')
       .select(`
         *,
         categories(*),
         enrollments(count)
       `)
       .eq('status', 'published')
     
     return <CourseGrid courses={courses} />
   }
   ```

### День 7: Feed Module Completion

#### Пилотный модуль #2: Feed (Лента)
1. **Функциональность**:
   - Лента постов с бесконечной прокруткой
   - Фильтрация по каналам
   - Создание и редактирование постов
   - Комментарии и реакции
   - Realtime обновления
   - Поиск по ленте
   - Медиа-контент (изображения, видео)

2. **Feed компоненты**:
   ```typescript
   // app/(dashboard)/feed/page.tsx
   export default function FeedPage() {
     const { posts, loading } = useFeed()
     const [view, setView] = useState<'classic' | 'telegram'>('classic')
     
     return (
       <div className="container mx-auto py-6">
         <FeedHeader 
           onViewChange={setView}
           onCreatePost={() => setShowEditor(true)}
         />
         
         <div className="grid grid-cols-12 gap-6">
           <aside className="col-span-3">
             <ChannelList />
             <FeedFilters />
           </aside>
           
           <main className="col-span-6">
             {view === 'classic' ? (
               <ClassicFeedView posts={posts} />
             ) : (
               <TelegramFeedView posts={posts} />
             )}
           </main>
           
           <aside className="col-span-3">
             <TrendingTopics />
             <ActiveUsers />
           </aside>
         </div>
       </div>
     )
   }
   ```

3. **Rich Post Editor**:
   ```typescript
   // components/features/feed/PostEditor.tsx
   export function PostEditor({ onSubmit }: PostEditorProps) {
     const [content, setContent] = useState('')
     const editor = useEditor({
       extensions: [
         StarterKit,
         Image,
         Link,
         Mention.configure({
           suggestion: mentionSuggestion,
         }),
       ],
     })
     
     return (
       <Card>
         <CardHeader>
           <ChannelSelector />
         </CardHeader>
         <CardContent>
           <EditorContent editor={editor} />
           <MediaUploader />
         </CardContent>
         <CardFooter>
           <Button onClick={() => onSubmit(editor.getHTML())}>
             Опубликовать
           </Button>
         </CardFooter>
       </Card>
     )
   }
   ```

4. **Тесты для Feed**:
   - [ ] Unit тесты компонентов Feed
   - [ ] Integration тесты с realtime
   - [ ] E2E тесты создания поста
   - [ ] Performance тесты прокрутки

### День 8: Production Deployment + iOS Integration

#### Задачи:
1. **Railway deployment**
   - [ ] Production build оптимизация
   - [ ] Environment variables setup
   - [ ] SSL certificates
   - [ ] CDN configuration
   - [ ] Monitoring setup

2. **Интеграция Feed с iOS приложением**
   - [ ] WebView для веб-версии Feed
   - [ ] Нативный Feed остается как есть
   - [ ] Синхронизация между версиями
   - [ ] Shared authentication
   - [ ] Deep linking для постов

3. **Feed-specific интеграция**:
   ```swift
   // iOS: Переключение между нативным и веб Feed
   struct FeedContainerView: View {
       @AppStorage("useWebFeed") var useWebFeed = false
       
       var body: some View {
           if useWebFeed {
               WebModuleView(
                   url: URL(string: "\(baseURL)/feed")!,
                   isLoading: .constant(false)
               )
           } else {
               NativeFeedView() // Существующий iOS Feed
           }
       }
   }
   ```

## 🔧 Технический стек

### Frontend:
- **Framework**: Next.js 14 (App Router)
- **UI Library**: React + shadcn/ui
- **Styling**: Tailwind CSS
- **State**: Zustand + React Query
- **Rich Text**: TipTap editor
- **Testing**: Vitest + Testing Library

### Backend:
- **Primary**: Supabase (PostgreSQL + Auth + Realtime)
- **Edge Functions**: Deno runtime
- **File Storage**: Supabase Storage
- **Search**: PostgreSQL full-text search
- **Legacy API**: PHP microservices (постепенная миграция)

### Infrastructure:
- **Hosting**: Railway (primary) + Vercel (static)
- **Database**: Supabase (PostgreSQL)
- **CDN**: Cloudflare
- **Monitoring**: Railway metrics + Sentry

## 📊 Метрики успеха

1. **Скорость разработки**
   - Новая feature: 2 часа vs 2 дня
   - Deployment: 2 минуты vs 30 минут
   - Bug fix: 30 минут vs 3 часа

2. **Developer Experience**
   - Onboarding: 30 минут до первого коммита
   - Local setup: 5 минут
   - Test execution: < 1 минута

3. **Performance**
   - Page load: < 1s
   - API response: < 100ms
   - Lighthouse score: > 95
   - Feed scroll: 60 FPS

4. **Adoption**
   - 2 модуля полностью мигрированы (Courses + Feed)
   - 5 новых features через веб
   - 10+ разработчиков обучены
   - 100+ пользователей тестируют веб-версию

## 🚀 Дальнейшие шаги

### Sprint 55: Расширение платформы
- Миграция модулей Tests и Competencies
- AI-powered content recommendations
- Advanced analytics dashboard

### Sprint 56: Full Web Parity
- Полный функционал в вебе
- Progressive Web App
- Offline support для Feed

### Sprint 57: Unified Platform
- Единая кодовая база
- Cross-platform components
- Shared business logic

## ⚠️ Риски и митигация

1. **Риск**: Несовместимость с iOS
   - **Митигация**: API compatibility layer + постепенная миграция

2. **Риск**: Performance деградация при большом объеме постов
   - **Митигация**: Virtual scrolling + pagination + caching

3. **Риск**: Security concerns с user-generated content
   - **Митигация**: Content sanitization + moderation tools

4. **Риск**: Сложность миграции существующих постов
   - **Митигация**: ETL pipeline + data validation

## 📝 Definition of Done

- [ ] Supabase проект настроен и работает
- [ ] Railway deployment автоматизирован
- [ ] Web приложение доступно по URL
- [ ] Course Catalog модуль полностью функционален
- [ ] Feed модуль с realtime обновлениями работает
- [ ] Переключение между Classic/Telegram режимами
- [ ] Rich text editor с медиа поддержкой
- [ ] Тесты написаны и проходят (>90% coverage)
- [ ] Документация для разработчиков готова
- [ ] Performance метрики соответствуют целям
- [ ] iOS приложение может использовать веб-модули
- [ ] Команда обучена новым инструментам
- [ ] Демо для стейкхолдеров проведено

---
*Этот спринт закладывает фундамент для радикального ускорения разработки LMS через современные веб-технологии и демонстрирует возможности на примере двух ключевых модулей: Courses и Feed.* 