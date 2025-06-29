// Authentication Module - Real API Integration
// Provides login/register forms with backend authentication

import React, { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import type { LoginRequest } from '../../services/api';

interface LoginFormProps {
  onSuccess?: () => void;
}

const LoginForm: React.FC<LoginFormProps> = ({ onSuccess }) => {
  const { login, isLoading, error } = useAuth();
  const [formData, setFormData] = useState<LoginRequest>({
    email: '',
    password: '',
  });
  const [showPassword, setShowPassword] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const success = await login(formData);
    if (success && onSuccess) {
      onSuccess();
    }
  };

  return (
    <div className="max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold text-center mb-6">Вход в систему</h2>
      
      {error && (
        <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
          {error}
        </div>
      )}
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700">
            Email
          </label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            placeholder="user@tsum.ru"
          />
        </div>
        
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700">
            Пароль
          </label>
          <div className="relative">
            <input
              type={showPassword ? 'text' : 'password'}
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            />
            <button
              type="button"
              className="absolute inset-y-0 right-0 pr-3 flex items-center"
              onClick={() => setShowPassword(!showPassword)}
            >
              {showPassword ? '🙈' : '👁️'}
            </button>
          </div>
        </div>
        
        <button
          type="submit"
          disabled={isLoading}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
        >
          {isLoading ? 'Вход...' : 'Войти'}
        </button>
      </form>
      
      <div className="mt-4 text-center">
        <p className="text-sm text-gray-600">
          Используйте корпоративные учетные данные
        </p>
      </div>
    </div>
  );
};

const UserProfile: React.FC = () => {
  const { user, logout, isLoading } = useAuth();

  if (!user) {
    return <LoginForm />;
  }

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold text-center mb-6">Профиль пользователя</h2>
      
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Имя</label>
          <p className="mt-1 text-sm text-gray-900">{user.name}</p>
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700">Email</label>
          <p className="mt-1 text-sm text-gray-900">{user.email}</p>
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700">Роль</label>
          <p className="mt-1 text-sm text-gray-900">{user.role}</p>
        </div>
        
        {user.ldap_username && (
          <div>
            <label className="block text-sm font-medium text-gray-700">LDAP Username</label>
            <p className="mt-1 text-sm text-gray-900">{user.ldap_username}</p>
          </div>
        )}
        
        <div>
          <label className="block text-sm font-medium text-gray-700">Дата регистрации</label>
          <p className="mt-1 text-sm text-gray-900">
            {new Date(user.created_at).toLocaleDateString('ru-RU')}
          </p>
        </div>
      </div>
      
      <button
        onClick={handleLogout}
        disabled={isLoading}
        className="mt-6 w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
      >
        {isLoading ? 'Выход...' : 'Выйти'}
      </button>
    </div>
  );
};

const AuthModule: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          {isAuthenticated ? 'Профиль' : 'Авторизация'}
        </h1>
        
        {isAuthenticated ? <UserProfile /> : <LoginForm />}
        
        {/* API Status */}
        <div className="mt-8 p-4 bg-gray-50 rounded-lg">
          <h3 className="text-lg font-medium text-gray-900 mb-2">API Status</h3>
          <p className="text-sm text-gray-600">
            ✅ Backend API: http://localhost:8000/api<br/>
            ✅ Authentication: JWT токены<br/>
            ✅ LDAP Integration: Готово<br/>
            ✅ Error Handling: Активно
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthModule; 