#!/usr/bin/env python3
"""
Cloud-ready Feedback Server с поддержкой скриншотов для iOS приложения
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
    'imgur': {
        'client_id': os.getenv('IMGUR_CLIENT_ID', ''),
    },
    'server': {
        'port': int(os.getenv('PORT', 5001)),
        'host': '0.0.0.0'
    }
}

FEEDBACK_STORAGE = []

def upload_to_imgur(base64_image):
    """Загружает изображение на Imgur и возвращает URL"""
    if not CONFIG['imgur']['client_id']:
        print("⚠️ Imgur client ID не настроен")
        return None
    
    try:
        if ',' in base64_image:
            base64_image = base64_image.split(',')[1]
        
        headers = {
            'Authorization': f"Client-ID {CONFIG['imgur']['client_id']}"
        }
        
        data = {
            'image': base64_image,
            'type': 'base64',
            'title': 'LMS Feedback Screenshot'
        }
        
        response = requests.post('https://api.imgur.com/3/image', headers=headers, data=data)
        
        if response.status_code == 200:
            result = response.json()
            if result['success']:
                image_url = result['data']['link']
                print(f"✅ Uploaded screenshot to Imgur: {image_url}")
                return image_url
        
        print(f"❌ Failed to upload to Imgur: {response.status_code}")
        return None
        
    except Exception as e:
        print(f"❌ Error uploading to Imgur: {e}")
        return None

def create_github_issue_with_screenshot(feedback):
    """Создает GitHub issue с поддержкой скриншотов"""
    token = CONFIG['github']['token']
    if not token:
        print("❌ GitHub token не настроен!")
        return None
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Обрабатываем скриншот
    screenshot_section = ""
    if feedback.get('screenshot'):
        imgur_url = upload_to_imgur(feedback['screenshot'])
        if imgur_url:
            screenshot_section = f"\n\n## 📸 Скриншот\n![Screenshot]({imgur_url})\n"
        else:
            screenshot_section = "\n\n## 📸 Скриншот\n*Скриншот был приложен к отзыву*\n"
    
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
        'imgur_configured': bool(CONFIG['imgur']['client_id']),
        'feedback_count': len(FEEDBACK_STORAGE)
    })

if __name__ == '__main__':
    port = CONFIG['server']['port']
    print(f"""
🚀 LMS Feedback Server (Enhanced Edition) Started!
================================================
📍 Port: {port}
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured'}
🖼️  Imgur Client: {'✅ Configured' if CONFIG['imgur']['client_id'] else '❌ Not configured'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}

Note: To enable screenshot uploads, register an app at https://api.imgur.com/oauth2/addclient
""")
    
    app.run(host=CONFIG['server']['host'], port=port)
