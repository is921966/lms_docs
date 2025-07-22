#!/usr/bin/env python3
"""
Railway-ready Feedback Server для приема отзывов из iOS приложения
v6 - сохранение скриншотов в репозиторий GitHub
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
import traceback
from PIL import Image
import io

app = Flask(__name__)
CORS(app)

# Конфигурация из переменных окружения
CONFIG = {
    'github': {
        'token': os.getenv('GITHUB_TOKEN', ''),
        'owner': os.getenv('GITHUB_OWNER', 'is921966'),
        'repo': os.getenv('GITHUB_REPO', 'lms_docs'),
        'labels': ['feedback', 'mobile-app', 'ios'],
        'screenshots_path': 'feedback_screenshots'  # Папка для скриншотов
    },
    'screenshot': {
        'max_width': 1024,
        'max_height': 768,
        'quality': 85,
    }
}

# In-memory storage для Railway
FEEDBACK_STORAGE = []

def optimize_screenshot(base64_image):
    """Оптимизирует скриншот для GitHub"""
    try:
        # Декодируем base64
        image_data = base64.b64decode(base64_image)
        img = Image.open(io.BytesIO(image_data))
        
        # Конвертируем в RGB если нужно
        if img.mode not in ('RGB', 'RGBA'):
            img = img.convert('RGB')
        
        # Изменяем размер если слишком большой
        max_width = CONFIG['screenshot']['max_width']
        max_height = CONFIG['screenshot']['max_height']
        
        if img.width > max_width or img.height > max_height:
            img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
        
        # Сохраняем как PNG для лучшего качества
        output = io.BytesIO()
        img.save(output, format='PNG', optimize=True)
        output.seek(0)
        
        # Возвращаем base64 оптимизированного изображения
        return base64.b64encode(output.getvalue()).decode('utf-8')
    except Exception as e:
        print(f"❌ Screenshot optimization error: {str(e)}")
        return None

def upload_screenshot_to_repo(screenshot_base64, issue_number):
    """Загружает скриншот в репозиторий GitHub"""
    try:
        # Генерируем уникальное имя файла
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{uuid.uuid4().hex[:8]}.png"
        file_path = f"{CONFIG['github']['screenshots_path']}/{filename}"
        
        # URL для API создания файла
        url = f"https://api.github.com/repos/{CONFIG['github']['owner']}/{CONFIG['github']['repo']}/contents/{file_path}"
        
        headers = {
            'Authorization': f"token {CONFIG['github']['token']}",
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Подготовка данных для создания файла
        data = {
            'message': f'Add screenshot for issue #{issue_number}',
            'content': screenshot_base64,
            'branch': 'main'  # Можно изменить на другую ветку
        }
        
        # Создаем файл в репозитории
        response = requests.put(url, headers=headers, json=data)
        
        if response.status_code == 201:
            file_info = response.json()
            # Формируем URL для просмотра изображения
            raw_url = file_info['content']['download_url']
            print(f"✅ Screenshot uploaded to repository: {file_path}")
            return raw_url
        else:
            print(f"❌ Failed to upload screenshot: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Screenshot upload error: {str(e)}")
        return None

def create_github_issue(feedback_data):
    """Создает issue в GitHub с правильной ссылкой на скриншот"""
    if not CONFIG['github']['token']:
        print("⚠️ GitHub token not configured")
        return None
    
    # Сначала загружаем скриншот если есть
    screenshot_url = None
    if feedback_data.get('screenshot'):
        print("📸 Uploading screenshot to repository...")
        # Оптимизируем скриншот
        optimized = optimize_screenshot(feedback_data['screenshot'])
        if optimized:
            # Сохраняем временно issue_number как placeholder
            screenshot_url = upload_screenshot_to_repo(optimized, 'pending')
    
    url = f"https://api.github.com/repos/{CONFIG['github']['owner']}/{CONFIG['github']['repo']}/issues"
    
    headers = {
        'Authorization': f"token {CONFIG['github']['token']}",
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Подготовка содержимого issue
    body = f"""## 📱 Feedback from iOS App

**Type**: {feedback_data.get('type', 'feedback')}
**User**: {feedback_data.get('userName', 'Anonymous')} ({feedback_data.get('userEmail', 'N/A')})
**Date**: {feedback_data.get('timestamp', datetime.now().isoformat())}
**Device**: {feedback_data.get('deviceInfo', {}).get('model', 'Unknown')}
**iOS Version**: {feedback_data.get('deviceInfo', {}).get('osVersion', 'Unknown')}
**App Version**: {feedback_data.get('deviceInfo', {}).get('appVersion', 'Unknown')}

### 📝 Description:
{feedback_data.get('text', 'No description provided')}

