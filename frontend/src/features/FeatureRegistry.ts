/**
 * Feature Registry для React - аналог iOS Feature Registry
 * Централизованное управление модулями приложения
 */

import { useState, useEffect } from 'react';

export interface FeatureConfig {
  name: string;
  path: string;
  icon: string;
  enabled: boolean;
  ready: boolean;
  component: () => Promise<{ default: React.ComponentType<any> }>;
  description?: string;
  version?: string;
}

/**
 * Единый реестр всех модулей приложения
 */
export const Feature = {
  // Основные модули (активные)
  AUTH: 'auth',
  USERS: 'users', 
  COURSES: 'courses',
  TESTS: 'tests',
  ANALYTICS: 'analytics',
  ONBOARDING: 'onboarding',
  PROFILE: 'profile',
  SETTINGS: 'settings',
  
  // Готовые модули (29.06.2025)
  COMPETENCIES: 'competencies',
  POSITIONS: 'positions', 
  FEED: 'feed',
  
  // Placeholder модули (в разработке)
  CERTIFICATES: 'certificates',
  GAMIFICATION: 'gamification',
  NOTIFICATIONS: 'notifications',
  PROGRAMS: 'programs',
  EVENTS: 'events',
  REPORTS: 'reports',
  
  // Debug модуль (только в development)
  DEBUG: 'debug'
} as const;

export type FeatureType = typeof Feature[keyof typeof Feature];

/**
 * Менеджер Feature Registry с реактивными обновлениями
 */
class FeatureRegistryManager {
  private static instance: FeatureRegistryManager;
  private features = new Map<string, FeatureConfig>();
  private listeners: Set<() => void> = new Set();

  private constructor() {
    this.registerAllFeatures();
  }

  static getInstance(): FeatureRegistryManager {
    if (!FeatureRegistryManager.instance) {
      FeatureRegistryManager.instance = new FeatureRegistryManager();
    }
    return FeatureRegistryManager.instance;
  }

  /**
   * Подписка на изменения feature flags
   */
  subscribe(callback: () => void): () => void {
    this.listeners.add(callback);
    return () => this.listeners.delete(callback);
  }

  /**
   * Уведомление об изменениях
   */
  private notify(): void {
    this.listeners.forEach(callback => callback());
  }

  /**
   * Регистрация всех модулей
   */
  private registerAllFeatures(): void {
    // Основные модули (enabled: true)
    this.register(Feature.AUTH, {
      name: 'Авторизация',
      path: '/auth',
      icon: '🔐',
      enabled: true,
      ready: true,
      component: () => import('../components/auth/AuthModule')
    });

    this.register(Feature.USERS, {
      name: 'Пользователи',
      path: '/users', 
      icon: '👥',
      enabled: true,
      ready: true,
      component: () => import('../components/users/UsersModule')
    });

    this.register(Feature.COURSES, {
      name: 'Курсы',
      path: '/courses',
      icon: '📚',
      enabled: true,
      ready: true,
      component: () => import('../components/courses/CoursesModule')
    });

    this.register(Feature.TESTS, {
      name: 'Тесты',
      path: '/tests',
      icon: '📝',
      enabled: true,
      ready: true,
      component: () => import('../components/tests/TestsModule')
    });

    this.register(Feature.ANALYTICS, {
      name: 'Аналитика',
      path: '/analytics',
      icon: '📊',
      enabled: true,
      ready: true,
      component: () => import('../components/analytics/AnalyticsModule')
    });

    this.register(Feature.ONBOARDING, {
      name: 'Онбординг',
      path: '/onboarding',
      icon: '🎯',
      enabled: true,
      ready: true,
      component: () => import('../components/onboarding/OnboardingModule')
    });

    this.register(Feature.PROFILE, {
      name: 'Профиль',
      path: '/profile',
      icon: '👤',
      enabled: true,
      ready: true,
      component: () => import('../components/profile/ProfileModule')
    });

    this.register(Feature.SETTINGS, {
      name: 'Настройки',
      path: '/settings',
      icon: '⚙️',
      enabled: true,
      ready: true,
      component: () => import('../components/settings/SettingsModule')
    });

    // Готовые модули (включены с 29.06.2025)
    this.register(Feature.COMPETENCIES, {
      name: 'Компетенции',
      path: '/competencies',
      icon: '🎖️',
      enabled: true, // включено после iOS 100%
      ready: true,
      component: () => import('../components/competencies/CompetenciesModule')
    });

    this.register(Feature.POSITIONS, {
      name: 'Должности', 
      path: '/positions',
      icon: '💼',
      enabled: true, // включено после iOS 100%
      ready: true,
      component: () => import('../components/positions/PositionsModule')
    });

    this.register(Feature.FEED, {
      name: 'Новости',
      path: '/feed',
      icon: '📰',
      enabled: true, // включено после iOS 100%
      ready: true,
      component: () => import('../components/feed/FeedModule')
    });

    // Placeholder модули (disabled)
    this.register(Feature.CERTIFICATES, {
      name: 'Сертификаты',
      path: '/certificates',
      icon: '🏆',
      enabled: false,
      ready: false,
      component: () => import('../components/common/PlaceholderModule')
    });

    // Debug модуль (только в development)
    if (import.meta.env.DEV) {
      this.register(Feature.DEBUG, {
        name: 'Debug',
        path: '/debug',
        icon: '🐛',
        enabled: true,
        ready: true,
        component: () => import('../components/debug/DebugModule')
      });
    }

    console.log('🎯 FeatureRegistry: Все модули зарегистрированы', this.features.size);
  }

