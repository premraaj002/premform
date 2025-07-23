import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/form_model.dart';

class FormShareScreen extends StatefulWidget {
  final FormModel form;

  const FormShareScreen({Key? key, required this.form}) : super(key: key);

  @override
  _FormShareScreenState createState() => _FormShareScreenState();
}

class _FormShareScreenState extends State<FormShareScreen> {
  late String _webUrl;
  late String _appUrl;
  bool _isPublic = true;
  bool _allowAnonymous = true;
  bool _collectEmails = false;

  @override
  void initState() {
    super.initState();
    _webUrl = 'https://yourapp.com/forms/${widget.form.id}';
    _appUrl = 'formsapp://form/${widget.form.id}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Share Form'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormInfo(),
            SizedBox(height: 32),
            _buildSharingSettings(),
            SizedBox(height: 32),
            _buildLinkSharing(),
            SizedBox(height: 32),
            _buildQRCode(),
            SizedBox(height: 32),
            _buildSocialSharing(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInfo() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.description,
              color: Color(0xFF6366F1),
              size: 32,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.form.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.form.fields.length} questions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.form.isPublished 
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.form.isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      color: widget.form.isPublished 
                          ? Color(0xFF10B981) 
                          : Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingSettings() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'Sharing Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSettingTile(
            'Public Access',
            'Anyone with the link can access this form',
            Icons.public,
            _isPublic,
            (value) => setState(() => _isPublic = value),
          ),
          _buildSettingTile(
            'Allow Anonymous Responses',
            'Users can submit without signing in',
            Icons.person_off,
            _allowAnonymous,
            (value) => setState(() => _allowAnonymous = value),
          ),
          _buildSettingTile(
            'Collect Email Addresses',
            'Require email for form submission',
            Icons.email,
            _collectEmails,
            (value) => setState(() => _collectEmails = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF6366F1), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSharing() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'Share Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildLinkTile(
            'Web Link',
            'Open in browser',
            _webUrl,
            Icons.web,
            Color(0xFF3B82F6),
          ),
          SizedBox(height: 16),
          _buildLinkTile(
            'App Link',
            'Open in mobile app',
            _appUrl,
            Icons.phone_android,
            Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(String title, String subtitle, String url, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(url),
                  icon: Icon(Icons.copy, size: 18, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  'QR Code',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Coming Soon',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement QR code download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QR Code download coming soon!')),
              );
            },
            icon: Icon(Icons.download),
            label: Text('Download QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSharing() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.share, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'Share on Social Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton('WhatsApp', Icons.message, Color(0xFF25D366)),
              _buildSocialButton('Email', Icons.email, Color(0xFF3B82F6)),
              _buildSocialButton('Twitter', Icons.share, Color(0xFF1DA1F2)),
              _buildSocialButton('More', Icons.more_horiz, Color(0xFF6B7280)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () => _shareVia(label),
            icon: Icon(icon, color: color),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Link copied to clipboard!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareVia(String platform) {
    final text = 'Check out this form: ${widget.form.title} - $_webUrl';
    
    switch (platform) {
      case 'WhatsApp':
        _launchUrl('https://wa.me/?text=${Uri.encodeComponent(text)}');
        break;
      case 'Email':
        _launchUrl('mailto:?subject=${Uri.encodeComponent(widget.form.title)}&body=${Uri.encodeComponent(text)}');
        break;
      case 'Twitter':
        _launchUrl('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}');
        break;
      case 'More':
        // Use Flutter's native share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('More sharing options coming soon!')),
        );
        break;
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
