#!/usr/bin/env python3
"""
Cloud-ready Log Server для приема логов из iOS приложения
"""

from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from datetime import datetime
import json
import os
import uuid
from collections import deque
import threading

app = Flask(__name__)
CORS(app)  # Разрешаем CORS для всех источников

# Конфигурация из переменных окружения
CONFIG = {
    'server': {
        'port': int(os.getenv('PORT', 5002)),
        'host': '0.0.0.0',
        'max_logs': int(os.getenv('MAX_LOGS', 10000))
    }
}

# Thread-safe in-memory storage с ограничением размера
LOGS_STORAGE = deque(maxlen=CONFIG['server']['max_logs'])
LOGS_LOCK = threading.Lock()

# HTML template для веб-интерфейса
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>LMS Log Server</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        :root {
            --bg-primary: #1a1a1a;
            --bg-secondary: #2a2a2a;
            --text-primary: #e0e0e0;
            --text-secondary: #a0a0a0;
            --accent: #4a9eff;
            --error: #ff4444;
            --warning: #ffaa44;
            --success: #44ff44;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #333;
        }
        
        h1 {
            font-size: 28px;
            color: var(--accent);
        }
        
        .stats {
            display: flex;
            gap: 30px;
            margin-bottom: 20px;
        }
        
        .stat {
            background: var(--bg-secondary);
            padding: 15px 25px;
            border-radius: 8px;
        }
        
        .stat-label {
            font-size: 12px;
            color: var(--text-secondary);
            text-transform: uppercase;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: var(--accent);
        }
        
        .filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        label {
            font-size: 12px;
            color: var(--text-secondary);
            text-transform: uppercase;
        }
        
        input, select {
            background: var(--bg-secondary);
            border: 1px solid #444;
            color: var(--text-primary);
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .logs-container {
            background: var(--bg-secondary);
            border-radius: 8px;
            overflow: hidden;
        }
        
        .log-entry {
            padding: 12px 20px;
            border-bottom: 1px solid #333;
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
            font-size: 13px;
            transition: background 0.2s;
        }
        
        .log-entry:hover {
            background: #333;
        }
        
        .log-time {
            color: var(--text-secondary);
            margin-right: 15px;
        }
        
        .log-level {
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: bold;
            margin-right: 10px;
        }
        
        .level-error { background: var(--error); color: white; }
        .level-warning { background: var(--warning); color: black; }
        .level-info { background: var(--accent); color: white; }
        .level-debug { background: #666; color: white; }
        
        .log-category {
            color: #888;
            margin-right: 10px;
        }
        
        .log-message {
            color: var(--text-primary);
        }
        
        .clear-button {
            background: var(--error);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .clear-button:hover {
            opacity: 0.8;
        }
        
        .auto-refresh {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px;
            color: var(--text-secondary);
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 20px;
            }
            
            .stats {
                flex-direction: column;
                gap: 10px;
            }
            
            .filters {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 LMS Log Server</h1>
            <div class="auto-refresh">
                <label>
                    <input type="checkbox" id="autoRefresh" checked> Auto-refresh
                </label>
                <button class="clear-button" onclick="clearLogs()">Clear All</button>
            </div>
        </div>
        
        <div class="stats">
            <div class="stat">
                <div class="stat-label">Total Logs</div>
                <div class="stat-value" id="totalLogs">0</div>
            </div>
            <div class="stat">
                <div class="stat-label">Error Count</div>
                <div class="stat-value" id="errorCount">0</div>
            </div>
            <div class="stat">
                <div class="stat-label">Last Update</div>
                <div class="stat-value" id="lastUpdate">Never</div>
            </div>
        </div>
        
        <div class="filters">
            <div class="filter-group">
                <label>Search</label>
                <input type="text" id="searchInput" placeholder="Search logs..." style="width: 300px">
            </div>
            <div class="filter-group">
                <label>Category</label>
                <select id="categoryFilter">
                    <option value="">All Categories</option>
                    <option value="ui">UI</option>
                    <option value="network">Network</option>
                    <option value="data">Data</option>
                    <option value="navigation">Navigation</option>
                    <option value="error">Error</option>
                    <option value="auth">Auth</option>
                    <option value="system">System</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Level</label>
                <select id="levelFilter">
                    <option value="">All Levels</option>
                    <option value="error">Error</option>
                    <option value="warning">Warning</option>
                    <option value="info">Info</option>
                    <option value="debug">Debug</option>
                </select>
            </div>
        </div>
        
        <div class="logs-container" id="logsContainer">
            <div class="empty-state">No logs yet. Waiting for iOS app to send logs...</div>
        </div>
    </div>
    
    <script>
        let lastLogId = null;
        let autoRefreshInterval = null;
        
        function formatTime(timestamp) {
            const date = new Date(timestamp);
            return date.toLocaleTimeString();
        }
        
        function renderLog(log) {
            const levelClass = 'level-' + log.level.toLowerCase();
            return `
                <div class="log-entry">
                    <span class="log-time">${formatTime(log.timestamp)}</span>
                    <span class="log-level ${levelClass}">${log.level.toUpperCase()}</span>
                    <span class="log-category">[${log.category}]</span>
                    <span class="log-message">${log.event}${log.details ? ' - ' + JSON.stringify(log.details) : ''}</span>
                </div>
            `;
        }
        
        async function fetchLogs() {
            try {
                const params = new URLSearchParams({
                    category: document.getElementById('categoryFilter').value,
                    level: document.getElementById('levelFilter').value,
                    search: document.getElementById('searchInput').value
                });
                
                if (lastLogId) {
                    params.append('after', lastLogId);
                }
                
                const response = await fetch(`/api/logs?${params}`);
                const data = await response.json();
                
                if (data.logs && data.logs.length > 0) {
                    const container = document.getElementById('logsContainer');
                    
                    if (!lastLogId) {
                        container.innerHTML = '';
                    }
                    
                    // Since logs come newest first, we need to process them in reverse
                    // to maintain chronological order when inserting at the beginning
                    const logsToInsert = lastLogId ? data.logs.reverse() : data.logs;
                    
                    logsToInsert.forEach(log => {
                        container.insertAdjacentHTML('afterbegin', renderLog(log));
                    });
                    
                    // Update lastLogId to the newest log ID (last in the original array)
                    if (data.logs.length > 0) {
                        lastLogId = data.logs[0].id; // First element is the newest
                    }
                    
                    // Update stats
                    document.getElementById('totalLogs').textContent = data.total || container.children.length;
                    document.getElementById('errorCount').textContent = data.error_count || 0;
                    document.getElementById('lastUpdate').textContent = formatTime(new Date());
                    
                    // Limit displayed logs
                    while (container.children.length > 1000) {
                        container.removeChild(container.lastChild);
                    }
                }
            } catch (error) {
                console.error('Failed to fetch logs:', error);
            }
        }
        
        async function clearLogs() {
            if (confirm('Clear all logs?')) {
                try {
                    await fetch('/api/logs/clear', { method: 'POST' });
                    document.getElementById('logsContainer').innerHTML = '<div class="empty-state">Logs cleared</div>';
                    lastLogId = null;
                    document.getElementById('totalLogs').textContent = '0';
                    document.getElementById('errorCount').textContent = '0';
                } catch (error) {
                    console.error('Failed to clear logs:', error);
                }
            }
        }
        
        function toggleAutoRefresh() {
            if (document.getElementById('autoRefresh').checked) {
                autoRefreshInterval = setInterval(fetchLogs, 1000);
            } else {
                clearInterval(autoRefreshInterval);
            }
        }
        
        // Event listeners
        document.getElementById('autoRefresh').addEventListener('change', toggleAutoRefresh);
        document.getElementById('searchInput').addEventListener('input', () => {
            lastLogId = null;
            fetchLogs();
        });
        document.getElementById('categoryFilter').addEventListener('change', () => {
            lastLogId = null;
            fetchLogs();
        });
        document.getElementById('levelFilter').addEventListener('change', () => {
            lastLogId = null;
            fetchLogs();
        });
        
        // Initial load
        fetchLogs();
        toggleAutoRefresh();
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    """Web interface for viewing logs"""
    return render_template_string(HTML_TEMPLATE)

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'logs_count': len(LOGS_STORAGE)
    })

@app.route('/api/logs', methods=['POST'])
def receive_logs():
    """Receive logs from iOS app"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        device_id = data.get('deviceId', 'unknown')
        logs = data.get('logs', [])
        
        if not logs:
            return jsonify({'error': 'No logs provided'}), 400
        
        # Process and store logs
        with LOGS_LOCK:
            for log in logs:
                log_entry = {
                    'id': log.get('id', str(uuid.uuid4())),
                    'deviceId': device_id,
                    'timestamp': log.get('timestamp', datetime.utcnow().isoformat()),
                    'category': log.get('category', 'unknown'),
                    'level': log.get('level', 'info'),
                    'event': log.get('event', ''),
                    'details': log.get('details', {})
                }
                LOGS_STORAGE.append(log_entry)
        
        print(f"📥 Received {len(logs)} logs from device {device_id}")
        
        return jsonify({
            'status': 'success',
            'received': len(logs),
            'total': len(LOGS_STORAGE)
        }), 200
        
    except Exception as e:
        print(f"❌ Error receiving logs: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/logs', methods=['GET'])
def get_logs():
    """Get logs with filtering"""
    try:
        # Get filter parameters
        category = request.args.get('category', '')
        level = request.args.get('level', '')
        search = request.args.get('search', '')
        after_id = request.args.get('after', '')
        limit = min(int(request.args.get('limit', 100)), 1000)
        
        with LOGS_LOCK:
            logs = list(LOGS_STORAGE)
        
        # Apply filters
        filtered_logs = []
        
        # If after_id is specified, we need to return only newer logs
        if after_id:
            # Find the position of after_id
            after_index = -1
            for i, log in enumerate(logs):
                if log['id'] == after_id:
                    after_index = i
                    break
            
            # Get only logs after this position (newer logs)
            if after_index >= 0:
                logs_to_process = logs[after_index + 1:]
            else:
                # If after_id not found, return all logs
                logs_to_process = logs
        else:
            logs_to_process = logs
        
        # Process logs in reverse order (newest first)
        for log in reversed(logs_to_process):
            # Apply category filter
            if category and log['category'] != category:
                continue
            
            # Apply level filter
            if level and log['level'] != level:
                continue
            
            # Apply search filter
            if search:
                search_lower = search.lower()
                if not any(search_lower in str(v).lower() for v in [
                    log['event'], 
                    log['category'],
                    json.dumps(log.get('details', {}))
                ]):
                    continue
            
            filtered_logs.append(log)
            
            if len(filtered_logs) >= limit:
                break
        
        # Count errors
        error_count = sum(1 for log in logs if log['level'] == 'error')
        
        return jsonify({
            'logs': filtered_logs,
            'total': len(logs),
            'error_count': error_count,
            'has_more': len(filtered_logs) == limit
        })
        
    except Exception as e:
        print(f"❌ Error getting logs: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/logs/clear', methods=['POST'])
def clear_logs():
    """Clear all logs"""
    try:
        with LOGS_LOCK:
            LOGS_STORAGE.clear()
        
        print("🗑️ All logs cleared")
        return jsonify({'status': 'success'}), 200
        
    except Exception as e:
        print(f"❌ Error clearing logs: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print(f"🚀 Starting LMS Log Server on port {CONFIG['server']['port']}")
    print(f"📊 Open http://localhost:{CONFIG['server']['port']} in your browser to view logs")
    print(f"📱 Configure iOS app to send logs to http://YOUR_IP:{CONFIG['server']['port']}/api/logs")
    
    app.run(
        host=CONFIG['server']['host'],
        port=CONFIG['server']['port'],
        debug=os.getenv('FLASK_ENV') == 'development'
    ) 