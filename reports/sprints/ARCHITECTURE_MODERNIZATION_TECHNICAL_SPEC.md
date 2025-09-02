# Техническая спецификация: Модернизация архитектуры LMS

**Версия**: 1.0.0  
**Дата**: 24 июля 2025  
**Sprint**: 54

## 🎯 Цель документа

Детальное техническое руководство по созданию платформы быстрой разработки для LMS с использованием современного веб-стека.

## 🚀 Quick Start Guide

### 1. Локальная разработка за 5 минут

```bash
# Клонируем новый репозиторий для веб-версии
git clone https://github.com/tsum/lms-web.git
cd lms-web

# Устанавливаем зависимости
npm install

# Копируем env файл
cp .env.example .env.local

# Запускаем dev сервер
npm run dev

# Открываем в браузере
open http://localhost:3000
```

### 2. Instant Preview в StackBlitz

```bash
# Открыть проект в браузере для мгновенной разработки
https://stackblitz.com/github/tsum/lms-web

# Или через npm
npx create-lms-module@latest my-feature
```

## 📦 Структура проекта

```
lms-web/
├── .env.example                 # Пример переменных окружения
├── package.json                 # Зависимости и скрипты
├── next.config.js              # Конфигурация Next.js
├── tailwind.config.js          # Конфигурация Tailwind
├── tsconfig.json               # TypeScript конфигурация
│
├── app/                        # Next.js App Router
│   ├── layout.tsx             # Root layout
│   ├── page.tsx               # Домашняя страница
│   ├── (auth)/                # Группа авторизации
│   │   ├── login/
│   │   ├── register/
│   │   └── layout.tsx
│   ├── (dashboard)/           # Группа dashboard
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── courses/
│   │   ├── profile/
│   │   └── settings/
│   └── api/                   # API Routes
│       ├── auth/
│       └── courses/
│
├── components/                # Компоненты
│   ├── ui/                   # shadcn/ui компоненты
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   └── ...
│   └── features/             # Feature-specific
│       ├── CourseCard.tsx
│       ├── LessonPlayer.tsx
│       └── ...
│
├── lib/                      # Утилиты
│   ├── supabase/            # Supabase клиенты
│   │   ├── client.ts
│   │   ├── server.ts
│   │   └── middleware.ts
│   ├── api/                 # API helpers
│   └── utils/               # Общие утилиты
│
├── hooks/                   # React hooks
│   ├── useAuth.ts
│   ├── useCourses.ts
│   └── useRealtime.ts
│
├── types/                   # TypeScript типы
│   ├── database.types.ts   # Сгенерированные из Supabase
│   └── app.types.ts
│
└── public/                  # Статические файлы
```

## 🔧 Настройка Supabase

### 1. Создание проекта

```bash
# Установка Supabase CLI
brew install supabase/tap/supabase

# Инициализация локального проекта
supabase init

# Запуск локального Supabase
supabase start
```

### 2. Схема базы данных

```sql
-- Миграция основных таблиц из существующей БД

-- Пользователи (расширение Supabase Auth)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'student',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Курсы
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  author_id UUID REFERENCES profiles(id),
  category_id UUID REFERENCES categories(id),
  duration_hours INTEGER,
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Записи на курсы
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  course_id UUID REFERENCES courses(id),
  status TEXT DEFAULT 'active',
  progress DECIMAL(5,2) DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, course_id)
);

-- Row Level Security
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;

-- Политики доступа
CREATE POLICY "Courses visible to all authenticated users" 
  ON courses FOR SELECT 
  TO authenticated 
  USING (status = 'published' OR author_id = auth.uid());

CREATE POLICY "Users can view their own enrollments" 
  ON enrollments FOR SELECT 
  TO authenticated 
  USING (user_id = auth.uid());
```

### 3. Edge Functions

```typescript
// supabase/functions/enroll-course/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { courseId } = await req.json()
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  const { data: { user } } = await supabase.auth.getUser(
    req.headers.get('Authorization')?.replace('Bearer ', '') ?? ''
  )
  
  if (!user) {
    return new Response('Unauthorized', { status: 401 })
  }
  
  // Проверяем существование курса
  const { data: course } = await supabase
    .from('courses')
    .select('id, title')
    .eq('id', courseId)
    .single()
  
  if (!course) {
    return new Response('Course not found', { status: 404 })
  }
  
  // Создаем запись
  const { data, error } = await supabase
    .from('enrollments')
    .insert({
      user_id: user.id,
      course_id: courseId
    })
    .select()
    .single()
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }
  
  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

## 🎨 UI Components с shadcn/ui

### 1. Установка компонентов

```bash
# Инициализация shadcn/ui
npx shadcn-ui@latest init

# Добавление компонентов
npx shadcn-ui@latest add button card dialog form
```

### 2. LMS-специфичные компоненты

```typescript
// components/features/CourseCard.tsx
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Clock, Users, Award } from "lucide-react"
import Image from "next/image"
import Link from "next/link"

interface CourseCardProps {
  course: {
    id: string
    title: string
    description: string
    thumbnail_url: string
    duration_hours: number
    difficulty_level: string
    enrollments_count: number
  }
  isEnrolled?: boolean
}

export function CourseCard({ course, isEnrolled = false }: CourseCardProps) {
  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      <div className="aspect-video relative">
        <Image
          src={course.thumbnail_url || "/placeholder-course.jpg"}
          alt={course.title}
          fill
          className="object-cover"
        />
        <Badge 
          className="absolute top-2 right-2"
          variant={
            course.difficulty_level === 'beginner' ? 'secondary' :
            course.difficulty_level === 'intermediate' ? 'default' : 
            'destructive'
          }
        >
          {course.difficulty_level}
        </Badge>
      </div>
      
      <CardHeader>
        <CardTitle className="line-clamp-2">{course.title}</CardTitle>
        <CardDescription className="line-clamp-3">
          {course.description}
        </CardDescription>
      </CardHeader>
      
      <CardContent>
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <Clock className="h-4 w-4" />
            <span>{course.duration_hours}ч</span>
          </div>
          <div className="flex items-center gap-1">
            <Users className="h-4 w-4" />
            <span>{course.enrollments_count}</span>
          </div>
          {isEnrolled && (
            <div className="flex items-center gap-1">
              <Award className="h-4 w-4 text-green-500" />
              <span className="text-green-500">Записан</span>
            </div>
          )}
        </div>
      </CardContent>
      
      <CardFooter>
        <Button asChild className="w-full">
          <Link href={`/courses/${course.id}`}>
            {isEnrolled ? 'Продолжить' : 'Подробнее'}
          </Link>
        </Button>
      </CardFooter>
    </Card>
  )
}
```

### 3. Интерактивные компоненты

```typescript
// components/features/LessonPlayer.tsx
"use client"

