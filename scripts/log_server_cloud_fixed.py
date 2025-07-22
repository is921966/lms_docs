#!/usr/bin/env python3
"""
LMS Log Server - Cloud Version (Fixed)
Receives and displays logs from iOS app with proper incremental updates
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import json
import os
import uuid
from collections import deque
import threading
import time

app = Flask(__name__)
CORS(app)

# Thread-safe storage with max 10000 logs
logs_storage = deque(maxlen=10000)
logs_lock = threading.Lock()

# Simple in-memory ID counter
log_id_counter = 0
log_id_lock = threading.Lock()

def get_next_id():
    global log_id_counter
    with log_id_lock:
        log_id_counter += 1
        return log_id_counter

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'logs_count': len(logs_storage)})

@app.route('/api/logs', methods=['POST'])
def receive_log():
    try:
        log_data = request.json
        
        # Add server timestamp and ID
        log_entry = {
            'id': get_next_id(),
            'timestamp': log_data.get('timestamp', datetime.now().isoformat()),
            'category': log_data.get('category', 'unknown'),
            'level': log_data.get('level', 'info'),
            'event': log_data.get('event', ''),
            'details': log_data.get('details', {}),
            'deviceId': log_data.get('deviceId', 'unknown'),
            'received_at': datetime.now().isoformat()
        }
        
        with logs_lock:
            logs_storage.append(log_entry)
        
        print(f"📝 Log received: [{log_entry['category']}] {log_entry['event']}")
        
        return jsonify({'success': True, 'id': log_entry['id']}), 200
        
    except Exception as e:
        print(f"❌ Error receiving log: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/logs', methods=['GET'])
def get_logs():
    try:
        # Get filter parameters
        category = request.args.get('category', '')
        level = request.args.get('level', '')
        search = request.args.get('search', '')
        after_id = request.args.get('after', type=int)
        
        with logs_lock:
            logs = list(logs_storage)
        
        # Apply filters
        filtered_logs = []
        for log in logs:
            if category and log['category'] != category:
                continue
            if level and log['level'] != level:
                continue
            if search and search.lower() not in json.dumps(log).lower():
                continue
            filtered_logs.append(log)
        
        # Sort by ID (newest first)
        filtered_logs.sort(key=lambda x: x['id'], reverse=True)
        
        # If after_id is provided, only return newer logs
        if after_id:
            filtered_logs = [log for log in filtered_logs if log['id'] > after_id]
        
        # Count errors
        error_count = sum(1 for log in logs if log['level'] == 'error')
        
        return jsonify({
            'logs': filtered_logs[:500],  # Limit to 500 logs per request
            'total': len(logs),
            'filtered': len(filtered_logs),
            'error_count': error_count
        })
        
    except Exception as e:
        print(f"❌ Error getting logs: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/')
def dashboard():
    """Serve the log dashboard"""
    return '''<!DOCTYPE html>
<html>
<head>
    <title>LMS Log Dashboard</title>
    <meta charset="utf-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: #1e1e1e;
            color: #d4d4d4;
        }
        .header {
            background: #2d2d30;
            padding: 20px;
            border-bottom: 1px solid #3e3e42;
        }
        .header h1 {
            margin: 0 0 10px 0;
            font-size: 24px;
        }
        .controls {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }
        .controls select, .controls input {
            background: #3c3c3c;
            color: #cccccc;
            border: 1px solid #3e3e42;
            padding: 5px 10px;
            border-radius: 3px;
        }
        .controls button {
            background: #0e639c;
            color: white;
            border: none;
            padding: 5px 15px;
            border-radius: 3px;
            cursor: pointer;
        }
        .controls button:hover {
            background: #1177bb;
        }
        .stats {
            display: flex;
            gap: 20px;
            font-size: 14px;
            color: #cccccc;
        }
        .stat {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .stat-value {
            font-weight: bold;
            color: #4ec9b0;
        }
        .logs-container {
            padding: 20px;
            max-height: calc(100vh - 200px);
            overflow-y: auto;
        }
        .log-entry {
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            font-size: 13px;
            line-height: 20px;
            padding: 2px 0;
            border-bottom: 1px solid #2d2d30;
        }
        .log-time {
            color: #858585;
            margin-right: 10px;
        }
        .log-level {
            font-weight: bold;
            margin-right: 10px;
            padding: 2px 6px;
            border-radius: 3px;
            text-transform: uppercase;
            font-size: 11px;
        }
        .level-debug { color: #858585; }
        .level-info { color: #4ec9b0; }
        .level-warning { 
            color: #ce9178; 
            background: rgba(206, 145, 120, 0.2);
        }
        .level-error { 
            color: #f48771; 
            background: rgba(244, 135, 113, 0.2);
        }
        .log-category {
            color: #9cdcfe;
            margin-right: 10px;
        }
        .log-message {
            color: #d4d4d4;
        }
        ::-webkit-scrollbar {
            width: 10px;
        }
        ::-webkit-scrollbar-track {
            background: #1e1e1e;
        }
        ::-webkit-scrollbar-thumb {
            background: #424242;
            border-radius: 5px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #4e4e4e;
        }
        .connection-status {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .connected {
            background: #4ec9b0;
            box-shadow: 0 0 4px #4ec9b0;
        }
        .disconnected {
            background: #f48771;
            box-shadow: 0 0 4px #f48771;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 LMS Log Dashboard</h1>
        <div class="controls">
            <select id="categoryFilter">
                <option value="">All Categories</option>
                <option value="ui">UI</option>
                <option value="network">Network</option>
                <option value="data">Data</option>
                <option value="navigation">Navigation</option>
                <option value="auth">Auth</option>
                <option value="error">Error</option>
                <option value="performance">Performance</option>
            </select>
            <select id="levelFilter">
                <option value="">All Levels</option>
                <option value="debug">Debug</option>
                <option value="info">Info</option>
                <option value="warning">Warning</option>
                <option value="error">Error</option>
            </select>
            <input type="text" id="searchInput" placeholder="Search logs...">
            <button onclick="clearLogs()">Clear</button>
            <button onclick="toggleAutoScroll()">Auto-scroll: <span id="autoScrollStatus">ON</span></button>
        </div>
        <div class="stats">
            <div class="stat">
                <span class="connection-status" id="connectionStatus"></span>
                <span>Status: <span id="connectionText">Connecting...</span></span>
            </div>
            <div class="stat">
                Total logs: <span class="stat-value" id="totalLogs">0</span>
            </div>
            <div class="stat">
                Errors: <span class="stat-value" id="errorCount" style="color: #f48771;">0</span>
            </div>
            <div class="stat">
                Last update: <span class="stat-value" id="lastUpdate">-</span>
            </div>
        </div>
    </div>
    
    <div class="logs-container" id="logsContainer"></div>
    
    <script>
        let lastLogId = null;
        let autoScroll = true;
        let refreshInterval = null;
        
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
                    
                    // Clear container on first load
                    if (!lastLogId) {
                        container.innerHTML = '';
                    }
                    
                    // Process logs from oldest to newest for correct order
                    const newLogs = data.logs.filter(log => !lastLogId || log.id > lastLogId);
                    
                    // Sort by ID ascending (oldest first)
                    newLogs.sort((a, b) => a.id - b.id);
                    
                    // Add each new log to the top
                    newLogs.forEach(log => {
                        container.insertAdjacentHTML('afterbegin', renderLog(log));
                    });
                    
                    // Update lastLogId to the highest ID we've seen
                    if (newLogs.length > 0) {
                        const maxId = Math.max(...newLogs.map(log => log.id));
                        if (!lastLogId || maxId > lastLogId) {
                            lastLogId = maxId;
                        }
                    }
                    
                    // Update stats
                    document.getElementById('totalLogs').textContent = data.total || container.children.length;
                    document.getElementById('errorCount').textContent = data.error_count || 0;
                    document.getElementById('lastUpdate').textContent = formatTime(new Date());
                    
                    // Limit displayed logs
                    while (container.children.length > 1000) {
                        container.removeChild(container.lastChild);
                    }
                    
                    // Auto scroll
                    if (autoScroll && newLogs.length > 0) {
                        container.scrollTop = 0;
                    }
                    
                    // Update connection status
                    setConnectionStatus(true);
                }
            } catch (error) {
                console.error('Error fetching logs:', error);
                setConnectionStatus(false);
            }
        }
        
        function setConnectionStatus(connected) {
            const statusEl = document.getElementById('connectionStatus');
            const textEl = document.getElementById('connectionText');
            
            if (connected) {
                statusEl.className = 'connection-status connected';
                textEl.textContent = 'Connected';
            } else {
                statusEl.className = 'connection-status disconnected';
                textEl.textContent = 'Disconnected';
            }
        }
        
        function clearLogs() {
            document.getElementById('logsContainer').innerHTML = '';
            lastLogId = null;
            fetchLogs();
        }
        
        function toggleAutoScroll() {
            autoScroll = !autoScroll;
            document.getElementById('autoScrollStatus').textContent = autoScroll ? 'ON' : 'OFF';
        }
        
        // Event listeners
        document.getElementById('categoryFilter').addEventListener('change', () => {
            lastLogId = null;
            fetchLogs();
        });
        
        document.getElementById('levelFilter').addEventListener('change', () => {
            lastLogId = null;
            fetchLogs();
        });
        
        let searchTimeout;
        document.getElementById('searchInput').addEventListener('input', (e) => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                lastLogId = null;
                fetchLogs();
            }, 300);
        });
        
        // Start fetching logs
        fetchLogs();
        refreshInterval = setInterval(fetchLogs, 1000);
        
        // Clean up on page unload
        window.addEventListener('beforeunload', () => {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        });
    </script>
</body>
</html>'''

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print(f"🚀 Starting LMS Log Server on port {port}")
    print(f"📊 Open http://localhost:{port} in your browser to view logs")
    print(f"📱 Configure iOS app to send logs to http://YOUR_IP:{port}/api/logs")
    app.run(host='0.0.0.0', port=port, debug=False) 