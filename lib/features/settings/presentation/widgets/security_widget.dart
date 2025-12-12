import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a class to hold all the security controllers
class SecurityControllers {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}

Widget security(BuildContext context, double width, double height, SecurityControllers controllers){  
  return Card(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Changer le mot de passe", style: Theme.of(context).textTheme.titleLarge!),
          SizedBox(height: height * 0.03),
          
          // Responsive layout for password fields and image
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildVerticalLayout(controllers, width, height);
              } else {
                return _buildHorizontalLayout(controllers, width, height);
              }
            },
          ),
          
          SizedBox(height: height * 0.05),
          
          // Save button - always full width
          _buildSaveButton(context, controllers, width),
        ],
      ),
    )
  );
}

// Layout methods
Widget _buildVerticalLayout(SecurityControllers controllers, double width, double height) {
  return Column(
    children: [
      _buildPasswordFields(controllers, height),
      SizedBox(height: height * 0.03),
      _buildSecurityImage(width, height),
    ],
  );
}

Widget _buildHorizontalLayout(SecurityControllers controllers, double width, double height) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 3, child: _buildPasswordFields(controllers, height)),
      SizedBox(width: width * 0.05),
      Expanded(flex: 2, child: _buildSecurityImage(width, height)),
    ],
  );
}

Widget _buildPasswordFields(SecurityControllers controllers, double height) {
  return Column(
    children: [
      _buildPasswordField('Mot de passe actuel', controllers.currentPasswordController, height),
      SizedBox(height: height * 0.02),
      _buildPasswordField('Nouveau mot de passe', controllers.newPasswordController, height),
      SizedBox(height: height * 0.02),
      _buildPasswordField('Confirmer le nouveau mot de passe', controllers.confirmPasswordController, height),
    ],
  );
}

// Helper method for password fields
Widget _buildPasswordField(String label, TextEditingController controller, double height) {
  bool isObscure = true;
  
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.title),
          SizedBox(height: height * 0.01),
          TextFormField(
            controller: controller,
            obscureText: isObscure,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Helper method for security image (keep your existing implementation)
Widget _buildSecurityImage(double width, double height) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/security.png",
          width: width * 0.3,
          height: height * 0.2,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width * 0.3,
              height: height * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 50, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text("Security Image", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          },
        ),
        SizedBox(height: height * 0.01),
        Text("Sécurité de votre compte", style: AppTextStyles.subtitle1, textAlign: TextAlign.center),
      ],
    ),
  );
}

// Helper method for save button
Widget _buildSaveButton(BuildContext context, SecurityControllers controllers, double width) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        _handlePasswordChange(context, controllers);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text("Sauvegarder le mot de passe", style: AppTextStyles.bodyWhite),
    ),
  );
}

// REAL PASSWORD CHANGE LOGIC
void _handlePasswordChange(BuildContext context, SecurityControllers controllers) async {
  final currentPassword = controllers.currentPasswordController.text;
  final newPassword = controllers.newPasswordController.text;
  final confirmPassword = controllers.confirmPasswordController.text;

  // Validation
  if (currentPassword.isEmpty) {
    _showErrorSnackBar(context, "Veuillez entrer votre mot de passe actuel");
    return;
  }

  if (newPassword.isEmpty) {
    _showErrorSnackBar(context, "Veuillez entrer un nouveau mot de passe");
    return;
  }

  if (newPassword.length < 6) {
    _showErrorSnackBar(context, "Le mot de passe doit contenir au moins 6 caractères");
    return;
  }

  if (newPassword != confirmPassword) {
    _showErrorSnackBar(context, "Les mots de passe ne correspondent pas");
    return;
  }

  if (currentPassword == newPassword) {
    _showErrorSnackBar(context, "Le nouveau mot de passe doit être différent de l'ancien");
    return;
  }

  // REAL PASSWORD CHANGE
  await _changePassword(context, currentPassword, newPassword, controllers);
}

// REAL PASSWORD CHANGE IMPLEMENTATION
// SIMPLE PASSWORD CHANGE WITHOUT AUTH
Future<void> _changePassword(BuildContext context, String currentPassword, String newPassword, SecurityControllers controllers) async {
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final supabase = Supabase.instance.client;
    
    // Use default user ID (assuming you have user with ID 1)
    const userId = 1;
    
    // Simple password verification
    // For testing, you can hardcode a check
    const defaultPassword = 'admin123'; // Your default password
    
    if (currentPassword != defaultPassword) {
      throw Exception('Mot de passe actuel incorrect');
    }
    
    // Create a simple hash for the new password
    final newHash = _createSimpleHash(newPassword);
    
    // Update in users table
    await supabase
        .from('users')
        .update({
          'password_hash': newHash,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    
    _handleSuccess(context, controllers, 'Mot de passe changé avec succès!');

  } catch (e) {
    Navigator.pop(context); // Remove loading
    _showErrorSnackBar(context, "Erreur: ${e.toString()}");
  }
}

// Simple hash for demonstration
String _createSimpleHash(String password) {
  return 'hash_${password}_${DateTime.now().millisecondsSinceEpoch}';
}
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}
void _handleSuccess(BuildContext context, SecurityControllers controllers, String message) {
  Navigator.pop(context); // Remove loading
  _showSuccessSnackBar(context, message);
  
  // Clear fields
  controllers.currentPasswordController.clear();
  controllers.newPasswordController.clear();
  controllers.confirmPasswordController.clear();
  
}
void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}