import { useState, useEffect } from 'react'
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { ChevronLeft, ChevronRight, CheckCircle } from "lucide-react"
import { useSupabase } from '@/hooks/useSupabase'

interface LessonPlayerProps {
  lesson: {
    id: string
    title: string
    content: string
    video_url?: string
    duration_minutes: number
  }
  courseId: string
  onComplete: () => void
}

export function LessonPlayer({ lesson, courseId, onComplete }: LessonPlayerProps) {
  const [progress, setProgress] = useState(0)
  const [isCompleted, setIsCompleted] = useState(false)
  const { supabase, user } = useSupabase()
  
  useEffect(() => {
    // Загружаем прогресс
    loadProgress()
  }, [lesson.id])
  
  async function loadProgress() {
    const { data } = await supabase
      .from('lesson_progress')
      .select('progress, is_completed')
      .eq('lesson_id', lesson.id)
      .eq('user_id', user?.id)
      .single()
    
    if (data) {
      setProgress(data.progress)
      setIsCompleted(data.is_completed)
    }
  }
  
  async function updateProgress(newProgress: number) {
    setProgress(newProgress)
    
    await supabase
      .from('lesson_progress')
      .upsert({
        user_id: user?.id,
        lesson_id: lesson.id,
        course_id: courseId,
        progress: newProgress,
        is_completed: newProgress >= 100
      })
    
    if (newProgress >= 100 && !isCompleted) {
      setIsCompleted(true)
      onComplete()
    }
  }
  
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">{lesson.title}</h2>
        {isCompleted && (
          <Badge variant="success" className="gap-1">
            <CheckCircle className="h-4 w-4" />
            Завершено
          </Badge>
        )}
      </div>
      
      <Progress value={progress} className="h-2" />
      
      {lesson.video_url ? (
        <video
          src={lesson.video_url}
          controls
          className="w-full rounded-lg"
          onTimeUpdate={(e) => {
            const video = e.currentTarget
            const progress = (video.currentTime / video.duration) * 100
            updateProgress(progress)
          }}
        />
      ) : (
        <div 
          className="prose prose-lg max-w-none"
          dangerouslySetInnerHTML={{ __html: lesson.content }}
        />
      )}
      
      <div className="flex justify-between">
        <Button variant="outline">
          <ChevronLeft className="mr-2 h-4 w-4" />
          Предыдущий урок
        </Button>
        <Button onClick={() => updateProgress(100)}>
          Завершить урок
          <ChevronRight className="ml-2 h-4 w-4" />
        </Button>
      </div>
    </div>
  )
}
```

## 🚄 Railway Deployment

### 1. Railway configuration

```toml
# railway.toml
[build]
builder = "nixpacks"
buildCommand = "npm run build"

[deploy]
startCommand = "npm start"
healthcheckPath = "/api/health"
healthcheckTimeout = 300

[variables]
NODE_ENV = "production"
```

### 2. GitHub Actions для автодеплоя

```yaml
# .github/workflows/deploy.yml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Railway
        run: npm i -g @railway/cli
      
      - name: Deploy
        run: railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

## 🎯 Bolt.new-style команды

### 1. Command система

```typescript
// lib/commands/index.ts
export const commands = {
  '/component': generateComponent,
  '/page': generatePage,
  '/api': generateAPI,
  '/test': generateTest,
}

async function generateComponent(args: string[]) {
  const [name, ...options] = args
  const template = `
import { FC } from 'react'

interface ${name}Props {
  // TODO: Add props
}

export const ${name}: FC<${name}Props> = (props) => {
  return (
    <div>
      {/* TODO: Implement ${name} */}
    </div>
  )
}
`
  
  // Сохраняем файл
  await fs.writeFile(
    `components/features/${name}.tsx`,
    template
  )
}
```

### 2. Live Preview интеграция

```typescript
// app/api/preview/route.ts
import { NextRequest } from 'next/server'
import { compile } from '@mdx-js/mdx'

export async function POST(request: NextRequest) {
  const { code, type } = await request.json()
  
  try {
    if (type === 'component') {
      // Компилируем и возвращаем preview
      const compiled = await compile(code, {
        outputFormat: 'function-body',
        development: true
      })
      
      return Response.json({ 
        success: true, 
        preview: compiled.toString() 
      })
    }
  } catch (error) {
    return Response.json({ 
      success: false, 
      error: error.message 
    })
  }
}
```

## 🔄 Интеграция с iOS

### 1. WebView компонент

```swift
// LMS/Features/WebModules/WebModuleView.swift
import SwiftUI
import WebKit

struct WebModuleView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Inject auth token
        let script = WKUserScript(
            source: """
            window.lmsAuth = {
                token: '\(AuthService.shared.token ?? "")',
                userId: '\(AuthService.shared.userId ?? "")'
            }
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        config.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebModuleView
        
        init(_ parent: WebModuleView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}
```

### 2. Deep linking

```typescript
// app/api/deeplink/route.ts
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const path = searchParams.get('path')
  const token = searchParams.get('token')
  
  // Валидируем токен
  const { data: { user } } = await supabase.auth.getUser(token)
  
  if (!user) {
    return Response.redirect('/login')
  }
  
  // Устанавливаем сессию
  const response = Response.redirect(path || '/')
  response.cookies.set('auth-token', token, {
    httpOnly: true,
    secure: true,
    sameSite: 'lax'
  })
  
  return response
}
```

