#!/usr/bin/env python3
"""
Simple Feedback Server для приема отзывов из iOS приложения
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import json
import os
import base64
import uuid
from pathlib import Path
import requests

app = Flask(__name__)
CORS(app)  # Разрешаем CORS для тестирования

# Конфигурация
FEEDBACK_DIR = Path("feedback_data")
SCREENSHOTS_DIR = FEEDBACK_DIR / "screenshots"

# Загружаем конфигурацию из файла
CONFIG = {}
try:
    with open('feedback_config.json', 'r') as f:
        CONFIG = json.load(f)
        print("✅ Конфигурация загружена из feedback_config.json")
except FileNotFoundError:
    print("⚠️  feedback_config.json не найден, используем переменные окружения")
    CONFIG = {
        'github': {
            'token': os.getenv("GITHUB_TOKEN", ""),
            'owner': 'is921966',
            'repo': 'lms_docs',
            'labels': ['feedback', 'mobile-app', 'ios']
        },
        'server': {
            'port': 5000,
            'host': '0.0.0.0'
        }
    }

# Создаем директории
FEEDBACK_DIR.mkdir(exist_ok=True)
SCREENSHOTS_DIR.mkdir(exist_ok=True)

@app.route('/api/v1/feedback', methods=['POST'])
def receive_feedback():
    """Принимает feedback от iOS приложения"""
    try:
        data = request.get_json()
        
        # Валидация
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing feedback text'}), 400
        
        # Добавляем серверные данные
        feedback = {
            **data,
            'received_at': datetime.utcnow().isoformat(),
            'ip_address': request.remote_addr,
            'user_agent': request.headers.get('User-Agent', '')
        }
        
        # Сохраняем скриншот если есть
        screenshot_path = None
        if 'screenshot' in data and data['screenshot']:
            screenshot_id = data.get('id', str(uuid.uuid4()))
            screenshot_path = save_screenshot(data['screenshot'], screenshot_id)
            feedback['screenshot_path'] = str(screenshot_path)
            # Удаляем base64 из JSON для экономии места
            feedback['screenshot'] = 'saved'
        
        # Сохраняем feedback
        feedback_id = data.get('id', str(uuid.uuid4()))
        feedback_path = FEEDBACK_DIR / f"{feedback_id}.json"
        
        with open(feedback_path, 'w') as f:
            json.dump(feedback, f, indent=2, ensure_ascii=False)
        
        # ВСЕГДА создаем GitHub issue для feedback из приложения
        github_url = create_github_issue(feedback, screenshot_path)
        
        # Отправляем в Slack/Discord если настроено
        send_notification(feedback, github_url)
        
        print(f"✅ Received feedback: {feedback_id}")
        if github_url:
            print(f"📝 GitHub Issue: {github_url}")
        
        return jsonify({
            'status': 'success',
            'id': feedback_id,
            'message': 'Feedback received successfully',
            'github_issue': github_url
        }), 201
        
    except Exception as e:
        print(f"❌ Error processing feedback: {e}")
        return jsonify({'error': str(e)}), 500

def save_screenshot(base64_data, feedback_id):
    """Сохраняет скриншот из base64"""
    try:
        # Удаляем префикс data:image/png;base64, если есть
        if ',' in base64_data:
            base64_data = base64_data.split(',')[1]
        
        screenshot_data = base64.b64decode(base64_data)
        screenshot_path = SCREENSHOTS_DIR / f"{feedback_id}.png"
        
        with open(screenshot_path, 'wb') as f:
            f.write(screenshot_data)
        
        return screenshot_path
    except Exception as e:
        print(f"Error saving screenshot: {e}")
        return None

def create_github_issue(feedback, screenshot_path):
    """Создает GitHub issue для всех отзывов"""
    token = CONFIG['github']['token']
    if not token:
        print("❌ GitHub token не настроен! Запустите ./github_feedback_config.sh")
        return None
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Формируем тело issue
    device_info = feedback.get('deviceInfo', {})
    body = f"""## 📱 Feedback из iOS приложения

**Тип**: {feedback.get('type', 'unknown')}
**Дата**: {feedback.get('timestamp', 'unknown')}
**Устройство**: {device_info.get('model', 'unknown')} (iOS {device_info.get('osVersion', 'unknown')})
**Версия приложения**: {device_info.get('appVersion', 'unknown')} (Build {device_info.get('buildNumber', 'unknown')})

### 📝 Описание:
{feedback.get('text', 'No description provided')}

### 📱 Детали устройства:
- Размер экрана: {device_info.get('screenSize', 'unknown')}
- Локаль: {device_info.get('locale', 'unknown')}