  /**
   * Регистрация модуля
   */
  register(feature: string, config: Partial<FeatureConfig>): void {
    const fullConfig = {
      name: config.name || feature,
      path: config.path || `/${feature}`,
      icon: config.icon || '📋',
      enabled: config.enabled ?? false,
      ready: config.ready ?? false,
      component: config.component || (() => import('../components/common/PlaceholderModule')),
      ...config
    } as FeatureConfig;

    this.features.set(feature, fullConfig);
  }

  /**
   * Получить конфигурацию модуля
   */
  getFeature(feature: string): FeatureConfig | undefined {
    return this.features.get(feature);
  }

  /**
   * Получить все включенные модули
   */
  getEnabledFeatures(): FeatureConfig[] {
    return Array.from(this.features.values())
      .filter(config => config.enabled);
  }

  /**
   * Включить модуль
   */
  enableFeature(feature: string): void {
    const config = this.features.get(feature);
    if (config) {
      config.enabled = true;
      this.notify();
      console.log(`✅ Feature enabled: ${config.name}`);
    }
  }

  /**
   * Включить все готовые модули (аналог iOS)
   */
  enableReadyModules(): void {
    const readyFeatures = [Feature.COMPETENCIES, Feature.POSITIONS, Feature.FEED];
    
    readyFeatures.forEach(feature => {
      this.enableFeature(feature);
    });

    this.notify();
    console.log('✅ Готовые модули включены:', readyFeatures.map(f => this.getFeature(f)?.name));
  }

  /**
   * Проверить включен ли модуль
   */
  isEnabled(feature: string): boolean {
    return this.features.get(feature)?.enabled ?? false;
  }

  /**
   * Получить роуты для React Router
   */
  getRoutes(): Array<{ path: string; component: () => Promise<{ default: React.ComponentType<any> }> }> {
    return this.getEnabledFeatures().map(config => ({
      path: config.path,
      component: config.component
    }));
  }
}

// Singleton экземпляр
export const FeatureRegistry = FeatureRegistryManager.getInstance();

// Хук для использования в React компонентах
export function useFeatureRegistry() {
  const [, forceUpdate] = useState({});
  
  useEffect(() => {
    const unsubscribe = FeatureRegistry.subscribe(() => {
      forceUpdate({});
    });
    return unsubscribe;
  }, []);

  return {
    enabledFeatures: FeatureRegistry.getEnabledFeatures(),
    isEnabled: (feature: string) => FeatureRegistry.isEnabled(feature),
    enableFeature: (feature: string) => FeatureRegistry.enableFeature(feature),
    enableReadyModules: () => FeatureRegistry.enableReadyModules()
  };
}

export default FeatureRegistry; 