## 📊 Мониторинг и аналитика

### 1. Performance monitoring

```typescript
// lib/monitoring.ts
import { Analytics } from '@vercel/analytics/react'
import * as Sentry from "@sentry/nextjs"

export function initMonitoring() {
  // Sentry для ошибок
  Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    tracesSampleRate: 0.1,
  })
  
  // Custom метрики
  if (typeof window !== 'undefined') {
    // Web Vitals
    const reportWebVitals = (metric: any) => {
      const { name, value, id } = metric
      
      // Отправляем в нашу аналитику
      fetch('/api/metrics', {
        method: 'POST',
        body: JSON.stringify({ name, value, id })
      })
    }
    
    // Page views
    const reportPageView = () => {
      fetch('/api/analytics/pageview', {
        method: 'POST',
        body: JSON.stringify({
          url: window.location.href,
          referrer: document.referrer
        })
      })
    }
  }
}
```

## 🧪 Тестирование

### 1. Unit tests с Vitest

```typescript
// components/features/__tests__/CourseCard.test.tsx
import { render, screen } from '@testing-library/react'
import { CourseCard } from '../CourseCard'

describe('CourseCard', () => {
  const mockCourse = {
    id: '1',
    title: 'Test Course',
    description: 'Test description',
    thumbnail_url: '/test.jpg',
    duration_hours: 10,
    difficulty_level: 'beginner',
    enrollments_count: 100
  }
  
  it('renders course information', () => {
    render(<CourseCard course={mockCourse} />)
    
    expect(screen.getByText('Test Course')).toBeInTheDocument()
    expect(screen.getByText('Test description')).toBeInTheDocument()
    expect(screen.getByText('10ч')).toBeInTheDocument()
    expect(screen.getByText('100')).toBeInTheDocument()
  })
  
  it('shows enrolled badge when enrolled', () => {
    render(<CourseCard course={mockCourse} isEnrolled={true} />)
    
    expect(screen.getByText('Записан')).toBeInTheDocument()
    expect(screen.getByText('Продолжить')).toBeInTheDocument()
  })
})
```

### 2. E2E tests с Playwright

```typescript
// e2e/course-enrollment.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Course Enrollment', () => {
  test('user can enroll in a course', async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('[name="email"]', 'test@example.com')
    await page.fill('[name="password"]', 'password')
    await page.click('button[type="submit"]')
    
    // Navigate to courses
    await page.goto('/courses')
    await expect(page).toHaveTitle(/Курсы/)
    
    // Click on first course
    await page.click('.course-card:first-child')
    
    // Enroll
    await page.click('button:has-text("Записаться")')
    
    // Verify enrollment
    await expect(page.locator('text=Вы записаны на курс')).toBeVisible()
  })
})
```

## 🚀 Performance оптимизация

### 1. Next.js оптимизации

```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['your-supabase-url.supabase.co'],
    formats: ['image/avif', 'image/webp'],
  },
  
  experimental: {
    serverActions: true,
  },
  
  // Bundle analyzer
  webpack: (config, { isServer }) => {
    if (process.env.ANALYZE) {
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: 'static',
          reportFilename: isServer 
            ? '../analyze/server.html' 
            : './analyze/client.html',
        })
      )
    }
    return config
  },
}
```

### 2. Database оптимизации

```sql
-- Индексы для производительности
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_category ON courses(category_id);
CREATE INDEX idx_enrollments_user ON enrollments(user_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);

-- Materialized view для статистики
CREATE MATERIALIZED VIEW course_stats AS
SELECT 
  c.id,
  c.title,
  COUNT(DISTINCT e.user_id) as enrollments_count,
  AVG(e.progress) as avg_progress,
  COUNT(DISTINCT CASE WHEN e.completed_at IS NOT NULL THEN e.user_id END) as completions_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title;

-- Refresh периодически
CREATE OR REPLACE FUNCTION refresh_course_stats()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY course_stats;
END;
$$ LANGUAGE plpgsql;
```

---

*Эта техническая спецификация обеспечивает полное руководство по созданию современной платформы быстрой разработки для LMS.* 

# Technical Specification: Architecture Modernization

**Sprint 54**: Rapid Development Platform  
**Версия**: 1.0  
**Дата**: 23 июля 2025

## 🚀 Quick Start

```bash
# Клонировать репозиторий
git clone https://github.com/tsum/lms-web.git
cd lms-web

# Установить зависимости
npm install

# Настроить окружение
cp .env.example .env.local
# Заполнить SUPABASE_URL и SUPABASE_ANON_KEY

# Запустить dev сервер
npm run dev

# Открыть в браузере
open http://localhost:3000
```

## 📁 Структура проекта

```
lms-web/
├── app/                      # Next.js App Router
│   ├── (auth)/              # Auth layout группа
│   │   ├── login/
│   │   ├── register/
│   │   └── forgot-password/
│   ├── (dashboard)/         # Dashboard layout
│   │   ├── page.tsx        # Home dashboard
│   │   ├── courses/        # Курсы
│   │   ├── feed/           # 🆕 Лента
│   │   │   ├── page.tsx
│   │   │   ├── [postId]/
│   │   │   └── create/
│   │   ├── tests/          # Тесты
│   │   └── profile/        # Профиль
│   ├── api/                # API Routes
│   │   ├── auth/
│   │   ├── courses/
│   │   ├── feed/           # 🆕 Feed API
│   │   └── webhooks/
│   └── layout.tsx          # Root layout
├── components/
│   ├── ui/                 # shadcn/ui компоненты
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   └── ...
│   ├── features/           # Feature-specific
│   │   ├── courses/
│   │   ├── feed/           # 🆕 Feed компоненты
│   │   │   ├── PostCard.tsx
│   │   │   ├── PostEditor.tsx
│   │   │   ├── ChannelList.tsx
│   │   │   └── FeedFilters.tsx
│   │   └── auth/
│   └── layout/            # Layout компоненты
├── lib/                   # Утилиты
│   ├── supabase/         # Supabase clients
│   ├── commands/         # Bolt-style commands
│   ├── hooks/            # React hooks
│   │   ├── useFeed.ts    # 🆕 Feed hooks
│   │   └── useCourses.ts
│   └── utils/            # Helpers
├── public/               # Статика
├── styles/              # Глобальные стили
└── tests/               # Тесты
```

