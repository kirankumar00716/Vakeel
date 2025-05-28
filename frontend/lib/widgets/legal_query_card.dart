import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/legal_query.dart';

class LegalQueryCard extends StatelessWidget {
  final LegalQuery query;
  final Function()? onTap;
  final Function()? onSaveToggle;
  final Function()? onDelete;
  final bool showFullResponse;

  const LegalQueryCard({
    Key? key,
    required this.query,
    this.onTap,
    this.onSaveToggle,
    this.onDelete,
    this.showFullResponse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(query.createdAt);
    final categoryName = LegalCategories.getCategoryDisplayName(query.category ?? LegalCategories.general);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(query.category ?? LegalCategories.general).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: _getCategoryColor(query.category ?? LegalCategories.general),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                query.query,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (query.response != null) ...[
                const SizedBox(height: 12),
                Text(
                  query.response!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  maxLines: showFullResponse ? null : 3,
                  overflow: showFullResponse ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSaveToggle != null)
                    IconButton(
                      icon: Icon(
                        query.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: query.isSaved ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      onPressed: onSaveToggle,
                      tooltip: query.isSaved ? 'Remove from saved' : 'Save query',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: onDelete,
                      tooltip: 'Delete query',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case LegalCategories.criminal:
        return Colors.red[700]!;
      case LegalCategories.civil:
        return Colors.blue[700]!;
      case LegalCategories.family:
        return Colors.green[700]!;
      case LegalCategories.property:
        return Colors.orange[700]!;
      case LegalCategories.employment:
        return Colors.purple[700]!;
      case LegalCategories.constitutional:
        return Colors.indigo[700]!;
      case LegalCategories.immigration:
        return Colors.teal[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}