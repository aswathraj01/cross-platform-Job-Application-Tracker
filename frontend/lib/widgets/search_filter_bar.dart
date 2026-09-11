import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/liquid_glass_theme.dart';

/// Liquid Glass search bar + filter chips for the job list.
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String? statusFilter;
  final String? sourceFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSourceChanged;
  final VoidCallback onClearFilters;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    this.sourceFilter,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onSourceChanged,
    required this.onClearFilters,
  });

  static const List<String> _statuses = [
    'Not Applied', 'Applied', 'Interview', 'Rejected', 'Offer',
  ];

  static const List<(String, String, String)> _sources = [
    ('extension', '🧩', 'Extension'),
    ('ai_extract', '✨', 'AI'),
    ('manual',    '✏️', 'Manual'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Glass search bar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.18), width: 1.2),
                    left:   BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    right:  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by company, role, or location...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.4)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.4), size: 18),
                            onPressed: () => onSearchChanged(''),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips row
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip(
                  label: 'All',
                  isSelected: statusFilter == null && sourceFilter == null,
                  onTap: () {
                    onStatusChanged(null);
                    onSourceChanged(null);
                  },
                ),
                const SizedBox(width: 8),
                ..._statuses.map((status) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _buildChip(
                    label: status,
                    isSelected: statusFilter == status,
                    onTap: () => onStatusChanged(status),
                  ),
                )),
                Container(
                  width: 1,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                ..._sources.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _buildSourceChip(
                    apiValue: s.$1,
                    emoji:    s.$2,
                    label:    s.$3,
                    isSelected: sourceFilter == s.$1,
                    onTap: () => onSourceChanged(sourceFilter == s.$1 ? null : s.$1),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? LiquidGlass.primaryGradient : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? LiquidGlass.accentPrimary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: isSelected
              ? LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.3, blur: 10)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceChip({
    required String apiValue,
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const color = LiquidGlass.accentSecond;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.2),
          ),
          boxShadow: isSelected
              ? LiquidGlass.glowShadow(color, intensity: 0.25, blur: 10)
              : null,
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            color: isSelected ? Colors.white : color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
