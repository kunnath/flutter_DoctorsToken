import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../database_helper.dart';
import '../services/email_service.dart';

class AppointmentReminderService {
  static Timer? _reminderTimer;
  static bool _isRunning = false;

  // Start the reminder service
  static void startReminderService() {
    if (_isRunning) return;
    
    _isRunning = true;
    _reminderTimer = Timer.periodic(
      const Duration(minutes: 5), // Check every 5 minutes
      (timer) => _checkAndSendReminders(),
    );
    
    if (kDebugMode) {
      print('AppointmentModel reminder service started');
    }
  }

  // Stop the reminder service
  static void stopReminderService() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
    _isRunning = false;
    
    if (kDebugMode) {
      print('AppointmentModel reminder service stopped');
    }
  }

  // Check for appointments that need reminders
  static Future<void> _checkAndSendReminders() async {
    try {
      final dbHelper = DatabaseHelper();
      final appointments = await dbHelper.getAppointmentsForReminders();
      
      final DateTime now = DateTime.now();
      
      for (final appointment in appointments) {
        final appointmentTime = appointment.appointmentDate;
        final timeDifference = appointmentTime.difference(now);
        
        // Send 1-hour reminder
        if (timeDifference.inMinutes <= 60 && 
            timeDifference.inMinutes > 45 && 
            !_hasReminderBeenSent(appointment, '1h')) {
          await _sendReminder(appointment, '1h');
          await dbHelper.markReminderSent(appointment.id!, '1h');
        }
        
        // Send 15-minute reminder
        if (timeDifference.inMinutes <= 15 && 
            timeDifference.inMinutes > 0 && 
            !_hasReminderBeenSent(appointment, '15m')) {
          await _sendReminder(appointment, '15m');
          await dbHelper.markReminderSent(appointment.id!, '15m');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking reminders: $e');
      }
    }
  }

  // Send reminder for a specific appointment
  static Future<void> _sendReminder(appointment, String reminderType) async {
    try {
      // Send email reminder
      await EmailService.sendAppointmentReminder(appointment, reminderType);
      
      // Create in-app notification
      final dbHelper = DatabaseHelper();
      final timeUntil = reminderType == '1h' ? '1 hour' : '15 minutes';
      
      await dbHelper.createNotification(
        appointment.patientId,
        'AppointmentModel Reminder',
        'Your appointment is in $timeUntil. Token: ${appointment.token}',
        'appointment_reminder',
        appointment.id,
      );
      
      if (kDebugMode) {
        print('Sent $reminderType reminder for appointment ${appointment.token}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send reminder: $e');
      }
    }
  }

  // Check if reminder has been sent (this would be stored in database)
  static bool _hasReminderBeenSent(appointment, String reminderType) {
    // This should check the database for reminder status
    // For now, returning false to ensure reminders are sent
    return false;
  }

  // Manual reminder check (can be called from UI)
  static Future<void> checkRemindersNow() async {
    await _checkAndSendReminders();
  }

  // Get service status
  static bool get isRunning => _isRunning;
}

// Background service for automatic appointment monitoring
class AppointmentMonitoringService {
  static Timer? _monitoringTimer;
  static bool _isRunning = false;

  // Start monitoring service
  static void startMonitoring() {
    if (_isRunning) return;
    
    _isRunning = true;
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 10), // Check every 10 minutes
      (timer) => _monitorAppointments(),
    );
    
    if (kDebugMode) {
      print('AppointmentModel monitoring service started');
    }
  }

  // Stop monitoring service
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isRunning = false;
    
    if (kDebugMode) {
      print('AppointmentModel monitoring service stopped');
    }
  }

  // Monitor appointments for automatic actions
  static Future<void> _monitorAppointments() async {
    try {
      final dbHelper = DatabaseHelper();
      final now = DateTime.now();
      
      // Get approved appointments that are overdue
      final overdueAppointments = await dbHelper.getOverdueAppointments();
      
      for (final appointment in overdueAppointments) {
        final appointmentTime = appointment.appointmentDate;
        final timeSinceAppointment = now.difference(appointmentTime);
        
        // Mark as no-show if more than 30 minutes past appointment time
        if (timeSinceAppointment.inMinutes > 30 && appointment.status == 'approved') {
          await dbHelper.updateAppointmentStatusEnhanced(
            appointment.id!,
            'no_show',
            notes: 'Automatically marked as no-show due to non-attendance',
          );
          
          if (kDebugMode) {
            print('Marked appointment ${appointment.token} as no-show');
          }
        }
      }
      
      // Check for location verification failures
      await _checkLocationVerificationTimeouts();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error monitoring appointments: $e');
      }
    }
  }

  // Check for appointments that failed location verification
  static Future<void> _checkLocationVerificationTimeouts() async {
    try {
      final dbHelper = DatabaseHelper();
      final now = DateTime.now();
      
      // Get today's approved appointments that haven't been location verified
      final appointments = await dbHelper.getTodaysApprovedAppointments();
      
      for (final appointment in appointments) {
        final appointmentTime = appointment.appointmentDate;
        final timeSinceAppointment = now.difference(appointmentTime);
        
        // If appointment time has passed and no location verification
        if (timeSinceAppointment.inMinutes > 0 && 
            !appointment.isLocationVerified) {
          // Auto-cancel after 15 minutes of appointment time
          if (timeSinceAppointment.inMinutes > 15) {
            await dbHelper.updateAppointmentStatusEnhanced(
              appointment.id!,
              'cancelled',
              notes: 'Automatically cancelled due to location verification failure',
            );
            
            if (kDebugMode) {
              print('Auto-cancelled appointment ${appointment.token} due to location verification failure');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location verification timeouts: $e');
      }
    }
  }

  // Get service status
  static bool get isRunning => _isRunning;
}

// Service manager to control all background services
class BackgroundServiceManager {
  static bool _servicesStarted = false;

  // Start all background services
  static void startAllServices() {
    if (_servicesStarted) return;
    
    AppointmentReminderService.startReminderService();
    AppointmentMonitoringService.startMonitoring();
    
    _servicesStarted = true;
    
    if (kDebugMode) {
      print('All background services started');
    }
  }

  // Stop all background services
  static void stopAllServices() {
    AppointmentReminderService.stopReminderService();
    AppointmentMonitoringService.stopMonitoring();
    
    _servicesStarted = false;
    
    if (kDebugMode) {
      print('All background services stopped');
    }
  }

  // Get overall service status
  static bool get areServicesRunning => _servicesStarted;
  
  // Get detailed service status
  static Map<String, bool> getServiceStatus() {
    return {
      'reminderService': AppointmentReminderService.isRunning,
      'monitoringService': AppointmentMonitoringService.isRunning,
      'allServices': _servicesStarted,
    };
  }
}