## 🗄️ Supabase Setup

### 1. Database Schema

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles (расширение auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT CHECK (role IN ('student', 'instructor', 'admin')),
  department TEXT,
  position TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Courses
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  cover_image TEXT,
  instructor_id UUID REFERENCES profiles(id),
  category TEXT,
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  duration_hours INTEGER,
  status TEXT CHECK (status IN ('draft', 'published', 'archived')) DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Course Modules
CREATE TABLE course_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lessons
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  video_url TEXT,
  order_index INTEGER NOT NULL,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enrollments
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  course_id UUID REFERENCES courses(id),
  status TEXT CHECK (status IN ('active', 'completed', 'dropped')) DEFAULT 'active',
  progress DECIMAL(5,2) DEFAULT 0,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, course_id)
);

-- Feed Tables 🆕
-- Каналы ленты
CREATE TABLE feed_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  icon TEXT DEFAULT 'megaphone',
  color TEXT DEFAULT '#3B82F6',
  is_official BOOLEAN DEFAULT false,
  is_archived BOOLEAN DEFAULT false,
  creator_id UUID REFERENCES profiles(id),
  subscribers_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Подписки на каналы
CREATE TABLE feed_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  channel_id UUID REFERENCES feed_channels(id),
  is_muted BOOLEAN DEFAULT false,
  subscribed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, channel_id)
);

-- Посты в ленте
CREATE TABLE feed_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_id UUID REFERENCES feed_channels(id),
  author_id UUID REFERENCES profiles(id),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  excerpt TEXT,
  media_urls JSONB DEFAULT '[]',
  is_pinned BOOLEAN DEFAULT false,
  is_draft BOOLEAN DEFAULT false,
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Комментарии
CREATE TABLE feed_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES feed_posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  parent_id UUID REFERENCES feed_comments(id),
  is_edited BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Реакции на посты
CREATE TABLE feed_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES feed_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  type TEXT CHECK (type IN ('like', 'celebrate', 'support', 'love', 'insightful')) DEFAULT 'like',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Закладки
CREATE TABLE feed_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  post_id UUID REFERENCES feed_posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- Индексы для производительности
CREATE INDEX idx_feed_posts_channel ON feed_posts(channel_id);
CREATE INDEX idx_feed_posts_author ON feed_posts(author_id);
CREATE INDEX idx_feed_posts_published ON feed_posts(published_at DESC);
CREATE INDEX idx_feed_comments_post ON feed_comments(post_id);
CREATE INDEX idx_feed_reactions_post ON feed_reactions(post_id);
```

### 2. Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_reactions ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone" 
  ON profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Courses policies
CREATE POLICY "Published courses are viewable by everyone" 
  ON courses FOR SELECT 
  USING (status = 'published' OR instructor_id = auth.uid());

CREATE POLICY "Instructors can create courses" 
  ON courses FOR INSERT 
  WITH CHECK (auth.uid() = instructor_id);

-- Feed policies 🆕
CREATE POLICY "Feed channels are viewable by everyone"
  ON feed_channels FOR SELECT
  USING (NOT is_archived);

CREATE POLICY "Official channels only by admins"
  ON feed_channels FOR INSERT
  WITH CHECK (
    (is_official = false) OR 
    (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  );

CREATE POLICY "Feed posts viewable by everyone"
  ON feed_posts FOR SELECT
  USING (NOT is_draft OR author_id = auth.uid());

CREATE POLICY "Users can create posts in subscribed channels"
  ON feed_posts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM feed_subscriptions 
      WHERE user_id = auth.uid() AND channel_id = feed_posts.channel_id
    )
  );

CREATE POLICY "Users can update own posts"
  ON feed_posts FOR UPDATE
  USING (author_id = auth.uid());

CREATE POLICY "Users can delete own posts"
  ON feed_posts FOR DELETE
  USING (author_id = auth.uid());

CREATE POLICY "Comments viewable by everyone"
  ON feed_comments FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can comment"
  ON feed_comments FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own comments"
  ON feed_comments FOR UPDATE
  USING (author_id = auth.uid());

CREATE POLICY "Reactions by authenticated users"
  ON feed_reactions FOR ALL
  USING (auth.uid() = user_id);
```

### 3. Edge Functions

```typescript
// supabase/functions/create-post/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { title, content, channel_id, media_urls } = await req.json()

    // Validate input
    if (!title || !content || !channel_id) {
      throw new Error('Missing required fields')
    }

    // Create post
    const { data: post, error: postError } = await supabaseClient
      .from('feed_posts')
      .insert({
        title,
        content,
        channel_id,
        media_urls: media_urls || [],
        author_id: (await supabaseClient.auth.getUser()).data.user?.id,
        excerpt: content.substring(0, 200)
      })
      .select()
      .single()

    if (postError) throw postError

    // Update channel stats
    await supabaseClient.rpc('increment_channel_posts', { 
      channel_id: channel_id 
    })

    // Send notifications to subscribers
    const { data: subscribers } = await supabaseClient
      .from('feed_subscriptions')
      .select('user_id')
      .eq('channel_id', channel_id)
      .eq('is_muted', false)

    // TODO: Send push notifications

    return new Response(
      JSON.stringify({ post }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
```

## 🎨 UI Components

### Feed Components 🆕

