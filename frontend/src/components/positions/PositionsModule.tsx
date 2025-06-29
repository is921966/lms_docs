import React, { useState } from 'react';

interface Position {
  id: string;
  title: string;
  department: string;
  level: 'junior' | 'middle' | 'senior' | 'lead';
  description: string;
  requirements: string[];
  responsibilities: string[];
  careerPath: string[];
}

const mockPositions: Position[] = [
  {
    id: '1',
    title: 'Менеджер по продажам',
    department: 'Продажи',
    level: 'middle',
    description: 'Управление клиентской базой и развитие продаж премиальных товаров',
    requirements: ['Опыт продаж 3+ лет', 'Знание английского языка', 'Навыки переговоров'],
    responsibilities: ['Развитие клиентской базы', 'Достижение KPI', 'Ведение CRM'],
    careerPath: ['Специалист по продажам', 'Менеджер по продажам', 'Старший менеджер', 'Руководитель отдела']
  },
  {
    id: '2',
    title: 'IT-специалист',
    department: 'Информационные технологии',
    level: 'junior',
    description: 'Техническая поддержка и администрирование IT-систем',
    requirements: ['Техническое образование', 'Знание Windows/Linux', 'Базовые знания сетей'],
    responsibilities: ['Техподдержка пользователей', 'Администрирование систем', 'Обновление ПО'],
    careerPath: ['Стажер IT', 'IT-специалист', 'Системный администратор', 'Ведущий специалист']
  },
  {
    id: '3',
    title: 'Бренд-менеджер',
    department: 'Маркетинг',
    level: 'senior',
    description: 'Управление брендом и разработка маркетинговых стратегий',
    requirements: ['Опыт в маркетинге 5+ лет', 'Высшее образование', 'Аналитические навыки'],
    responsibilities: ['Стратегия бренда', 'Планирование кампаний', 'Анализ рынка'],
    careerPath: ['Маркетолог', 'Бренд-менеджер', 'Старший бренд-менеджер', 'Директор по маркетингу']
  }
];

const PositionsModule: React.FC = () => {
  const [positions] = useState<Position[]>(mockPositions);
  const [selectedDepartment, setSelectedDepartment] = useState<string>('all');
  const [selectedLevel, setSelectedLevel] = useState<string>('all');

  const departments = ['all', ...Array.from(new Set(positions.map(p => p.department)))];
  const levels = ['all', 'junior', 'middle', 'senior', 'lead'];

  const filteredPositions = positions.filter(position => {
    return (selectedDepartment === 'all' || position.department === selectedDepartment) &&
           (selectedLevel === 'all' || position.level === selectedLevel);
  });

  const getLevelColor = (level: string) => {
    switch (level) {
      case 'junior': return 'bg-green-100 text-green-800';
      case 'middle': return 'bg-blue-100 text-blue-800';
      case 'senior': return 'bg-purple-100 text-purple-800';
      case 'lead': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getLevelText = (level: string) => {
    switch (level) {
      case 'junior': return 'Младший';
      case 'middle': return 'Средний';
      case 'senior': return 'Старший';
      case 'lead': return 'Ведущий';
      default: return level;
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="text-3xl">💼</div>
          <h1 className="text-3xl font-bold text-gray-900">Должности</h1>
        </div>
        <p className="text-gray-600">
          Управление должностями и карьерными путями сотрудников
        </p>
      </div>

      {/* Filters */}
      <div className="mb-6 space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Отдел:</label>
          <div className="flex flex-wrap gap-2">
            {departments.map(dept => (
              <button
                key={dept}
                onClick={() => setSelectedDepartment(dept)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedDepartment === dept
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {dept === 'all' ? 'Все отделы' : dept}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Уровень:</label>
          <div className="flex flex-wrap gap-2">
            {levels.map(level => (
              <button
                key={level}
                onClick={() => setSelectedLevel(level)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedLevel === level
                    ? 'bg-purple-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {level === 'all' ? 'Все уровни' : getLevelText(level)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Positions Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {filteredPositions.map(position => (
          <div
            key={position.id}
            className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow border border-gray-200"
          >
            {/* Header */}
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-1">
                  {position.title}
                </h3>
                <p className="text-sm text-gray-600">{position.department}</p>
              </div>
              <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLevelColor(position.level)}`}>
                {getLevelText(position.level)}
              </span>
            </div>

            {/* Description */}
            <p className="text-gray-700 mb-4">
              {position.description}
            </p>

            {/* Requirements */}
            <div className="mb-4">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Требования:</h4>
              <ul className="space-y-1">
                {position.requirements.map((req, index) => (
                  <li key={index} className="text-sm text-gray-600 flex items-start">
                    <span className="text-green-500 mr-2">•</span>
                    {req}
                  </li>
                ))}
              </ul>
            </div>

            {/* Responsibilities */}
            <div className="mb-4">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Обязанности:</h4>
              <ul className="space-y-1">
                {position.responsibilities.map((resp, index) => (
                  <li key={index} className="text-sm text-gray-600 flex items-start">
                    <span className="text-blue-500 mr-2">•</span>
                    {resp}
                  </li>
                ))}
              </ul>
            </div>

            {/* Career Path */}
            <div className="mb-6">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Карьерный путь:</h4>
              <div className="flex flex-wrap gap-2">
                {position.careerPath.map((step, index) => (
                  <div key={index} className="flex items-center">
                    <span className={`px-2 py-1 rounded text-xs ${
                      step === position.title 
                        ? 'bg-blue-100 text-blue-800 font-medium' 
                        : 'bg-gray-100 text-gray-600'
                    }`}>
                      {step}
                    </span>
                    {index < position.careerPath.length - 1 && (
                      <span className="mx-2 text-gray-400">→</span>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm">
                Подробнее
              </button>
              <button className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm">
                Заявка
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Empty State */}
      {filteredPositions.length === 0 && (
        <div className="text-center py-12">
          <div className="text-4xl mb-4">🔍</div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            Должности не найдены
          </h3>
          <p className="text-gray-600">
            Попробуйте изменить фильтры или создать новую должность
          </p>
        </div>
      )}
    </div>
  );
};

export default PositionsModule; 