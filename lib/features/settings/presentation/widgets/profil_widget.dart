import 'dart:typed_data';
import 'package:dentist_ms/features/settings/bloc/setting_bloc.dart';
import 'package:dentist_ms/features/settings/bloc/setting_event.dart';
import 'package:dentist_ms/features/settings/bloc/setting_state.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilControllers {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  
  String profilePhotoPath = '';
  Uint8List? selectedImage;
  bool _initialized = false;

  // Add this method to save image locally
  Future<String> saveImageLocally(dynamic imageFile, String fileName) async {
    if (kIsWeb) {
      // Web: Use pseudo-path and store in memory/browser storage
      return 'web_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    } else {
      // Desktop: Actual file system storage
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profilePicsDir = path.join(appDir.path, 'profile_pictures');
      
      final Directory dir = Directory(profilePicsDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String localPath = path.join(profilePicsDir, uniqueFileName);
      
      if (imageFile is File) {
        await imageFile.copy(localPath);
      } else if (imageFile is Uint8List) {
        // If we have bytes instead of File
        await File(localPath).writeAsBytes(imageFile);
      }
      
      return localPath;
    }
  }
  // Method to get image file from local path
  Future<File?> getLocalImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update the updateControllersFromSetting to handle local images
  void updateControllersFromSetting(Setting setting) {
    if (_initialized) return;
    
    _initialized = true;
    firstNameController.text = setting.firstName ?? '';
    lastNameController.text = setting.lastName ?? '';
    emailController.text = setting.email ?? '';
    phoneController.text = setting.phone ?? '';
    specializationController.text = setting.specialization ?? '';
    licenseNumberController.text = setting.identificationNumber?.toString() ?? '';
    bioController.text = setting.bio ?? '';
    profilePhotoPath = setting.profilePhotoPath ?? '';
    
    // Load the local image if path exists
    if (profilePhotoPath.isNotEmpty) {
      _loadLocalImage(profilePhotoPath);
    }
  }

  // Helper method to load local image into memory
  Future<void> _loadLocalImage(String filePath) async {
    try {
      final file = await getLocalImageFile(filePath);
      if (file != null) {
        final imageBytes = await file.readAsBytes();
        selectedImage = imageBytes;
      }
    } catch (e) {
    }
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    licenseNumberController.dispose();
    bioController.dispose();
  }

  Setting toSetting({required int userId}) {
    return Setting(
      id: userId,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneController.text,
      specialization: specializationController.text,
      identificationNumber: licenseNumberController.text,
      bio: bioController.text,
      profilePhotoPath: profilePhotoPath, // This now contains local file path
    );
  }
}
// Stateful widget to handle image updates
class ProfilWidget extends StatefulWidget {
  final double width;
  final double height;
  final ProfilControllers controllers;

  const ProfilWidget({
    super.key,
    required this.width,
    required this.height,
    required this.controllers,
  });

  @override
  State<ProfilWidget> createState() => _ProfilWidgetState();
}

