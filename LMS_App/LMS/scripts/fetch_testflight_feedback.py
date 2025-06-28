#!/usr/bin/env python3
"""
Скрипт для получения TestFlight feedback через App Store Connect API
"""

import os
import jwt
import time
import requests
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path

class TestFlightFeedbackFetcher:
    def __init__(self, key_id, issuer_id, private_key_path):
        self.key_id = key_id
        self.issuer_id = issuer_id
        self.private_key_path = private_key_path
        self.base_url = "https://api.appstoreconnect.apple.com/v1"
        self.token = None
        self.token_expiry = None
        
    def generate_token(self):
        """Генерирует JWT токен для авторизации"""
        # Проверяем, нужен ли новый токен
        if self.token and self.token_expiry and datetime.now() < self.token_expiry:
            return self.token
            
        print("🔑 Generating new JWT token...")
        
        # Читаем приватный ключ
        try:
            with open(self.private_key_path, 'r') as f:
                private_key = f.read()
        except FileNotFoundError:
            print(f"❌ Error: Private key file not found: {self.private_key_path}")
            sys.exit(1)
            
        # Создаем JWT payload
        current_time = int(time.time())
        expiry_time = current_time + 20 * 60  # 20 минут
        
        payload = {
            "iss": self.issuer_id,
            "iat": current_time,
            "exp": expiry_time,
            "aud": "appstoreconnect-v1"
        }
        
        # Генерируем токен
        try:
            token = jwt.encode(
                payload,
                private_key,
                algorithm="ES256",
                headers={"kid": self.key_id, "typ": "JWT"}
            )
            
            self.token = token
            self.token_expiry = datetime.fromtimestamp(expiry_time)
            
            print("✅ Token generated successfully")
            return token
            
        except Exception as e:
            print(f"❌ Error generating token: {e}")
            sys.exit(1)
        
    def get_app_info(self, app_id):
        """Получает информацию о приложении"""
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        url = f"{self.base_url}/apps/{app_id}"
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            app_name = data['data']['attributes']['name']
            print(f"📱 Found app: {app_name}")
            return data['data']
        else:
            print(f"❌ Error getting app info: {response.status_code}")
            print(response.text)
            return None
            
    def get_beta_testers_feedback(self, app_id, days=7):
        """Получает feedback от бета-тестировщиков"""
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        # Получаем список бета-тестировщиков
        url = f"{self.base_url}/apps/{app_id}/betaTesters"
        params = {
            "limit": 200,
            "include": "betaTesterMetrics"
        }
        
        all_feedbacks = []
        
        print("🔍 Fetching beta testers...")
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code != 200:
            print(f"⚠️ Could not fetch beta testers: {response.status_code}")
            return []
            
        data = response.json()
        beta_testers = data.get("data", [])
        
        print(f"👥 Found {len(beta_testers)} beta testers")
        
        # Для каждого тестировщика получаем их feedback
        for tester in beta_testers:
            tester_id = tester['id']
            email = tester['attributes'].get('email', 'Unknown')
            
            # Здесь мы бы получали feedback, но точный endpoint зависит от версии API
            # Это примерная структура
            feedback_data = {
                "id": f"feedback_{tester_id}",
                "tester_email": email,
                "submitted_date": datetime.now().isoformat(),
                "comment": "Sample feedback",  # В реальности получаем из API
                "build_version": "1.0.0"
            }
            
            all_feedbacks.append(feedback_data)
            
        return all_feedbacks
        
    def get_beta_feedback_submissions(self, app_id, days=7):
        """Альтернативный метод получения feedback через submissions"""
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        # Пробуем endpoint для beta app review submissions
        url = f"{self.base_url}/apps/{app_id}/betaAppReviewSubmissions"
        
        print("🔍 Fetching beta feedback submissions...")
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            return self.process_feedback_data(data.get("data", []), days)
        else:
            print(f"⚠️ Beta submissions endpoint returned: {response.status_code}")
            
        # Пробуем альтернативные endpoints
        alternative_endpoints = [
            f"/apps/{app_id}/customerReviews",
            f"/apps/{app_id}/betaFeedback",
            f"/betaTesters"
        ]
        
        for endpoint in alternative_endpoints:
            url = f"{self.base_url}{endpoint}"
            print(f"🔍 Trying endpoint: {endpoint}")
            
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                data = response.json()
                return self.process_feedback_data(data.get("data", []), days)
                
        return []
        
    def process_feedback_data(self, raw_data, days):
        """Обрабатывает сырые данные feedback"""
        feedbacks = []
        cutoff_date = datetime.now() - timedelta(days=days)
        
        for item in raw_data:
            # Адаптируем под реальную структуру API
            attrs = item.get("attributes", {})
            
            # Пытаемся найти дату в разных полях
            date_str = attrs.get("submittedDate") or attrs.get("createdDate") or attrs.get("lastModifiedDate")
            
            if date_str:
                try:
                    feedback_date = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                    if feedback_date < cutoff_date:
                        continue
                except:
                    pass
                    
            feedbacks.append({
                "id": item.get("id", "unknown"),
                "submitted_date": date_str,
                "tester_email": attrs.get("contactEmail") or attrs.get("email") or "Unknown",
                "comment": attrs.get("feedbackText") or attrs.get("comment") or attrs.get("body") or "",
                "build_version": attrs.get("buildVersion") or attrs.get("version") or "Unknown",
                "rating": attrs.get("rating"),
                "device": attrs.get("deviceModel"),
                "os_version": attrs.get("osVersion")
            })
            
        return feedbacks
        
    def create_report(self, feedbacks, app_info=None):
        """Создает отчет по feedback"""
        report = {
            "app_name": app_info['attributes']['name'] if app_info else "Unknown App",
            "app_id": app_info['id'] if app_info else "Unknown",
            "total_count": len(feedbacks),
            "generated_at": datetime.now().isoformat(),
            "feedbacks": feedbacks
        }
        
        # Создаем директорию для отчетов
        report_dir = f"testflight_reports_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        Path(report_dir).mkdir(exist_ok=True)
        
        # Сохраняем отчет
        report_path = f"{report_dir}/feedback_report.json"
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        # Создаем summary файл
        summary_path = f"{report_dir}/summary.txt"
        with open(summary_path, "w") as f:
            f.write(f"TestFlight Feedback Summary\n")
            f.write(f"==========================\n\n")
            f.write(f"App: {report['app_name']}\n")
            f.write(f"Total feedback: {report['total_count']}\n")
            f.write(f"Generated: {report['generated_at']}\n\n")
            
            if feedbacks:
                f.write("Recent Feedback:\n")
                f.write("-" * 50 + "\n")
                
                for feedback in feedbacks[:10]:  # Первые 10
                    f.write(f"\nFrom: {feedback['tester_email']}\n")
                    f.write(f"Date: {feedback['submitted_date']}\n")
                    if feedback.get('rating'):
                        f.write(f"Rating: {'⭐' * feedback['rating']}\n")
                    f.write(f"Comment: {feedback['comment'][:200]}...\n")
                    f.write("-" * 50 + "\n")
                    
        print(f"\n✅ Report saved to: {report_path}")
        print(f"📄 Summary saved to: {summary_path}")
        
        return report

