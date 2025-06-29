import React from 'react';

const FeedModule: React.FC = () => {
  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="text-3xl">📰</div>
          <h1 className="text-3xl font-bold text-gray-900">Новости</h1>
        </div>
        <p className="text-gray-600">
          Корпоративная лента новостей и объявлений ЦУМ
        </p>
      </div>
      <div className="bg-white rounded-lg shadow-md border border-gray-200 p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Запуск новой программы корпоративного обучения
        </h2>
        <p className="text-gray-700 mb-4">
          С 1 июля стартует новая программа развития сотрудников "ЦУМ Профи"...
        </p>
        <div className="flex items-center gap-4 text-sm text-gray-600">
          <span>👤 HR Департамент</span>
          <span>📅 29 июня 2025</span>
          <span>👍 24</span>
          <span>💬 8</span>
        </div>
      </div>
    </div>
  );
};

export default FeedModule;
