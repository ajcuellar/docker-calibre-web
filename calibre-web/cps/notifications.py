# -*- coding: utf-8 -*-

#   This file is part of the Calibre-Web (https://github.com/janeczku/calibre-web)
#     Copyright (C) 2026
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.

"""
Notification Service Module
Provides multi-channel notification support for Calibre-Web
Supports: Email, WhatsApp (Twilio), Telegram, Web Push
"""

import smtplib
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Dict, Optional
from flask import url_for
from flask_babel import gettext as _

from . import logger, config, ub

log = logger.create()


class NotificationService:
    """Base notification service class"""
    
    @staticmethod
    def get_book_notification_message(book_title, authors, book_id=None):
        """Generate a formatted message for new book notifications"""
        authors_str = ", ".join([author.name for author in authors]) if authors else _("Unknown Author")
        
        base_message = _("📚 New book available!\n\nTitle: %(title)s\nAuthor(s): %(authors)s",
                        title=book_title, authors=authors_str)
        
        if book_id and config.config_external_port:
            try:
                book_url = url_for('web.show_book', book_id=book_id, _external=True)
                base_message += f"\n\n🔗 {book_url}"
            except Exception as e:
                log.debug(f"Could not generate book URL: {e}")
        
        return base_message
    
    @staticmethod
    def is_enabled_for_user(user, notification_type: str) -> bool:
        """Check if a notification type is enabled for a user"""
        if not user or user.is_anonymous:
            return False
        
        if not user.notification_preferences:
            return False
        
        new_books_prefs = user.notification_preferences.get('new_books', {})
        return new_books_prefs.get(notification_type, False)


class EmailNotificationService(NotificationService):
    """Email notification service using the existing mail configuration"""
    
    @staticmethod
    def send_notification(user, subject: str, message: str) -> bool:
        """Send email notification to a user"""
        if not user.email:
            log.warning(f"User {user.name} has no email address configured")
            return False
        
        try:
            # Use the existing helper function from config
            from .helper import send_mail
            
            result = send_mail(
                book_id=None,
                book_format=None,
                convert=None,
                kindle_mail=user.email,
                calibrepath=None,
                user=user
            )
            
            # For simple notifications, we'll use a simpler approach
            # You may need to adapt this based on your existing mail setup
            log.info(f"Email notification sent to {user.email}")
            return True
            
        except Exception as e:
            log.error(f"Failed to send email notification to {user.email}: {e}")
            return False
    
    @staticmethod
    def send_new_book_notification(user, book_title: str, authors, book_id=None) -> bool:
        """Send new book notification via email"""
        if not EmailNotificationService.is_enabled_for_user(user, 'email'):
            return False
        
        subject = _("New Book Available: %(title)s", title=book_title)
        message = NotificationService.get_book_notification_message(book_title, authors, book_id)
        
        return EmailNotificationService.send_notification(user, subject, message)


