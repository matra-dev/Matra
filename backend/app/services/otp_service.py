import os
import random
import string
from datetime import datetime, timedelta
from typing import Optional, Dict

# Fast2SMS Configuration
# Set FAST2SMS_API_KEY in your environment or .env file
# For demo/testing, OTPs are printed to console instead of sent
FAST2SMS_API_KEY = os.getenv("FAST2SMS_API_KEY", "")
FAST2SMS_ENABLED = os.getenv("FAST2SMS_ENABLED", "false").lower() == "true"

# In-memory OTP store (use Redis in production)
# Format: { "phone_number": { "otp": "123456", "expires_at": timestamp, "attempts": 0 } }
_otp_store: Dict[str, dict] = {}

OTP_LENGTH = 6
OTP_EXPIRY_MINUTES = 5
MAX_ATTEMPTS = 3


def _generate_otp() -> str:
    """Generate a 6-digit numeric OTP."""
    return ''.join(random.choices(string.digits, k=OTP_LENGTH))


def _format_phone(phone: str, country_code: str) -> str:
    """Format phone number with country code for Fast2SMS."""
    # Remove any leading + or 00 from phone
    clean_phone = phone.lstrip('+').lstrip('0')
    # Remove any + from country code
    clean_code = country_code.lstrip('+')
    return f"{clean_code}{clean_phone}"


def _send_fast2ms_sms(phone: str, otp: str) -> bool:
    """
    Send OTP via Fast2SMS API.
    Returns True if sent successfully, False otherwise.
    
    NOTE: For demo/testing without API key, OTP is printed to console.
    Set FAST2SMS_API_KEY and FAST2SMS_ENABLED=true in production.
    """
    if not FAST2SMS_ENABLED or not FAST2SMS_API_KEY:
        print(f"\n{'='*50}")
        print(f"  DEMO OTP for {phone}: {otp}")
        print(f"  (Set FAST2SMS_API_KEY env var for real SMS)")
        print(f"{'='*50}\n")
        return True

    try:
        import requests
        
        url = "https://www.fast2sms.com/dev/bulkV2"
        
        # Fast2SMS supports multiple message formats
        # Using the promotional/transactional route
        payload = {
            "variables_values": otp,
            "route": "otp",
            "numbers": phone,
        }
        
        headers = {
            "authorization": FAST2SMS_API_KEY,
            "Content-Type": "application/json",
        }
        
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        data = response.json()
        
        if response.status_code == 200 and data.get("return"):
            print(f"OTP sent successfully to {phone}")
            return True
        else:
            print(f"Fast2SMS error: {data}")
            return False
            
    except Exception as e:
        print(f"Failed to send SMS: {e}")
        return False


def send_otp(phone: str, country_code: str = "+91") -> dict:
    """
    Send OTP to the given phone number.
    
    Args:
        phone: Phone number (without country code)
        country_code: Country code (default +91 for India)
    
    Returns:
        dict with success status and message
    """
    formatted_phone = _format_phone(phone, country_code)
    
    # Check if there's an existing OTP that hasn't expired
    existing = _otp_store.get(formatted_phone)
    if existing:
        if datetime.now().timestamp() < existing["expires_at"]:
            # Rate limit: don't allow resend within 60 seconds
            time_since_sent = datetime.now().timestamp() - existing["sent_at"]
            if time_since_sent < 60:
                return {
                    "success": False,
                    "message": f"Please wait {60 - int(time_since_sent)} seconds before requesting a new OTP",
                }
        # Clear old OTP
        del _otp_store[formatted_phone]
    
    # Generate new OTP
    otp = _generate_otp()
    
    # Store OTP with expiry
    _otp_store[formatted_phone] = {
        "otp": otp,
        "expires_at": (datetime.now() + timedelta(minutes=OTP_EXPIRY_MINUTES)).timestamp(),
        "sent_at": datetime.now().timestamp(),
        "attempts": 0,
    }
    
    # Send via Fast2SMS (or console in demo mode)
    sent = _send_fast2ms_sms(formatted_phone, otp)
    
    if sent:
        return {
            "success": True,
            "message": f"OTP sent successfully to {country_code} {phone}",
            "expires_in": OTP_EXPIRY_MINUTES * 60,  # seconds
        }
    else:
        # Clean up stored OTP if send failed
        del _otp_store[formatted_phone]
        return {
            "success": False,
            "message": "Failed to send OTP. Please try again.",
        }


def verify_otp(phone: str, country_code: str, otp: str) -> dict:
    """
    Verify OTP for the given phone number.
    
    Args:
        phone: Phone number (without country code)
        country_code: Country code
        otp: OTP entered by user
    
    Returns:
        dict with success status and message
    """
    formatted_phone = _format_phone(phone, country_code)
    stored = _otp_store.get(formatted_phone)
    
    if not stored:
        return {
            "success": False,
            "message": "OTP not found. Please request a new OTP.",
        }
    
    # Check expiry
    if datetime.now().timestamp() > stored["expires_at"]:
        del _otp_store[formatted_phone]
        return {
            "success": False,
            "message": "OTP has expired. Please request a new one.",
        }
    
    # Check max attempts
    if stored["attempts"] >= MAX_ATTEMPTS:
        del _otp_store[formatted_phone]
        return {
            "success": False,
            "message": "Too many failed attempts. Please request a new OTP.",
        }
    
    # Verify OTP
    if otp == stored["otp"]:
        # Success - clear OTP
        del _otp_store[formatted_phone]
        return {
            "success": True,
            "message": "OTP verified successfully",
        }
    else:
        # Increment attempts
        stored["attempts"] += 1
        remaining = MAX_ATTEMPTS - stored["attempts"]
        return {
            "success": False,
            "message": f"Invalid OTP. {remaining} attempts remaining.",
        }


def cleanup_expired_otps():
    """Remove expired OTPs from memory. Call periodically."""
    now = datetime.now().timestamp()
    expired = [phone for phone, data in _otp_store.items() if now > data["expires_at"]]
    for phone in expired:
        del _otp_store[phone]
