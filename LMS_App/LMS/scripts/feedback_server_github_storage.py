#!/usr/bin/env python3
"""
Cloud-ready Feedback Server с сохранением скриншотов в GitHub
Альтернативное решение без зависимости от Imgur
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
CORS(app)

# Конфигурация
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

FEEDBACK_STORAGE = []

def upload_screenshot_to_github(base64_image, feedback_id):
    """Загружает скриншот прямо в GitHub репозиторий"""
    token = CONFIG['github']['token']
    if not token:
        print("❌ GitHub token не настроен для загрузки файлов")
        return None
    
    try:
        # Убираем префикс data:image/png;base64, если есть
        if ',' in base64_image:
            base64_image = base64_image.split(',')[1]
        
        # Создаем путь для файла
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"feedback_screenshots/{timestamp}_{feedback_id}.png"
        
        # GitHub API для создания файла
        url = f"https://api.github.com/repos/{CONFIG['github']['owner']}/{CONFIG['github']['repo']}/contents/{filename}"
        
        headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        data = {
            'message': f'Add feedback screenshot for {feedback_id}',
            'content': base64_image,
            'branch': 'master'
        }
        
        response = requests.put(url, headers=headers, json=data)
        
        if response.status_code == 201:
            result = response.json()
            # Получаем прямую ссылку на изображение
            download_url = result['content']['download_url']
            # Конвертируем в raw ссылку для отображения
            raw_url = download_url.replace('github.com', 'raw.githubusercontent.com').replace('/blob/', '/')
            print(f"✅ Screenshot uploaded to GitHub: {raw_url}")
            return raw_url
        else:
            print(f"❌ Failed to upload to GitHub: {response.status_code}")
            print(f"   Response: {response.text[:200]}...")
            return None
            
    except Exception as e:
        print(f"❌ Error uploading to GitHub: {e}")
        import traceback
        traceback.print_exc()
        return None

def create_github_issue_with_screenshot(feedback):
    """Создает GitHub issue со скриншотом, сохраненным в репозитории"""
    token = CONFIG['github']['token']
    if not token:
        print("❌ GitHub token не настроен!")
        return None
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Генерируем ID для фидбэка
    feedback_id = feedback.get('id', str(uuid.uuid4()))
    
    # Обрабатываем скриншот
    screenshot_section = ""
    if feedback.get('screenshot'):
        print("📸 Обрабатываем скриншот...")
        screenshot_url = upload_screenshot_to_github(feedback['screenshot'], feedback_id)
        if screenshot_url:
            screenshot_section = f"\n\n## 📸 Скриншот\n![Screenshot]({screenshot_url})\n"
        else:
            screenshot_section = "\n\n## 📸 Скриншот\n*Не удалось загрузить скриншот*\n"
    
    # Формируем тело issue
    device_info = feedback.get('deviceInfo', {})
    feedback_type = feedback.get('type', 'unknown')
    
    # Определяем emoji для типа
    type_emoji = {
        'bug': '🐛',
        'feature': '💡',
        'improvement': '✨',
        'question': '❓'
    }.get(feedback_type.lower(), '📝')
    
    body = f"""## 📱 Feedback из iOS приложения

**Тип**: {type_emoji} {feedback_type}
**Дата**: {feedback.get('timestamp', 'unknown')}
**Пользователь**: {feedback.get('userEmail', 'Anonymous')}

### 📝 Описание:
{feedback.get('text', 'No description provided')}
{screenshot_section}
### 📱 Информация об устройстве:
- **Модель**: {device_info.get('model', 'unknown')}
- **iOS**: {device_info.get('osVersion', 'unknown')}
- **Версия приложения**: {device_info.get('appVersion', 'unknown')} (Build {device_info.get('buildNumber', 'unknown')})
- **Размер экрана**: {device_info.get('screenSize', 'unknown')}
- **Локаль**: {device_info.get('locale', 'unknown')}

---
*Автоматически создано из мобильного приложения*
"""
    
    # Определяем лейблы на основе типа
    labels = CONFIG['github']['labels'].copy()
    
    type_to_label = {
        'bug': 'bug',
        'feature': 'enhancement',
        'improvement': 'improvement',
        'question': 'question'
    }
    
    github_label = type_to_label.get(feedback_type.lower())
    if github_label:
        labels.append(github_label)
    
    # Формируем заголовок с emoji
    title_text = feedback.get('text', '')[:50]
    if len(feedback.get('text', '')) > 50:
        title_text += '...'
    title = f"{type_emoji} [{feedback_type}] {title_text}"
    
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
            return None
    except Exception as e:
        print(f"❌ Error creating GitHub issue: {e}")
        return None

@app.route('/api/v1/feedback', methods=['POST'])
def receive_feedback():
    """Принимает feedback от iOS приложения"""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing feedback text'}), 400
        
        feedback = {
            **data,
            'received_at': datetime.utcnow().isoformat(),
            'ip_address': request.remote_addr,
            'user_agent': request.headers.get('User-Agent', '')
        }
        
        github_url = create_github_issue_with_screenshot(feedback)
        if github_url:
            feedback['github_issue_url'] = github_url
        
        feedback_id = data.get('id', str(uuid.uuid4()))
        feedback_for_storage = {k: v for k, v in feedback.items() if k != 'screenshot'}
        feedback_for_storage['has_screenshot'] = bool(feedback.get('screenshot'))
        feedback_for_storage['id'] = feedback_id
        FEEDBACK_STORAGE.append(feedback_for_storage)
        
        if len(FEEDBACK_STORAGE) > 100:
            FEEDBACK_STORAGE.pop(0)
        
        print(f"✅ Received feedback: {feedback_id}")
        print(f"   Type: {feedback.get('type', 'unknown')}")
        print(f"   Has screenshot: {bool(feedback.get('screenshot'))}")
        
        return jsonify({
            'status': 'success',
            'id': feedback_id,
            'message': 'Feedback received successfully',
            'github_issue': github_url
        }), 201
        
    except Exception as e:
        print(f"❌ Error processing feedback: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'github_configured': bool(CONFIG['github']['token']),
        'storage_method': 'github',
        'feedback_count': len(FEEDBACK_STORAGE)
    })

@app.route('/api/v1/feedbacks', methods=['GET'])
def get_feedbacks():
    """Возвращает список последних фидбэков для отображения в приложении"""
    # Возвращаем последние 50 фидбэков
    recent_feedbacks = sorted(
        FEEDBACK_STORAGE, 
        key=lambda x: x.get('received_at', ''), 
        reverse=True
    )[:50]
    
    return jsonify({
        'status': 'success',
        'count': len(recent_feedbacks),
        'feedbacks': recent_feedbacks
    })

if __name__ == '__main__':
    port = CONFIG['server']['port']
    print(f"""
🚀 LMS Feedback Server (GitHub Storage Edition) Started!
======================================================
📍 Port: {port}
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}
🖼️  Storage: GitHub Repository (no external dependencies)

Note: Screenshots are saved directly to the repository
""")
    
    app.run(host=CONFIG['server']['host'], port=port) 