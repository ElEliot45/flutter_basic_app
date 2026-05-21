import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/promotion.dart';
import '../../services/authservice.dart';
import '../../services/promotion_service.dart';
import '../utils/app_theme.dart';
import '../widgets/promotion_card.dart';
import 'login_screen.dart';
import 'create_promotion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _promoService = PromotionService();

  // Filtro: 'all', 'active', 'inactive', 'sent'
  String _filter = 'all';

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  Future<void> _sendPromotion(Promotion promo) async {
    // Simula el envío con un delay visual de 1.5s
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold)),
          const SizedBox(width: 16),
          Text('Enviando "${promo.title}"...'),
        ]),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    await _promoService.sendPromotion(promo.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: AppTheme.success),
            const SizedBox(width: 12),
            Text('¡Promoción "${promo.title}" enviada!'),
          ]),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _toggleStatus(Promotion promo) async {
    await _promoService.toggleStatus(promo.id, !promo.isActive);
  }

  Future<void> _delete(Promotion promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Eliminar promoción'),
        content: Text('¿Eliminar "${promo.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _promoService.deletePromotion(promo.id);
    }
  }

  List<Promotion> _applyFilter(List<Promotion> list) {
    switch (_filter) {
      case 'active':
        return list.where((p) => p.isActive && !p.isSent).toList();
      case 'inactive':
        return list.where((p) => !p.isActive).toList();
      case 'sent':
        return list.where((p) => p.isSent).toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.local_offer_rounded, color: AppTheme.accent, size: 22),
          const SizedBox(width: 10),
          const Text('PromoManager'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePromotionScreen()),
        ),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nueva Promoción', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Filtros ──────────────────────────────────────────────────────
          _FilterBar(
            current: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),

          // ── Lista ────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Promotion>>(
              stream: _promoService.getPromotions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.accent)),
                  );
                }
                final all = snapshot.data ?? [];
                final filtered = _applyFilter(all);

                if (filtered.isEmpty) {
                  return _EmptyState(filter: _filter);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => PromotionCard(
                    promotion: filtered[i],
                    onSend: () => _sendPromotion(filtered[i]),
                    onToggle: () => _toggleStatus(filtered[i]),
                    onDelete: () => _delete(filtered[i]),
                  ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.15),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget de filtros ──────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _FilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'Todas', Icons.apps_rounded),
      ('active', 'Activas', Icons.check_circle_outline),
      ('inactive', 'Inactivas', Icons.pause_circle_outline),
      ('sent', 'Enviadas', Icons.send_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = current == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: selected,
                onSelected: (_) => onChanged(f.$1),
                avatar: Icon(f.$3, size: 16, color: selected ? Colors.white : AppTheme.textMuted),
                label: Text(f.$2),
                selectedColor: AppTheme.accent,
                backgroundColor: AppTheme.surface,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
                side: BorderSide(color: selected ? AppTheme.accent : AppTheme.cardBg),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final msgs = {
      'all': 'Aún no hay promociones.\n¡Crea la primera!',
      'active': 'No hay promociones activas.',
      'inactive': 'No hay promociones inactivas.',
      'sent': 'Aún no se han enviado promociones.',
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            msgs[filter] ?? 'Sin resultados.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 16, height: 1.5),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}