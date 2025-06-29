#!/usr/bin/env python3
"""
Cloud-ready Feedback Server для приема отзывов из iOS приложения
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
CORS(app)  # Разрешаем CORS для всех источников

# Конфигурация из переменных окружения
CONFIG = {
    'github': {
        'token': os.getenv('GITHUB_TOKEN', ''),
        'owner': os.getenv('GITHUB_OWNER', 'is921966'),
        'repo': os.getenv('GITHUB_REPO', 'lms_docs'),
        'labels': ['feedback', 'mobile-app', 'ios']
    },
    'server': {
        'port': int(os.getenv('PORT', 5001)),
        'host': '0.0.0.0'
    }
}

# Создаем директории для локального хранения (если используется volume)
FEEDBACK_DIR = Path("feedback_data")
SCREENSHOTS_DIR = FEEDBACK_DIR / "screenshots"
FEEDBACK_DIR.mkdir(exist_ok=True)
SCREENSHOTS_DIR.mkdir(exist_ok=True)

# In-memory storage для облачного развертывания
FEEDBACK_STORAGE = []

@app.route('/')
def index():
    """Веб-интерфейс для просмотра feedback"""
    # Читаем из памяти вместо файлов
    feedbacks = sorted(FEEDBACK_STORAGE, key=lambda x: x.get('received_at', ''), reverse=True)
    
    html = """<!DOCTYPE html>
<html>
<head>
    <title>LMS Feedback Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            margin: 20px; 
            background: #f5f5f7; 
        }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #1d1d1f; }
        .info { 
            background: #e3f2fd; 
            padding: 15px; 
            border-radius: 8px; 
            margin-bottom: 20px; 
        }
        .feedback { 
            background: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 12px; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
        }
        .type { 
            display: inline-block; 
            padding: 4px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600; 
            margin-right: 10px; 
        }
        .bug { background: #fee; color: #c33; }
        .feature { background: #e3f2fd; color: #1976d2; }
        .question { background: #f3e5f5; color: #7b1fa2; }
        .improvement { background: #e8f5e9; color: #388e3c; }
        .test { background: #fff3e0; color: #ef6c00; }
        .meta { color: #86868b; font-size: 14px; margin: 10px 0; }
        .text { margin: 15px 0; line-height: 1.5; }
        .device { 
            background: #f5f5f7; 
            padding: 10px; 
            border-radius: 8px; 
            font-size: 13px; 
            color: #86868b; 
        }
        .github-link {
            margin-top: 10px;
            font-size: 14px;
        }
        .github-link a {
            color: #0366d6;
            text-decoration: none;
        }
        .github-link a:hover {
            text-decoration: underline;
        }
        @media (max-width: 600px) {
            body { margin: 10px; }
            .feedback { padding: 15px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 LMS Feedback Dashboard</h1>
        <div class="info">
            <strong>Cloud Instance</strong><br>
            GitHub Integration: """ + ('✅ Configured' if CONFIG['github']['token'] else '❌ Not configured') + """<br>
            Total feedbacks: """ + str(len(feedbacks)) + """
        </div>
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
        
        if feedback.get('github_issue_url'):
            html += f"""
            <div class="github-link">
                📝 <a href="{feedback['github_issue_url']}" target="_blank">View GitHub Issue</a>
            </div>
"""
        
        html += "</div>"
    
    html += """
    </div>
</body>
</html>"""
    
    return html

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
        
        # Создаем GitHub issue
        github_url = create_github_issue(feedback)
        if github_url:
            feedback['github_issue_url'] = github_url
        
        # Сохраняем в памяти
        feedback_id = data.get('id', str(uuid.uuid4()))
        feedback['id'] = feedback_id
        FEEDBACK_STORAGE.append(feedback)
        
        # Ограничиваем размер хранилища (последние 100 записей)
        if len(FEEDBACK_STORAGE) > 100:
            FEEDBACK_STORAGE.pop(0)
        
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

@app.route('/api/v1/feedback/list')
def list_feedback():
    """API endpoint для получения списка feedback"""
    feedbacks = sorted(FEEDBACK_STORAGE, key=lambda x: x.get('received_at', ''), reverse=True)
    return jsonify(feedbacks)

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'github_configured': bool(CONFIG['github']['token']),
        'feedback_count': len(FEEDBACK_STORAGE)
    })

def create_github_issue(feedback):
    """Создает GitHub issue для всех отзывов"""
    token = CONFIG['github']['token']
    if not token:
        print("❌ GitHub token не настроен!")
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

### 🌐 Метаданные:
- IP адрес: {feedback.get('ip_address', 'unknown')}
- User Agent: {feedback.get('user_agent', 'unknown')}

---
*Этот issue был автоматически создан из feedback в мобильном приложении*
"""
    
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

if __name__ == '__main__':
    port = CONFIG['server']['port']
    print(f"""
🚀 LMS Feedback Server (Cloud Edition) Started!
==============================================
📍 Port: {port}
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured - set GITHUB_TOKEN env var'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}

Environment Variables:
- GITHUB_TOKEN: {'Set' if CONFIG['github']['token'] else 'Not set'}
- GITHUB_OWNER: {CONFIG['github']['owner']}
- GITHUB_REPO: {CONFIG['github']['repo']}
- PORT: {port}
""")
    
    app.run(
        host=CONFIG['server']['host'], 
        port=port,
        debug=os.getenv('DEBUG', 'False').lower() == 'true'
    ) 