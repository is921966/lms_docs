#!/usr/bin/env python3
"""
Railway-ready Feedback Server для приема отзывов из iOS приложения
Оптимизирован для работы с gunicorn
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

app = Flask(__name__)
CORS(app)

# Конфигурация из переменных окружения
CONFIG = {
    'github': {
        'token': os.getenv('GITHUB_TOKEN', ''),
        'owner': os.getenv('GITHUB_OWNER', 'is921966'),
        'repo': os.getenv('GITHUB_REPO', 'lms_docs'),
        'labels': ['feedback', 'mobile-app', 'ios']
    }
}

# In-memory storage для Railway
FEEDBACK_STORAGE = []

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
**iOS Version**: {feedback_data.get('deviceInfo', {}).get('systemVersion', 'Unknown')}
**App Version**: {feedback_data.get('appVersion', 'Unknown')}

### 📝 Description:
{feedback_data.get('text', 'No description provided')}

### 📊 Additional Info:
- Screen: {feedback_data.get('screenName', 'Unknown')}
- User ID: {feedback_data.get('userId', 'N/A')}
"""

    # Добавляем скриншот если есть
    if feedback_data.get('screenshotUrl'):
        body += f"\n### 📸 Screenshot:\n![Screenshot]({feedback_data['screenshotUrl']})"

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
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 LMS Feedback Server</h1>
            <p>Railway Production Server</p>
            
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
        
        <script>
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
                        list.innerHTML = data.items.slice(-10).reverse().map(f => `
                            <div class="feedback-item">
                                <span class="feedback-type type-${f.type}">${f.type}</span>
                                <strong>${f.userName || 'Anonymous'}</strong> - 
                                ${new Date(f.timestamp).toLocaleString()}
                                <p>${f.text}</p>
                                ${f.githubIssue ? `<a href="${f.githubIssue}" target="_blank">View Issue</a>` : ''}
                            </div>
                        `).join('');
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
        'server': 'Railway Feedback Server',
        'timestamp': datetime.now().isoformat(),
        'github_configured': bool(CONFIG['github']['token']),
        'feedback_count': len(FEEDBACK_STORAGE)
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
            
            # Сохраняем скриншот если есть
            if data.get('screenshot'):
                # Для Railway просто сохраняем base64 в памяти
                # В production лучше использовать S3 или другое хранилище
                data['screenshotStored'] = True
            
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
                'githubIssue': data.get('githubIssue')
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
🚀 LMS Feedback Server (Railway Edition) Initialized!
====================================================
🔐 GitHub Token: {'✅ Configured' if CONFIG['github']['token'] else '❌ Not configured'}
📦 Repository: {CONFIG['github']['owner']}/{CONFIG['github']['repo']}

Note: Running with gunicorn in production mode
""") 