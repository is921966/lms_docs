#!/usr/bin/env python3
"""
iOS App Log Analyzer for Automated Testing
Analyzes comprehensive logs from the iOS app to verify test scenarios
"""

import json
import sys
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Any, Optional
import argparse
from pathlib import Path

class LogAnalyzer:
    def __init__(self, log_file: str):
        self.log_file = log_file
        self.logs = []
        self.load_logs()
    
    def load_logs(self):
        """Load logs from JSON file"""
        try:
            with open(self.log_file, 'r') as f:
                content = f.read()
                # Handle both single log entries and arrays
                if content.strip().startswith('['):
                    self.logs = json.loads(content)
                else:
                    # Handle multiple log entries separated by commas
                    self.logs = json.loads(f'[{content}]')
        except Exception as e:
            print(f"Error loading logs: {e}")
            sys.exit(1)
    
    def find_navigation_path(self, start_time: Optional[datetime] = None) -> List[str]:
        """Extract navigation path from logs"""
        nav_logs = [log for log in self.logs if log['category'] == 'Navigation']
        if start_time:
            nav_logs = [log for log in nav_logs if datetime.fromisoformat(log['timestamp']) >= start_time]
        
        path = []
        for log in sorted(nav_logs, key=lambda x: x['timestamp']):
            if '→' in log['event']:
                path.append(log['event'])
        return path
    
    def verify_login_flow(self, email: str) -> Dict[str, Any]:
        """Verify login flow for specific email"""
        result = {
            'success': False,
            'steps': [],
            'errors': []
        }
        
        # Find login button tap
        login_taps = [log for log in self.logs 
                     if log['category'] == 'UI' 
                     and log['event'] == 'Button Tap'
                     and 'Login' in log['details'].get('buttonName', '')]
        
        if not login_taps:
            result['errors'].append("No login button tap found")
            return result
        
        login_tap = login_taps[-1]  # Get most recent
        login_time = datetime.fromisoformat(login_tap['timestamp'])
        result['steps'].append(f"Login button tapped at {login_time}")
        
        # Check if correct email was used
        if login_tap['details'].get('email') == email:
            result['steps'].append(f"Correct email used: {email}")
        else:
            result['errors'].append(f"Wrong email: expected {email}, got {login_tap['details'].get('email')}")
        
        # Find network request
        auth_requests = [log for log in self.logs 
                        if log['category'] == 'Network' 
                        and '/api/login' in log['details'].get('url', '')
                        and datetime.fromisoformat(log['timestamp']) >= login_time]
        
        if auth_requests:
            auth_request = auth_requests[0]
            status_code = auth_request['details'].get('statusCode')
            result['steps'].append(f"Auth request made, status: {status_code}")
            
            if status_code == 200:
                result['steps'].append("Authentication successful")
                
                # Check navigation to feed
                nav_path = self.find_navigation_path(login_time)
                if any('FeedView' in nav for nav in nav_path):
                    result['steps'].append("Successfully navigated to Feed")
                    result['success'] = True
                else:
                    result['errors'].append("Did not navigate to Feed after login")
            else:
                result['errors'].append(f"Authentication failed with status {status_code}")
        else:
            result['errors'].append("No authentication request found")
        
        return result
    
    def analyze_ui_interactions(self, view_name: str, time_window: int = 60) -> Dict[str, Any]:
        """Analyze all UI interactions in a specific view"""
        ui_logs = [log for log in self.logs 
                  if log['category'] == 'UI' 
                  and log['details'].get('viewName') == view_name]
        
        interactions = {
            'button_taps': [],
            'text_inputs': [],
            'list_selections': [],
            'errors': [],
            'loading_states': []
        }
        
        for log in ui_logs:
            if log['event'] == 'Button Tap':
                interactions['button_taps'].append({
                    'button': log['details'].get('buttonName'),
                    'time': log['timestamp']
                })
            elif log['event'] == 'Text Input':
                interactions['text_inputs'].append({
                    'field': log['details'].get('fieldName'),
                    'value': log['details'].get('newValue'),
                    'time': log['timestamp']
                })
            elif log['event'] == 'List Item Tap':
                interactions['list_selections'].append({
                    'item': log['details'].get('item'),
                    'index': log['details'].get('index'),
                    'time': log['timestamp']
                })
            elif log['event'] == 'Error State':
                interactions['errors'].append({
                    'error': log['details'].get('error'),
                    'time': log['timestamp']
                })
            elif log['event'] == 'Loading State':
                interactions['loading_states'].append({
                    'loading': log['details'].get('isLoading'),
                    'reason': log['details'].get('reason'),
                    'time': log['timestamp']
                })
        
        return interactions
    
    def get_performance_metrics(self) -> Dict[str, float]:
        """Extract performance metrics from logs"""
        perf_logs = [log for log in self.logs if log['category'] == 'Performance']
        
        metrics = defaultdict(list)
        for log in perf_logs:
            metric_name = log['details'].get('metric', 'unknown')
            value = log['details'].get('value', 0)
            metrics[metric_name].append(value)
        
        # Calculate averages
        avg_metrics = {}
        for metric, values in metrics.items():
            avg_metrics[f"{metric}_avg"] = sum(values) / len(values) if values else 0
            avg_metrics[f"{metric}_max"] = max(values) if values else 0
            avg_metrics[f"{metric}_min"] = min(values) if values else 0
        
        return avg_metrics
    
    def generate_test_report(self, test_name: str) -> str:
        """Generate a comprehensive test report"""
        report = f"# Test Report: {test_name}\n\n"
        report += f"Generated at: {datetime.now().isoformat()}\n\n"
        
        # Navigation Path
        report += "## Navigation Path\n"
        nav_path = self.find_navigation_path()
        for nav in nav_path[-10:]:  # Last 10 navigations
            report += f"- {nav}\n"
        report += "\n"
        
        # UI Interactions by View
        report += "## UI Interactions\n"
        views = set(log['details'].get('viewName', '') for log in self.logs if log['category'] == 'UI')
        for view in sorted(views):
            if view:
                interactions = self.analyze_ui_interactions(view)
                report += f"\n### {view}\n"
                report += f"- Button taps: {len(interactions['button_taps'])}\n"
                report += f"- Text inputs: {len(interactions['text_inputs'])}\n"
                report += f"- Errors: {len(interactions['errors'])}\n"
        
        # Performance Metrics
        report += "\n## Performance Metrics\n"
        metrics = self.get_performance_metrics()
        for metric, value in sorted(metrics.items()):
            report += f"- {metric}: {value:.2f}\n"
        
        # Errors
        report += "\n## Errors\n"
        error_logs = [log for log in self.logs if log['level'] == 'ERROR']
        for error in error_logs[-10:]:  # Last 10 errors
            report += f"- [{error['timestamp']}] {error['event']}\n"
        
        return report

