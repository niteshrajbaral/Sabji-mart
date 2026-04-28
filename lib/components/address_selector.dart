import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/address.dart';
import '../data/app_data.dart';

/// Address selector row in multiple variants.
enum AddressSelectorVariant { header, compact, full }

class AddressSelector extends StatelessWidget {
  final int selectedId;
  final VoidCallback onTap;
  final AddressSelectorVariant variant;

  const AddressSelector({
    super.key,
    required this.selectedId,
    required this.onTap,
    this.variant = AddressSelectorVariant.full,
  });

  Address get _address => AppData.savedAddresses.firstWhere(
        (a) => a.id == selectedId,
        orElse: () => AppData.savedAddresses.first,
      );

  @override
  Widget build(BuildContext context) {
    final addr = _address;
    final isHeader = variant == AddressSelectorVariant.header;
    final isCompact = variant == AddressSelectorVariant.compact;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
            : isHeader
                ? const EdgeInsets.symmetric(vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isCompact
            ? BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.beige),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isHeader) ...[
              Container(
                width: isCompact ? 32 : 34,
                height: isCompact ? 32 : 34,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('📍', style: TextStyle(fontSize: 14)),
              ),
              SizedBox(width: isCompact ? 8 : 10),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  if (isHeader)
                  // Padding(padding: EdgeInsetsGeometry.only(left: 20),
                    // alignment: FractionalOffset(0.2,1),
                    // child: 
                    Text(
                      'Deliver to ✦',
                      style: AppTextStyles.caption.copyWith(letterSpacing: 0.3,
                    
                      ),
                    ),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHeader) ...[
                        const Text('📍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          isHeader ? addr.address.split(',').first : addr.label,
                          style: isHeader
                              ? AppTextStyles.headlineSmall
                                  .copyWith(fontSize: 16)
                              : AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isCompact ? 13 : 14,
                                ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isHeader) ...[
                        const SizedBox(width: 6),
                        _typeBadge(addr.type),
                      ],
                    ],
                  ),
                  if (!isHeader)
                    Text(
                      addr.address,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.softBrown,
              size: isHeader ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final isPickup = type == 'Pickup';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isPickup
            ? AppColors.sage.withValues(alpha: 0.13)
            : AppColors.golden.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        type,
        style: AppTextStyles.caption.copyWith(
          color: isPickup ? AppColors.sage : AppColors.softBrown,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Modal bottom sheet to select an address.
class AddressBottomSheet extends StatelessWidget {
  final int selectedId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddNew;

  const AddressBottomSheet({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select Address',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            ...AppData.savedAddresses.map((addr) {
            final isSelected = addr.id == selectedId;
            return GestureDetector(
              onTap: () {
                onSelect(addr.id);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.beige : AppColors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.darkBrown : AppColors.beige,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkBrown.withValues(alpha: 0.1)
                            : AppColors.beige,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        addr.icon,
                        size: 18,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr.label,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w500)),
                          Text(addr.address,
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.sage, size: 20),
                  ],
                ),
              ),
            );
          }),
          // Add new
          GestureDetector(
            onTap: onAddNew,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.beige, width: 2, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.softBrown, size: 18),
                  const SizedBox(width: 8),
                  Text('Add new address',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.softBrown,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
