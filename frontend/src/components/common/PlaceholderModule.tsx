import React from 'react';

interface PlaceholderModuleProps {
  title?: string;
  description?: string;
}

const PlaceholderModule: React.FC<PlaceholderModuleProps> = ({ 
  title = "Модуль в разработке", 
  description = "Этот модуль находится в разработке и будет доступен в ближайшее время." 
}) => {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] p-8 text-center">
      <div className="text-6xl mb-4">🚧</div>
      <h2 className="text-2xl font-bold text-gray-800 mb-4">{title}</h2>
      <p className="text-gray-600 max-w-md">{description}</p>
      <div className="mt-6 px-4 py-2 bg-blue-100 text-blue-800 rounded-lg">
        Скоро появится!
      </div>
    </div>
  );
};

export default PlaceholderModule; 