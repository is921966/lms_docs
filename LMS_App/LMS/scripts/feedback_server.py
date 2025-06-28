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

app = Flask(__name__)
CORS(app)  # Разрешаем CORS для тестирования

# Конфигурация
FEEDBACK_DIR = Path("feedback_data")
SCREENSHOTS_DIR = FEEDBACK_DIR / "screenshots"
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", "")
GITHUB_REPO = os.getenv("GITHUB_REPO", "your-org/your-repo")

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
        
        # Создаем GitHub issue если критично
        if data.get('type') == 'bug' or 'crash' in data.get('text', '').lower():
            create_github_issue(feedback, screenshot_path)
        
        # Отправляем в Slack/Discord если настроено
        send_notification(feedback)
        
        print(f"✅ Received feedback: {feedback_id}")
        
        return jsonify({
            'status': 'success',
            'id': feedback_id,
            'message': 'Feedback received successfully'
        }), 201
        
    except Exception as e:
        print(f"❌ Error processing feedback: {e}")
        return jsonify({'error': str(e)}), 500

def save_screenshot(base64_data, feedback_id):
    """Сохраняет скриншот из base64"""
    try:
        # Декодируем base64
        image_data = base64.b64decode(base64_data)
        
        # Сохраняем файл
        screenshot_path = SCREENSHOTS_DIR / f"{feedback_id}.png"
        with open(screenshot_path, 'wb') as f:
            f.write(image_data)
        
        return screenshot_path
    except Exception as e:
        print(f"Error saving screenshot: {e}")
        return None

def create_github_issue(feedback, screenshot_path):
    """Создает GitHub issue для критичных отзывов"""
    if not GITHUB_TOKEN:
        print("GitHub token not configured")
        return
    
    import requests
    
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Формируем тело issue
    device_info = feedback.get('deviceInfo', {})
    body = f"""## Feedback Report

**Type**: {feedback.get('type', 'unknown')}
**Date**: {feedback.get('timestamp', 'unknown')}
**Device**: {device_info.get('model', 'unknown')} (iOS {device_info.get('osVersion', 'unknown')})
**App Version**: {device_info.get('appVersion', 'unknown')} (Build {device_info.get('buildNumber', 'unknown')})

### Description:
{feedback.get('text', 'No description provided')}

### Device Details:
- Screen Size: {device_info.get('screenSize', 'unknown')}
- Locale: {device_info.get('locale', 'unknown')}

---
*This issue was automatically created from in-app feedback*
"""
    
    # Добавляем ссылку на скриншот если есть
    if screenshot_path:
        body += f"\n\n📸 Screenshot saved: `{screenshot_path.name}`"
    
    issue_data = {
        'title': f"[Feedback] {feedback.get('type', 'Bug')}: {feedback.get('text', '')[:50]}...",
        'body': body,
        'labels': ['feedback', feedback.get('type', 'bug'), 'ios']
    }
    
    try:
        response = requests.post(
            f"https://api.github.com/repos/{GITHUB_REPO}/issues",
            headers=headers,
            json=issue_data
        )
        
        if response.status_code == 201:
            issue_url = response.json()['html_url']
            print(f"✅ Created GitHub issue: {issue_url}")
        else:
            print(f"❌ Failed to create GitHub issue: {response.status_code}")
    except Exception as e:
        print(f"❌ Error creating GitHub issue: {e}")

def send_notification(feedback):
    """Отправляет уведомление в Slack/Discord"""
    # Можно добавить интеграцию с вашим каналом уведомлений
    pass

@app.route('/api/v1/feedback/list', methods=['GET'])
def list_feedback():
    """Возвращает список всех feedback"""
    try:
        feedbacks = []
        
        for file_path in FEEDBACK_DIR.glob("*.json"):
            with open(file_path, 'r') as f:
                feedback = json.load(f)
                # Убираем полный путь к скриншоту
                if 'screenshot_path' in feedback:
                    feedback['screenshot_url'] = f"/screenshots/{Path(feedback['screenshot_path']).name}"
                feedbacks.append(feedback)
        
        # Сортируем по дате
        feedbacks.sort(key=lambda x: x.get('received_at', ''), reverse=True)
        
        return jsonify({
            'status': 'success',
            'count': len(feedbacks),
            'feedbacks': feedbacks
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/screenshots/<filename>')
def serve_screenshot(filename):
    """Отдает скриншоты"""
    from flask import send_from_directory
    return send_from_directory(SCREENSHOTS_DIR, filename)

@app.route('/')
def index():
    """Простая страница для просмотра feedback"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Feedback Viewer</title>
        <style>
            body { font-family: -apple-system, Arial; margin: 20px; }
            .feedback { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 8px; }
            .bug { border-left: 4px solid #ff4444; }
            .feature { border-left: 4px solid #4444ff; }
            .improvement { border-left: 4px solid #ff8844; }
            .screenshot { max-width: 300px; margin: 10px 0; }
            .metadata { color: #666; font-size: 0.9em; }
        </style>
    </head>
    <body>
        <h1>📱 iOS App Feedback</h1>
        <div id="feedbacks">Loading...</div>
        
        <script>
            fetch('/api/v1/feedback/list')
                .then(r => r.json())
                .then(data => {
                    const container = document.getElementById('feedbacks');
                    container.innerHTML = `<p>Total: ${data.count} feedback items</p>`;
                    
                    data.feedbacks.forEach(fb => {
                        const div = document.createElement('div');
                        div.className = `feedback ${fb.type || 'bug'}`;
                        
                        const screenshot = fb.screenshot_url ? 
                            `<img src="${fb.screenshot_url}" class="screenshot">` : '';
                        
                        div.innerHTML = `
                            <h3>${fb.type || 'Feedback'} - ${new Date(fb.timestamp).toLocaleString()}</h3>
                            <p>${fb.text}</p>
                            ${screenshot}
                            <div class="metadata">
                                Device: ${fb.deviceInfo?.model} (iOS ${fb.deviceInfo?.osVersion})<br>
                                App: v${fb.deviceInfo?.appVersion} (${fb.deviceInfo?.buildNumber})<br>
                                ID: ${fb.id}
                            </div>
                        `;
                        container.appendChild(div);
                    });
                })
                .catch(err => {
                    document.getElementById('feedbacks').innerHTML = 'Error: ' + err;
                });
        </script>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    print("🚀 Feedback Server")
    print("=" * 40)
    print(f"📁 Feedback directory: {FEEDBACK_DIR.absolute()}")
    print(f"🖼  Screenshots directory: {SCREENSHOTS_DIR.absolute()}")
    print("")
    print("Endpoints:")
    print("  POST   /api/v1/feedback     - Receive feedback")
    print("  GET    /api/v1/feedback/list - List all feedback")
    print("  GET    /                     - Web viewer")
    print("")
    
    # Запускаем сервер
    app.run(host='0.0.0.0', port=5000, debug=True) 