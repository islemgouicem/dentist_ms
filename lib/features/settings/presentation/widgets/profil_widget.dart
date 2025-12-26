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

Widget profil(BuildContext context, double width, double height, ProfilControllers controllers) {
  return ProfilWidget(width: width, height: height, controllers: controllers);
}

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
  
  static final Map<String, Uint8List> _imageCache = {};

  Future<String> saveImageLocally(dynamic imageFile, int userId) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    
    // Create user-specific directory
    final String userProfileDir = path.join(
      appDir.path, 
      'profile_pictures', 
      'user_$userId'
    );
      
    final Directory dir = Directory(userProfileDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }


    // Clean up old profile pictures for this user (keep only one)
    await _cleanupOldProfilePictures(userProfileDir);
    
    // Create unique filename with timestamp
    final String uniqueFileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = path.join(userProfileDir, uniqueFileName);
    

    if (imageFile is File) {
      await imageFile.copy(localPath);
    } else if (imageFile is Uint8List) {
      await File(localPath).writeAsBytes(imageFile);
    }
    
    // Cache the image
    if (imageFile is File) {
      final bytes = await imageFile.readAsBytes();
      _imageCache[localPath] = bytes;
    } else if (imageFile is Uint8List) {
      _imageCache[localPath] = imageFile;
    }
    
    return localPath;
  }
  Future<void> _cleanupOldProfilePictures(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old profile pictures: $e');
    }
  }
  Future<String?> getUserProfilePicturePath(int userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      final String userProfileDir = path.join(
        appDir.path, 
        'profile_pictures', 
        'user_$userId'
      );
      
      
      final Directory dir = Directory(userProfileDir);
      if (!await dir.exists()) {
        return null;
      }
      
    final files = await dir.list().where((file) => file is File).toList();
    
    if (files.isEmpty) {
      return null;
    }
    
    // Get the most recent file
    File? latestFile;
    DateTime? latestModified;
    
    for (final file in files) {
      if (file is File) {
        try {
          final stat = await file.stat();
          if (latestModified == null || stat.modified.isAfter(latestModified)) {
            latestModified = stat.modified;
            latestFile = file;
          }
        } catch (e) {
          print('⚠️ Error reading file ${file.path}: $e');
        }
      }
    }
    
    if (latestFile != null) {
      return latestFile.path;
    } else {
      return null;
    }
    
  } catch (e) {
    return null;
  }
}
  Future<Uint8List?> getProfileImage(int userId) async {
    try {
      final imagePath = await getUserProfilePicturePath(userId);
      if (imagePath == null) return null;
      
      // Check cache first
      if (_imageCache.containsKey(imagePath)) {
        return _imageCache[imagePath];
      }
      
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _imageCache[imagePath] = bytes;
        return bytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  void updateControllersFromSetting(Setting setting) async {
    if (_initialized) return;
    
    _initialized = true;
    firstNameController.text = setting.firstName ?? '';
    lastNameController.text = setting.lastName ?? '';
    emailController.text = setting.email ?? '';
    phoneController.text = setting.phone ?? '';
    specializationController.text = setting.specialization ?? '';
    licenseNumberController.text = setting.identificationNumber?.toString() ?? '';
    bioController.text = setting.bio ?? '';
    
    
    // Always try to load from Documents folder first
    if (setting.id != null) {
      try {
        final imageBytes = await getProfileImage(setting.id!);
        
        if (imageBytes != null) {
          selectedImage = imageBytes;
          
          // Update the path
          final imagePath = await getUserProfilePicturePath(setting.id!);
          if (imagePath != null) {
            profilePhotoPath = imagePath;
          }
        } else {
          
          // Check old path from database as fallback
          if (setting.profilePhotoPath != null && setting.profilePhotoPath!.isNotEmpty) {
            final oldFile = File(setting.profilePhotoPath!);
            if (await oldFile.exists()) {
              final bytes = await oldFile.readAsBytes();
              selectedImage = bytes;
              profilePhotoPath = setting.profilePhotoPath!;
              
              // Migrate to new location in Documents folder
              final newPath = await saveImageLocally(oldFile, setting.id!);
              profilePhotoPath = newPath;
            }
          }
        }
      } catch (e) {
        print('❌ Error loading profile image: $e');
      }
    }
  }
  Future<void> loadProfileImage(int userId) async {
    try {
      
      final imageBytes = await getProfileImage(userId);
      
      if (imageBytes != null) {
        selectedImage = imageBytes;
        
        // Also get the path
        final imagePath = await getUserProfilePicturePath(userId);
        if (imagePath != null) {
          profilePhotoPath = imagePath;
        }
      } else {
        selectedImage = null;
      }
    } catch (e) {
      selectedImage = null;
    }
  }
  Future<void> saveProfileImage(File image, int userId, BuildContext context) async {
    try {
      // Save image locally with user ID
      final String localPath = await saveImageLocally(image, userId);
      
      // Update local state
      profilePhotoPath = localPath;
      selectedImage = await image.readAsBytes();
      
      // Clear the initialized flag to force reload on next navigation
      _initialized = false;
      
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
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
      profilePhotoPath: profilePhotoPath,
    );
  }
}

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
  int? _currentUserId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state is SettingsOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
       
        if (state is SettingsInitial) {
          Future.microtask(() {
            var userId = 1;
            _currentUserId = userId;
            context.read<SettingBloc>().add(LoadUser(userId));
            widget.controllers.loadProfileImage(_currentUserId!).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          });
        }

        if (state is SettingsLoadSuccess && state.users.isNotEmpty) {
          final user = state.users.first;
          _currentUserId = user.id;
          widget.controllers.updateControllersFromSetting(user);
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
                Text("Informations personnelles", 
                    style: Theme.of(context).textTheme.titleLarge!),
                SizedBox(height: widget.height * 0.03),
                
                // Profile photo section
                _buildProfilePhotoSection(context),
                
                SizedBox(height: widget.height * 0.04),
                
                if (state is SettingsLoadInProgress)
                  const Center(child: CircularProgressIndicator()),
                
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
                
                _buildUpdateButton(context, state, _currentUserId!),
              ],
            ),
          ),
        );
      },
    );
  }

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
              Text("JPG, PNG ou GIF. Taille maximale: 2Mo.", 
                  style: AppTextStyles.subtitle1)
            ],
          ),
        )
      ],
    );
  }
  Widget _buildProfileAvatar() {

    if (widget.controllers.profilePhotoPath.isNotEmpty) {
      return FutureBuilder<File?>(
        future: Future(() async {
          try {
            final file = File(widget.controllers.profilePhotoPath);
            if (await file.exists()) {
              return file;
            }
            return null;
          } catch (e) {
            return null;
          }
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return CircleAvatar(
              radius: widget.width * 0.04,
              backgroundColor: Colors.blue[100],
              backgroundImage: FileImage(snapshot.data!),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              radius: widget.width * 0.04,
              backgroundColor: Colors.grey[200],
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else {
            return _buildDefaultAvatar();
          }
        },
      );
    } 
    else {
      return _buildDefaultAvatar();
    }
  }
  Widget _buildDefaultAvatar() {

    return CircleAvatar(
      radius: widget.width * 0.04,
      backgroundColor: Colors.blue[100],
      child: Icon(
        Icons.person,
        size: widget.width * 0.04,
        color: Colors.blue[600],
      ),
    );
  }
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
  Widget _buildUpdateButton(BuildContext context, SettingState state, int id) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is SettingsLoadInProgress 
            ? null 
            : () {
                var userId = id;
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

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        await _handlePickedImage(File(image.path), context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _handlePickedImage(File image, BuildContext context) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show saving indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sauvegarde de la photo...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Save the image with user ID
      await widget.controllers.saveProfileImage(image, _currentUserId!, context);
      
      // Update the UI immediately
      if (mounted) {
        setState(() {});
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo sauvegardée avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Trigger a reload of user data to ensure consistency
      if (_currentUserId != null && mounted) {
        context.read<SettingBloc>().add(LoadUser(_currentUserId!));
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