class _ProfilWidgetState extends State<ProfilWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingBloc, SettingState>(
      listener: (context, state) {
        // Only handle failures - remove the success state check
        if (state is SettingsOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        // Load data only once when initializing
        if (state is SettingsInitial) {
          Future.microtask(() {
            const userId = 1;
            context.read<SettingBloc>().add(LoadUser(userId));
          });
        }

        // Update controllers when data is loaded
        if (state is SettingsLoadSuccess && state.users.isNotEmpty) {
          widget.controllers.updateControllersFromSetting(state.users.first);
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.height * 0.02, 
              horizontal: widget.width * 0.03
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Informations personnelles", style: Theme.of(context).textTheme.titleLarge!),
                SizedBox(height: widget.height * 0.03),
                
                // Profile photo section
                _buildProfilePhotoSection(context),
                
                SizedBox(height: widget.height * 0.04),
                
                // Show loading indicator only when loading
                if (state is SettingsLoadInProgress)
                  const Center(child: CircularProgressIndicator()),
                
                // Show form fields when not loading
                if (state is! SettingsLoadInProgress)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return _buildVerticalFields(context);
                      } else {
                        return _buildHorizontalFields(context);
                      }
                    },
                  ),
                
                SizedBox(height: widget.height * 0.04),
                
                // Update button
                _buildUpdateButton(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  // Profile photo section
  Widget _buildProfilePhotoSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Profile avatar
        _buildProfileAvatar(),
        SizedBox(width: widget.width * 0.02),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(context), 
                child: Text("Changer la photo")
              ),
              SizedBox(height: widget.height * 0.01),
              Text("JPG, PNG ou GIF. Taille maximale: 2Mo.", style: AppTextStyles.subtitle1)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfileAvatar() {
    if (widget.controllers.selectedImage != null) {
      // Show image from memory (recently picked - works for both web and mobile)
      return CircleAvatar(
        radius: widget.width * 0.04,
        backgroundImage: MemoryImage(widget.controllers.selectedImage!),
      );
    } else if (widget.controllers.profilePhotoPath.isNotEmpty && !kIsWeb) {
      // For mobile: Show image from local file path
      return FutureBuilder<File?>(
        future: widget.controllers.getLocalImageFile(widget.controllers.profilePhotoPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return CircleAvatar(
              radius: widget.width * 0.04,
              backgroundColor: Colors.blue[100],
              backgroundImage: FileImage(snapshot.data!),
            );
          } else {
            return _buildDefaultAvatar();
          }
        },
      );
    } else {
      // For web or no image
      return _buildDefaultAvatar();
    }
  }
  // Helper method for default avatar
  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: widget.width * 0.04,
      backgroundColor: Colors.blue[100],
      child: Icon(Icons.person, color: Colors.blue[600]),
    );
  }

  // Horizontal layout for larger screens
  Widget _buildHorizontalFields(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField('Prénom', widget.controllers.firstNameController)),
            SizedBox(width: widget.width * 0.02),
            Expanded(child: _buildField('Nom', widget.controllers.lastNameController)),
          ],
        ),
        SizedBox(height: widget.height * 0.02),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField('Email', widget.controllers.emailController)),
            SizedBox(width: widget.width * 0.02),
            Expanded(child: _buildField('Téléphone', widget.controllers.phoneController, TextInputType.phone)),
          ],
        ),
        SizedBox(height: widget.height * 0.02),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildField('Spécialisation', widget.controllers.specializationController)),
            SizedBox(width: widget.width * 0.02),
            Expanded(child: _buildField("Numéro d'identification", widget.controllers.licenseNumberController, TextInputType.number)),
          ],
        ),
        SizedBox(height: widget.height * 0.02),
        
        _buildFullWidthField('Bio', widget.controllers.bioController, maxLines: 5),
      ],
    );
  }

  // Vertical layout for small screens
  Widget _buildVerticalFields(BuildContext context) {
    return Column(
      children: [
        _buildField('Prénom', widget.controllers.firstNameController),
        SizedBox(height: widget.height * 0.02),
        _buildField('Nom', widget.controllers.lastNameController),
        SizedBox(height: widget.height * 0.02),
        _buildField('Email', widget.controllers.emailController),
        SizedBox(height: widget.height * 0.02),
        _buildField('Téléphone', widget.controllers.phoneController, TextInputType.phone),
        SizedBox(height: widget.height * 0.02),
        _buildField('Spécialisation', widget.controllers.specializationController),
        SizedBox(height: widget.height * 0.02),
        _buildField("Numéro d'identification", widget.controllers.licenseNumberController, TextInputType.number),
        SizedBox(height: widget.height * 0.02),
        _buildFullWidthField('Bio', widget.controllers.bioController, maxLines: 5),
      ],
    );
  }

  // Helper method for regular fields
  Widget _buildField(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.title),
        SizedBox(height: widget.height * 0.01),
        SizedBox(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for full width fields
  Widget _buildFullWidthField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.title),
        SizedBox(height: widget.height * 0.01),
        SizedBox(
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  // Update button
  Widget _buildUpdateButton(BuildContext context, SettingState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is SettingsLoadInProgress 
            ? null 
            : () {
                const userId = 1;
                final updatedUser = widget.controllers.toSetting(userId: userId);
                                
                context.read<SettingBloc>().add(UpdateUser(updatedUser));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
        child: state is SettingsLoadInProgress
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text("Mettre à jour le profil", style: AppTextStyles.bodyWhite),
      ),
    );
  }

  // Image picking method
  // Update _pickImage method to handle web properly
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final BuildContext localContext = context;
    
    showModalBottomSheet(
      context: localContext,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null && mounted) {
                    // For web, we need to convert XFile to bytes first
                    if (kIsWeb) {
                      final bytes = await image.readAsBytes();
                      _handlePickedImageWeb(bytes, localContext);
                    } else {
                      _handlePickedImage(File(image.path), localContext);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null && mounted) {
                    if (kIsWeb) {
                      final bytes = await image.readAsBytes();
                      _handlePickedImageWeb(bytes, localContext);
                    } else {
                      _handlePickedImage(File(image.path), localContext);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Separate method for web image handling
Future<void> _handlePickedImageWeb(Uint8List imageBytes, BuildContext context) async {
  final BuildContext localContext = context;
  
  try {
    if (mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
          content: Text('Sauvegarde de la photo...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // For web, save using the web-compatible method
    final String localPath = await widget.controllers.saveImageLocally(
      imageBytes, 
      'profile_photo.jpg'
    );
    
    // Update the profile photo path
    widget.controllers.profilePhotoPath = localPath;
    widget.controllers.selectedImage = imageBytes;
    
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(localContext).showSnackBar(
      const SnackBar(
        content: Text('✅ Photo sauvegardée!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    setState(() {
    });
    
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  // Handle picked image
  // Handle picked image - SUPER SIMPLE VERSION
 Future<void> _handlePickedImage(File image, BuildContext context) async {
    // Store context in a local variable before any async operations
    final BuildContext localContext = context;
    
    try {
      
      // Show loading indicator using the local context
      if (mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          const SnackBar(
            content: Text('Sauvegarde de la photo...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Save image locally
      final String localPath = await widget.controllers.saveImageLocally(
        image, 
        'profile_photo.jpg'
      );
      
      // Update the profile photo path
      widget.controllers.profilePhotoPath = localPath;
      
      // Load image into memory for display
      final imageBytes = await image.readAsBytes();
      widget.controllers.selectedImage = imageBytes;
      
      
      // Check if widget is still mounted before updating UI
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
          content: Text('✅ Photo sauvegardée localement!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Force UI update
      setState(() {
      });
      
    } catch (e) {
      
      // Check if widget is still mounted before showing error
      if (mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Main profil function
Widget profil(BuildContext context, double width, double height, ProfilControllers controllers) {
  return ProfilWidget(width: width, height: height, controllers: controllers);
}