#### PostCard Component
```typescript
// components/features/feed/PostCard.tsx
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'
import { Heart, MessageCircle, Bookmark, Share } from 'lucide-react'
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

interface PostCardProps {
  post: {
    id: string
    title: string
    content: string
    author: {
      full_name: string
      avatar_url?: string
    }
    channel: {
      name: string
      color: string
    }
    published_at: string
    likes_count: number
    comments_count: number
    media_urls?: string[]
    is_liked?: boolean
    is_bookmarked?: boolean
  }
  variant?: 'classic' | 'telegram'
}

export function PostCard({ post, variant = 'classic' }: PostCardProps) {
  if (variant === 'telegram') {
    return <TelegramPostCard post={post} />
  }

  return (
    <Card className="mb-4">
      <CardHeader>
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <Avatar>
              <AvatarImage src={post.author.avatar_url} />
              <AvatarFallback>{post.author.full_name[0]}</AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium">{post.author.full_name}</p>
              <p className="text-sm text-muted-foreground">
                {formatDistanceToNow(new Date(post.published_at), { 
                  addSuffix: true, 
                  locale: ru 
                })}
              </p>
            </div>
          </div>
          <Badge style={{ backgroundColor: post.channel.color }}>
            {post.channel.name}
          </Badge>
        </div>
      </CardHeader>
      
      <CardContent>
        <h3 className="text-lg font-semibold mb-2">{post.title}</h3>
        <div 
          className="prose prose-sm max-w-none"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />
        
        {post.media_urls && post.media_urls.length > 0 && (
          <div className="grid grid-cols-2 gap-2 mt-4">
            {post.media_urls.map((url, idx) => (
              <img 
                key={idx}
                src={url} 
                alt=""
                className="rounded-lg object-cover w-full h-48"
              />
            ))}
          </div>
        )}
      </CardContent>
      
      <CardFooter className="flex justify-between">
        <div className="flex gap-2">
          <Button 
            variant="ghost" 
            size="sm"
            className={post.is_liked ? 'text-red-500' : ''}
          >
            <Heart className="w-4 h-4 mr-1" />
            {post.likes_count}
          </Button>
          <Button variant="ghost" size="sm">
            <MessageCircle className="w-4 h-4 mr-1" />
            {post.comments_count}
          </Button>
        </div>
        <div className="flex gap-2">
          <Button 
            variant="ghost" 
            size="sm"
            className={post.is_bookmarked ? 'text-blue-500' : ''}
          >
            <Bookmark className="w-4 h-4" />
          </Button>
          <Button variant="ghost" size="sm">
            <Share className="w-4 h-4" />
          </Button>
        </div>
      </CardFooter>
    </Card>
  )
}

function TelegramPostCard({ post }: { post: PostCardProps['post'] }) {
  return (
    <div className="flex gap-3 mb-4 hover:bg-muted/50 p-3 rounded-lg transition-colors">
      <Avatar className="w-10 h-10">
        <AvatarImage src={post.author.avatar_url} />
        <AvatarFallback>{post.author.full_name[0]}</AvatarFallback>
      </Avatar>
      
      <div className="flex-1">
        <div className="flex items-baseline gap-2 mb-1">
          <span className="font-medium">{post.author.full_name}</span>
          <span className="text-xs text-muted-foreground">
            {formatDistanceToNow(new Date(post.published_at), { 
              addSuffix: true, 
              locale: ru 
            })}
          </span>
        </div>
        
        <h4 className="font-medium mb-1">{post.title}</h4>
        <div 
          className="text-sm"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />
        
        <div className="flex gap-4 mt-2 text-sm text-muted-foreground">
          <button className="hover:text-red-500 transition-colors">
            ❤️ {post.likes_count}
          </button>
          <button className="hover:text-blue-500 transition-colors">
            💬 {post.comments_count}
          </button>
        </div>
      </div>
    </div>
  )
}
```

#### PostEditor Component
```typescript
// components/features/feed/PostEditor.tsx
import { useState } from 'react'
import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import Mention from '@tiptap/extension-mention'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { 
  Bold, 
  Italic, 
  List, 
  ListOrdered, 
  Link2, 
  Image as ImageIcon,
  Send
} from 'lucide-react'
import { ChannelSelector } from './ChannelSelector'
import { MediaUploader } from './MediaUploader'

interface PostEditorProps {
  onSubmit: (post: {
    title: string
    content: string
    channel_id: string
    media_urls?: string[]
  }) => Promise<void>
  channels: Array<{ id: string; name: string; color: string }>
}

export function PostEditor({ onSubmit, channels }: PostEditorProps) {
  const [title, setTitle] = useState('')
  const [selectedChannel, setSelectedChannel] = useState('')
  const [mediaUrls, setMediaUrls] = useState<string[]>([])
  const [isSubmitting, setIsSubmitting] = useState(false)

  const editor = useEditor({
    extensions: [
      StarterKit,
      Image,
      Link.configure({
        openOnClick: false,
      }),
      Mention.configure({
        HTMLAttributes: {
          class: 'mention',
        },
        suggestion: {
          // Implement mention suggestions
        },
      }),
    ],
    content: '<p>Начните писать...</p>',
    editorProps: {
      attributes: {
        class: 'prose prose-sm max-w-none focus:outline-none min-h-[150px]',
      },
    },
  })

  const handleSubmit = async () => {
    if (!title || !editor?.getHTML() || !selectedChannel) return

    setIsSubmitting(true)
    try {
      await onSubmit({
        title,
        content: editor.getHTML(),
        channel_id: selectedChannel,
        media_urls: mediaUrls.length > 0 ? mediaUrls : undefined,
      })
      
      // Reset form
      setTitle('')
      editor?.commands.clearContent()
      setSelectedChannel('')
      setMediaUrls([])
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <div className="space-y-4">
          <div>
            <Label htmlFor="title">Заголовок</Label>
            <Input
              id="title"
              placeholder="О чем вы хотите рассказать?"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>
          
          <ChannelSelector
            channels={channels}
            value={selectedChannel}
            onChange={setSelectedChannel}
          />
        </div>
      </CardHeader>
      
      <CardContent>
        <div className="border rounded-lg p-4">
          <div className="flex items-center gap-2 mb-4 pb-4 border-b">
            <Button
              size="sm"
              variant="ghost"
              onClick={() => editor?.chain().focus().toggleBold().run()}
              className={editor?.isActive('bold') ? 'bg-muted' : ''}
            >
              <Bold className="w-4 h-4" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => editor?.chain().focus().toggleItalic().run()}
              className={editor?.isActive('italic') ? 'bg-muted' : ''}
            >
              <Italic className="w-4 h-4" />
            </Button>
            <div className="w-px h-6 bg-border" />
            <Button
              size="sm"
              variant="ghost"
              onClick={() => editor?.chain().focus().toggleBulletList().run()}
              className={editor?.isActive('bulletList') ? 'bg-muted' : ''}
            >
              <List className="w-4 h-4" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => editor?.chain().focus().toggleOrderedList().run()}
              className={editor?.isActive('orderedList') ? 'bg-muted' : ''}
            >
              <ListOrdered className="w-4 h-4" />
            </Button>
            <div className="w-px h-6 bg-border" />
            <Button
              size="sm"
              variant="ghost"
              onClick={() => {
                const url = window.prompt('URL:')
                if (url) {
                  editor?.chain().focus().setLink({ href: url }).run()
                }
              }}
            >
              <Link2 className="w-4 h-4" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => {
                // Open media uploader
              }}
            >
              <ImageIcon className="w-4 h-4" />
            </Button>
          </div>
          
          <EditorContent editor={editor} />
        </div>
        
        <MediaUploader
          value={mediaUrls}
          onChange={setMediaUrls}
          className="mt-4"
        />
      </CardContent>
      
      <CardFooter className="flex justify-between">
        <div className="text-sm text-muted-foreground">
          {editor?.storage.characterCount.characters()} символов
        </div>
        <Button 
          onClick={handleSubmit}
          disabled={!title || !selectedChannel || isSubmitting}
        >
          <Send className="w-4 h-4 mr-2" />
          Опубликовать
        </Button>
      </CardFooter>
    </Card>
  )
}
```