---
*Этот issue был автоматически создан из feedback в мобильном приложении*
"""
    
    # Добавляем ссылку на скриншот если есть
    if screenshot_path:
        body += f"\n\n📸 Скриншот сохранен локально: `{screenshot_path.name}`"
        # TODO: Загрузить на imgur или другой хостинг
    
    # Определяем лейблы
    labels = CONFIG['github']['labels'].copy()
    feedback_type = feedback.get('type', 'bug').lower()
    if feedback_type in ['bug', 'error', 'ошибка']:
        labels.append('bug')
    elif feedback_type in ['feature', 'предложение']:
        labels.append('enhancement')
    elif feedback_type in ['question', 'вопрос']:
        labels.append('question')
    
    # Формируем заголовок
    title_text = feedback.get('text', '')[:50]
    if len(feedback.get('text', '')) > 50:
        title_text += '...'
    title = f"[Feedback] {feedback.get('type', 'Bug')}: {title_text}"
    
    issue_data = {
        'title': title,
        'body': body,
        'labels': labels
    }
    
    try:
        url = f"https://api.github.com/repos/{CONFIG['github']['owner']}/{CONFIG['github']['repo']}/issues"
        response = requests.post(url, headers=headers, json=issue_data)
        
        if response.status_code == 201:
            issue_url = response.json()['html_url']
            print(f"✅ Created GitHub issue: {issue_url}")
            return issue_url
        else:
            print(f"❌ Failed to create GitHub issue: {response.status_code}")
            print(f"Response: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error creating GitHub issue: {e}")
        return None

def send_notification(feedback, github_url=None):
    """Отправляет уведомление в Slack/Discord"""
    # TODO: Реализовать если нужно
    pass

@app.route('/')
def index():
    """Веб-интерфейс для просмотра feedback"""
    feedbacks = []
    for feedback_file in sorted(FEEDBACK_DIR.glob("*.json"), reverse=True):
        try:
            with open(feedback_file) as f:
                feedbacks.append(json.load(f))
        except:
            pass
    
    html = """<!DOCTYPE html>
<html>
<head>
    <title>LMS Feedback Dashboard</title>
    <meta charset="utf-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
               margin: 20px; background: #f5f5f7; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #1d1d1f; }
        .feedback { background: white; padding: 20px; margin: 15px 0; 
                   border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .type { display: inline-block; padding: 4px 12px; border-radius: 20px; 
               font-size: 12px; font-weight: 600; margin-right: 10px; }
        .bug { background: #fee; color: #c33; }
        .feature { background: #e3f2fd; color: #1976d2; }
        .question { background: #f3e5f5; color: #7b1fa2; }
        .improvement { background: #e8f5e9; color: #388e3c; }
        .meta { color: #86868b; font-size: 14px; margin: 10px 0; }
        .text { margin: 15px 0; line-height: 1.5; }
        .device { background: #f5f5f7; padding: 10px; border-radius: 8px; 
                 font-size: 13px; color: #86868b; }
        .screenshot { margin: 10px 0; }
        .screenshot img { max-width: 300px; border: 1px solid #d2d2d7; 
                         border-radius: 8px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 LMS Feedback Dashboard</h1>
        <p>Всего отзывов: """ + str(len(feedbacks)) + """</p>
        <hr>
"""
    
    for feedback in feedbacks:
        device_info = feedback.get('deviceInfo', {})
        feedback_type = feedback.get('type', 'unknown').lower()
        
        html += f"""
        <div class="feedback">
            <span class="type {feedback_type}">{feedback.get('type', 'Unknown')}</span>
            <span class="meta">{feedback.get('timestamp', 'Unknown time')}</span>
            <div class="text">{feedback.get('text', 'No text')}</div>
            <div class="device">
                {device_info.get('model', 'Unknown')} • 
                iOS {device_info.get('osVersion', 'Unknown')} • 
                v{device_info.get('appVersion', 'Unknown')} 
                ({device_info.get('buildNumber', 'Unknown')})
            </div>
"""
        
        if feedback.get('screenshot_path'):
            screenshot_name = Path(feedback['screenshot_path']).name
            html += f"""
            <div class="screenshot">
                <img src="/screenshot/{screenshot_name}" 
                     onclick="window.open(this.src)" 
                     title="Click to view full size">
            </div>
"""
        
        html += "</div>"
    
    html += """
    </div>
</body>
</html>"""
    
    return html

@app.route('/screenshot/<filename>')
def serve_screenshot(filename):
    """Отдает скриншоты"""
    from flask import send_from_directory
    return send_from_directory(SCREENSHOTS_DIR, filename)

@app.route('/api/v1/feedback/list')
def list_feedback():
    """API endpoint для получения списка feedback"""
    feedbacks = []
    for feedback_file in sorted(FEEDBACK_DIR.glob("*.json"), reverse=True):
        try:
            with open(feedback_file) as f:
                feedbacks.append(json.load(f))
        except:
            pass
    return jsonify(feedbacks)

if __name__ == '__main__':
    print(f"""
🚀 LMS Feedback Server Started!
================================
📍 URL: http://localhost:{CONFIG['server']['port']}
📱 iOS endpoint: http://localhost:{CONFIG['server']['port']}/api/v1/feedback
🌐 Web dashboard: http://localhost:{CONFIG['server']['port']}/
📊 API list: http://localhost:{CONFIG['server']['port']}/api/v1/feedback/list

GitHub Integration: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured (run ./github_feedback_config.sh)'}
Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}

Press Ctrl+C to stop
""")
    
    app.run(
        host=CONFIG['server']['host'], 
        port=CONFIG['server']['port'], 
        debug=True
    ) 