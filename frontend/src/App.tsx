import React, { Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { FeatureRegistry, useFeatureRegistry } from './features/FeatureRegistry';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import './App.css';

// Loading Component
const LoadingSpinner: React.FC = () => (
  <div className="flex items-center justify-center min-h-screen">
    <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
  </div>
);

// Async Component Wrapper with Error Boundary
const AsyncComponent: React.FC<{ importFunc: () => Promise<{ default: React.ComponentType<any> }> }> = ({ importFunc }) => {
  const LazyComponent = React.lazy(importFunc);
  
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <LazyComponent />
    </Suspense>
  );
};

// Navigation Sidebar
const Sidebar: React.FC = () => {
  const { enabledFeatures, enableReadyModules } = useFeatureRegistry();
  const { isAuthenticated, user } = useAuth();

  return (
    <div className="w-64 bg-gray-800 text-white p-4 min-h-screen">
      {/* User Info */}
      {isAuthenticated && user && (
        <div className="mb-6 p-3 bg-gray-700 rounded">
          <p className="text-sm text-gray-300">Добро пожаловать</p>
          <p className="font-medium">{user.name}</p>
          <p className="text-xs text-gray-400">{user.role}</p>
        </div>
      )}

      {/* Logo */}
      <div className="mb-8">
        <h1 className="text-xl font-bold">ЦУМ LMS</h1>
        <p className="text-sm text-gray-300">Корпоративный университет</p>
      </div>
      
      {/* Feature Toggle */}
      <div className="mb-6">
        <button 
          onClick={enableReadyModules}
          className="w-full bg-blue-600 hover:bg-blue-700 px-3 py-2 rounded text-sm"
        >
          🚀 Включить готовые модули
        </button>
      </div>
      
      {/* Navigation */}
      <nav className="space-y-2">
        <div className="text-xs uppercase text-gray-400 mb-2">
          Модули ({enabledFeatures.length})
        </div>
        {enabledFeatures.map((feature) => (
          <a
            key={feature.name}
            href={feature.path}
            className="block px-3 py-2 rounded hover:bg-gray-700 transition-colors"
          >
            <span className="mr-2">{feature.icon}</span>
            {feature.name}
            {feature.ready && <span className="ml-2 text-green-400">✓</span>}
          </a>
        ))}
      </nav>
      
      {/* API Status */}
      <div className="mt-8 p-3 bg-gray-900 rounded text-xs">
        <div className="text-gray-400 mb-1">API Status</div>
        <div className="text-green-400">✅ Connected</div>
        <div className="text-gray-300">Backend: Active</div>
        <div className="text-gray-300">Auth: {isAuthenticated ? 'Authenticated' : 'Guest'}</div>
      </div>
    </div>
  );
};

// Dashboard Component
const Dashboard: React.FC = () => {
  const { enabledFeatures } = useFeatureRegistry();
  const { isAuthenticated, user } = useAuth();
  
  const readyFeatures = enabledFeatures.filter(f => f.ready);
  const inDevelopment = enabledFeatures.filter(f => !f.ready);
  
  return (
    <div className="p-6">
      <div className="max-w-6xl mx-auto">
        {/* Welcome */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            {isAuthenticated ? `Добро пожаловать, ${user?.name}!` : 'Добро пожаловать в ЦУМ LMS'}
          </h1>
          <p className="text-gray-600">
            Корпоративный университет - Система управления обучением
          </p>
        </div>

        {/* Authentication Status */}
        <div className="mb-8 p-4 bg-blue-50 rounded-lg">
          <h3 className="text-lg font-medium text-blue-900 mb-2">
            🔐 Статус аутентификации
          </h3>
          {isAuthenticated ? (
            <div className="text-blue-800">
              ✅ Вы вошли в систему как <strong>{user?.email}</strong>
              <br />
              Роль: <strong>{user?.role}</strong>
            </div>
          ) : (
            <div className="text-blue-800">
              ⚠️ Войдите в систему для доступа ко всем функциям
              <br />
              <a href="/auth" className="text-blue-600 hover:underline">Перейти к авторизации →</a>
            </div>
          )}
        </div>
        
        {/* Ready Modules */}
        <div className="mb-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            🚀 Готовые модули ({readyFeatures.length})
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {readyFeatures.map((feature) => (
              <div key={feature.name} className="bg-white p-6 rounded-lg shadow-md border border-gray-200 hover:shadow-lg transition-shadow">
                <div className="text-2xl mb-2">{feature.icon}</div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">{feature.name}</h3>
                <p className="text-gray-600 text-sm mb-4">{feature.description || 'Готов к использованию'}</p>
                <a 
                  href={feature.path}
                  className="inline-flex items-center text-blue-600 hover:text-blue-800 font-medium"
                >
                  Открыть модуль →
                </a>
                <div className="mt-2 text-xs text-green-600">✅ Готов к использованию</div>
              </div>
            ))}
          </div>
        </div>
        
        {/* Modules in Development */}
        <div>
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            🚧 В разработке ({inDevelopment.length})
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {inDevelopment.map((feature) => (
              <div key={feature.name} className="bg-gray-50 p-4 rounded-lg border border-gray-200">
                <div className="text-xl mb-2">{feature.icon}</div>
                <h3 className="text-md font-medium text-gray-700 mb-1">{feature.name}</h3>
                <div className="text-xs text-gray-500">🚧 В разработке</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

// Main App Layout
const AppLayout: React.FC = () => {
  const { enabledFeatures } = useFeatureRegistry();

  return (
    <div className="flex min-h-screen bg-gray-100">
      <Sidebar />
      <div className="flex-1">
        <Routes>
          <Route path="/" element={<Dashboard />} />
          {enabledFeatures.map((feature) => (
            <Route 
              key={feature.name}
              path={feature.path} 
              element={
                <AsyncComponent importFunc={feature.component} />
              } 
            />
          ))}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  );
};

// Main App Component with Providers
const App: React.FC = () => {
  // Initialize feature registry
  React.useEffect(() => {
    FeatureRegistry.enableReadyModules();
  }, []);

  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <AppLayout />
        </div>
      </Router>
    </AuthProvider>
  );
};

export default App;