### Course Components

#### CourseCard Component
```typescript
// components/features/courses/CourseCard.tsx
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Clock, Users, BarChart } from 'lucide-react'

interface CourseCardProps {
  course: {
    id: string
    title: string
    description: string
    cover_image?: string
    instructor: {
      full_name: string
      avatar_url?: string
    }
    category: string
    difficulty: 'beginner' | 'intermediate' | 'advanced'
    duration_hours: number
    enrollments_count: number
    progress?: number
  }
  onEnroll?: () => void
  onContinue?: () => void
}

export function CourseCard({ course, onEnroll, onContinue }: CourseCardProps) {
  const difficultyColors = {
    beginner: 'bg-green-500',
    intermediate: 'bg-yellow-500',
    advanced: 'bg-red-500'
  }

  const isEnrolled = course.progress !== undefined

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      {course.cover_image && (
        <div className="aspect-video relative overflow-hidden">
          <img 
            src={course.cover_image} 
            alt={course.title}
            className="object-cover w-full h-full"
          />
          <Badge className="absolute top-2 right-2">
            {course.category}
          </Badge>
        </div>
      )}
      
      <CardHeader>
        <h3 className="font-semibold text-lg line-clamp-2">
          {course.title}
        </h3>
        <p className="text-sm text-muted-foreground line-clamp-2">
          {course.description}
        </p>
      </CardHeader>
      
      <CardContent>
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <Clock className="w-4 h-4" />
            {course.duration_hours}ч
          </div>
          <div className="flex items-center gap-1">
            <Users className="w-4 h-4" />
            {course.enrollments_count}
          </div>
          <div className="flex items-center gap-1">
            <BarChart className="w-4 h-4" />
            <span className={`px-2 py-0.5 rounded text-xs text-white ${difficultyColors[course.difficulty]}`}>
              {course.difficulty}
            </span>
          </div>
        </div>
        
        {isEnrolled && (
          <div className="mt-4">
            <div className="flex justify-between text-sm mb-1">
              <span>Прогресс</span>
              <span>{course.progress}%</span>
            </div>
            <Progress value={course.progress} />
          </div>
        )}
      </CardContent>
      
      <CardFooter>
        {isEnrolled ? (
          <Button onClick={onContinue} className="w-full">
            Продолжить обучение
          </Button>
        ) : (
          <Button onClick={onEnroll} className="w-full">
            Записаться на курс
          </Button>
        )}
      </CardFooter>
    </Card>
  )
}
```

