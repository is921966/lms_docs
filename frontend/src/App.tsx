import React, { Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route, NavLink } from 'react-router-dom';
import { useFeatureRegistry } from './features/FeatureRegistry';
import './App.css';

function App() {
  const { enabledFeatures, enableReadyModules } = useFeatureRegistry();

  // Автоматически включаем готовые модули при запуске
  React.useEffect(() => {
    enableReadyModules();
    console.log('🎯 React Feature Registry инициализирован');
  }, []);

  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <div className="flex items-center">
                <h1 className="text-xl font-bold text-gray-900">
                  ЦУМ: Корпоративный университет
                </h1>
              </div>
              <div className="text-sm text-gray-600">
                React Frontend v1.0.0
              </div>
            </div>
          </div>
        </header>

        <div className="flex">
          {/* Sidebar Navigation */}
          <nav className="w-64 bg-white shadow-sm min-h-screen">
            <div className="p-4">
              <h2 className="text-sm font-medium text-gray-900 mb-4">
                Модули ({enabledFeatures.length})
              </h2>
              <ul className="space-y-1">
                {enabledFeatures.map(feature => (
                  <li key={feature.path}>
                    <NavLink
                      to={feature.path}
                      className={({ isActive }) => 
                        `flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                          isActive 
                            ? 'bg-blue-100 text-blue-700' 
                            : 'text-gray-700 hover:bg-gray-100'
                        }`
                      }
                    >
                      <span className="text-lg">{feature.icon}</span>
                      {feature.name}
                    </NavLink>
                  </li>
                ))}
              </ul>
            </div>
          </nav>

          {/* Main Content */}
          <main className="flex-1">
            <Suspense 
              fallback={
                <div className="flex items-center justify-center h-64">
                  <div className="text-center">
                    <div className="text-4xl mb-4">⏳</div>
                    <p className="text-gray-600">Загрузка модуля...</p>
                  </div>
                </div>
              }
            >
              <Routes>
                {/* Default route */}
                <Route 
                  path="/" 
                  element={
                    <div className="p-6">
                      <div className="max-w-4xl mx-auto">
                        <div className="text-center mb-8">
                          <div className="text-6xl mb-4">🎓</div>
                          <h1 className="text-3xl font-bold text-gray-900 mb-4">
                            Добро пожаловать в ЦУМ Корпоративный университет
                          </h1>
                          <p className="text-gray-600 mb-8">
                            React Frontend готов! Выберите модуль из меню слева.
                          </p>
                        </div>

                        {/* Feature Status */}
                        <div className="bg-white rounded-lg shadow-md p-6">
                          <h2 className="text-xl font-semibold mb-4">
                            📊 Статус модулей
                          </h2>
                          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            {enabledFeatures.map(feature => (
                              <div key={feature.path} className="flex items-center gap-3 p-3 bg-green-50 rounded-lg">
                                <span className="text-lg">{feature.icon}</span>
                                <div>
                                  <div className="font-medium text-green-800">{feature.name}</div>
                                  <div className="text-sm text-green-600">Активен</div>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  } 
                />

                {/* Dynamic routes from Feature Registry */}
                {enabledFeatures.map(feature => (
                  <Route
                    key={feature.path}
                    path={feature.path}
                    element={<AsyncComponent component={feature.component} />}
                  />
                ))}

                {/* 404 */}
                <Route 
                  path="*" 
                  element={
                    <div className="flex items-center justify-center h-64">
                      <div className="text-center">
                        <div className="text-6xl mb-4">🔍</div>
                        <h1 className="text-2xl font-bold text-gray-900 mb-2">
                          Страница не найдена
                        </h1>
                        <p className="text-gray-600">
                          Возможно, модуль еще не активирован
                        </p>
                      </div>
                    </div>
                  } 
                />
              </Routes>
            </Suspense>
          </main>
        </div>
      </div>
    </Router>
  );
}

// Компонент для lazy loading модулей
interface AsyncComponentProps {
  component: () => Promise<{ default: React.ComponentType<any> }>;
}

const AsyncComponent: React.FC<AsyncComponentProps> = ({ component }) => {
  const [Component, setComponent] = React.useState<React.ComponentType<any> | null>(null);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    component()
      .then(module => setComponent(() => module.default))
      .catch(err => {
        console.error('Ошибка загрузки модуля:', err);
        setError('Ошибка загрузки модуля');
      });
  }, [component]);

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="text-4xl mb-4">❌</div>
          <p className="text-red-600">{error}</p>
        </div>
      </div>
    );
  }

  if (!Component) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="text-4xl mb-4">⏳</div>
          <p className="text-gray-600">Загрузка...</p>
        </div>
      </div>
    );
  }

  return <Component />;
};

export default App;
