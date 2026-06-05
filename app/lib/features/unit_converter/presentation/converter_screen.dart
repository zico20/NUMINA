import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class _Category {
  final String key;
  final String label;
  final IconData icon;
  final Map<String, double> units; // value: factor to base unit
  const _Category(this.key, this.label, this.icon, this.units);
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late List<_Category> _categories;
  late _Category _cat;
  late String _from;
  late String _to;
  final _input = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final p = context.numina;

    // Categories depend on locale, so build them in build().
    _categories = [
      _Category('length', t.categoryLength, Icons.straighten,
          {'m': 1, 'cm': 0.01, 'km': 1000, 'mi': 1609.344, 'ft': 0.3048, 'in': 0.0254}),
      _Category('weight', t.categoryWeight, Icons.fitness_center,
          {'kg': 1, 'g': 0.001, 't': 1000, 'lb': 0.45359237, 'oz': 0.0283495}),
      _Category('time', t.categoryTime, Icons.schedule,
          {'s': 1, 'min': 60, 'h': 3600, 'd': 86400}),
      _Category('angle', t.categoryAngle, Icons.rotate_right,
          {'deg': 1, 'rad': 57.29577951, 'grad': 0.9}),
      _Category('speed', t.categorySpeed, Icons.speed,
          {'m/s': 1, 'km/h': 0.27777778, 'mph': 0.44704, 'kn': 0.51444444}),
      _Category('temp', t.categoryTemperature, Icons.thermostat,
          {'°C': 1, '°F': 1, 'K': 1}),
    ];

    // Init defaults on first build.
    final cat = _categories.firstWhere(
      (c) => c.key == (_cat.key),
      orElse: () => _categories.first,
    );
    _cat = cat;
    _from = _cat.units.keys.contains(_from) ? _from : _cat.units.keys.first;
    _to = _cat.units.keys.contains(_to) ? _to : _cat.units.keys.elementAt(1);

    final input = double.tryParse(_input.text) ?? 0.0;
    final out = _convert(input);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text(
          t.converterTitle,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
        const SizedBox(height: 16),
        // FROM card
        _ConvertCard(
          label: t.fromValue,
          accent: false,
          unit: _from,
          onUnitTap: () => _pickUnit(true),
          valueWidget: TextField(
            controller: _input,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
            textDirection: TextDirection.ltr,
            onChanged: (_) => setState(() {}),
          ),
        ),
        // Swap button overlapping the gap
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.bg,
                shape: BoxShape.circle,
                border: Border.all(color: p.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: p.isDark ? 0.4 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  final tmp = _from;
                  setState(() {
                    _from = _to;
                    _to = tmp;
                  });
                },
                icon: Icon(Icons.swap_vert, size: 18, color: p.accent),
              ),
            ),
          ),
        ),
        // TO card with accent gradient
        _ConvertCard(
          label: t.toValue,
          accent: true,
          unit: _to,
          onUnitTap: () => _pickUnit(false),
          valueWidget: Text(
            out == null
                ? '—'
                : (out.abs() < 1e-4 || out.abs() >= 1e10
                    ? out.toStringAsExponential(4)
                    : out.toStringAsPrecision(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'CATEGORY',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: p.textMute,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: _categories.map((c) => _CatTile(
                category: c,
                selected: c.key == _cat.key,
                onTap: () {
                  setState(() {
                    _cat = c;
                    _from = c.units.keys.first;
                    _to = c.units.keys.elementAt(1);
                  });
                },
              )).toList(),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cat = _Category('length', '', Icons.straighten,
        {'m': 1, 'cm': 0.01, 'km': 1000, 'mi': 1609.344, 'ft': 0.3048, 'in': 0.0254});
    _from = 'm';
    _to = 'mi';
  }

  double? _convert(double v) {
    if (_cat.key == 'temp') {
      // Special-case temperature.
      final double c;
      if (_from == '°C') {
        c = v;
      } else if (_from == '°F') {
        c = (v - 32) * 5 / 9;
      } else {
        c = v - 273.15; // K
      }
      if (_to == '°C') return c;
      if (_to == '°F') return c * 9 / 5 + 32;
      return c + 273.15;
    }
    final base = v * _cat.units[_from]!;
    return base / _cat.units[_to]!;
  }

  void _pickUnit(bool isFrom) async {
    final p = context.numina;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _cat.units.keys
              .map((u) => ListTile(
                    title: Text(u, style: GoogleFonts.inter(color: p.text)),
                    onTap: () => Navigator.pop(context, u),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }
}

class _ConvertCard extends StatelessWidget {
  const _ConvertCard({
    required this.label,
    required this.accent,
    required this.unit,
    required this.onUnitTap,
    required this.valueWidget,
  });

  final String label;
  final bool accent;
  final String unit;
  final VoidCallback onUnitTap;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final labelColor = accent ? p.accent : p.textMute;
    final decoration = accent
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [p.accentSoft, p.surface],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.accent.withValues(alpha: 0.25)),
          )
        : BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.border),
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: valueWidget),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onUnitTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent ? p.bgRaised : p.accentSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: accent ? Border.all(color: p.border) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unit,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent ? p.text : p.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.expand_more,
                        size: 14,
                        color: accent ? p.textDim : p.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  const _CatTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.transparent : p.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 20,
              color: selected ? p.accent : p.textDim,
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                category.label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? p.accent : p.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