#### LessonPlayer Component
```typescript
// components/features/courses/LessonPlayer.tsx
import { useState } from 'react'
import ReactPlayer from 'react-player'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { CheckCircle, PlayCircle, FileText, Download } from 'lucide-react'

interface LessonPlayerProps {
  lesson: {
    id: string
    title: string
    video_url?: string
    content?: string
    materials?: Array<{
      id: string
      title: string
      url: string
      type: string
    }>
  }
  onComplete: () => void
  onNext?: () => void
  onPrevious?: () => void
}

export function LessonPlayer({ lesson, onComplete, onNext, onPrevious }: LessonPlayerProps) {
  const [isCompleted, setIsCompleted] = useState(false)
  const [progress, setProgress] = useState(0)

  const handleComplete = () => {
    setIsCompleted(true)
    onComplete()
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold mb-2">{lesson.title}</h1>
        <div className="flex items-center gap-4">
          <Button
            variant="outline"
            size="sm"
            onClick={onPrevious}
            disabled={!onPrevious}
          >
            Предыдущий урок
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={onNext}
            disabled={!onNext}
          >
            Следующий урок
          </Button>
          <div className="ml-auto">
            {isCompleted ? (
              <Badge variant="success">
                <CheckCircle className="w-4 h-4 mr-1" />
                Завершено
              </Badge>
            ) : (
              <Button onClick={handleComplete} size="sm">
                Отметить как пройденное
              </Button>
            )}
          </div>
        </div>
      </div>

      {lesson.video_url && (
        <Card>
          <CardContent className="p-0">
            <div className="aspect-video">
              <ReactPlayer
                url={lesson.video_url}
                width="100%"
                height="100%"
                controls
                onProgress={({ played }) => setProgress(played * 100)}
                onEnded={handleComplete}
              />
            </div>
          </CardContent>
        </Card>
      )}

      <Tabs defaultValue="content">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="content">Содержание</TabsTrigger>
          <TabsTrigger value="materials">Материалы</TabsTrigger>
        </TabsList>
        
        <TabsContent value="content" className="mt-4">
          {lesson.content && (
            <Card>
              <CardContent className="prose max-w-none">
                <div dangerouslySetInnerHTML={{ __html: lesson.content }} />
              </CardContent>
            </Card>
          )}
        </TabsContent>
        
        <TabsContent value="materials" className="mt-4">
          <div className="space-y-2">
            {lesson.materials?.map((material) => (
              <Card key={material.id}>
                <CardContent className="flex items-center justify-between p-4">
                  <div className="flex items-center gap-3">
                    <FileText className="w-5 h-5 text-muted-foreground" />
                    <div>
                      <p className="font-medium">{material.title}</p>
                      <p className="text-sm text-muted-foreground">
                        {material.type}
                      </p>
                    </div>
                  </div>
                  <Button variant="ghost" size="sm" asChild>
                    <a href={material.url} download>
                      <Download className="w-4 h-4" />
                    </a>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
```

## 🚀 Railway Deployment

### railway.toml
```toml
[build]
builder = "NIXPACKS"
buildCommand = "npm run build"

[deploy]
startCommand = "npm start"
healthcheckPath = "/api/health"
healthcheckTimeout = 100
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[[services]]
name = "web"
port = 3000

[services.web]
numReplicas = 2

[[services.web.healthcheck]]
type = "http"
path = "/api/health"
interval = 30
timeout = 10
```

### Environment Variables
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# Railway
RAILWAY_STATIC_URL=https://your-app.up.railway.app

# Analytics
NEXT_PUBLIC_VERCEL_ANALYTICS_ID=your-analytics-id
SENTRY_DSN=your-sentry-dsn
```

## 🤖 GitHub Actions

### .github/workflows/deploy.yml
```yaml
name: Deploy to Railway

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Run E2E tests
        run: npm run test:e2e

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Railway
        uses: berviantoleo/railway-deploy@v1.0.1
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
          service: "lms-web"
```

## ⚡ Bolt.new-style Commands

### Command System Setup
```typescript
// lib/commands/index.ts
import { componentCommand } from './component'
import { pageCommand } from './page'
import { apiCommand } from './api'
import { testCommand } from './test'

export const commands = {
  '/component': componentCommand,
  '/page': pageCommand,
  '/api': apiCommand,
  '/test': testCommand,
}

// Example: /component command
export async function componentCommand(args: string[]) {
  const [name, ...options] = args
  const template = await getComponentTemplate(name, options)
  
  return {
    files: [{
      path: `components/features/${name}.tsx`,
      content: template
    }],
    message: `Created ${name} component`
  }
}
```

### Usage Examples
```bash
# Create a feed post component
/component FeedPost style="minimal" features="likes,share"

# Create a new page
/page dashboard/analytics layout="grid" auth="required"

# Create API endpoint
/api courses/enroll method="POST" validate="true"

# Generate tests
/test CourseCard type="unit,integration"
```

## 📱 iOS Integration

### WebView Module
```swift
// Features/WebModules/WebModuleView.swift
import SwiftUI
import WebKit

struct WebModuleView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    var onNavigate: ((URL) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Inject auth token
        let script = """
        window.addEventListener('message', function(e) {
            if (e.data.type === 'auth-token') {
                localStorage.setItem('supabase.auth.token', e.data.token);
            }
        });
        """
        
        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        config.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebModuleView
        
        init(_ parent: WebModuleView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            // Send auth token
            if let token = AuthService.shared.currentToken {
                let js = "window.postMessage({type: 'auth-token', token: '\(token)'}, '*')"
                webView.evaluateJavaScript(js)
            }
        }
    }
}
```

### Deep Linking
```typescript
// app/api/deeplink/route.ts
import { NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const path = searchParams.get('path')
  const token = searchParams.get('token')
  
  // Validate token
  const { data: user } = await supabase.auth.getUser(token)
  if (!user) {
    return new Response('Unauthorized', { status: 401 })
  }
  
  // Redirect to requested path
  return Response.redirect(new URL(path || '/', request.url))
}
```

## 📊 Monitoring

### Setup
```typescript
// lib/monitoring.ts
import * as Sentry from "@sentry/nextjs"
import { Analytics } from '@vercel/analytics/react'

// Sentry initialization
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
})

// Custom metrics
export function trackEvent(name: string, properties?: Record<string, any>) {
  // Vercel Analytics
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', name, properties)
  }
  
  // Custom backend
  fetch('/api/analytics', {
    method: 'POST',
    body: JSON.stringify({ event: name, properties })
  })
}

// Performance monitoring
export function measurePerformance(name: string, fn: () => void) {
  const start = performance.now()
  fn()
  const duration = performance.now() - start
  
  trackEvent('performance', {
    metric: name,
    duration: Math.round(duration)
  })
}
```

## 🧪 Testing

### Unit Tests (Vitest)
```typescript
// tests/components/CourseCard.test.tsx
import { render, screen } from '@testing-library/react'
import { CourseCard } from '@/components/features/courses/CourseCard'