def main():
    parser = argparse.ArgumentParser(description='Analyze iOS app logs for automated testing')
    parser.add_argument('log_file', help='Path to log file (JSON format)')
    parser.add_argument('--test', choices=['login', 'navigation', 'performance', 'full'], 
                       default='full', help='Type of analysis to perform')
    parser.add_argument('--email', help='Email for login verification')
    parser.add_argument('--view', help='View name for UI interaction analysis')
    parser.add_argument('--output', help='Output file for report')
    
    args = parser.parse_args()
    
    analyzer = LogAnalyzer(args.log_file)
    
    if args.test == 'login':
        if not args.email:
            print("Error: --email required for login test")
            sys.exit(1)
        result = analyzer.verify_login_flow(args.email)
        print(json.dumps(result, indent=2))
    
    elif args.test == 'navigation':
        path = analyzer.find_navigation_path()
        print("Navigation Path:")
        for nav in path:
            print(f"  {nav}")
    
    elif args.test == 'performance':
        metrics = analyzer.get_performance_metrics()
        print("Performance Metrics:")
        for metric, value in sorted(metrics.items()):
            print(f"  {metric}: {value:.2f}")
    
    elif args.test == 'full':
        report = analyzer.generate_test_report("Full App Analysis")
        if args.output:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"Report saved to {args.output}")
        else:
            print(report)
    
    if args.view:
        interactions = analyzer.analyze_ui_interactions(args.view)
        print(f"\nInteractions in {args.view}:")
        print(json.dumps(interactions, indent=2))

if __name__ == '__main__':
    main() 