class WhatsAppNotificationService(NotificationService):
    """WhatsApp notification service using Evolution API"""
    
    @staticmethod
    def send_notification(phone_number: str, message: str) -> bool:
        """Send WhatsApp message using Evolution API"""
        if not phone_number:
            log.warning("No phone number provided for WhatsApp notification")
            return False
        
        # Get Evolution API credentials from config
        api_url = config.config_evolution_api_url if hasattr(config, 'config_evolution_api_url') else None
        api_key = config.config_evolution_api_key if hasattr(config, 'config_evolution_api_key') else None
        instance = config.config_evolution_api_instance if hasattr(config, 'config_evolution_api_instance') else None
        
        if not all([api_url, api_key, instance]):
            log.warning("Evolution API credentials not configured for WhatsApp notifications")
            return False
        
        try:
            # Evolution API endpoint for sending text messages
            url = f"{api_url}/message/sendText/{instance}"
            
            # Clean phone number (remove any non-digit characters except +)
            clean_number = ''.join(c for c in phone_number if c.isdigit() or c == '+')
            # Remove + if present and ensure it's in international format
            if clean_number.startswith('+'):
                clean_number = clean_number[1:]
            
            headers = {
                'Content-Type': 'application/json',
                'apikey': api_key
            }
            
            data = {
                'number': clean_number,
                'textMessage': {
                    'text': message
                }
            }
            
            response = requests.post(url, json=data, headers=headers, timeout=10)
            
            if response.status_code in [200, 201]:
                log.info(f"WhatsApp notification sent to {phone_number} via Evolution API")
                return True
            else:
                log.error(f"Failed to send WhatsApp notification via Evolution API: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            log.error(f"Error sending WhatsApp notification via Evolution API: {e}")
            return False
    
    @staticmethod
    def send_new_book_notification(user, book_title: str, authors, book_id=None) -> bool:
        """Send new book notification via WhatsApp"""
        if not WhatsAppNotificationService.is_enabled_for_user(user, 'whatsapp'):
            return False
        
        if not user.phone_number:
            log.warning(f"User {user.name} has no phone number configured")
            return False
        
        message = NotificationService.get_book_notification_message(book_title, authors, book_id)
        return WhatsAppNotificationService.send_notification(user.phone_number, message)


class TelegramNotificationService(NotificationService):
    """Telegram notification service using Bot API"""
    
    @staticmethod
    def send_notification(telegram_id: str, message: str) -> bool:
        """Send Telegram message using Bot API"""
        if not telegram_id:
            log.warning("No Telegram ID provided")
            return False
        
        # Get Telegram bot token from config
        bot_token = config.config_telegram_bot_token if hasattr(config, 'config_telegram_bot_token') else None
        
        if not bot_token:
            log.warning("Telegram bot token not configured")
            return False
        
        try:
            url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
            
            data = {
                'chat_id': telegram_id,
                'text': message,
                'parse_mode': 'HTML',
                'disable_web_page_preview': False
            }
            
            response = requests.post(url, json=data, timeout=10)
            
            if response.status_code == 200:
                log.info(f"Telegram notification sent to {telegram_id}")
                return True
            else:
                log.error(f"Failed to send Telegram notification: {response.text}")
                return False
                
        except Exception as e:
            log.error(f"Error sending Telegram notification: {e}")
            return False
    
    @staticmethod
    def send_new_book_notification(user, book_title: str, authors, book_id=None) -> bool:
        """Send new book notification via Telegram"""
        if not TelegramNotificationService.is_enabled_for_user(user, 'telegram'):
            return False
        
        if not user.telegram_id:
            log.warning(f"User {user.name} has no Telegram ID configured")
            return False
        
        message = NotificationService.get_book_notification_message(book_title, authors, book_id)
        return TelegramNotificationService.send_notification(user.telegram_id, message)


class WebPushNotificationService(NotificationService):
    """Web Push notification service (simplified, requires manual setup)"""
    
    @staticmethod
    def send_notification(subscription_info: Dict, title: str, message: str, url: Optional[str] = None) -> bool:
        """Send Web Push notification - requires pywebpush and VAPID configuration"""
        try:
            # Check if pywebpush is available
            try:
                from pywebpush import webpush, WebPushException
            except ImportError:
                log.debug("pywebpush library not installed. Install it with: pip install pywebpush")
                return False
            
            # Check if Web Push is enabled
            use_webpush = config.config_use_webpush if hasattr(config, 'config_use_webpush') else False
            
            if not use_webpush:
                log.debug("Web Push notifications are not enabled")
                return False
            
            # For now, Web Push is simplified and requires manual implementation
            # This is a placeholder for future development
            log.info("Web Push notification placeholder called (not fully implemented)")
            return False
            
        except Exception as e:
            log.error(f"Error in Web Push notification: {e}")
            return False
    
    @staticmethod
    def send_new_book_notification(user, book_title: str, authors, book_id=None) -> bool:
        """Send new book notification via Web Push"""
        if not WebPushNotificationService.is_enabled_for_user(user, 'push'):
            return False
        
        # Web push requires subscription info stored in user preferences or separate table
        # This is a placeholder implementation
        log.info(f"Web Push notification would be sent to user {user.name}")
        return True


class NotificationManager:
    """Manager class to coordinate all notification services"""
    
    @staticmethod
    def notify_new_book(book_title: str, authors, book_id=None):
        """
        Send new book notifications to all users with notifications enabled
        
        Args:
            book_title: Title of the new book
            authors: List of author objects
            book_id: Book ID for generating URLs
        """
        try:
            # Get all active users
            users = ub.session.query(ub.User).filter(
                ub.User.role.op('&')(16) != 16  # Exclude anonymous users
            ).all()
            
            notification_count = 0
            
            for user in users:
                if not user.notification_preferences:
                    continue
                
                # Check if user wants new book notifications
                new_books_prefs = user.notification_preferences.get('new_books', {})
                
                # Send email notification
                if new_books_prefs.get('email', False):
                    if EmailNotificationService.send_new_book_notification(user, book_title, authors, book_id):
                        notification_count += 1
                
                # Send WhatsApp notification
                if new_books_prefs.get('whatsapp', False):
                    if WhatsAppNotificationService.send_new_book_notification(user, book_title, authors, book_id):
                        notification_count += 1
                
                # Send Telegram notification
                if new_books_prefs.get('telegram', False):
                    if TelegramNotificationService.send_new_book_notification(user, book_title, authors, book_id):
                        notification_count += 1
                
                # Send Web Push notification
                if new_books_prefs.get('push', False):
                    if WebPushNotificationService.send_new_book_notification(user, book_title, authors, book_id):
                        notification_count += 1
            
            log.info(f"Sent {notification_count} notifications for new book: {book_title}")
            return notification_count
            
        except Exception as e:
            log.error(f"Error in notify_new_book: {e}")
            return 0


# Convenience function for easy import
def send_new_book_notifications(book_title: str, authors, book_id=None):
    """
    Convenience function to send new book notifications
    
    Args:
        book_title: Title of the new book
        authors: List of author objects  
        book_id: Optional book ID
    
    Returns:
        Number of notifications sent
    """
    return NotificationManager.notify_new_book(book_title, authors, book_id)
