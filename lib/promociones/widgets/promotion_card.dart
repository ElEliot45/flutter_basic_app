// lib/widgets/promotion_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/promotion.dart';
import '../utils/app_theme.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onSend;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onSend,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = promotion;
    final dateStr = DateFormat('dd/MM/yyyy').format(p.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imagen ──────────────────────────────────────────────────────
          if (p.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: p.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(height: 160, color: AppTheme.cardBg),
                errorWidget: (_, __, ___) => Container(
                  height: 100,
                  color: AppTheme.cardBg,
                  child: const Icon(Icons.broken_image_outlined, color: AppTheme.textMuted),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Badges de estado ───────────────────────────────────────
                Row(children: [
                  _StatusBadge(isActive: p.isActive, isSent: p.isSent),
                  const Spacer(),
                  // Fecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(dateStr, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),

                // ── Título ─────────────────────────────────────────────────
                Text(
                  p.title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Descripción ────────────────────────────────────────────
                Text(
                  p.description,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // ── Sent at ────────────────────────────────────────────────
                if (p.isSent && p.sentAt != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle, size: 14, color: AppTheme.success),
                      const SizedBox(width: 6),
                      Text(
                        'Enviada el ${DateFormat('dd/MM/yyyy HH:mm').format(p.sentAt!)}',
                        style: const TextStyle(color: AppTheme.success, fontSize: 12),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 14),

                // ── Acciones ───────────────────────────────────────────────
                _ActionRow(
                  promotion: p,
                  onSend: onSend,
                  onToggle: onToggle,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge de estado ────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isSent;

  const _StatusBadge({required this.isActive, required this.isSent});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    if (isSent) {
      color = AppTheme.success;
      label = 'Enviada';
      icon = Icons.send_rounded;
    } else if (isActive) {
      color = AppTheme.accentGold;
      label = 'Activa';
      icon = Icons.circle;
    } else {
      color = AppTheme.inactive;
      label = 'Inactiva';
      icon = Icons.pause_circle_filled_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── Fila de acciones ───────────────────────────────────────────────────────────
class _ActionRow extends StatefulWidget {
  final Promotion promotion;
  final VoidCallback onSend;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActionRow({
    required this.promotion,
    required this.onSend,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _sending = false;

  Future<void> _handleSend() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onSend();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.promotion;

    return Row(children: [
      // Enviar
      if (!p.isSent)
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _handleSend,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: _sending ? AppTheme.cardBg : AppTheme.accent,
              ),
              icon: _sending
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(_sending ? 'Enviando...' : 'Enviar', style: const TextStyle(fontSize: 13)),
            ).animate(target: _sending ? 1 : 0).shimmer(color: AppTheme.accent.withOpacity(0.3)),
          ),
        ),
      if (!p.isSent) const SizedBox(width: 8),

      // Toggle activo/inactivo
      _IconBtn(
        icon: p.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: p.isActive ? AppTheme.inactive : AppTheme.success,
        tooltip: p.isActive ? 'Desactivar' : 'Activar',
        onTap: widget.onToggle,
      ),
      const SizedBox(width: 8),

      // Eliminar
      _IconBtn(
        icon: Icons.delete_outline_rounded,
        color: Colors.red.shade400,
        tooltip: 'Eliminar',
        onTap: widget.onDelete,
      ),
    ]);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}