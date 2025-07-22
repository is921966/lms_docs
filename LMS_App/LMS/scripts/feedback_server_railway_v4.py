#!/usr/bin/env python3
"""
Railway-ready Feedback Server для приема отзывов из iOS приложения
v4 - с модальным окном для просмотра скриншотов
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
        'labels': ['feedback', 'mobile-app', 'ios']
    },
    'screenshot': {
        'max_width': 800,
        'max_height': 600,
        'quality': 70,
        'max_size_kb': 50  # Максимум 50KB для GitHub
    }
}

# In-memory storage для Railway
FEEDBACK_STORAGE = []

def optimize_screenshot(base64_string):
    """Оптимизирует скриншот для уменьшения размера"""
    try:
        # Декодируем base64
        img_data = base64.b64decode(base64_string)
        img = Image.open(io.BytesIO(img_data))
        
        # Конвертируем в RGB если нужно
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Ресайз если слишком большой
        max_width = CONFIG['screenshot']['max_width']
        max_height = CONFIG['screenshot']['max_height']
        
        if img.width > max_width or img.height > max_height:
            img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
        
        # Сохраняем с оптимизацией
        output = io.BytesIO()
        quality = CONFIG['screenshot']['quality']
        
        # Постепенно уменьшаем качество пока не достигнем нужного размера
        while quality > 20:
            output.seek(0)
            output.truncate(0)
            img.save(output, format='JPEG', quality=quality, optimize=True)
            
            # Проверяем размер
            size_kb = len(output.getvalue()) / 1024
            if size_kb <= CONFIG['screenshot']['max_size_kb']:
                break
            
            quality -= 10
        
        # Возвращаем оптимизированный base64
        output.seek(0)
        return base64.b64encode(output.read()).decode('utf-8')
        
    except Exception as e:
        print(f"⚠️ Failed to optimize screenshot: {str(e)}")
        return None

def create_github_issue(feedback_data):
    """Создает issue в GitHub репозитории"""
    if not CONFIG['github']['token']:
        print("⚠️  GitHub token not configured - skipping issue creation")
        return None
    
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

    # Обработка скриншота
    screenshot_included = False
    if feedback_data.get('screenshot'):
        try:
            # Оптимизируем скриншот
            optimized = optimize_screenshot(feedback_data['screenshot'])
            if optimized:
                # Проверяем финальный размер
                screenshot_size = len(optimized)
                remaining_space = 65000 - len(body.encode('utf-8'))  # Оставляем запас
                
                if screenshot_size < remaining_space:
                    screenshot_url = f"data:image/jpeg;base64,{optimized}"
                    body += f"\n### 📸 Screenshot:\n![Screenshot]({screenshot_url})"
                    screenshot_included = True
                    print(f"✅ Screenshot optimized and included ({screenshot_size} chars)")
                else:
                    body += "\n### 📸 Screenshot:\n*Screenshot was too large to include in issue. Available in feedback dashboard.*"
                    print(f"⚠️ Screenshot too large even after optimization ({screenshot_size} chars)")
            else:
                body += "\n### 📸 Screenshot:\n*Screenshot optimization failed. Original available in feedback dashboard.*"
        except Exception as e:
            print(f"⚠️ Failed to process screenshot: {str(e)}")
            body += "\n### 📸 Screenshot:\n*Screenshot processing failed.*"

    # Определяем labels
    labels = CONFIG['github']['labels'].copy()
    feedback_type = feedback_data.get('type', 'feedback')
    if feedback_type == 'bug':
        labels.append('bug')
    elif feedback_type == 'feature':
        labels.append('enhancement')
    
    # Данные для создания issue
    issue_data = {
        'title': f"[iOS] {feedback_type.capitalize()}: {feedback_data.get('text', '')[:50]}...",
        'body': body,
        'labels': labels
    }
    
    try:
        url = f"https://api.github.com/repos/{CONFIG['github']['owner']}/{CONFIG['github']['repo']}/issues"
        response = requests.post(url, json=issue_data, headers=headers)
        
        if response.status_code == 201:
            issue_url = response.json()['html_url']
            print(f"✅ GitHub issue created: {issue_url}")
            return issue_url
        else:
            print(f"❌ Failed to create GitHub issue: {response.status_code}")
            print(response.text)
            return None
    except Exception as e:
        print(f"❌ Error creating GitHub issue: {str(e)}")
        traceback.print_exc()
        return None

@app.route('/')
def index():
    """Dashboard страница"""
    html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>LMS Feedback Server</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; background: #f5f5f7; }
            .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 12px; }
            h1 { color: #1d1d1f; }
            .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0; }
            .stat { background: #f5f5f7; padding: 20px; border-radius: 8px; text-align: center; }
            .stat-number { font-size: 2em; font-weight: bold; color: #0071e3; }
            .feedback-item { border: 1px solid #d2d2d7; padding: 15px; margin: 10px 0; border-radius: 8px; }
            .feedback-type { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; }
            .type-bug { background: #ffeeee; color: #ff3b30; }
            .type-feature { background: #e8f5e9; color: #34c759; }
            .type-feedback { background: #e3f2fd; color: #007aff; }
            .screenshot-preview { 
                max-width: 300px; 
                max-height: 200px; 
                margin-top: 10px; 
                border-radius: 8px; 
                cursor: pointer; 
                transition: transform 0.2s;
                border: 1px solid #d2d2d7;
            }
            .screenshot-preview:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }
            .version-info { color: #6e6e73; font-size: 14px; margin-top: 10px; }
            
            /* Modal styles */
            .modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.9);
                overflow: auto;
            }
            .modal-content {
                margin: auto;
                display: block;
                max-width: 90%;
                max-height: 90%;
                margin-top: 2%;
            }
            .modal-content {
                animation-name: zoom;
                animation-duration: 0.3s;
            }
            @keyframes zoom {
                from {transform: scale(0)}
                to {transform: scale(1)}
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
            .close:hover { color: #bbb; }
            #caption {
                margin: auto;
                display: block;
                width: 80%;
                max-width: 700px;
                text-align: center;
                color: #ccc;
                padding: 10px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 LMS Feedback Server</h1>
            <p>Railway Production Server - v4 with Modal Screenshot Viewer</p>
            <p class="version-info">Max screenshot size: 800x600, Quality: auto-adjusted, Max: 50KB for GitHub</p>
            
            <div class="stats">
                <div class="stat">
                    <div class="stat-number" id="totalCount">0</div>
                    <div>Total Feedback</div>
                </div>
                <div class="stat">
                    <div class="stat-number" id="todayCount">0</div>
                    <div>Today</div>
                </div>
                <div class="stat">
                    <div class="stat-number" id="issuesCount">0</div>
                    <div>GitHub Issues</div>
                </div>
            </div>
            
            <h2>Recent Feedback</h2>
            <div id="feedbackList"></div>
        </div>
        
        <!-- Modal for fullscreen image -->
        <div id="imageModal" class="modal">
            <span class="close">&times;</span>
            <img class="modal-content" id="modalImage">
            <div id="caption"></div>
        </div>
        
        <script>
            // Modal functionality
            const modal = document.getElementById('imageModal');
            const modalImg = document.getElementById('modalImage');
            const captionText = document.getElementById('caption');
            const span = document.getElementsByClassName('close')[0];
            
            function showScreenshot(imgSrc, feedbackInfo) {
                modal.style.display = 'block';
                modalImg.src = imgSrc;
                captionText.innerHTML = feedbackInfo;
            }
            
            span.onclick = function() {
                modal.style.display = 'none';
            }
            
            window.onclick = function(event) {
                if (event.target == modal) {
                    modal.style.display = 'none';
                }
            }
            
            // Escape key closes modal
            document.addEventListener('keydown', function(event) {
                if (event.key === 'Escape') {
                    modal.style.display = 'none';
                }
            });
            
            function loadFeedback() {
                fetch('/api/v1/feedback')
                    .then(r => r.json())
                    .then(data => {
                        document.getElementById('totalCount').textContent = data.items.length;
                        
                        const today = new Date().toDateString();
                        const todayItems = data.items.filter(f => 
                            new Date(f.timestamp).toDateString() === today
                        );
                        document.getElementById('todayCount').textContent = todayItems.length;
                        
                        const withIssues = data.items.filter(f => f.githubIssue);
                        document.getElementById('issuesCount').textContent = withIssues.length;
                        
                        const list = document.getElementById('feedbackList');
                        list.innerHTML = data.items.slice(-10).reverse().map(f => {
                            let screenshotHtml = '';
                            if (f.screenshot) {
                                const feedbackInfo = `${f.type} от ${f.userName || 'Anonymous'} - ${new Date(f.timestamp).toLocaleString()}`;
                                screenshotHtml = `
                                    <img src="data:image/png;base64,${f.screenshot}" 
                                         class="screenshot-preview" 
                                         alt="Screenshot"
                                         onclick="showScreenshot(this.src, '${feedbackInfo.replace(/'/g, "\\'")}')">
                                `;
                            }
                            
                            return `
                                <div class="feedback-item">
                                    <span class="feedback-type type-${f.type}">${f.type}</span>
                                    <strong>${f.userName || 'Anonymous'}</strong> - 
                                    ${new Date(f.timestamp).toLocaleString()}
                                    <p>${f.text}</p>
                                    ${screenshotHtml}
                                    ${f.githubIssue ? `<a href="${f.githubIssue}" target="_blank">View Issue</a>` : ''}
                                    ${f.screenshotOptimized ? '<small>📸 Screenshot optimized</small>' : ''}
                                </div>
                            `;
                        }).join('');
                    })
                    .catch(err => {
                        console.error('Error loading feedback:', err);
                    });
            }
            
            loadFeedback();
            setInterval(loadFeedback, 5000);
        </script>
    </body>
    </html>
    '''
    return html

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'server': 'Railway Feedback Server v4',
        'timestamp': datetime.now().isoformat(),
        'github_configured': bool(CONFIG['github']['token']),
        'feedback_count': len(FEEDBACK_STORAGE),
        'version': '4.0.0',
        'features': ['base64-screenshots', 'github-integration', 'screenshot-optimization', 'modal-viewer']
    })

@app.route('/api/v1/feedback', methods=['GET', 'POST'])
def feedback():
    """API endpoint для работы с feedback"""
    if request.method == 'GET':
        return jsonify({
            'status': 'success',
            'items': FEEDBACK_STORAGE,
            'count': len(FEEDBACK_STORAGE)
        })
    
    if request.method == 'POST':
        try:
            data = request.get_json()
            
            # Добавляем метаданные
            data['id'] = str(uuid.uuid4())
            data['timestamp'] = data.get('timestamp', datetime.now().isoformat())
            data['serverReceived'] = datetime.now().isoformat()
            
            # Логируем наличие скриншота
            if data.get('screenshot'):
                original_size = len(data['screenshot'])
                print(f"📸 Screenshot received: {original_size} characters")
                data['screenshotSize'] = original_size
                data['screenshotStored'] = True
                
                # Пробуем оптимизировать для хранения
                optimized = optimize_screenshot(data['screenshot'])
                if optimized:
                    data['screenshotOptimized'] = True
                    data['screenshotOptimizedSize'] = len(optimized)
                    print(f"📸 Screenshot optimized for storage: {original_size} -> {len(optimized)} chars")
            
            # Извлекаем информацию для удобства
            data['userName'] = data.get('userId', 'Anonymous')
            if data.get('userEmail'):
                data['userName'] = data['userEmail'].split('@')[0]
            
            # Создаем GitHub issue для багов
            if data.get('type') == 'bug' or (data.get('type') == 'feedback' and 'error' in data.get('text', '').lower()):
                issue_url = create_github_issue(data)
                if issue_url:
                    data['githubIssue'] = issue_url
            
            # Сохраняем в памяти
            FEEDBACK_STORAGE.append(data)
            
            # Ограничиваем размер хранилища (держим последние 1000)
            if len(FEEDBACK_STORAGE) > 1000:
                FEEDBACK_STORAGE.pop(0)
            
            print(f"✅ Feedback received: {data.get('type', 'unknown')} from {data.get('userName', 'Anonymous')}")
            
            return jsonify({
                'status': 'success',
                'message': 'Feedback received',
                'id': data['id'],
                'githubIssue': data.get('githubIssue'),
                'screenshotStored': data.get('screenshotStored', False),
                'screenshotOptimized': data.get('screenshotOptimized', False)
            }), 201
            
        except Exception as e:
            print(f"❌ Error processing feedback: {str(e)}")
            traceback.print_exc()
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

# Важно! Для gunicorn нужно, чтобы приложение было доступно на уровне модуля
# НЕ добавляем if __name__ == '__main__' для Railway!

print(f"""
🚀 LMS Feedback Server (Railway Edition v4) Initialized!
==========================================================
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}
📸 Screenshot Support: ✅ Enabled with optimization
📏 Max screenshot: {CONFIG['screenshot']['max_width']}x{CONFIG['screenshot']['max_height']}
💾 Max size for GitHub: {CONFIG['screenshot']['max_size_kb']}KB
🖼️ Modal viewer: ✅ Enabled

Note: Running with gunicorn in production mode
""") 