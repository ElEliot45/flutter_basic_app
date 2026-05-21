import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/promotion_service.dart';
import '../utils/app_theme.dart';

class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _promoService = PromotionService();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isActive = true;
  bool _loading = false;

  // Preview de la URL ingresada
  bool get _hasValidImageUrl {
    final url = _imageUrlCtrl.text.trim();
    return url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent, surface: AppTheme.surface),
          dialogBackgroundColor: AppTheme.primary,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _promoService.createPromotion(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate,
        isActive: _isActive,
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: AppTheme.success),
              SizedBox(width: 12),
              Text('Promoción creada exitosamente'),
            ]),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Promoción'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent)),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Guardar',
                  style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── URL de imagen ──────────────────────────────────────────────
              _SectionLabel('URL de imagen (opcional)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlCtrl,
                style: const TextStyle(color: AppTheme.textLight),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://ejemplo.com/imagen.jpg',
                  prefixIcon: const Icon(Icons.link_rounded),
                  suffixIcon: _imageUrlCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _imageUrlCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}), // refresca preview
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // es opcional
                  if (!v.trim().startsWith('http://') &&
                      !v.trim().startsWith('https://')) {
                    return 'La URL debe comenzar con http:// o https://';
                  }
                  return null;
                },
              ),

              // ── Preview de imagen ──────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _hasValidImageUrl
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrlCtrl.text.trim(),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(
                                        height: 160,
                                        color: AppTheme.surface,
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                                color: AppTheme.accent)),
                                      ),
                            errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade800),
                              ),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined,
                                        color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('No se pudo cargar la imagen',
                                        style: TextStyle(color: Colors.red)),
                                  ]),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Título ─────────────────────────────────────────────────────
              _SectionLabel('Título *'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: const InputDecoration(
                  hintText: 'Ej. 20% de descuento en toda la tienda',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                maxLength: 80,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El título es requerido';
                  if (v.trim().length < 4) return 'Mínimo 4 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Descripción ────────────────────────────────────────────────
              _SectionLabel('Descripción *'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: const InputDecoration(
                  hintText: 'Describe los detalles de la promoción...',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 400,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'La descripción es requerida';
                  if (v.trim().length < 10) return 'Mínimo 10 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Fecha ──────────────────────────────────────────────────────
              _SectionLabel('Fecha de vigencia *'),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBg, width: 1.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_month_rounded, color: AppTheme.textMuted),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // ── Estatus ────────────────────────────────────────────────────
              _SectionLabel('Estatus'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBg, width: 1.5),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: AppTheme.success,
                  title: Text(
                    _isActive ? 'Activa' : 'Inactiva',
                    style: TextStyle(
                      color: _isActive ? AppTheme.success : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _isActive ? 'La promoción estará visible' : 'La promoción estará oculta',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Botón guardar ──────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: const Icon(Icons.save_rounded),
                label: Text(_loading ? 'Guardando...' : 'Guardar Promoción'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}