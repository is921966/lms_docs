#!/usr/bin/env python3
"""
LMS Log Server - Веб-интерфейс для просмотра логов в реальном времени
"""

from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS
import json
import datetime
import os
from collections import deque
import threading
import time

app = Flask(__name__)
CORS(app)

# Хранилище логов в памяти (последние 10000 записей)
logs_storage = deque(maxlen=10000)
logs_lock = threading.Lock()

# HTML шаблон для веб-интерфейса
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>LMS Logs Viewer</title>
    <meta charset="utf-8">
    <style>
        body { 
            font-family: monospace; 
            margin: 0; 
            padding: 20px; 
            background: #1e1e1e; 
            color: #d4d4d4;
        }
        .controls {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: #2d2d2d;
            padding: 10px 20px;
            border-bottom: 1px solid #444;
            z-index: 1000;
        }
        .logs-container {
            margin-top: 120px;
            padding-bottom: 50px;
        }
        .log-entry {
            margin: 2px 0;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        .log-ui { background: #1e3a5f; }
        .log-navigation { background: #3f1e5f; }
        .log-network { background: #1e5f3a; }
        .log-data { background: #5f3a1e; }
        .log-error { background: #5f1e1e; color: #ff6b6b; }
        .log-auth { background: #5f5f1e; }
        .filter-btn {
            margin: 0 5px;
            padding: 5px 15px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            background: #444;
            color: #fff;
        }
        .filter-btn.active { background: #0084ff; }
        .search-box {
            padding: 5px 10px;
            border: 1px solid #444;
            background: #2d2d2d;
            color: #fff;
            border-radius: 3px;
            width: 300px;
        }
        .stats {
            position: fixed;
            top: 60px;
            right: 20px;
            background: #2d2d2d;
            padding: 10px;
            border-radius: 5px;
            font-size: 12px;
        }
        .timestamp { color: #858585; margin-right: 10px; }
        .category { font-weight: bold; margin-right: 10px; }
        .clear-btn {
            background: #d73a49;
            color: white;
            float: right;
        }
        #auto-refresh {
            margin-left: 20px;
        }
        .current-screen {
            background: #0366d6;
            color: white;
            padding: 5px 10px;
            border-radius: 3px;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="controls">
        <h2 style="margin: 0 0 10px 0;">🔍 LMS Logs Viewer</h2>
        <button class="filter-btn active" data-category="all">All</button>
        <button class="filter-btn" data-category="ui">UI</button>
        <button class="filter-btn" data-category="navigation">Navigation</button>
        <button class="filter-btn" data-category="network">Network</button>
        <button class="filter-btn" data-category="data">Data</button>
        <button class="filter-btn" data-category="error">Error</button>
        <button class="filter-btn" data-category="auth">Auth</button>
        <input type="text" class="search-box" placeholder="Search logs..." id="search">
        <label id="auto-refresh">
            <input type="checkbox" checked> Auto-refresh
        </label>
        <span class="current-screen" id="current-screen">Screen: Unknown</span>
        <button class="filter-btn clear-btn" onclick="clearLogs()">Clear</button>
    </div>
    
    <div class="stats">
        <div>Total logs: <span id="total-logs">0</span></div>
        <div>Filtered: <span id="filtered-logs">0</span></div>
        <div>Last update: <span id="last-update">-</span></div>
        <div>Current user: <span id="current-user">-</span></div>
    </div>
    
    <div class="logs-container" id="logs"></div>
    
    <script>
        let currentFilter = 'all';
        let searchQuery = '';
        let autoRefresh = true;
        let lastLogId = '';
        
        // Фильтрация по категории
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                if (btn.classList.contains('clear-btn')) return;
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                currentFilter = btn.dataset.category;
                fetchLogs();
            });
        });
        
        // Поиск
        document.getElementById('search').addEventListener('input', (e) => {
            searchQuery = e.target.value;
            fetchLogs();
        });
        
        // Auto-refresh
        document.querySelector('#auto-refresh input').addEventListener('change', (e) => {
            autoRefresh = e.target.checked;
        });
        
        // Очистка логов
        function clearLogs() {
            if (confirm('Clear all logs?')) {
                fetch('/api/logs/clear', { method: 'POST' })
                    .then(() => fetchLogs());
            }
        }
        
        // Форматирование лога
        function formatLog(log) {
            const time = new Date(log.timestamp).toLocaleTimeString();
            const details = log.details ? JSON.stringify(log.details, null, 2) : '';
            
            return `
                <div class="log-entry log-${log.category.toLowerCase()}">
                    <span class="timestamp">${time}</span>
                    <span class="category">[${log.category}]</span>
                    <strong>${log.event}</strong>
                    ${details ? '<br><small>' + details + '</small>' : ''}
                </div>
            `;
        }
        
        // Загрузка логов
        function fetchLogs() {
            const params = new URLSearchParams({
                category: currentFilter,
                search: searchQuery,
                after: lastLogId
            });
            
            fetch(`/api/logs?${params}`)
                .then(r => r.json())
                .then(data => {
                    const container = document.getElementById('logs');
                    
                    if (data.logs.length > 0) {
                        // Добавляем только новые логи
                        const newLogs = data.logs.map(formatLog).join('');
                        container.insertAdjacentHTML('afterbegin', newLogs);
                        
                        // Ограничиваем количество отображаемых логов
                        while (container.children.length > 1000) {
                            container.removeChild(container.lastChild);
                        }
                        
                        lastLogId = data.logs[0].id;
                    }
                    
                    // Обновляем статистику
                    document.getElementById('total-logs').textContent = data.total;
                    document.getElementById('filtered-logs').textContent = data.filtered;
                    document.getElementById('last-update').textContent = new Date().toLocaleTimeString();
                    
                    // Обновляем текущий экран
                    if (data.current_screen) {
                        document.getElementById('current-screen').textContent = `Screen: ${data.current_screen}`;
                    }
                    
                    // Обновляем текущего пользователя
                    if (data.current_user) {
                        document.getElementById('current-user').textContent = data.current_user;
                    }
                });
        }
        
        // Начальная загрузка и автообновление
        fetchLogs();
        setInterval(() => {
            if (autoRefresh) fetchLogs();
        }, 1000);
    </script>
</body>
</html>
"""

def get_current_screen():
    """Определяет текущий экран из последних логов навигации"""
    with logs_lock:
        # Ищем последний лог навигации
        for log in reversed(list(logs_storage)):
            if log.get('category') == 'Navigation':
                if 'Screen changed' in log.get('event', ''):
                    details = log.get('details', {})
                    return details.get('to', 'Unknown')
                elif 'Tab selected' in log.get('event', ''):
                    details = log.get('details', {})
                    return f"Tab: {details.get('tab', 'Unknown')}"
        
        # Если нет навигационных логов, ищем UI логи с trackScreen
        for log in reversed(list(logs_storage)):
            if log.get('category') == 'UI':
                event = log.get('event', '')
                if 'appeared' in event:
                    # Извлекаем имя view из события
                    if 'FeedView' in event:
                        return 'Classic Feed'
                    elif 'TelegramFeedView' in event:
                        return 'Telegram Feed'
                    elif 'LogTestView' in event:
                        return 'Log Test Screen'
                    elif 'SettingsView' in event:
                        return 'Settings'
        
        return 'Unknown'

def get_current_user():
    """Определяет текущего пользователя из логов"""
    with logs_lock:
        for log in reversed(list(logs_storage)):
            if log.get('category') == 'Auth':
                details = log.get('details', {})
                if 'user' in details:
                    return details['user']
        return 'Anonymous'

@app.route('/')
def index():
    """Главная страница с веб-интерфейсом"""
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/logs', methods=['GET'])
def get_logs():
    """API endpoint для получения логов с фильтрацией"""
    category = request.args.get('category', 'all')
    search = request.args.get('search', '').lower()
    after_id = request.args.get('after', '')
    
    with logs_lock:
        # Фильтруем логи
        filtered_logs = []
        found_after = not after_id
        
        for log in logs_storage:
            if not found_after:
                if log['id'] == after_id:
                    found_after = True
                continue
                
            # Фильтр по категории
            if category != 'all' and log['category'] != category:
                continue
            
            # Поиск по тексту
            if search and search not in json.dumps(log).lower():
                continue
                
            filtered_logs.append(log)
        
        # Возвращаем последние логи в обратном порядке
        result_logs = list(reversed(filtered_logs))[:100]
        
        return jsonify({
            'logs': result_logs,
            'total': len(logs_storage),
            'filtered': len(filtered_logs),
            'current_screen': get_current_screen(),
            'current_user': get_current_user(),
            'categories': {
                'UI': sum(1 for log in logs_storage if log['category'] == 'UI'),
                'Navigation': sum(1 for log in logs_storage if log['category'] == 'Navigation'),
                'Network': sum(1 for log in logs_storage if log['category'] == 'Network'),
                'Data': sum(1 for log in logs_storage if log['category'] == 'Data'),
                'Error': sum(1 for log in logs_storage if log['category'] == 'Error'),
                'Auth': sum(1 for log in logs_storage if log['category'] == 'Auth')
            }
        })

@app.route('/api/logs', methods=['POST'])
def receive_logs():
    """API endpoint для приема логов от iOS приложения"""
    try:
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Обрабатываем batch upload
        logs = data.get('logs', [])
        
        with logs_lock:
            for log in logs:
                # Добавляем метаданные
                log['received_at'] = datetime.datetime.now().isoformat()
                log['device_id'] = data.get('deviceId', 'unknown')
                log['session_id'] = data.get('sessionId', 'unknown')
                log['user_id'] = data.get('userId', 'anonymous')
                
                logs_storage.append(log)
        
        print(f"📥 Received {len(logs)} logs from device {data.get('deviceId', 'unknown')}")
        
        return jsonify({
            'success': True,
            'received': len(logs),
            'total': len(logs_storage)
        })
        
    except Exception as e:
        print(f"❌ Error receiving logs: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/logs/clear', methods=['POST'])
def clear_logs():
    """Очистка всех логов"""
    with logs_lock:
        logs_storage.clear()
    return jsonify({'success': True})

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'logs_count': len(logs_storage),
        'timestamp': datetime.datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🚀 Starting LMS Log Server on http://localhost:5002")
    print("📊 Open http://localhost:5002 in your browser to view logs")
    print("📱 Configure iOS app to send logs to http://YOUR_IP:5002/api/logs")
    app.run(host='0.0.0.0', port=5002, debug=True) 