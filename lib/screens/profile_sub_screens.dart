import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../components/primary_button.dart';
import '../data/app_data.dart';
import 'package:go_router/go_router.dart';
import '../components/app_back_button.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address.dart';

// ── Edit Profile ──────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _selectedDiet = 'None';
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();

    // First load local stored data
    final user = authProvider.user;
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _birthdayController = TextEditingController(text: user?.birthday ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    if (user?.dietaryPreference != null &&
        user!.dietaryPreference!.isNotEmpty) {
      _selectedDiet = user.dietaryPreference!;
    }

    // Then fetch latest data from API
    await authProvider.fetchUserProfile();

    // Update controllers with fresh API data
    if (mounted) {
      final updatedUser = authProvider.user;
      setState(() {
        _emailController.text = updatedUser?.email ?? '';
        _phoneController.text = updatedUser?.phone ?? '';
        _birthdayController.text = updatedUser?.birthday ?? '';
        _bioController.text = updatedUser?.bio ?? '';
        if (updatedUser?.dietaryPreference != null &&
            updatedUser!.dietaryPreference!.isNotEmpty) {
          _selectedDiet = updatedUser.dietaryPreference!;
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  static const List<String> _avatarAssets = [
    'assets/images/avatars/avatar1.png',
    'assets/images/avatars/avatar2.png',
    'assets/images/avatars/avatar3.png',
    'assets/images/avatars/avatar4.png',
    'assets/images/avatars/avatar5.png',
    'assets/images/avatars/avatar6.png',
    'assets/images/avatars/avatar7.png',
    'assets/images/avatars/avatar8.png',
    'assets/images/avatars/avatar9.png',
    'assets/images/avatars/avatar10.png',
    'assets/images/avatars/avatar11.png',
    'assets/images/avatars/avatar12.png',
    'assets/images/avatars/avatar13.png',
    'assets/images/avatars/avatar14.png',
    'assets/images/avatars/avatar15.png',
  ];

  // Back-compat: earlier code saved paths without the `assets/images/` prefix.
  // Normalize both the old short form and the new full form so stored values
  // keep working.
  static String _resolveAvatarAsset(String stored) {
    if (stored.startsWith('assets/')) return stored;
    if (stored.startsWith('avatars/')) return 'assets/images/$stored';
    return stored;
  }

  Future<void> _showAvatarPicker() async {
    final authProvider = context.read<AuthProvider>();
    final currentAvatar = authProvider.user?.avatar == null
        ? null
        : _resolveAvatarAsset(authProvider.user!.avatar!);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose Avatar',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _avatarAssets.length,
                itemBuilder: (_, i) {
                  final asset = _avatarAssets[i];
                  final selected = asset == currentAvatar;
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await authProvider.updateProfile(avatar: asset);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Theme.of(ctx).colorScheme.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.asset(
                          asset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdayController.text.isNotEmpty
          ? DateTime.parse(_birthdayController.text)
          : DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) async {
    final tempController = TextEditingController(text: controller.text);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $label'),
        content: TextField(
          controller: tempController,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                controller.text = tempController.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: Text('Save',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();

    setState(() => _isSaving = true);

    final success = await authProvider.updateProfile(
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      birthday:
          _birthdayController.text.isEmpty ? null : _birthdayController.text,
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      dietaryPreference: _selectedDiet,
    );

    setState(() => _isSaving = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Profile updated successfully!'
              : 'Failed to update profile'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Edit Profile',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: user?.avatar == null
                                    ? LinearGradient(colors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.tertiary,
                                      ])
                                    : null,
                                borderRadius: BorderRadius.circular(50),
                             
                              ),
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: user?.avatar != null
                                  ? Image.asset(
                                      _resolveAvatarAsset(user!.avatar!),
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                      filterQuality: FilterQuality.high,
                                    )
                                  : Text(user?.initials ?? 'U',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                              color: AppColors.white,
                                              fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Text('Change photo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _FieldLabel('FULL NAME'),
                    _FieldInput(hint: user?.customerName ?? '', enabled: false),
                    const SizedBox(height: 14),
                    _FieldLabel('EMAIL'),
                    _FieldInput(
                        hint: _emailController.text.isEmpty
                            ? 'Not provided'
                            : _emailController.text,
                        enabled: false),
                    const SizedBox(height: 14),
                    _FieldLabel('PHONE'),
                    _FieldInput(
                        hint: _phoneController.text.isEmpty
                            ? 'Not provided'
                            : _phoneController.text,
                        enabled: false),
                    const SizedBox(height: 14),
                    _FieldLabel('BIRTHDAY'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: _FieldInput(
                          hint: _birthdayController.text.isEmpty
                              ? 'Select birthday'
                              : _birthdayController.text,
                          suffixIcon: Icons.calendar_today_outlined),
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel('BIO'),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Leafy Vegetable Lover',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(14),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _FieldLabel('DIETARY PREFERENCE'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppData.dietaryPreferenceOptions.map((d) {
                        final active = d == _selectedDiet;
                        return ChoiceChip(
                          label: Text(d),
                          selected: active,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDiet = d);
                          },
                          backgroundColor: Theme.of(context).dividerColor,
                          selectedColor:
                              Theme.of(context).colorScheme.onSurface,
                          showCheckmark: false,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelStyle: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: active
                                    ? Theme.of(context).colorScheme.onTertiary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontSize: 13,
                              ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: PrimaryButton(
                  label: _isSaving ? 'Saving...' : 'Save Changes',
                  onTap: _isSaving ? null : _saveProfile,
                  isLoading: _isSaving),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontSize: 11, letterSpacing: 0.5)),
    );
  }
}

class _FieldInput extends StatelessWidget {
  final String hint;
  final IconData? suffixIcon;
  final bool isHint;
  final bool enabled;

  const _FieldInput({
    required this.hint,
    this.suffixIcon,
    this.enabled = true,
    this.isHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(hint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
          ),
          if (suffixIcon != null)
            Icon(suffixIcon,
                color: Theme.of(context).colorScheme.outline, size: 18),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _EditableField({
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    required this.keyboardType,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (suffixIcon != null)
            Icon(suffixIcon,
                color: Theme.of(context).colorScheme.outline, size: 18),
        ],
      ),
    );
  }
}

// ── Saved Addresses ──────────────────────────────────────────────────────────

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  void _confirmDelete(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address?'),
        content: Text(
          'Are you sure you want to delete "${address.label}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              context.read<AddressProvider>().removeAddress(address.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Saved Addresses',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AddressProvider>(
                builder: (context, addressProvider, _) {
                  final addresses = addressProvider.addresses;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      ...addresses.map((a) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Theme.of(context).cardColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                a.icon,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text(a.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: a.type == 'Pickup'
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.12)
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    a.type,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: a.type == 'Pickup'
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                a.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 22),
                              onPressed: () => _confirmDelete(context, a),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/profile/addresses/add'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: BorderSide(
                              color: Theme.of(context).dividerColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        icon: Icon(Icons.add_rounded),
                        label: Text('Add New Address',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Methods ──────────────────────────────────────────────────────────

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.chevron_left_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).dividerColor,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      minimumSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Payment Methods',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  // Card
                  _PaymentCard(
                    icon: Icons.credit_card_rounded,
                    label: 'Visa ending in 4289',
                    sub: 'Expires 09/27',
                    isDefault: true,
                  ),
                  const SizedBox(height: 10),
                  _PaymentCard(
                    icon: Icons.apple_rounded,
                    label: 'Apple Pay',
                    sub: 'Express checkout',
                  ),
                  const SizedBox(height: 10),
                  _PaymentCard(
                    icon: Icons.account_balance_rounded,
                    label: 'PayPal',
                    sub: 'sophie@email.com',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: BorderSide(
                          color: Theme.of(context).dividerColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    icon: Icon(Icons.add_rounded),
                    label: Text('Add Payment Method',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isDefault;

  const _PaymentCard(
      {required this.icon,
      required this.label,
      required this.sub,
      this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            sub,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Default',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 11),
                ),
              )
            : null,
      ),
    );
  }
}

// ── Notifications ──────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Notifications',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  _SectionLabel('TODAY'),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    context,
                    icon: Icons.shopping_bag_rounded,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Order Ready for Pickup',
                    message:
                        'Your order #BAK-1942 is freshly baked and ready to be picked up at the store.',
                    time: '10m ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    context,
                    icon: Icons.cake_rounded,
                    iconColor: Theme.of(context).colorScheme.tertiary,
                    title: 'New Seasonal Item',
                    message:
                        'Our seasonal strawberry is back for a limited time! 🍓',
                    time: '2h ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('THIS WEEK'),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    context,
                    icon: Icons.stars_rounded,
                    iconColor: AppColors.golden,
                    title: 'Points Earned!',
                    message:
                        'You earned 50 loyalty points from your last order. You now have 320 points.',
                    time: '1d ago',
                    isUnread: false,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    context,
                    icon: Icons.local_offer_rounded,
                    iconColor: Theme.of(context).colorScheme.secondary,
                    title: 'Weekend Promo',
                    message:
                        'Get 20% off all whole cakes this weekend. Use code SWEET20 at checkout.',
                    time: '3d ago',
                    isUnread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Add New Address ──────────────────────────────────────────────────────────

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  String _selectedType = 'Delivery';
  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.business_outlined,
    Icons.store_outlined,
    Icons.restaurant_outlined,
    Icons.factory_outlined,
  ];
  IconData _selectedIcon = Icons.home_outlined;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: AppData.nextId,
        label: _labelController.text.trim(),
        address:
            '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_postcodeController.text.trim()}',
        icon: _selectedIcon,
        type: _selectedType,
      );

      context.read<AddressProvider>().addAddress(address);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('New Address',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map placeholder
                      // Container(
                      //   height: 180,
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).dividerColor,
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   alignment: Alignment.center,
                      //   child: Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Text('🗺️', style: TextStyle(fontSize: 40)),
                      //       const SizedBox(height: 8),
                      //       Text('Tap to set location',
                      //           style: Theme.of(context).textTheme.bodySmall),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      _buildLbl(context, 'LABEL'),
                      _buildTextField(
                        context,
                        controller: _labelController,
                        hint: 'e.g. Home, Office',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a label';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLbl(context, 'STREET ADDRESS'),
                      _buildTextField(
                        context,
                        controller: _addressController,
                        hint: '123 Bakery Street',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLbl(context, 'CITY'),
                      _buildTextField(
                        context,
                        controller: _cityController,
                        hint: 'London',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLbl(context, 'POSTCODE'),
                      _buildTextField(
                        context,
                        controller: _postcodeController,
                        hint: 'W1F 0TH',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter postcode';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLbl(context, 'ADDRESS TYPE'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeButton(
                              label: 'Delivery',
                              isSelected: _selectedType == 'Delivery',
                              onTap: () =>
                                  setState(() => _selectedType = 'Delivery'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeButton(
                              label: 'Pickup',
                              isSelected: _selectedType == 'Pickup',
                              onTap: () =>
                                  setState(() => _selectedType = 'Pickup'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildLbl(context, 'SELECT ICON'),
                      const SizedBox(height: 8),
                      Row(
                        children: _icons
                            .map(
                              (icon) => Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedIcon = icon),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedIcon == icon
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.15)
                                          : Theme.of(context).dividerColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedIcon == icon
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      icon,
                                      size: 24,
                                      color: _selectedIcon == icon
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: PrimaryButton(label: 'Save Address', onTap: _saveAddress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLbl(BuildContext context, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontSize: 11, letterSpacing: 0.5)));

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      );
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                )),
      ),
    );
  }
}

// ── Shared private ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(letterSpacing: 1, fontSize: 11));
  }
}
