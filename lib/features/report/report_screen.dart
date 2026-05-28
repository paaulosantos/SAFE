import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/models/report_record.dart';
import 'package:safe/shared/services/safe_app_store.dart';
import 'package:safe/shared/services/safe_location_service.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onReportSubmitted;

  const ReportScreen({super.key, this.onBack, this.onReportSubmitted});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final SafeAppStore _store = SafeAppStore.instance;
  final TextEditingController _detailsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  ReportCategory _selectedCategory = ReportCategory.phone;
  XFile? _evidenceFile;
  SafeResolvedLocation? _resolvedLocation;
  bool _isLocating = false;
  String _currentLocation = 'Buscando localização atual...';

  bool get _hasPhoto => _evidenceFile != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshLocation());
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildEvidenceSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildDetailsSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Denúncias são anônimas',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              _buildRecentReports(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Nova denúncia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria da infração',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ReportCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  selected: isSelected,
                  label: Text(category.label),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.bgCardLight,
                  side: BorderSide(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidência visual',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showEvidenceOptions,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasPhoto ? AppColors.purpleBg : AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasPhoto ? AppColors.purple : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.purpleBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _hasPhoto ? Icons.image_rounded : Icons.camera_alt_rounded,
                    color: AppColors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _hasPhoto
                      ? 'Foto anexada: ${_evidenceFile!.name}'
                      : 'Toque para anexar foto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isLocating
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      )
                    : const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.green,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usando localização atual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentLocation,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isLocating ? null : _refreshLocation,
                icon: const Icon(Icons.my_location_rounded),
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes adicionais',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _detailsController,
          maxLines: 4,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText:
                'Placa do veículo, ponto de referência ou horário aproximado',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _resolvedLocation == null ? null : _submitReport,
        icon: const Icon(Icons.send_rounded, size: 20),
        label: Text(
          _resolvedLocation == null
              ? 'Aguardando localização'
              : 'Enviar denúncia',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.bgCardLight,
          foregroundColor: Colors.black,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    final reports = _store.reports.take(3).toList();
    if (reports.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relatórios gerados',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        for (final report in reports) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_rounded, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.category.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.protocol,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  report.hasPhoto
                      ? Icons.image_rounded
                      : Icons.image_not_supported_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showEvidenceOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEvidenceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Tirar foto',
                  onTap: () => _selectEvidence(context, ImageSource.camera),
                ),
                _buildEvidenceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Escolher arquivo',
                  onTap: () => _selectEvidence(context, ImageSource.gallery),
                ),
                if (_hasPhoto)
                  _buildEvidenceOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remover foto',
                    color: AppColors.red,
                    onTap: () {
                      setState(() => _evidenceFile = null);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvidenceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _selectEvidence(
    BuildContext sheetContext,
    ImageSource source,
  ) async {
    Navigator.of(sheetContext).pop();

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 1600,
      );

      if (!mounted || pickedFile == null) return;
      setState(() => _evidenceFile = pickedFile);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Não foi possível anexar a imagem.');
    }
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLocating = true);

    try {
      final location = await SafeLocationService.getCurrentLocation();
      _finishLocationLookup(location.label, resolvedLocation: location);
    } on SafeLocationException catch (error) {
      _finishLocationLookup(error.message);
    } catch (_) {
      _finishLocationLookup('Não foi possível obter sua localização agora.');
    }
  }

  void _finishLocationLookup(
    String label, {
    SafeResolvedLocation? resolvedLocation,
  }) {
    if (!mounted) return;

    setState(() {
      _currentLocation = label;
      _resolvedLocation = resolvedLocation;
      _isLocating = false;
    });
  }

  Future<void> _submitReport() async {
    final resolvedLocation = _resolvedLocation;
    if (resolvedLocation == null) return;

    final report = _store.submitReport(
      category: _selectedCategory,
      location: _currentLocation,
      details: _detailsController.text,
      hasPhoto: _hasPhoto,
      x: resolvedLocation.mapX,
      y: resolvedLocation.mapY,
      latitude: resolvedLocation.latitude,
      longitude: resolvedLocation.longitude,
    );
    final mapPointId = _store.latestTrafficPointId;

    setState(() {
      _detailsController.clear();
      _evidenceFile = null;
    });

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text(
            'Relatório gerado',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            report.detranSummary,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: report.detranSummary));
                Navigator.of(context).pop();
                _showSnackBar('Relatório copiado para encaminhar ao DETRAN.');
              },
              child: const Text('Copiar relatório'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (mapPointId != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ver no mapa'),
              ),
          ],
        );
      },
    );

    if (!mounted || mapPointId == null) return;
    widget.onReportSubmitted?.call(mapPointId);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.bgCard),
    );
  }
}
