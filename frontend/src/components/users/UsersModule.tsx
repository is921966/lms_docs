import React from 'react';

const UsersModule: React.FC = () => {
  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="text-3xl">👥</div>
          <h1 className="text-3xl font-bold text-gray-900">Пользователи</h1>
        </div>
        <p className="text-gray-600">Управление пользователями и сотрудниками</p>
      </div>
      <div className="bg-white rounded-lg shadow-md border border-gray-200 p-6">
        <h3 className="text-lg font-semibold mb-4">Список сотрудников</h3>
        <p className="text-gray-600">Модуль в разработке...</p>
      </div>
    </div>
  );
};

export default UsersModule;
