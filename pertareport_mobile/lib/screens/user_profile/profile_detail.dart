import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/user_profile/profile_buyer_entry.dart';
import 'package:pertareport_mobile/models/user_profile/profile_seller_entry.dart';
import 'package:pertareport_mobile/screens/user_profile/edit_profile.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  dynamic profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final request = context.read<CookieRequest>();
    try {
      // Try buyer endpoint
      try {
        final buyerResponse = await request.get('https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/buyer/');
        if (buyerResponse['profile_type'] == 'buyer') {
          profile = ProfileBuyerEntry.fromJson(buyerResponse).profile;
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        // If buyer endpoint fails, continue to try seller endpoint
      }

      // Try seller endpoint
      try {
        final sellerResponse = await request.get('https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/seller/');
        if (sellerResponse['profile_type'] == 'seller') {
          profile = ProfileSellerEntry.fromJson(sellerResponse).profile;
        }
      } catch (e) {
        // Handle seller endpoint error
      }
    } catch (e) {
      // Handle any other errors
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Detail',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Edit Profile Button in AppBar
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(profile: profile),
                ),
              );
              if (result != null) {
                // Refresh the profile data after edit
                await fetchProfile();
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: profile != null ? _buildProfileContent() : _buildErrorContent(),
    );
  }

  Widget _buildProfileContent() {
    return Stack(
      children: [
        // Background gradient
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.6),
              ],
            ),
          ),
        ),

        RefreshIndicator(
          onRefresh: fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Profile Picture with animation
                      Hero(
                        tag: 'profile-picture',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(
                              profile.profilePicture,
                            ),
                            onBackgroundImageError: (exception, stackTrace) {
                              if (kDebugMode) {
                                print('Error loading profile image: $exception');
                              }
                            },
                            child: profile.profilePicture.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User name with animation
                      Text(
                        profile.storeName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        profile.userName,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Information Section
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      if (profile is ProfileSeller) ...[
                        _buildInfoSection(
                          'Store Details',
                          [
                            _buildDetailTile(Icons.location_city, 'City', profile.city),
                            _buildDetailTile(Icons.map, 'Subdistrict', profile.subdistrict),
                            _buildDetailTile(Icons.holiday_village, 'Village', profile.village),
                            _buildDetailTile(Icons.home, 'Address', profile.address),
                            _buildMapTile(profile.maps),
                          ],
                        ),
                      ] else if (profile is ProfileBuyer) ...[
                        _buildInfoSection(
                          'Personal Information',
                          [
                            _buildDetailTile(Icons.public, 'Nationality', profile.nationality),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Unable to load profile',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMapTile(String mapsUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.map, color: Colors.blue),
        ),
        title: const Text('Store Location'),
        subtitle: Text(
          mapsUrl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: () {
          // Implement map opening logic here
        },
      ),
    );
  }
}