import 'package:flutter/material.dart';

/// Search and filter bar widget for the job list.
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
    'Not Applied',
    'Applied',
    'Interview',
    'Rejected',
    'Offer',
  ];

  static const List<(String, String, String)> _sources = [
    ('extension', '🧩', 'Extension'),
    ('ai_extract', '✨', 'AI'),
    ('manual', '✏️', 'Manual'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by company, role, or location...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status filter chips
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
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildChip(
                        label: status,
                        isSelected: statusFilter == status,
                        onTap: () => onStatusChanged(status),
                      ),
                    )),
                const SizedBox(width: 4),
                // Divider
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  color: Colors.white12,
                ),
                const SizedBox(width: 4),
                // Source filters
                ..._sources.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSourceChip(
                        apiValue: s.$1,
                        emoji: s.$2,
                        label: s.$3,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF)
              : const Color(0xFF16213E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
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
    const color = Color(0xFF9D4EDD);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
          ),
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