### 📊 Additional Info:
- Screen: {feedback_data.get('screenName', 'Unknown')}
- User ID: {feedback_data.get('userId', 'N/A')}
"""

    # Добавляем скриншот если загружен
    if screenshot_url:
        body += f"\n### 📸 Screenshot:\n![Screenshot]({screenshot_url})"
    elif feedback_data.get('screenshot'):
        body += "\n### 📸 Screenshot:\n*Screenshot upload failed. Available in feedback dashboard.*"

    # Определяем labels
    labels = CONFIG['github']['labels'].copy()
    if feedback_data.get('type') == 'bug':
        labels.append('bug')
    
    # Создаем issue
    issue_data = {
        'title': f"[iOS] {feedback_data.get('type', 'Feedback').title()}: {feedback_data.get('text', 'No description')[:50]}...",
        'body': body,
        'labels': labels
    }
    
    try:
        response = requests.post(url, headers=headers, json=issue_data)
        if response.status_code == 201:
            issue_info = response.json()
            print(f"✅ GitHub issue created: {issue_info['html_url']}")
            return issue_info['html_url']
        else:
            print(f"❌ Failed to create GitHub issue: {response.status_code}")
            print(f"Response: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error creating GitHub issue: {str(e)}")
        print(f"Traceback: {traceback.format_exc()}")
        return None

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'service': 'feedback-server', 'version': '6.0.0'})

@app.route('/api/feedback', methods=['POST'])
def receive_feedback():
    try:
        feedback_data = request.json
        feedback_data['id'] = str(uuid.uuid4())
        feedback_data['received_at'] = datetime.now().isoformat()
        
        # Добавляем IP адрес
        feedback_data['ip_address'] = request.remote_addr
        
        # Логируем
        print(f"✅ Feedback received: {feedback_data.get('type', 'unknown')} from {feedback_data.get('userName', 'Unknown')}")
        
        if feedback_data.get('screenshot'):
            print(f"📸 Screenshot received: {len(feedback_data['screenshot'])} characters")
        
        # Сохраняем в памяти
        FEEDBACK_STORAGE.append(feedback_data)
        
        # Ограничиваем хранилище последними 100 записями
        if len(FEEDBACK_STORAGE) > 100:
            FEEDBACK_STORAGE.pop(0)
        
        # Создаем GitHub issue если настроено
        github_url = None
        if CONFIG['github']['token']:
            github_url = create_github_issue(feedback_data)
            feedback_data['github_issue'] = github_url
        
        return jsonify({
            'success': True,
            'id': feedback_data['id'],
            'github_issue': github_url
        }), 200
        
    except Exception as e:
        print(f"❌ Error processing feedback: {str(e)}")
        print(f"Traceback: {traceback.format_exc()}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/', methods=['GET'])
def dashboard():
    """Отображает dashboard с feedback"""
    html = """<!DOCTYPE html>
