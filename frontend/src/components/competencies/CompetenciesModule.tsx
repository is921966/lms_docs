import React, { useState } from 'react';

interface Competency {
  id: string;
  name: string;
  description: string;
  level: 'beginner' | 'intermediate' | 'advanced';
  category: string;
  skills: string[];
}

const mockCompetencies: Competency[] = [
  {
    id: '1',
    name: 'Управление проектами',
    description: 'Планирование, организация и контроль проектной деятельности',
    level: 'intermediate',
    category: 'Менеджмент',
    skills: ['Планирование', 'Контроль', 'Риск-менеджмент', 'Командная работа']
  },
  {
    id: '2', 
    name: 'Цифровые технологии',
    description: 'Работа с современными IT-инструментами и платформами',
    level: 'beginner',
    category: 'IT',
    skills: ['MS Office', 'CRM', 'Аналитика', 'Автоматизация']
  },
  {
    id: '3',
    name: 'Клиентский сервис',
    description: 'Взаимодействие с клиентами и повышение лояльности',
    level: 'advanced',
    category: 'Продажи',
    skills: ['Коммуникация', 'Решение конфликтов', 'Консультирование']
  }
];

const CompetenciesModule: React.FC = () => {
  const [competencies] = useState<Competency[]>(mockCompetencies);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  const categories = ['all', ...Array.from(new Set(competencies.map(c => c.category)))];
  
  const filteredCompetencies = selectedCategory === 'all' 
    ? competencies 
    : competencies.filter(c => c.category === selectedCategory);

  const getLevelColor = (level: string) => {
    switch (level) {
      case 'beginner': return 'bg-green-100 text-green-800';
      case 'intermediate': return 'bg-yellow-100 text-yellow-800';
      case 'advanced': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getLevelText = (level: string) => {
    switch (level) {
      case 'beginner': return 'Начальный';
      case 'intermediate': return 'Средний';
      case 'advanced': return 'Продвинутый';
      default: return level;
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="text-3xl">🎖️</div>
          <h1 className="text-3xl font-bold text-gray-900">Компетенции</h1>
        </div>
        <p className="text-gray-600">
          Управление навыками и компетенциями сотрудников компании
        </p>
      </div>

      {/* Filters */}
      <div className="mb-6">
        <div className="flex flex-wrap gap-2">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                selectedCategory === category
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {category === 'all' ? 'Все категории' : category}
            </button>
          ))}
        </div>
      </div>

      {/* Competencies Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCompetencies.map(competency => (
          <div
            key={competency.id}
            className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow border border-gray-200"
          >
            {/* Header */}
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-lg font-semibold text-gray-900">
                {competency.name}
              </h3>
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${getLevelColor(competency.level)}`}>
                {getLevelText(competency.level)}
              </span>
            </div>

            {/* Description */}
            <p className="text-gray-600 text-sm mb-4">
              {competency.description}
            </p>

            {/* Category */}
            <div className="flex items-center gap-2 mb-4">
              <span className="text-xs text-gray-500">Категория:</span>
              <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                {competency.category}
              </span>
            </div>

            {/* Skills */}
            <div>
              <div className="text-xs text-gray-500 mb-2">Навыки:</div>
              <div className="flex flex-wrap gap-1">
                {competency.skills.map((skill, index) => (
                  <span
                    key={index}
                    className="px-2 py-1 bg-gray-100 text-gray-700 rounded-full text-xs"
                  >
                    {skill}
                  </span>
                ))}
              </div>
            </div>

            {/* Actions */}
            <div className="mt-4 pt-4 border-t border-gray-200">
              <button className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm">
                Подробнее
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Empty State */}
      {filteredCompetencies.length === 0 && (
        <div className="text-center py-12">
          <div className="text-4xl mb-4">🔍</div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            Компетенции не найдены
          </h3>
          <p className="text-gray-600">
            Попробуйте изменить фильтры или добавить новые компетенции
          </p>
        </div>
      )}

      {/* Add Button */}
      <div className="fixed bottom-6 right-6">
        <button className="bg-blue-600 text-white p-4 rounded-full shadow-lg hover:bg-blue-700 transition-colors">
          <span className="text-xl">+</span>
        </button>
      </div>
    </div>
  );
};

export default CompetenciesModule; 