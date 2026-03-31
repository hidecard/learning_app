import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'activation_key_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(() {
        final currentUser = authController.currentUser.value;
        if (currentUser == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
            ),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(currentUser),
              const SizedBox(height: 20),
              _buildMenuItems(context, currentUser),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(currentUser) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00C2FF), const Color(0xFF007BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Avatar with modern styling
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // User Name with better typography
              Text(
                currentUser.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Email with subtle styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  currentUser.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Premium Status with enhanced styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: currentUser.isPremium 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: currentUser.isPremium ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentUser.isPremium ? Icons.verified : Icons.lock,
                      size: 18,
                      color: currentUser.isPremium 
                          ? const Color(0xFF00C2FF) 
                          : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentUser.isPremium ? 'Premium Member' : 'Free Plan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: currentUser.isPremium 
                            ? const Color(0xFF00C2FF) 
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Courses',
              '12',
              Icons.school,
              const Color(0xFF00C2FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Completed',
              '8',
              Icons.check_circle,
              const Color(0xFF007BFF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Certificates',
              '5',
              Icons.card_membership,
              const Color(0xFF1A4BCC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C4852),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C4852).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, currentUser) {
    final authController = Get.find<AuthController>();
    final menuItems = [
      {'icon': Icons.person, 'title': 'Edit Profile', 'color': const Color(0xFF00C2FF)},
      {'icon': Icons.vpn_key, 'title': 'Activation Key', 'color': const Color(0xFF007BFF)},
      {'icon': Icons.info, 'title': 'About', 'color': const Color(0xFF007BFF)},
      {'icon': Icons.logout, 'title': 'Logout', 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: menuItems.map((item) {
            final isLast = menuItems.last == item;
            return _buildMenuItem(
              context,
              item['icon'] as IconData,
              item['title'] as String,
              item['color'] as Color,
              isLast,
              currentUser,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color color, bool isLast, currentUser) {
    final authController = Get.find<AuthController>();
    
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Edit Profile':
            Get.to(() => const EditProfileScreen());
            break;
          case 'Activation Key':
            Get.to(() => const ActivationKeyScreen());
            break;
          case 'About':
            Get.to(() => const AboutScreen());
            break;
          case 'Logout':
            _showLogoutDialog(context, authController);
            break;
        }
      },
      borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(20)) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4852),
                ),
              ),
            ),
            // Show activation key status if user has one
            if (title == 'Activation Key' && currentUser.activationKey != null && currentUser.activationKey!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF3C4852).withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