<html>
<head>
    <title>LMS Feedback Dashboard</title>
    <meta charset="utf-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f7;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            color: #1d1d1f;
            font-size: 2.5em;
            margin-bottom: 30px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
        }
        .stat-value {
            font-size: 2.5em;
            font-weight: 600;
            color: #007aff;
            margin-bottom: 5px;
        }
        .stat-label {
            color: #86868b;
            font-size: 0.9em;
        }
        .feedback-item {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }
        .feedback-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .feedback-type {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .type-bug {
            background: #ffeeee;
            color: #ff3b30;
        }
        .type-feature {
            background: #e8f5e9;
            color: #34c759;
        }
        .type-feedback {
            background: #e3f2fd;
            color: #007aff;
        }
        .feedback-meta {
            color: #86868b;
            font-size: 0.9em;
            margin-bottom: 15px;
        }
        .feedback-text {
            color: #1d1d1f;
            font-size: 1.1em;
            line-height: 1.5;
            margin-bottom: 15px;
        }
        .screenshot-preview {
            max-width: 300px;
            max-height: 200px;
            border-radius: 8px;
            border: 1px solid #d2d2d7;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .screenshot-preview:hover {
            transform: scale(1.02);
        }
        .github-link {
            color: #007aff;
            text-decoration: none;
            font-size: 0.9em;
        }
        .github-link:hover {
            text-decoration: underline;
        }
        .empty-state {
            text-align: center;
            padding: 60px;
            color: #86868b;
        }
        
        /* Modal стили */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            padding-top: 50px;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.9);
        }
        .modal-content {
            margin: auto;
            display: block;
            max-width: 90%;
            max-height: 90vh;
        }
        .close {
            position: absolute;
            top: 15px;
            right: 35px;
            color: #f1f1f1;
            font-size: 40px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: #999;
        }
        #caption {
            margin: auto;
            display: block;
            width: 80%;
            max-width: 700px;
            text-align: center;
            color: #ccc;
            padding: 10px 0;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 LMS Feedback Dashboard</h1>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value" id="totalCount">0</div>
                <div class="stat-label">Total Feedback</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="bugCount">0</div>
                <div class="stat-label">Bug Reports</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="featureCount">0</div>
                <div class="stat-label">Feature Requests</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="githubCount">0</div>
                <div class="stat-label">GitHub Issues</div>
            </div>
        </div>
        
        <div id="feedbackList"></div>
    </div>
    
    <!-- Modal для просмотра скриншотов -->
    <div id="imageModal" class="modal">
        <span class="close">&times;</span>
        <img class="modal-content" id="modalImage">
        <div id="caption"></div>
    </div>
    
    <script>
        // Функция для отображения скриншота в модальном окне
        function showScreenshot(imgSrc, feedbackInfo) {
            const modal = document.getElementById('imageModal');
            const modalImg = document.getElementById('modalImage');
            const captionText = document.getElementById('caption');
            
            modal.style.display = 'block';
            modalImg.src = imgSrc;
            captionText.innerHTML = `Feedback from ${feedbackInfo}`;
        }
        
        // Закрытие модального окна
        const modal = document.getElementById('imageModal');
        const span = document.getElementsByClassName('close')[0];
        
        span.onclick = function() {
            modal.style.display = 'none';
        }
        
        modal.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
        
        // Закрытие по Esc
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                modal.style.display = 'none';
            }
        });
        
        function loadFeedback() {
            fetch('/api/feedback/list')
                .then(response => response.json())
                .then(data => {
                    // Обновляем статистику
                    document.getElementById('totalCount').textContent = data.length;
                    document.getElementById('bugCount').textContent = 
                        data.filter(f => f.type === 'bug').length;
                    document.getElementById('featureCount').textContent = 
                        data.filter(f => f.type === 'feature').length;
                    document.getElementById('githubCount').textContent = 
                        data.filter(f => f.github_issue).length;
                    
                    // Отображаем feedback
                    const list = document.getElementById('feedbackList');
                    if (data.length === 0) {
                        list.innerHTML = '<div class="empty-state">No feedback received yet</div>';
                        return;
                    }
                    
                    list.innerHTML = data.reverse().map(feedback => `
                        <div class="feedback-item">
                            <div class="feedback-header">
                                <span class="feedback-type type-${feedback.type}">${feedback.type.toUpperCase()}</span>
                                <span>${new Date(feedback.timestamp || feedback.received_at).toLocaleString()}</span>
                            </div>
                            <div class="feedback-meta">
                                <strong>${feedback.userName}</strong> • ${feedback.deviceInfo?.model || 'Unknown device'} • 
                                iOS ${feedback.deviceInfo?.osVersion || '?'} • v${feedback.deviceInfo?.appVersion || '?'}
                            </div>
                            <div class="feedback-text">${feedback.text}</div>
                            ${feedback.screenshot ? `
                                <img src="data:image/png;base64,${feedback.screenshot}" 
                                     class="screenshot-preview" 
                                     onclick="showScreenshot(this.src, '${feedback.userName} - ${new Date(feedback.timestamp).toLocaleDateString()}')"
                                     alt="Screenshot">
                            ` : ''}
                            ${feedback.github_issue ? `
                                <a href="${feedback.github_issue}" target="_blank" class="github-link">
                                    View GitHub Issue →
                                </a>
                            ` : ''}
                        </div>
                    `).join('');
                })
                .catch(error => {
                    console.error('Error loading feedback:', error);
                });
        }
        
        // Загружаем при открытии и обновляем каждые 10 секунд
        loadFeedback();
        setInterval(loadFeedback, 10000);
    </script>
</body>
</html>"""
    return html

@app.route('/api/feedback/list', methods=['GET'])
def list_feedback():
    """Возвращает список всех feedback"""
    return jsonify(FEEDBACK_STORAGE)

# Инициализация при запуске
if os.getenv('RAILWAY_ENVIRONMENT'):
    print(f"""
🚀 LMS Feedback Server (Railway Edition v6) Initialized!
==========================================================
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}
📸 Screenshot Support: ✅ Enabled (saved to repository)
📂 Screenshots path: {CONFIG['github']['screenshots_path']}/
📏 Max screenshot: {CONFIG['screenshot']['max_width']}x{CONFIG['screenshot']['max_height']}
🖼️ Quality: {CONFIG['screenshot']['quality']}%
🖼️ Modal viewer: ✅ Enabled

Note: Running with gunicorn in production mode
Screenshots will be saved directly to the repository
""")
else:
    # Локальный запуск
    if __name__ == '__main__':
        print(f"""
🚀 LMS Feedback Server (Local Mode v6) Started!
==============================================
📱 Dashboard: http://localhost:5001
🔌 API Endpoint: http://localhost:5001/api/feedback
🔐 GitHub Integration: {'✅ Enabled' if CONFIG['github']['token'] else '❌ Disabled'}
📸 Screenshot Support: ✅ Enabled

Configure iOS app to send feedback to your local IP:
http://YOUR_LOCAL_IP:5001/api/feedback
""")
        app.run(host='0.0.0.0', port=5001, debug=True) 