describe('CourseCard', () => {
  const mockCourse = {
    id: '1',
    title: 'Test Course',
    description: 'Test description',
    instructor: { full_name: 'John Doe' },
    category: 'Programming',
    difficulty: 'beginner' as const,
    duration_hours: 10,
    enrollments_count: 100
  }

  it('renders course information', () => {
    render(<CourseCard course={mockCourse} />)
    
    expect(screen.getByText('Test Course')).toBeInTheDocument()
    expect(screen.getByText('Test description')).toBeInTheDocument()
    expect(screen.getByText('10ч')).toBeInTheDocument()
  })

  it('shows enroll button when not enrolled', () => {
    render(<CourseCard course={mockCourse} />)
    
    expect(screen.getByText('Записаться на курс')).toBeInTheDocument()
  })

  it('shows progress when enrolled', () => {
    const enrolledCourse = { ...mockCourse, progress: 60 }
    render(<CourseCard course={enrolledCourse} />)
    
    expect(screen.getByText('60%')).toBeInTheDocument()
    expect(screen.getByText('Продолжить обучение')).toBeInTheDocument()
  })
})
```

### E2E Tests (Playwright)
```typescript
// tests/e2e/feed.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Feed functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('[name="email"]', 'test@example.com')
    await page.fill('[name="password"]', 'password')
    await page.click('button[type="submit"]')
    await page.waitForURL('/feed')
  })

  test('create new post', async ({ page }) => {
    // Click create post button
    await page.click('button:has-text("Создать пост")')
    
    // Fill form
    await page.fill('[name="title"]', 'Test Post')
    await page.fill('.ProseMirror', 'This is a test post content')
    
    // Select channel
    await page.click('[data-testid="channel-selector"]')
    await page.click('text=Общий')
    
    // Submit
    await page.click('button:has-text("Опубликовать")')
    
    // Verify post appears
    await expect(page.locator('text=Test Post')).toBeVisible()
  })

  test('switch between feed views', async ({ page }) => {
    // Default is classic view
    await expect(page.locator('[data-view="classic"]')).toBeVisible()
    
    // Switch to telegram view
    await page.click('button[aria-label="Telegram view"]')
    await expect(page.locator('[data-view="telegram"]')).toBeVisible()
    
    // Posts should still be visible
    await expect(page.locator('[data-testid="post-card"]').first()).toBeVisible()
  })

  test('real-time updates', async ({ page, context }) => {
    // Open second tab
    const page2 = await context.newPage()
    await page2.goto('/feed')
    
    // Create post in first tab
    await page.click('button:has-text("Создать пост")')
    await page.fill('[name="title"]', 'Real-time Test')
    await page.fill('.ProseMirror', 'Testing real-time updates')
    await page.click('[data-testid="channel-selector"]')
    await page.click('text=Общий')
    await page.click('button:has-text("Опубликовать")')
    
    // Verify post appears in second tab without refresh
    await expect(page2.locator('text=Real-time Test')).toBeVisible({ timeout: 5000 })
  })
})
```

### Integration Tests
```typescript
// tests/integration/feed-api.test.ts
import { createClient } from '@supabase/supabase-js'
import { describe, it, expect, beforeEach } from 'vitest'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
)

describe('Feed API', () => {
  beforeEach(async () => {
    // Clean up test data
    await supabase.from('feed_posts').delete().match({ title: 'Test Post' })
  })

  it('creates post with proper permissions', async () => {
    // Create test user
    const { data: { user } } = await supabase.auth.signUp({
      email: 'test@example.com',
      password: 'password'
    })

    // Subscribe to channel
    await supabase.from('feed_subscriptions').insert({
      user_id: user!.id,
      channel_id: 'general-channel-id'
    })

    // Create post
    const { data: post, error } = await supabase
      .from('feed_posts')
      .insert({
        title: 'Test Post',
        content: 'Test content',
        channel_id: 'general-channel-id',
        author_id: user!.id
      })
      .select()
      .single()

    expect(error).toBeNull()
    expect(post).toBeDefined()
    expect(post.title).toBe('Test Post')
  })

  it('prevents posting to unsubscribed channels', async () => {
    const { data: { user } } = await supabase.auth.signUp({
      email: 'test2@example.com',
      password: 'password'
    })

    // Try to post without subscription
    const { error } = await supabase
      .from('feed_posts')
      .insert({
        title: 'Unauthorized Post',
        content: 'Should fail',
        channel_id: 'private-channel-id',
        author_id: user!.id
      })

    expect(error).toBeDefined()
    expect(error.code).toBe('42501') // PostgreSQL permission denied
  })
})
```

## 🚀 Performance Optimization

### Next.js Config
```javascript
// next.config.js
module.exports = {
  images: {
    domains: ['your-supabase-url.supabase.co'],
    formats: ['image/avif', 'image/webp'],
  },
  experimental: {
    optimizeCss: true,
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}
```

### Database Optimization
```sql
-- Indexes for feed performance
CREATE INDEX idx_feed_posts_published_channel 
  ON feed_posts(published_at DESC, channel_id) 
  WHERE is_draft = false;

CREATE INDEX idx_feed_posts_author_published 
  ON feed_posts(author_id, published_at DESC);

-- Materialized view for trending posts
CREATE MATERIALIZED VIEW trending_posts AS
SELECT 
  p.*,
  COUNT(DISTINCT r.user_id) as reaction_count,
  COUNT(DISTINCT c.id) as comment_count,
  (COUNT(DISTINCT r.user_id) * 2 + COUNT(DISTINCT c.id) + p.views_count) as trending_score
FROM feed_posts p
LEFT JOIN feed_reactions r ON p.id = r.post_id
LEFT JOIN feed_comments c ON p.id = c.post_id
WHERE p.published_at > NOW() - INTERVAL '7 days'
  AND p.is_draft = false
GROUP BY p.id
ORDER BY trending_score DESC
LIMIT 100;

-- Refresh trending posts every hour
CREATE OR REPLACE FUNCTION refresh_trending_posts()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY trending_posts;
END;
$$ LANGUAGE plpgsql;

-- Schedule refresh
SELECT cron.schedule('refresh-trending', '0 * * * *', 'SELECT refresh_trending_posts()');
```

---

*Эта техническая спецификация обеспечивает полную документацию для реализации новой архитектуры с фокусом на скорость разработки и простоту развертывания, включая детальную реализацию модуля Feed.* 