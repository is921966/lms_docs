//
//  Cmi5DemoContent.swift
//  LMS
//
//  Demo content for Cmi5 activities
//

import Foundation
import WebKit

/// Провайдер демо-контента для Cmi5 активностей
public class Cmi5DemoContent {
    
    /// HTML контент для Introduction to AI
    static let introToAIContent = """
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Введение в искусственный интеллект</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                line-height: 1.6;
                margin: 0;
                padding: 20px;
                background-color: #f5f5f7;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #1d1d1f;
                font-size: 32px;
                margin-bottom: 10px;
            }
            .subtitle {
                color: #6e6e73;
                font-size: 18px;
                margin-bottom: 30px;
            }
            .section {
                margin-bottom: 30px;
            }
            .section h2 {
                color: #1d1d1f;
                font-size: 24px;
                margin-bottom: 15px;
            }
            .progress-bar {
                width: 100%;
                height: 8px;
                background-color: #e5e5e7;
                border-radius: 4px;
                overflow: hidden;
                margin-bottom: 30px;
            }
            .progress-fill {
                height: 100%;
                background-color: #0071e3;
                width: 0%;
                transition: width 0.3s ease;
            }
            .interactive-element {
                background-color: #f5f5f7;
                border: 2px solid #0071e3;
                border-radius: 8px;
                padding: 20px;
                margin: 20px 0;
                cursor: pointer;
                transition: all 0.3s ease;
            }
            .interactive-element:hover {
                background-color: #e8f3ff;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,113,227,0.2);
            }
            .interactive-element.clicked {
                background-color: #d1f3d1;
                border-color: #34c759;
            }
            .button {
                background-color: #0071e3;
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 16px;
                cursor: pointer;
                transition: background-color 0.3s ease;
            }
            .button:hover {
                background-color: #0051d5;
            }
            .quiz-question {
                background-color: #f5f5f7;
                padding: 20px;
                border-radius: 8px;
                margin: 20px 0;
            }
            .quiz-option {
                display: block;
                width: 100%;
                text-align: left;
                padding: 12px 20px;
                margin: 8px 0;
                border: 2px solid #d1d1d6;
                border-radius: 8px;
                background: white;
                cursor: pointer;
                transition: all 0.3s ease;
            }
            .quiz-option:hover {
                border-color: #0071e3;
                background-color: #f8f8f8;
            }
            .quiz-option.selected {
                border-color: #0071e3;
                background-color: #e8f3ff;
            }
            .quiz-option.correct {
                border-color: #34c759;
                background-color: #d1f3d1;
            }
            .quiz-option.incorrect {
                border-color: #ff3b30;
                background-color: #ffd1cf;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Введение в искусственный интеллект</h1>
            <p class="subtitle">Урок 1: Основы ИИ и машинного обучения</p>
            
            <div class="progress-bar">
                <div class="progress-fill" id="progress"></div>
            </div>
            
            <div class="section">
                <h2>Что такое искусственный интеллект?</h2>
                <p>Искусственный интеллект (ИИ) — это область компьютерных наук, которая занимается созданием интеллектуальных машин, способных выполнять задачи, обычно требующие человеческого интеллекта.</p>
                
                <div class="interactive-element" onclick="markAsRead(this, 'definition')">
                    <strong>💡 Ключевое определение</strong>
                    <p>ИИ включает в себя машинное обучение, обработку естественного языка, компьютерное зрение и робототехнику.</p>
                    <small>Нажмите, чтобы отметить как прочитанное</small>
                </div>
            </div>
            
            <div class="section">
                <h2>История развития ИИ</h2>
                <p>Развитие искусственного интеллекта началось в 1950-х годах с работ Алана Тьюринга и его знаменитого теста Тьюринга.</p>
                
                <div class="interactive-element" onclick="markAsRead(this, 'history')">
                    <strong>📅 Ключевые даты</strong>
                    <ul>
                        <li>1950 - Тест Тьюринга</li>
                        <li>1956 - Дартмутская конференция</li>
                        <li>1997 - Deep Blue побеждает Каспарова</li>
                        <li>2011 - Watson выигрывает Jeopardy!</li>
                        <li>2016 - AlphaGo побеждает чемпиона по Го</li>
                    </ul>
                    <small>Нажмите, чтобы отметить как прочитанное</small>
                </div>
            </div>
            
            <div class="section">
                <h2>Проверка знаний</h2>
                <div class="quiz-question">
                    <p><strong>Вопрос:</strong> Что из перечисленного НЕ является областью искусственного интеллекта?</p>
                    <button class="quiz-option" onclick="selectAnswer(this, false)">Машинное обучение</button>
                    <button class="quiz-option" onclick="selectAnswer(this, false)">Компьютерное зрение</button>
                    <button class="quiz-option" onclick="selectAnswer(this, true)">Квантовая физика</button>
                    <button class="quiz-option" onclick="selectAnswer(this, false)">Обработка естественного языка</button>
                </div>
            </div>
            
            <div class="section">
                <h2>Завершение урока</h2>
                <p>Поздравляем! Вы успешно изучили основы искусственного интеллекта.</p>
                <button class="button" onclick="completeLesson()">Завершить урок</button>
            </div>
        </div>
        
        <script>
            // Отслеживание прогресса
            let progress = 0;
            let completedSections = new Set();
            
            function updateProgress() {
                const progressBar = document.getElementById('progress');
                progressBar.style.width = progress + '%';
                
                // Отправка xAPI statement о прогрессе
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'progressed',
                        result: {
                            extensions: {
                                'progress': progress / 100
                            }
                        }
                    });
                }
            }
            
            function markAsRead(element, sectionId) {
                if (!completedSections.has(sectionId)) {
                    completedSections.add(sectionId);
                    element.classList.add('clicked');
                    progress += 30;
                    updateProgress();
                }
            }
            
            function selectAnswer(button, isCorrect) {
                // Отключаем все кнопки
                const buttons = button.parentElement.querySelectorAll('.quiz-option');
                buttons.forEach(btn => {
                    btn.disabled = true;
                    btn.style.cursor = 'default';
                });
                
                // Показываем результат
                if (isCorrect) {
                    button.classList.add('correct');
                    if (!completedSections.has('quiz')) {
                        completedSections.add('quiz');
                        progress += 40;
                        updateProgress();
                    }
                } else {
                    button.classList.add('incorrect');
                }
            }
            
            function completeLesson() {
                progress = 100;
                updateProgress();
                
                // Отправка xAPI statement о завершении
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'completed',
                        result: {
                            success: true,
                            score: {
                                scaled: 1.0
                            }
                        }
                    });
                }
                
                alert('Урок завершен! Вы можете закрыть это окно.');
            }
            
            // Инициализация
            window.onload = function() {
                // Отправка xAPI statement об инициализации
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'initialized'
                    });
                }
            };
        </script>
    </body>
    </html>
    """
    
