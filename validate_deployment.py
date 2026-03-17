#!/usr/bin/env python3
"""
Comprehensive deployment validation for merchant shops CRUD
"""
import subprocess
import sys
import json
from pathlib import Path

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def run_ssh(cmd):
    """Run SSH command and return output"""
    full_cmd = f'ssh -p 2222 ubuntu@sirius-djibouti.com "{cmd}"'
    try:
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, timeout=10)
        return result.stdout.strip(), result.returncode
    except subprocess.TimeoutExpired:
        return "", -1

def print_header(text):
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text.center(60)}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.ENDC}\n")

def print_test(name, result, details=""):
    icon = f"{Colors.GREEN}✓{Colors.ENDC}" if result else f"{Colors.RED}✗{Colors.ENDC}"
    print(f"{icon} {name}")
    if details:
        print(f"  {details}")

def test_service_status():
    """Test if service is running"""
    output, code = run_ssh("sudo systemctl is-active localboost-backend")
    is_active = "active" in output.lower()
    print_test("Service Active", is_active, f"Status: {output}")
    return is_active

def test_merchant_files():
    """Test if merchant files are deployed"""
    files = {
        "urls.py": "/srv/localboost/backend/apps/merchants/urls.py",
        "views.py": "/srv/localboost/backend/apps/merchants/views.py",
        "permissions.py": "/srv/localboost/backend/apps/merchants/permissions.py",
        "serializers.py": "/srv/localboost/backend/apps/merchants/serializers.py",
    }
    
    all_exist = True
    for name, path in files.items():
        output, code = run_ssh(f"sudo test -f {path} && echo exists")
        exists = "exists" in output
        all_exist = all_exist and exists
        print_test(f"  {name}", exists)
    
    return all_exist

def test_api_urls_config():
    """Test if api_urls.py has merchant route"""
    output, code = run_ssh("sudo grep -c 'merchant' /srv/localboost/backend/config/api_urls.py")
    has_merchant = int(output) > 0 if output.isdigit() else False
    print_test("  API config has merchant route", has_merchant, f"Match count: {output}")
    return has_merchant

def test_migration():
    """Test if migration 0003 is applied"""
    output, code = run_ssh("/srv/localboost/.venv/bin/python /srv/localboost/backend/manage.py showmigrations shops 2>&1 | grep 0003")
    is_applied = "[X]" in output
    status = "Applied ✓" if is_applied else "Not Applied ✗"
    print_test(f"  Migration 0003", is_applied, status)
    return is_applied

def test_api_health():
    """Test basic API health"""
    output, code = run_ssh("curl -s -w '%{http_code}' 'http://127.0.0.1:8000/api/v1/health/status/' 2>&1 | tail -c 4")
    status_code = output.strip()[-3:] if output else "000"
    is_responding = status_code in ["200", "301", "302", "307"]
    print_test("  API health endpoint", is_responding, f"Status code: {status_code}")
    return is_responding

def test_merchant_endpoints():
    """Test merchant CRUD endpoints structure"""
    # We can't fully test without auth, but we can check for import errors
    output, code = run_ssh("/srv/localboost/.venv/bin/python /srv/localboost/backend/manage.py check 2>&1 | grep -i error | head -5")
    has_errors = len(output) > 0
    status = "No errors found" if not has_errors else f"Errors: {output[:100]}"
    print_test("  Django system check", not has_errors, status)
    return not has_errors

def test_database_connection():
    """Test database connection"""
    output, code = run_ssh("/srv/localboost/.venv/bin/python /srv/localboost/backend/manage.py dbshell --no-input < /dev/null 2>&1 | head -1")
    has_errors = "error" in output.lower() or "refused" in output.lower()
    print_test("  Database connection", not has_errors)
    return not has_errors

def main():
    print_header("MERCHANT SHOPS DEPLOYMENT VALIDATION REPORT")
    
    results = {}
    
    # Test Categories
    print(f"{Colors.BOLD}1. SERVICE STATUS{Colors.ENDC}")
    results['service'] = test_service_status()
    
    print(f"\n{Colors.BOLD}2. FILE DEPLOYMENT{Colors.ENDC}")
    results['merchant_files'] = test_merchant_files()
    
    print(f"\n{Colors.BOLD}3. CONFIGURATION{Colors.ENDC}")
    results['api_config'] = test_api_urls_config()
    
    print(f"\n{Colors.BOLD}4. DATABASE{Colors.ENDC}")
    results['migration'] = test_migration()
    results['database'] = test_database_connection()
    
    print(f"\n{Colors.BOLD}5. API ENDPOINTS{Colors.ENDC}")
    results['api_health'] = test_api_health()
    results['api_check'] = test_merchant_endpoints()
    
    # Summary
    print_header("VALIDATION SUMMARY")
    
    all_passed = all(results.values())
    
    print(f"{Colors.BOLD}Results Overview:{Colors.ENDC}")
    for test_name, result in results.items():
        icon = f"{Colors.GREEN}✓{Colors.ENDC}" if result else f"{Colors.RED}✗{Colors.ENDC}"
        print(f"  {icon} {test_name.replace('_', ' ').title()}: {'PASS' if result else 'FAIL'}")
    
    print(f"\n{Colors.BOLD}Final Status:{Colors.ENDC}")
    if all_passed:
        print(f"{Colors.GREEN}✓ ALL TESTS PASSED - DEPLOYMENT SUCCESSFUL!{Colors.ENDC}")
        print("\nNext Steps:")
        print("  1. Run comprehensive CRUD validation tests")
        print("  2. Test merchant login and ownership boundaries")
        print("  3. Validate public discovery filtering")
        print("  4. Deploy Flutter app to devices")
        return 0
    else:
        print(f"{Colors.RED}✗ SOME TESTS FAILED - PLEASE REVIEW ABOVE{Colors.ENDC}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
