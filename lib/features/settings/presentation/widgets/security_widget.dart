import 'package:dentist_ms/features/settings/bloc/setting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/settings/bloc/setting_bloc.dart';
import 'package:dentist_ms/features/settings/bloc/setting_event.dart';

Widget security(BuildContext context, double width, double height, SecurityControllers controllers){  
  return BlocConsumer<SettingBloc, SettingState>(
    listener: (context, state) {
      // Handle password change success
      if (state is SettingsLoadSuccess && controllers.currentPasswordController.text.isNotEmpty) {
        _handleSuccess(context, controllers, 'Mot de passe changé avec succès!');
      }
      
      // Handle errors
      if (state is SettingsOperationFailure) {
        _showErrorSnackBar(context, state.message);
      }
    },
    builder: (context, state) {
      final isLoading = state is SettingsLoadInProgress;
      
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
              _buildSaveButton(context, controllers, width, isLoading),
            ],
          ),
        )
      );
    },
  );
}

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
Widget _buildSaveButton(BuildContext context, SecurityControllers controllers, double width, bool isLoading) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : () {
        _handlePasswordChange(context, controllers);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading 
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text("Sauvegarder le mot de passe", style: AppTextStyles.bodyWhite),
    ),
  );
}

void _handlePasswordChange(BuildContext context, SecurityControllers controllers) async {
  final currentPassword = controllers.currentPasswordController.text;
  final newPassword = controllers.newPasswordController.text;
  final confirmPassword = controllers.confirmPasswordController.text;

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

  var userId = 1;
  
  context.read<SettingBloc>().add(ChangePassword(
    userId: userId,
    currentPassword: currentPassword,
    newPassword: newPassword,
  ));
}
void _handleSuccess(BuildContext context, SecurityControllers controllers, String message) {
  controllers.currentPasswordController.clear();
  controllers.newPasswordController.clear();
  controllers.confirmPasswordController.clear();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
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