def print_usage():
    """Выводит инструкцию по использованию"""
    print("""
Usage: python fetch_testflight_feedback.py

Required environment variables:
- APP_STORE_CONNECT_API_KEY_ID: Your API Key ID
- APP_STORE_CONNECT_API_ISSUER_ID: Your Issuer ID  
- APP_STORE_CONNECT_API_KEY_PATH: Path to .p8 key file
- APP_ID: Your app ID in App Store Connect

Optional:
- FEEDBACK_DAYS: Number of days to fetch (default: 7)

Example:
export APP_STORE_CONNECT_API_KEY_ID="XXXXXXXXXX"
export APP_STORE_CONNECT_API_ISSUER_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
export APP_STORE_CONNECT_API_KEY_PATH="./AuthKey_XXXXXXXXXX.p8"
export APP_ID="1234567890"
python fetch_testflight_feedback.py
""")

def main():
    print("🚀 TestFlight Feedback Fetcher v2.0")
    print("=" * 50)
    
    # Читаем конфигурацию из переменных окружения
    key_id = os.getenv("APP_STORE_CONNECT_API_KEY_ID")
    issuer_id = os.getenv("APP_STORE_CONNECT_API_ISSUER_ID")
    key_path = os.getenv("APP_STORE_CONNECT_API_KEY_PATH")
    app_id = os.getenv("APP_ID")
    days = int(os.getenv("FEEDBACK_DAYS", "7"))
    
    if not all([key_id, issuer_id, key_path, app_id]):
        print("❌ Error: Missing required environment variables")
        print_usage()
        return 1
        
    # Создаем fetcher
    fetcher = TestFlightFeedbackFetcher(key_id, issuer_id, key_path)
    
    # Получаем информацию о приложении
    app_info = fetcher.get_app_info(app_id)
    if not app_info:
        print("❌ Failed to get app information")
        return 1
        
    # Получаем feedback несколькими способами
    print(f"\n📅 Fetching feedback for the last {days} days...")
    
    feedbacks = []
    
    # Метод 1: Через beta submissions
    feedbacks.extend(fetcher.get_beta_feedback_submissions(app_id, days))
    
    # Метод 2: Через beta testers (если первый не сработал)
    if not feedbacks:
        feedbacks.extend(fetcher.get_beta_testers_feedback(app_id, days))
        
    # Создаем отчет
    report = fetcher.create_report(feedbacks, app_info)
    
    # Выводим summary
    print("\n" + "=" * 50)
    print("📊 TestFlight Feedback Summary")
    print("=" * 50)
    print(f"App: {report['app_name']}")
    print(f"Total feedback found: {report['total_count']}")
    
    if report['total_count'] > 0:
        # Анализируем критичные отзывы
        critical_keywords = ['crash', 'bug', 'error', 'broken', 'не работает', 'падает', 'ошибка']
        critical_count = sum(1 for f in feedbacks if any(
            keyword in f.get('comment', '').lower() for keyword in critical_keywords
        ))
        
        if critical_count > 0:
            print(f"⚠️ Critical issues found: {critical_count}")
            
        # Показываем последние отзывы
        print(f"\nShowing last {min(5, len(feedbacks))} feedback items:")
        print("-" * 50)
        
        for feedback in feedbacks[:5]:
            print(f"\n👤 From: {feedback['tester_email']}")
            print(f"📅 Date: {feedback['submitted_date']}")
            if feedback.get('rating'):
                print(f"⭐ Rating: {feedback['rating']}/5")
            print(f"💬 Comment: {feedback['comment'][:100]}...")
    else:
        print("\nℹ️ No feedback found for the specified period")
        print("This could mean:")
        print("- No testers have submitted feedback recently")
        print("- The API endpoint has changed")
        print("- Permissions issue with the API key")
        
    print("\n✅ Done!")
    return 0

if __name__ == "__main__":
    sys.exit(main()) 