    /// HTML контент для AI Applications
    static let aiApplicationsContent = """
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Применение ИИ в реальном мире</title>
        <style>
            /* Используем те же стили */
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                line-height: 1.6;
                margin: 0;
                padding: 20px;
                background-color: #f5f5f7;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #1d1d1f;
                font-size: 32px;
                margin-bottom: 10px;
            }
            .application-card {
                border: 1px solid #e5e5e7;
                border-radius: 12px;
                padding: 20px;
                margin: 20px 0;
                transition: all 0.3s ease;
            }
            .application-card:hover {
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                transform: translateY(-2px);
            }
            .icon {
                font-size: 48px;
                margin-bottom: 10px;
            }
            .progress-indicator {
                display: flex;
                justify-content: space-between;
                margin: 30px 0;
            }
            .progress-step {
                width: 30px;
                height: 30px;
                border-radius: 50%;
                background-color: #e5e5e7;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                transition: all 0.3s ease;
            }
            .progress-step.completed {
                background-color: #34c759;
                color: white;
            }
            .case-study {
                background-color: #f5f5f7;
                border-left: 4px solid #0071e3;
                padding: 20px;
                margin: 20px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Применение ИИ в реальном мире</h1>
            <p class="subtitle">Урок 2: Практические примеры использования ИИ</p>
            
            <div class="progress-indicator">
                <div class="progress-step" id="step1">1</div>
                <div class="progress-step" id="step2">2</div>
                <div class="progress-step" id="step3">3</div>
                <div class="progress-step" id="step4">4</div>
            </div>
            
            <div class="section">
                <h2>Области применения ИИ</h2>
                
                <div class="application-card" onclick="exploreApplication(this, 'healthcare', 1)">
                    <div class="icon">🏥</div>
                    <h3>Здравоохранение</h3>
                    <p>Диагностика заболеваний, анализ медицинских изображений, персонализированная медицина</p>
                </div>
                
                <div class="application-card" onclick="exploreApplication(this, 'finance', 2)">
                    <div class="icon">💰</div>
                    <h3>Финансы</h3>
                    <p>Обнаружение мошенничества, алгоритмическая торговля, оценка кредитных рисков</p>
                </div>
                
                <div class="application-card" onclick="exploreApplication(this, 'retail', 3)">
                    <div class="icon">🛍️</div>
                    <h3>Розничная торговля</h3>
                    <p>Рекомендательные системы, управление запасами, персонализация опыта покупателей</p>
                </div>
                
                <div class="application-card" onclick="exploreApplication(this, 'transport', 4)">
                    <div class="icon">🚗</div>
                    <h3>Транспорт</h3>
                    <p>Беспилотные автомобили, оптимизация маршрутов, управление трафиком</p>
                </div>
            </div>
            
            <div class="case-study" id="case-study" style="display: none;">
                <h3>Практический пример</h3>
                <p id="case-study-content"></p>
            </div>
            
            <div class="section" id="completion-section" style="display: none;">
                <h2>Отличная работа!</h2>
                <p>Вы изучили основные области применения ИИ в современном мире.</p>
                <button class="button" onclick="completeLesson()">Завершить урок</button>
            </div>
        </div>
        
        <script>
            let exploredApplications = new Set();
            
            function updateProgressSteps() {
                for (let i = 1; i <= exploredApplications.size; i++) {
                    document.getElementById('step' + i).classList.add('completed');
                }
                
                if (exploredApplications.size === 4) {
                    document.getElementById('completion-section').style.display = 'block';
                }
            }
            
            function exploreApplication(card, appType, stepNumber) {
                card.style.borderColor = '#34c759';
                card.style.backgroundColor = '#f0fff0';
                
                exploredApplications.add(appType);
                updateProgressSteps();
                
                // Показываем пример
                const caseStudy = document.getElementById('case-study');
                const content = document.getElementById('case-study-content');
                
                const examples = {
                    healthcare: 'IBM Watson помогает врачам в диагностике рака, анализируя миллионы медицинских записей и исследований.',
                    finance: 'JPMorgan использует ИИ для анализа юридических документов, экономя 360,000 часов работы юристов в год.',
                    retail: 'Amazon использует ИИ для персонализации рекомендаций, что приносит 35% от общей выручки компании.',
                    transport: 'Waymo (Google) разрабатывает беспилотные такси, которые уже проехали миллионы километров в тестовом режиме.'
                };
                
                content.textContent = examples[appType];
                caseStudy.style.display = 'block';
                
                // Отправка прогресса
                const progress = (exploredApplications.size / 4) * 100;
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'progressed',
                        result: {
                            extensions: {
                                'progress': progress / 100
                            }
                        }
                    });
                }
            }
            
            function completeLesson() {
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'completed',
                        result: {
                            success: true,
                            score: {
                                scaled: 1.0
                            }
                        }
                    });
                }
                
                alert('Поздравляем! Вы успешно завершили курс по основам ИИ.');
            }
            
            // Инициализация
            window.onload = function() {
                if (window.webkit && window.webkit.messageHandlers.xapi) {
                    window.webkit.messageHandlers.xapi.postMessage({
                        verb: 'initialized'
                    });
                }
            };
        </script>
    </body>
    </html>
    """
    
    /// Возвращает контент для активности по ID
    static func getContent(for activityId: String) -> String? {
        switch activityId {
        case "intro_to_ai":
            return introToAIContent
        case "ai_applications":
            return aiApplicationsContent
        default:
            return nil
        }
    }
    
    /// Создает Data URL для контента
    static func getDataURL(for activityId: String) -> URL? {
        guard let content = getContent(for: activityId),
              let data = content.data(using: .utf8) else {
            return nil
        }
        
        let base64 = data.base64EncodedString()
        let urlString = "data:text/html;base64,\(base64)"
        return URL(string: urlString)
    }
} 