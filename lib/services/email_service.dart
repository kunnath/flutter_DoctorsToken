import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';
import '../database_helper.dart';

class EmailService {
  static const String _sendGridApiKey = 'YOUR_SENDGRID_API_KEY'; // Replace with actual API key
  static const String _sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';
  static const String _fromEmail = 'noreply@healthcare-app.com';
  static const String _fromName = 'Healthcare AppointmentModel System';

  static Future<bool> sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String htmlContent,
    String? textContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendGridUrl),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': toEmail, 'name': toName}
              ],
              'subject': subject,
            }
          ],
          'from': {'email': _fromEmail, 'name': _fromName},
          'content': [
            {'type': 'text/html', 'value': htmlContent},
            if (textContent != null) {'type': 'text/plain', 'value': textContent},
          ],
        }),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Failed to send email: $e');
      return false;
    }
  }

  // Send appointment request notification to doctor
  static Future<void> sendAppointmentRequest(int doctorUserId, AppointmentModel appointment) async {
    final dbHelper = DatabaseHelper();
    final doctor = await dbHelper.getUserById(doctorUserId);
    
    if (doctor == null) return;
    
    final patient = await dbHelper.getUserById(appointment.patientId);
    final hospital = await dbHelper.getHospitalById(appointment.hospitalId);
    
    final subject = 'New AppointmentModel Request - ${appointment.token}';
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #2c5aa0; margin-bottom: 30px; }
            .appointment-details { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .label { font-weight: bold; color: #666; }
            .value { color: #333; }
            .button { display: inline-block; padding: 12px 24px; background-color: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
            .button.reject { background-color: #dc3545; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🩺 New AppointmentModel Request</h1>
                <p>You have received a new appointment request</p>
            </div>
            
            <div class="appointment-details">
                <h3>AppointmentModel Details</h3>
                <div class="detail-row">
                    <span class="label">Token:</span>
                    <span class="value">${appointment.token}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Patient:</span>
                    <span class="value">${patient?['full_name'] ?? 'Unknown'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Date:</span>
                    <span class="value">${_formatDate(appointment.appointmentDate)}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Time:</span>
                    <span class="value">${appointment.timeSlot}</span>
                </div>
                <div class="detail-row">
                    <span class="label">HospitalModel:</span>
                    <span class="value">${hospital?.name ?? 'Unknown HospitalModel'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Reason:</span>
                    <span class="value">${appointment.reason}</span>
                </div>
                ${appointment.notes?.isNotEmpty == true ? '''
                <div class="detail-row">
                    <span class="label">Notes:</span>
                    <span class="value">${appointment.notes}</span>
                </div>
                ''' : ''}
            </div>
            
            <div style="text-align: center; margin: 30px 0;">
                <p>Please review this appointment request and take appropriate action.</p>
            </div>
            
            <div class="footer">
                <p>This is an automated message from Healthcare AppointmentModel System.</p>
                <p>Please do not reply to this email.</p>
            </div>
        </div>
    </body>
    </html>
    ''';

    await sendEmail(
      toEmail: doctor['email'],
      toName: doctor['full_name'],
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  // Send appointment status update to patient
  static Future<void> sendAppointmentStatusUpdate(int patientUserId, AppointmentModel appointment, String newStatus, String? notes) async {
    final dbHelper = DatabaseHelper();
    final patient = await dbHelper.getUserById(patientUserId);
    
    if (patient == null) return;
    
    final doctor = await dbHelper.getDoctorById(appointment.doctorId);
    final hospital = await dbHelper.getHospitalById(appointment.hospitalId);
    
    String subject;
    String statusMessage;
    String statusColor;
    
    switch (newStatus) {
      case 'approved':
        subject = 'AppointmentModel Approved - ${appointment.token}';
        statusMessage = 'Your appointment has been approved by the doctor!';
        statusColor = '#28a745';
        break;
      case 'rejected':
        subject = 'AppointmentModel Not Approved - ${appointment.token}';
        statusMessage = 'Unfortunately, your appointment request could not be approved.';
        statusColor = '#dc3545';
        break;
      case 'completed':
        subject = 'AppointmentModel Completed - ${appointment.token}';
        statusMessage = 'Your appointment has been completed. Thank you for visiting us!';
        statusColor = '#007bff';
        break;
      case 'cancelled':
        subject = 'AppointmentModel Cancelled - ${appointment.token}';
        statusMessage = 'Your appointment has been cancelled.';
        statusColor = '#6c757d';
        break;
      default:
        subject = 'AppointmentModel Update - ${appointment.token}';
        statusMessage = 'Your appointment status has been updated.';
        statusColor = '#17a2b8';
    }

    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; margin-bottom: 30px; }
            .status-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; color: white; font-weight: bold; text-transform: uppercase; }
            .appointment-details { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .label { font-weight: bold; color: #666; }
            .value { color: #333; }
            .important-info { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📅 AppointmentModel Update</h1>
                <span class="status-badge" style="background-color: $statusColor;">$newStatus</span>
                <p>$statusMessage</p>
            </div>
            
            <div class="appointment-details">
                <h3>AppointmentModel Details</h3>
                <div class="detail-row">
                    <span class="label">Token:</span>
                    <span class="value">${appointment.token}</span>
                </div>
                <div class="detail-row">
                    <span class="label">DoctorModel:</span>
                    <span class="value">Dr. ${doctor?.fullName ?? 'Unknown'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Specialization:</span>
                    <span class="value">${doctor?.specialization ?? 'General'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Date:</span>
                    <span class="value">${_formatDate(appointment.appointmentDate)}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Time:</span>
                    <span class="value">${appointment.timeSlot}</span>
                </div>
                <div class="detail-row">
                    <span class="label">HospitalModel:</span>
                    <span class="value">${hospital?.name ?? 'Unknown HospitalModel'}</span>
                </div>
                ${notes != null && notes.isNotEmpty ? '''
                <div class="detail-row">
                    <span class="label">DoctorModel's Notes:</span>
                    <span class="value">$notes</span>
                </div>
                ''' : ''}
            </div>
            
            ${newStatus == 'approved' ? '''
            <div class="important-info">
                <h4>⚠️ Important Reminders:</h4>
                <ul>
                    <li>Please arrive 15 minutes before your scheduled time</li>
                    <li>Carry your appointment token: <strong>${appointment.token}</strong></li>
                    <li>Bring a valid photo ID</li>
                    <li>You will receive location verification reminders on appointment day</li>
                </ul>
            </div>
            ''' : newStatus == 'rejected' ? '''
            <div class="important-info">
                <h4>Next Steps:</h4>
                <ul>
                    <li>You can book a new appointment with the same or different doctor</li>
                    <li>Contact the hospital directly if you have questions</li>
                    <li>Consider scheduling for a different date/time</li>
                </ul>
            </div>
            ''' : ''}
            
            <div class="footer">
                <p>This is an automated message from Healthcare AppointmentModel System.</p>
                <p>Please do not reply to this email.</p>
            </div>
        </div>
    </body>
    </html>
    ''';

    await sendEmail(
      toEmail: patient['email'],
      toName: patient['full_name'],
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  // Send appointment reminder
  static Future<void> sendAppointmentReminder(AppointmentModel appointment, String reminderType) async {
    final dbHelper = DatabaseHelper();
    final patient = await dbHelper.getUserById(appointment.patientId);
    
    if (patient == null) return;
    
    final doctor = await dbHelper.getDoctorById(appointment.doctorId);
    final hospital = await dbHelper.getHospitalById(appointment.hospitalId);
    
    String timeUntil = reminderType == '1h' ? '1 hour' : '15 minutes';
    String subject = 'AppointmentModel Reminder - ${appointment.token} (${timeUntil})';

    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #ff6b35; margin-bottom: 30px; }
            .reminder-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; background-color: #ff6b35; color: white; font-weight: bold; }
            .appointment-details { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .label { font-weight: bold; color: #666; }
            .value { color: #333; }
            .important-info { background-color: #d1ecf1; border-left: 4px solid #0c5460; padding: 15px; margin: 20px 0; border-radius: 4px; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>⏰ AppointmentModel Reminder</h1>
                <span class="reminder-badge">$timeUntil until appointment</span>
            </div>
            
            <div class="appointment-details">
                <h3>Your Upcoming AppointmentModel</h3>
                <div class="detail-row">
                    <span class="label">Token:</span>
                    <span class="value">${appointment.token}</span>
                </div>
                <div class="detail-row">
                    <span class="label">DoctorModel:</span>
                    <span class="value">Dr. ${doctor?.fullName ?? 'Unknown'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Date:</span>
                    <span class="value">${_formatDate(appointment.appointmentDate)}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Time:</span>
                    <span class="value">${appointment.timeSlot}</span>
                </div>
                <div class="detail-row">
                    <span class="label">HospitalModel:</span>
                    <span class="value">${hospital?.name ?? 'Unknown HospitalModel'}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Address:</span>
                    <span class="value">${hospital?.address ?? 'Address not available'}</span>
                </div>
            </div>
            
            <div class="important-info">
                <h4>📋 Pre-AppointmentModel Checklist:</h4>
                <ul>
                    <li>✅ Arrive 15 minutes early</li>
                    <li>✅ Bring your appointment token: <strong>${appointment.token}</strong></li>
                    <li>✅ Carry valid photo identification</li>
                    <li>✅ Enable location services for verification</li>
                    <li>✅ Bring list of current medications (if any)</li>
                </ul>
            </div>
            
            ${reminderType == '15m' ? '''
            <div style="background-color: #fff3cd; border-left: 4px solid #856404; padding: 15px; margin: 20px 0; border-radius: 4px;">
                <h4>🚨 Final Reminder - Location Verification Required!</h4>
                <p>Please ensure you are heading to the hospital. Location verification will be required when you arrive.</p>
                <p>If you cannot make it, please cancel your appointment immediately.</p>
            </div>
            ''' : ''}
            
            <div class="footer">
                <p>This is an automated reminder from Healthcare AppointmentModel System.</p>
                <p>Please do not reply to this email.</p>
            </div>
        </div>
    </body>
    </html>
    ''';

    await sendEmail(
      toEmail: patient['email'],
      toName: patient['full_name'],
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  // Send location verification failed notification
  static Future<void> sendLocationVerificationFailed(int patientUserId, AppointmentModel appointment, double distance) async {
    final dbHelper = DatabaseHelper();
    final patient = await dbHelper.getUserById(patientUserId);
    
    if (patient == null) return;
    
    final hospital = await dbHelper.getHospitalById(appointment.hospitalId);
    
    final subject = 'AppointmentModel Cancelled - Location Verification Failed';
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #dc3545; margin-bottom: 30px; }
            .error-info { background-color: #f8d7da; border-left: 4px solid #dc3545; padding: 15px; margin: 20px 0; border-radius: 4px; }
            .appointment-details { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .label { font-weight: bold; color: #666; }
            .value { color: #333; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>❌ AppointmentModel Cancelled</h1>
                <p>Location verification failed</p>
            </div>
            
            <div class="error-info">
                <h4>Location Verification Failed</h4>
                <p>Your appointment has been automatically cancelled because you were not within the required distance of the hospital.</p>
                <ul>
                    <li><strong>Your distance from hospital:</strong> ${distance.toStringAsFixed(2)} km</li>
                    <li><strong>Maximum allowed distance:</strong> 0.5 km (500 meters)</li>
                </ul>
            </div>
            
            <div class="appointment-details">
                <h3>Cancelled AppointmentModel Details</h3>
                <div class="detail-row">
                    <span class="label">Token:</span>
                    <span class="value">${appointment.token}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Date:</span>
                    <span class="value">${_formatDate(appointment.appointmentDate)}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Time:</span>
                    <span class="value">${appointment.timeSlot}</span>
                </div>
                <div class="detail-row">
                    <span class="label">HospitalModel:</span>
                    <span class="value">${hospital?.name ?? 'Unknown HospitalModel'}</span>
                </div>
            </div>
            
            <div style="background-color: #d1ecf1; border-left: 4px solid #0c5460; padding: 15px; margin: 20px 0; border-radius: 4px;">
                <h4>📞 Next Steps:</h4>
                <ul>
                    <li>Contact the hospital to explain your situation</li>
                    <li>Book a new appointment if needed</li>
                    <li>Ensure you are at the hospital location for future appointments</li>
                </ul>
            </div>
            
            <div class="footer">
                <p>This is an automated message from Healthcare AppointmentModel System.</p>
                <p>For assistance, please contact the hospital directly.</p>
            </div>
        </div>
    </body>
    </html>
    ''';

    await sendEmail(
      toEmail: patient['email'],
      toName: patient['full_name'],
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
