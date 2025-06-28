#!/usr/bin/env python3
"""
TestFlight Email Feedback Monitor
Мониторит email от Apple и создает GitHub issues со скриншотами
"""

import imaplib
import email
from email.header import decode_header
import os
import re
import time
from datetime import datetime
import requests
import base64
from pathlib import Path
import json

# Конфигурация
CONFIG = {
    # Email настройки (для Gmail нужен app-specific password)
    'IMAP_SERVER': 'imap.gmail.com',
    'IMAP_PORT': 993,
    'EMAIL': 'your-email@gmail.com',
    'PASSWORD': 'your-app-specific-password',  # https://support.google.com/accounts/answer/185833
    
    # GitHub настройки
    'GITHUB_TOKEN': os.getenv('GITHUB_TOKEN', ''),
    'GITHUB_REPO': 'your-org/your-repo',
    
    # Slack webhook (опционально)
    'SLACK_WEBHOOK': os.getenv('SLACK_WEBHOOK', ''),
    
    # Папка для сохранения
    'SAVE_DIR': 'testflight_feedback_emails'
}

class TestFlightEmailMonitor:
    def __init__(self):
        self.setup_folders()
        self.processed_emails = self.load_processed_emails()
        
    def setup_folders(self):
        """Создает необходимые папки"""
        Path(CONFIG['SAVE_DIR']).mkdir(exist_ok=True)
        Path(f"{CONFIG['SAVE_DIR']}/screenshots").mkdir(exist_ok=True)
        
    def load_processed_emails(self):
        """Загружает список обработанных email ID"""
        processed_file = f"{CONFIG['SAVE_DIR']}/processed.json"
        if os.path.exists(processed_file):
            with open(processed_file, 'r') as f:
                return set(json.load(f))
        return set()
        
    def save_processed_email(self, email_id):
        """Сохраняет ID обработанного email"""
        self.processed_emails.add(email_id)
        processed_file = f"{CONFIG['SAVE_DIR']}/processed.json"
        with open(processed_file, 'w') as f:
            json.dump(list(self.processed_emails), f)
    
    def connect_to_email(self):
        """Подключается к email серверу"""
        mail = imaplib.IMAP4_SSL(CONFIG['IMAP_SERVER'], CONFIG['IMAP_PORT'])
        mail.login(CONFIG['EMAIL'], CONFIG['PASSWORD'])
        mail.select('inbox')
        return mail
        
    def search_testflight_emails(self, mail):
        """Ищет email от TestFlight"""
        # Поиск писем от Apple с темой TestFlight
        search_criteria = '(FROM "noreply@email.apple.com" SUBJECT "TestFlight")'
        _, messages = mail.search(None, search_criteria)
        return messages[0].split()
        
    def parse_email(self, mail, email_id):
        """Парсит email и извлекает информацию"""
        _, msg_data = mail.fetch(email_id, '(RFC822)')
        msg = email.message_from_bytes(msg_data[0][1])
        
        # Декодируем заголовок
        subject = decode_header(msg['Subject'])[0][0]
        if isinstance(subject, bytes):
            subject = subject.decode()
            
        # Извлекаем тело письма
        body = ""
        attachments = []
        
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
            elif part.get_content_type() == "text/html":
                if not body:  # Используем HTML только если нет plain text
                    body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                    # Простое удаление HTML тегов
                    body = re.sub('<[^<]+?>', '', body)
            elif part.get_content_disposition() == 'attachment':
                # Сохраняем вложения (скриншоты)
                filename = part.get_filename()
                if filename:
                    filepath = f"{CONFIG['SAVE_DIR']}/screenshots/{email_id}_{filename}"
                    with open(filepath, 'wb') as f:
                        f.write(part.get_payload(decode=True))
                    attachments.append(filepath)
                    
        return {
            'id': email_id.decode() if isinstance(email_id, bytes) else email_id,
            'subject': subject,
            'body': body,
            'date': msg['Date'],
            'attachments': attachments
        }
        
    def extract_feedback_info(self, email_data):
        """Извлекает информацию о feedback из email"""
        body = email_data['body']
        
        # Попытка извлечь информацию с помощью regex
        info = {
            'tester_email': '',
            'app_version': '',
            'device': '',
            'os_version': '',
            'feedback_text': body,
            'has_screenshot': len(email_data['attachments']) > 0
        }
        
        # Паттерны для извлечения информации
        patterns = {
            'tester_email': r'From: ([^\n]+)',
            'app_version': r'App Version: ([^\n]+)',
            'device': r'Device: ([^\n]+)',
            'os_version': r'OS: ([^\n]+)'
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, body)
            if match:
                info[key] = match.group(1).strip()
                
        return info
        
    def upload_to_imgur(self, image_path):
        """Загружает изображение на Imgur для использования в GitHub"""
        # Для работы нужен Imgur Client ID
        # Получить на https://api.imgur.com/oauth2/addclient
        imgur_client_id = os.getenv('IMGUR_CLIENT_ID', '')
        
        if not imgur_client_id:
            print("⚠️  Imgur Client ID не настроен, скриншоты не будут загружены")
            return None
            
        headers = {'Authorization': f'Client-ID {imgur_client_id}'}
        
        with open(image_path, 'rb') as f:
            image_data = base64.b64encode(f.read())
            
        response = requests.post(
            'https://api.imgur.com/3/image',
            headers=headers,
            data={'image': image_data}
        )
        
        if response.status_code == 200:
            return response.json()['data']['link']
        return None
        
    def create_github_issue(self, feedback_data):
        """Создает GitHub issue из feedback"""
        if not CONFIG['GITHUB_TOKEN']:
            print("⚠️  GitHub token не настроен")
            return None
            
        headers = {
            'Authorization': f'token {CONFIG["GITHUB_TOKEN"]}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Формируем тело issue
        body = f"""## TestFlight Feedback
        
**Date**: {feedback_data['date']}
**Tester**: {feedback_data['info']['tester_email'] or 'Anonymous'}
**Device**: {feedback_data['info']['device']}
**OS**: {feedback_data['info']['os_version']}
**App Version**: {feedback_data['info']['app_version']}

### Feedback:
{feedback_data['info']['feedback_text']}

---
*This issue was automatically created from TestFlight feedback email*
"""
        
        # Добавляем скриншоты
        if feedback_data['attachments']:
            body += "\n\n### Screenshots:\n"
            for attachment in feedback_data['attachments']:
                # Загружаем на Imgur
                imgur_url = self.upload_to_imgur(attachment)
                if imgur_url:
                    body += f"\n![Screenshot]({imgur_url})\n"
                else:
                    body += f"\n*Screenshot saved locally: {attachment}*\n"
                    
        # Создаем issue
        issue_data = {
            'title': f"TestFlight: {feedback_data['subject']}",
            'body': body,
            'labels': ['testflight', 'feedback', 'bug']
        }
        
        response = requests.post(
            f"https://api.github.com/repos/{CONFIG['GITHUB_REPO']}/issues",
            headers=headers,
            json=issue_data
        )
        
        if response.status_code == 201:
            return response.json()['html_url']
        else:
            print(f"❌ Ошибка создания issue: {response.status_code}")
            print(response.text)
            return None
            
    def send_to_slack(self, feedback_data, github_url=None):
        """Отправляет уведомление в Slack"""
        if not CONFIG['SLACK_WEBHOOK']:
            return
            
        text = f"📱 Новый TestFlight feedback"
        if github_url:
            text += f"\n<{github_url}|Посмотреть в GitHub>"
            
        attachments = [{
            "color": "warning",
            "fields": [
                {"title": "Tester", "value": feedback_data['info']['tester_email'] or 'Anonymous', "short": True},
                {"title": "Device", "value": feedback_data['info']['device'], "short": True},
                {"title": "Has Screenshot", "value": "Yes" if feedback_data['info']['has_screenshot'] else "No", "short": True},
                {"title": "App Version", "value": feedback_data['info']['app_version'], "short": True}
            ],
            "footer": "TestFlight Monitor",
            "ts": int(time.time())
        }]
        
        requests.post(CONFIG['SLACK_WEBHOOK'], json={
            'text': text,
            'attachments': attachments
        })
        
    def process_emails(self):
        """Основной цикл обработки email"""
        print("🔍 Подключаемся к email...")
        mail = self.connect_to_email()
        
        print("📧 Ищем TestFlight emails...")
        email_ids = self.search_testflight_emails(mail)
        
        new_count = 0
        for email_id in email_ids:
            email_id_str = email_id.decode() if isinstance(email_id, bytes) else email_id
            
            # Пропускаем уже обработанные
            if email_id_str in self.processed_emails:
                continue
                
            print(f"\n📨 Обрабатываем email {email_id_str}...")
            
            try:
                # Парсим email
                email_data = self.parse_email(mail, email_id)
                
                # Извлекаем информацию
                email_data['info'] = self.extract_feedback_info(email_data)
                
                # Создаем GitHub issue
                github_url = self.create_github_issue(email_data)
                
                if github_url:
                    print(f"✅ Создан GitHub issue: {github_url}")
                    
                    # Отправляем в Slack
                    self.send_to_slack(email_data, github_url)
                    
                    # Помечаем как обработанный
                    self.save_processed_email(email_id_str)
                    new_count += 1
                    
            except Exception as e:
                print(f"❌ Ошибка обработки email: {e}")
                
        mail.logout()
        
        if new_count > 0:
            print(f"\n✅ Обработано новых feedback: {new_count}")
        else:
            print("\n📭 Новых feedback не найдено")
            
def main():
    """Запускает мониторинг"""
    monitor = TestFlightEmailMonitor()
    
    # Можно запустить один раз
    monitor.process_emails()
    
    # Или в цикле каждые 5 минут
    # while True:
    #     monitor.process_emails()
    #     time.sleep(300)  # 5 минут

if __name__ == "__main__":
    print("🚀 TestFlight Email Monitor")
    print("=" * 40)
    
    # Проверяем конфигурацию
    if not CONFIG['EMAIL'] or CONFIG['EMAIL'] == 'your-email@gmail.com':
        print("❌ Настройте email в CONFIG!")
        exit(1)
        
    if not CONFIG['GITHUB_TOKEN']:
        print("⚠️  GitHub token не настроен - issues не будут создаваться")
        print("   Установите: export GITHUB_TOKEN=your-token")
        
    main() 